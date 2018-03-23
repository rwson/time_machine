import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:quiver_hashcode/hashcode.dart';

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_utilities.dart';
import 'package:time_machine/time_machine_calendars.dart';
import 'package:time_machine/time_machine_timezones.dart';

import 'dart:typed_data';
import 'dart:convert';

class DateTimeZoneReader {
  final ByteData binary;
  int _offset;

  DateTimeZoneReader(this.binary, [this._offset = 0]);

  int readInt32() => binary.getInt32(_offset+=4);
  int readUint8() => binary.getUint8(_offset++);
  bool readBool() => readUint8() == 1;
  Offset readOffsetSeconds() => Offset.fromSeconds(read7BitEncodedInt());

  bool get hasMoreData => binary.lengthInBytes < _offset;

  ZoneInterval readZoneInterval() {
    var name = /*stream.*/readString();
    var flag = /*stream.*/readUint8();
    bool hasStart = (flag & 1) == 1;
    bool hasEnd = (flag & 2) == 2;
    int startSeconds = null;
    int endSeconds = null;

    if (hasStart) {
      startSeconds = /*stream.*/readInt32();
    }
    if (hasEnd) {
      endSeconds = /*stream.*/readInt32();
    }

    Instant start = startSeconds == null ? null : new Instant.fromUnixTimeSeconds(startSeconds);
    Instant end = endSeconds == null ? null : new Instant.fromUnixTimeSeconds(endSeconds);

    var wallOffset = /*stream.*/readOffsetSeconds(); // Offset.fromSeconds(stream.readInt32());
    var savings = /*stream.*/readOffsetSeconds(); // Offset.fromSeconds(stream.readInt32());
    return new ZoneInterval(name, start, end, wallOffset, savings);
  }

  int read7BitEncodedInt() { //ByteData binary, int offset) {
    int count = 0;
    int shift = 0;
    int b;
    do {
      if (shift == 5 * 7) {
        throw new StateError('7bitInt32 Format Error');
      }

      b = binary.getUint8(_offset++);
      count |= (b & 0x7F) << shift;
      shift += 7;
    } while ((b & 0x80) != 0);
    return count;
  }

  // todo: it might just be superior to change the C# project to record the byte length... AND NOT the character count
  String readString() {
    int length = read7BitEncodedInt();
    var byteLength = _getStringByteCount(_offset, length);
    var bytes = binary.buffer.asUint8List(_offset, byteLength);
    return UTF8.decode(bytes);
  }

  // note: I just looked here: https://en.wikipedia.org/wiki/UTF-8 and then guessed a routine
  //    I'm sure there are much more clever and awesome algorithms out there for doing this
  //    Or even some way to just do this with the [UTF8.decoder]
  int _getUnicodeCodeSize(int o) {
    var b = binary.getUint8(o);
    if (b <= 127) return 1;
    if (b <= 191) return 0; // This is a tail byte
    if (b <= 223) return 2;
    if (b <= 239) return 3;
    if (b <= 247) return 4;
    throw new StateError('Impossible UTF-8 byte.');
  }

  int _getStringByteCount(int o, int charLength) {
    int byteCount = 0;

    // I'm not proud of this
    for (int i = o; i < o+byteCount; i++) {
      byteCount += _getUnicodeCodeSize(o);
    }

    return byteCount;
  }
}
