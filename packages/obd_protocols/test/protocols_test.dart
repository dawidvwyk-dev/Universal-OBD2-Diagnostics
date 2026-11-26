import 'package:obd_protocols/obd_protocols.dart';
import 'package:test/test.dart';

void main() {
  group('ObdProtocol', () {
    test('parses ATDPN replies', () {
      expect(ObdProtocol.fromDpn('A6'), ObdProtocol.can11b500);
      expect(ObdProtocol.fromDpn('3'), ObdProtocol.iso9141);
      expect(ObdProtocol.fromDpn('A'), ObdProtocol.j1939);
      expect(ObdProtocol.fromDpn('junk'), ObdProtocol.auto);
    });
  });

  group('CAN 11-bit', () {
    const p = ObdProtocol.can11b500;
    test('single frame with spaces', () {
      final r = parseElmResponse('7E8 04 41 0C 1A F8 \r\r>', p);
      expect(r.ok, isTrue);
      expect(r.messages.single.source, '7E8');
      expect(r.messages.single.data, [0x41, 0x0C, 0x1A, 0xF8]);
    });
    test('single frame without spaces, CAN padding ignored', () {
      final r = parseElmResponse('7E804410C1AF8AAAA', p);
      expect(r.messages.single.data, [0x41, 0x0C, 0x1A, 0xF8]);
    });
    test('two ECUs answer', () {
      final r = parseElmResponse('7E8 06 41 00 BE 3F A8 13\n7E9 06 41 00 98 18 80 11', p);
      expect(r.messages.map((m) => m.source), ['7E8', '7E9']);
    });
    test('multi-frame VIN is reassembled', () {
      const resp = '7E8 10 14 49 02 01 31 4D 38\n'
          '7E8 21 47 44 4D 39 41 58 4B\n'
          '7E8 22 50 30 34 32 37 38 38\n';
      final r = parseElmResponse(resp, p);
      final d = r.messages.single.data;
      expect(d.length, 0x14);
      expect(String.fromCharCodes(d.sublist(3)), '1M8GDM9AXKP042788');
    });
    test('out-of-order consecutive frame drops the message', () {
      const resp = '7E8 10 14 49 02 01 31 4D 38\n'
          '7E8 22 50 30 34 32 37 38 38\n';
      expect(parseElmResponse(resp, p).ok, isFalse);
    });
    test('echo and SEARCHING are skipped', () {
      final r = parseElmResponse('0100\rSEARCHING...\r7E8 06 41 00 BE 3F A8 13\r\r>', p,
          echo: '0100');
      expect(r.messages.single.data.first, 0x41);
    });
  });

  test('CAN 29-bit header', () {
    final r = parseElmResponse('18 DA F1 10 03 41 0D 32 00', ObdProtocol.can29b500);
    expect(r.messages.single.source, '18DAF110');
    expect(r.messages.single.data, [0x41, 0x0D, 0x32]);
  });

  test('legacy ISO 9141 strips header and checksum', () {
    final r = parseElmResponse('48 6B 10 41 0C 1A F8 A2', ObdProtocol.iso9141);
    expect(r.messages.single.source, '10');
    expect(r.messages.single.data, [0x41, 0x0C, 0x1A, 0xF8]);
  });

  group('errors', () {
    test('NO DATA', () {
      expect(parseElmResponse('NO DATA\r\r>', ObdProtocol.can11b500).error, ElmError.noData);
    });
    test('UNABLE TO CONNECT', () {
      expect(parseElmResponse('SEARCHING...\rUNABLE TO CONNECT', ObdProtocol.auto).error,
          ElmError.unableToConnect);
    });
    test('unknown command', () {
      expect(parseElmResponse('?', ObdProtocol.auto).error, ElmError.unknownCommand);
    });
    test('CAN ERROR is not plain ERROR', () {
      expect(parseElmResponse('CAN ERROR', ObdProtocol.can11b500).error, ElmError.canError);
    });
  });

  group('checkResponse', () {
    test('positive with PID echo', () {
      final c = checkResponse(const ObdRequest(0x01, [0x0C]),
          const ObdMessage('7E8', [0x41, 0x0C, 0x1A, 0xF8]));
      expect(c, isA<PositiveResponse>());
      expect((c as PositiveResponse).payload, [0x0C, 0x1A, 0xF8]);
    });
    test('wrong PID is unrelated', () {
      final c = checkResponse(const ObdRequest(0x01, [0x0C]),
          const ObdMessage('7E8', [0x41, 0x0D, 0x00]));
      expect(c, isA<UnrelatedResponse>());
    });
    test('negative response', () {
      final c = checkResponse(const ObdRequest(0x04),
          const ObdMessage('7E8', [0x7F, 0x04, 0x22]));
      expect((c as NegativeResponse).description, 'Conditions not correct');
    });
    test('services that change the vehicle are flagged', () {
      expect(ObdService.clearDtcs.readOnly, isFalse);
      expect(ObdService.controlSystem.readOnly, isFalse);
      expect(ObdService.values.where((s) => !s.readOnly).length, 2);
    });
  });
}
