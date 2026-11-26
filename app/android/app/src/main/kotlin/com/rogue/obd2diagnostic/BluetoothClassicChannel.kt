package com.rogue.obd2diagnostic

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/**
 * Bluetooth Classic (SPP/RFCOMM) link for ELM327-style adapters.
 *
 * Methods on "rogue/bt_classic": isEnabled, bondedDevices, startDiscovery,
 * cancelDiscovery, connect(address), write(data), disconnect.
 * Events: "rogue/bt_classic/discovery" (found devices),
 * "rogue/bt_classic/data" (received bytes; error or end when the link drops).
 * Permissions are requested from Dart before these are called.
 */
@SuppressLint("MissingPermission")
class BluetoothClassicChannel(private val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    companion object {
        val SPP: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    }

    private val main = Handler(Looper.getMainLooper())
    private val io = Executors.newSingleThreadExecutor()
    private val methods = MethodChannel(messenger, "rogue/bt_classic")
    private var discoverySink: EventChannel.EventSink? = null
    private var dataSink: EventChannel.EventSink? = null
    private var socket: BluetoothSocket? = null
    private var reader: Thread? = null
    private var receiverRegistered = false

    private val adapter: BluetoothAdapter?
        get() = (context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(c: Context, intent: Intent) {
            if (intent.action != BluetoothDevice.ACTION_FOUND) return
            val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= 33) {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            } else {
                @Suppress("DEPRECATION") intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            }
            device ?: return
            // Skip BLE-only devices; they are handled by the BLE scanner.
            if (device.type == BluetoothDevice.DEVICE_TYPE_LE) return
            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE)
            discoverySink?.success(mapOf(
                "address" to device.address,
                "name" to (device.name ?: ""),
                "rssi" to if (rssi == Short.MIN_VALUE) null else rssi.toInt(),
                "bonded" to (device.bondState == BluetoothDevice.BOND_BONDED),
            ))
        }
    }

    init {
        methods.setMethodCallHandler(this)
        EventChannel(messenger, "rogue/bt_classic/discovery").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { discoverySink = events }
            override fun onCancel(arguments: Any?) { discoverySink = null }
        })
        EventChannel(messenger, "rogue/bt_classic/data").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { dataSink = events }
            override fun onCancel(arguments: Any?) { dataSink = null }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isEnabled" -> result.success(adapter?.isEnabled == true)
                "bondedDevices" -> result.success(adapter?.bondedDevices?.filter { it.type != BluetoothDevice.DEVICE_TYPE_LE }?.map {
                    mapOf("address" to it.address, "name" to (it.name ?: ""), "bonded" to true)
                } ?: emptyList<Map<String, Any>>())
                "startDiscovery" -> {
                    val a = adapter ?: return result.error("unavailable", "Bluetooth is not available", null)
                    if (!receiverRegistered) {
                        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
                        if (Build.VERSION.SDK_INT >= 33) context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
                        else context.registerReceiver(receiver, filter)
                        receiverRegistered = true
                    }
                    if (a.isDiscovering) a.cancelDiscovery()
                    result.success(a.startDiscovery())
                }
                "cancelDiscovery" -> { adapter?.cancelDiscovery(); result.success(null) }
                "connect" -> connect(call.argument<String>("address")!!, result)
                "write" -> {
                    val s = socket ?: return result.error("closed", "Not connected", null)
                    val data = call.argument<ByteArray>("data")!!
                    io.execute {
                        try {
                            s.outputStream.write(data)
                            s.outputStream.flush()
                            main.post { result.success(null) }
                        } catch (e: IOException) {
                            main.post { result.error("write", e.message, null) }
                        }
                    }
                }
                "disconnect" -> { closeSocket(); result.success(null) }
                else -> result.notImplemented()
            }
        } catch (e: SecurityException) {
            result.error("permission", "Bluetooth permission was not granted", e.message)
        }
    }

    private fun connect(address: String, result: MethodChannel.Result) {
        val a = adapter ?: return result.error("unavailable", "Bluetooth is not available", null)
        closeSocket()
        a.cancelDiscovery()
        val device = a.getRemoteDevice(address)
        io.execute {
            var last: Exception? = null
            // Secure SPP first, then insecure SPP, then RFCOMM channel 1, which
            // some clone adapters need.
            val attempts = listOf<() -> BluetoothSocket>(
                { device.createRfcommSocketToServiceRecord(SPP) },
                { device.createInsecureRfcommSocketToServiceRecord(SPP) },
                { device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType).invoke(device, 1) as BluetoothSocket },
            )
            for (make in attempts) {
                var s: BluetoothSocket? = null
                try {
                    s = make()
                    s.connect()
                    socket = s
                    startReader(s)
                    main.post { result.success(null) }
                    return@execute
                } catch (e: Exception) {
                    last = e
                    try { s?.close() } catch (_: IOException) {}
                }
            }
            main.post { result.error("connect", "Could not open a Bluetooth serial connection: ${last?.message}", null) }
        }
    }

    private fun startReader(s: BluetoothSocket) {
        reader = Thread {
            val buf = ByteArray(1024)
            try {
                val input = s.inputStream
                while (true) {
                    val n = input.read(buf)
                    if (n < 0) break
                    if (n > 0) {
                        val chunk = buf.copyOf(n)
                        main.post { dataSink?.success(chunk) }
                    }
                }
                main.post { dataSink?.error("closed", "Adapter closed the connection", null) }
            } catch (e: IOException) {
                if (socket === s) main.post { dataSink?.error("lost", e.message, null) }
            }
        }.apply { isDaemon = true; start() }
    }

    private fun closeSocket() {
        val s = socket
        socket = null
        try { s?.close() } catch (_: IOException) {}
        reader = null
    }

    fun dispose() {
        closeSocket()
        if (receiverRegistered) {
            try { context.unregisterReceiver(receiver) } catch (_: Exception) {}
            receiverRegistered = false
        }
        methods.setMethodCallHandler(null)
        io.shutdown()
    }
}
