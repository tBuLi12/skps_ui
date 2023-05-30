import 'dart:async';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';

const sampleRate = 240;

class Connection {
  Socket? socket;

  Connection() {}

  // bool changeChannel(int channel) {
  //   if (socket == null) {
  //     return false;
  //   }
  //   socket?.add([channel]);
  //   return true;
  // }

  // bool? checkTrigger(double prevSample, double sample) {
  //   // if (DateTime.now().millisecondsSinceEpoch - tick < 100) {
  //   //   return false;
  //   // }
  //   var res = rising && prevSample < trigger && sample > trigger ||
  //       !rising && prevSample > trigger && sample < trigger;
  //   if (res) {
  //     print('edge trigger: $prevSample -> $sample');
  //     samplesSinceTrigger = 0;
  //   } else if (useTimeout && samplesSinceTrigger > sampleRate) {
  //     print('timeout trigger');
  //     samplesSinceTrigger = DateTime.now().millisecondsSinceEpoch;
  //     return null;
  //   }
  //   return res;
  // }

  // Stream<int> getData() async* {
  //   socket = await Socket.connect('127.0.0.1', 8000);
  //   bool first = true;
  //   int prev = 0;
  //   await for (var byte in socket!.expand((msg) => msg)) {
  //     if (first) {
  //       if (byte == 255) {
  //         yield 8000;
  //         continue;
  //       }
  //       first = false;
  //       prev = byte;
  //     } else {
  //       yield (prev << 8) | byte;
  //       first = true;
  //     }
  //   }
  //   socket!.destroy();
  // }

  // Stream<List<double>> getTriggers() async* {
  //   var buffSize = _minSamples;
  //   print('buffer size: $buffSize');
  //   var prevBuff = List<double>.filled(buffSize, 0);
  //   double prevSample = -2;
  //   var buffer = <double>[];
  //   var remainingSamples = -1;
  //   samplesSinceTrigger = 0;
  //   await for (var val in dataStream) {
  //     if (val != 8000) {
  //       if (buffer.length == _minSamples) {
  //         prevBuff = buffer;
  //         buffer = [];
  //       }
  //       var sample = (val * 5 / 4096);
  //       buffer.add(sample);
  //       if (remainingSamples == -1) {
  //         bool? hasTriggered = checkTrigger(prevSample, sample);
  //         if (hasTriggered != false) {
  //           remainingSamples =
  //               hasTriggered == null ? 1 : (buffSize / 2).round();
  //         }
  //       } else if (--remainingSamples == 0) {
  //         --remainingSamples;
  //         yield prevBuff.skip(buffer.length).followedBy(buffer).toList();
  //       } // else {
  //       //   print(remainingSamples);
  //       // }
  //       prevSample = sample;
  //     } else {
  //       return;
  //     }
  //   }
  // }

  Stream<List<int>> getBlocks() async* {
    socket = await Socket.connect('127.0.0.1', 8000);
    await for (var data in socket!.expand((msg) => msg).transform(sortMessages())) {
      if (data is List<int>) {
        yield data;
      } else if (data is String) {}
    }
  }
}

StreamTransformer<int, Object> sortMessages() {
  List<int>? dataBuff;
  String? message;
  return StreamTransformer.fromHandlers(handleData: (data, sink) {
    if (dataBuff != null) {
      var buff = dataBuff!;
      buff.add(data);
      if (buff.length == 20) {
        sink.add(buff);
        dataBuff = null;
      }
    } else if (message != null) {
      var msg = message!;
      if (data == 0) {
        sink.add(msg);
        message = null;
      } else {
        message = msg + String.fromCharCode(data);
      }
    } else {
      if (data == 0) {
        dataBuff = [];
      } else {
        message = "";
      }
    }
  });
}
