import 'dart:async';
import "dart:collection";
import 'connection.dart';

class DataGenerator {
  static Duration timeSpan = const Duration(seconds: 4);
  static int activeChannel = 0;
  static bool rising = true;
  static double level = 0;

  List<Channel> channels = List.filled(4, Channel());
  DateTime prevTime = DateTime.now();
  Queue<DateTime> triggers = Queue();
  Connection conn;
  DataGenerator(this.conn);

  Stream<DateTime> getTriggers() async* {
    await for (var bytes in conn.getBlocks()) {
      Iterable<int> iter = bytes;
      for (var chan in channels) {
        var sample = Sample.parse(iter, prevTime);
        prevTime = sample.timestamp;
        if (sample.timestamp == DateTime.fromMillisecondsSinceEpoch(0)) {
          sample.timestamp = prevTime = DateTime.now();
          reset();
        }
        chan.push(sample);
        iter = iter.skip(5);
      }

      var trig = channels[activeChannel].trigTime;
      if (trig != null) {
        triggers.addLast(trig);
      }

      var last = channels[3].buffer.last.timestamp;
      DateTime? readyTrig;
      for (var trig in triggers) {
        if (last.difference(trig) > timeSpan) {
          readyTrig = trig;
        } else {
          break;
        }
      }
      if (readyTrig != null) {
        yield readyTrig;
      }
    }
  }

  void reset() {
    triggers.clear();
    for (var chan in channels) {
      chan.buffer.clear();
    }
  }
}

class Channel {
  DateTime? trigTime;
  Channel();
  var buffer = Queue<Sample>();

  void push(Sample sample) {
    var last = buffer.last.value;
    var smp = sample.value;
    if ((DataGenerator.rising &&
            smp >= DataGenerator.level &&
            last <= DataGenerator.level) ||
        (!DataGenerator.rising &&
            smp <= DataGenerator.level &&
            last >= DataGenerator.level)) {
      var prop = (DataGenerator.level - last) / (smp - last);
      trigTime = DateTime.fromMillisecondsSinceEpoch(
          (sample.timestamp.millisecondsSinceEpoch * (1 - prop) +
                  buffer.last.timestamp.millisecondsSinceEpoch * prop)
              .toInt());
    } else {
      trigTime = null;
    }
    buffer.addLast(sample);
    if (canDropFirst()) {
      buffer.removeFirst();
    }
  }

  bool canDropFirst() {
    if (buffer.length > 1) {
      var newest = buffer.last.timestamp;
      var afterOldest = buffer.elementAt(1).timestamp;
      return newest.difference(afterOldest) > DataGenerator.timeSpan;
    }
    return false;
  }
}

class Sample {
  double value;
  DateTime timestamp;
  Sample(this.value, this.timestamp);
  Sample.parse(Iterable<int> bytes, DateTime prev)
      : value = parseValue(bytes),
        timestamp = parseTime(bytes.skip(3), prev);

  static double parseValue(Iterable<int> data) {
    var value = 0;
    var bytes = data.toList();
    value |= (bytes[2] & 0xff) << 16;
    value |= (bytes[1] & 0xff) << 8;
    value |= (bytes[0] & 0xff);
    if (bytes[2] & 0x80 != 0) {
      value |= -1 << 24;
    }
    return value.toDouble();
  }

  static DateTime parseTime(Iterable<int> data, DateTime prev) {
    var millis = 0;
    var bytes = data.toList();
    millis |= (bytes[1] & 0xff) << 8;
    millis |= (bytes[0] & 0xff);
    if (millis == 0xffff) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return prev.add(Duration(milliseconds: millis));
  }
}

// StreamTransformer<int, List<int>> group(int n) {
//   var items = <int>[];
//   return StreamTransformer.fromHandlers(handleData: ((data, sink) {
//     items.add(data);
//     if (items.length == n) {
//       sink.add(items);
//       items = [];
//     }
//   }));
// }
