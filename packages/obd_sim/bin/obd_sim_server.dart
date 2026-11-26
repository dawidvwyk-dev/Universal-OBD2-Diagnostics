import 'dart:io';

import 'package:obd_sim/obd_sim.dart';

/// Runs a simulated Wi-Fi adapter: `dart run obd_sim:obd_sim_server [scenario] [port]`.
Future<void> main(List<String> args) async {
  final scenario = args.isNotEmpty ? args[0] : 'healthy_can';
  final port = args.length > 1 ? int.parse(args[1]) : 35000;
  final factory = Scenarios.all[scenario];
  if (factory == null) {
    stderr.writeln('Unknown scenario. Choose one of: ${Scenarios.all.keys.join(', ')}');
    exitCode = 64;
    return;
  }
  final server = SimulatorServer(vehicleFactory: factory);
  await server.start(host: '0.0.0.0', port: port);
  stdout.writeln('SIMULATED adapter "$scenario" listening on port ${server.port}');
}
