import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:obd_transport/obd_transport.dart';

import 'adapter_profile.dart';
import 'elm_emulator.dart';
import 'vehicle.dart';

/// Connects an [ElmEmulator] to the engine through a [MemoryTransport].
MemoryTransport simulatorTransport(
  ElmEmulator emulator, {
  Duration latency = Duration.zero,
  int? chunkSize,
}) {
  return MemoryTransport(
    endpoint: TransportEndpoint(
      kind: TransportKind.simulator,
      address: 'sim:${emulator.profile.id}',
      name: 'Simulator: ${emulator.vehicle.name}',
    ),
    latency: latency,
    chunkSize: chunkSize,
    onWrite: (bytes, t) {
      final reply = emulator.receive(bytes);
      if (reply.isNotEmpty) t.deliver(reply);
    },
  );
}

/// Serves the emulator over TCP so the real Wi-Fi transport and the full app
/// can be tested against it. Each connection gets a fresh adapter.
class SimulatorServer {
  SimulatorServer({
    required this.vehicleFactory,
    this.profile = SimAdapterProfile.genuineElm,
  });

  final VirtualVehicle Function() vehicleFactory;
  final SimAdapterProfile profile;
  ServerSocket? _server;

  int get port => _server!.port;

  Future<void> start({String host = '127.0.0.1', int port = 35000}) async {
    _server = await ServerSocket.bind(host, port);
    _server!.listen((client) {
      final emu = ElmEmulator(vehicle: vehicleFactory(), profile: profile);
      client.listen(
        (Uint8List data) {
          final reply = emu.receive(data);
          if (reply.isNotEmpty) client.add(reply);
        },
        onError: (Object _) => client.destroy(),
        onDone: client.destroy,
      );
    });
  }

  Future<void> stop() async => _server?.close();
}
