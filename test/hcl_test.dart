import 'package:hlc/hlc.dart';
import 'package:test/test.dart';

void main() {
  test('Pack and unpack are inverse operations.', () {
    final hlc = HLC.now('test');
    expect(HLC.unpack(hlc.pack()), hlc);
  });

  test('Unpacking with unrelated input throws an exception.', () {
    expect(() => HLC.unpack('Hello, world!'), throwsA(TypeMatcher<FormatException>()));
  });

  group('Receiving a clock', () {
    group('when the wall clock is later than both timestamps', () {
      test('uses the current wall clock and resets the count.', () {
        final a = HLC.now('a').copy(timestamp: 0, count: 1);
        final b = HLC.now('b').copy(timestamp: 10, count: 1);
        final c = a.receive(b, now: 15);
        expect(c.timestamp, 15);
        expect(c.count, 0);
        expect(c.node, a.node);
      });
    });

    test('when the local and remote timestamps match increments the greater count.', () {
      final a = HLC.now('a').copy(count: 4, timestamp: 10);
      final b = HLC.now('b').copy(count: 2, timestamp: a.timestamp);
      expect(a.receive(b, now: 0).count, 5);
      expect(b.receive(a, now: 0).count, 5);
    });

    test('when the local timestamp exceeds the remote one increments the local count.', () {
      final a = HLC.now('a').copy(count: 2, timestamp: 5);
      final b = HLC.now('b').copy(count: 4, timestamp: 10);
      final c = b.receive(a, now: 0);
      expect(c.timestamp, 10);
      expect(c.count, 5);
      expect(c.node, 'b');
    });

    test('when the remote timestamp exceeds the local one increments the remote count.', () {
      final a = HLC.now('a').copy(count: 2, timestamp: 5);
      final b = HLC.now('b').copy(count: 4, timestamp: 10);
      final c = a.receive(b, now: 0);
      expect(c.timestamp, 10);
      expect(c.count, 5);
      expect(c.node, 'a');
    });

    test('if the drift exceeds the maximum drift throws an exception.', () {
      final a = HLC.now('a').copy(timestamp: 0);
      final b = HLC.now('b').copy(timestamp: 111);

      expect(
        () => a.receive(b, now: 10, maximumDrift: Duration(milliseconds: 100)),
        throwsA(TypeMatcher<TimeDriftException>()),
      );

      expect(
        () => a.receive(b, now: 11, maximumDrift: Duration(milliseconds: 100)),
        returnsNormally,
      );
    });
  });
}
