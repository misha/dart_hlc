import 'package:hlc/hlc.dart';
import 'package:test/test.dart';

void main() {
  test('Pack and unpack are inverse operations.', () {
    final hlc = HLC.now('test');
    expect(HLC.unpack(hlc.pack()), hlc);
  });

  group('Receiving a clock...', () {
    group('When the wall clock is later than both timestamps...', () {
      test('Uses the current wall clock and resets the count.', () {
        final a = HLC.now('a').copy(timestamp: 0, count: 1);
        final b = HLC.now('b').copy(timestamp: 10, count: 1);
        final c = a.receive(b, now: 15);

        expect(c.timestamp, 15);
        expect(c.count, 0);
        expect(c.node, a.node);
      });
    });

    group('When the wall clock is not later than either timestamp...', () {
      test('Receiving a clock with the same timestamp increments the greater count.', () {
        final a = HLC.now('a').copy(count: 4, timestamp: 10);
        final b = HLC.now('b').copy(count: 2, timestamp: a.timestamp);
        expect(a.receive(b, now: 0).count, 5);
        expect(b.receive(a, now: 0).count, 5);
      });

      test('Receiving a clock with an earlier timestamp increments the current count.', () {
        final a = HLC.now('a').copy(count: 2, timestamp: 5);
        final b = HLC.now('b').copy(count: 4, timestamp: 10);
        final c = b.receive(a, now: 0);
        expect(c.timestamp, 10);
        expect(c.count, 5);
        expect(c.node, 'b');
      });

      test('Receiving a clock with a later timestamp increments the later clock\'s count.', () {
        final a = HLC.now('a').copy(count: 2, timestamp: 5);
        final b = HLC.now('b').copy(count: 4, timestamp: 10);
        final c = a.receive(b, now: 0);
        expect(c.timestamp, 10);
        expect(c.count, 5);
        expect(c.node, 'a');
      });
    });
  });
}
