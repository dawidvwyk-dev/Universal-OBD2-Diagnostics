package com.rogue.obd2diagnostic

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var btClassic: BluetoothClassicChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        btClassic = BluetoothClassicChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        btClassic?.dispose()
        btClassic = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
