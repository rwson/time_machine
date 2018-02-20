import 'package:time_machine/time_machine.dart';

@internal
class YearMonthDay {
  // static const int _dayBits = 6; // Up to 64 days in a month.
  // static const int _monthBits = 4; // Up to 16 months per year.
  // static const int _yearBits = 15; // 32K range; only need -10K to +10K.

  static const int _dayMask = (1 << YearMonthDayCalendar.dayBits) - 1;
  static const int _monthMask = ((1 << YearMonthDayCalendar.monthBits) - 1) << YearMonthDayCalendar.dayBits;

  final int _value;

  @internal
  YearMonthDay.raw(int rawValue) : _value = rawValue;

  @internal
  /// Constructs a new value for the given year, month and day. No validation is performed.
  YearMonthDay(int year, int month, int day) :
        _value = ((year - 1) << (YearMonthDayCalendar.dayBits + YearMonthDayCalendar.monthBits)) | ((month - 1) << YearMonthDayCalendar.dayBits) | (day - 1);

  @internal
  int get year => (_value >> (YearMonthDayCalendar.dayBits + YearMonthDayCalendar.monthBits)) + 1;

  int get month => ((_value & _monthMask) >> YearMonthDayCalendar.dayBits) + 1;

  int get day => (_value & _dayMask) + 1;

  int get rawValue => _value;

// Just for testing purposes...
  @internal
  static YearMonthDay parse(String text) {
// Handle a leading - to negate the year
    if (text.startsWith("-")) {
      var ymd = parse(text.substring(1));
      return new YearMonthDay(-ymd.year, ymd.month, ymd.day);
    }

    var bits = text.split('-');
// todo: , CultureInfo.InvariantCulture))
    return new YearMonthDay(
        int.parse(bits[0]),
        int.parse(bits[1]),
        int.parse(bits[2]));
  }

  @override
  String toString() => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @internal
  YearMonthDayCalendar WithCalendar(CalendarSystem calendar) =>
      new YearMonthDayCalendar.ymd(_value, calendar == null ? 0 : calendar.ordinal);

  @internal
  YearMonthDayCalendar WithCalendarOrdinal(CalendarOrdinal calendarOrdinal) =>
      new YearMonthDayCalendar.ymd(_value, calendarOrdinal);

  int compareTo(YearMonthDay other) => _value.compareTo(other._value);

  //bool Equals(YearMonthDay other)
  //{
  //return _value == other._value;
  //}
  //
  //@override
  //bool Equals(dynamic other) => other is YearMonthDay && Equals(other);

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(dynamic rhs) => rhs is YearMonthDay ? _value == rhs._value : false;

  //@override
  //bool operator !=(YearMonthDay rhs) => _value != rhs._value;

  bool operator <(YearMonthDay rhs) => _value < rhs._value;

  bool operator <=(YearMonthDay rhs) => _value <= rhs._value;

  bool operator >(YearMonthDay rhs) => _value > rhs._value;

  bool operator >=(YearMonthDay rhs) => _value >= rhs._value;
}