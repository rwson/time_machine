// https://github.com/nodatime/nodatime/blob/master/src/NodaTime.Test/LocalTimeTest.Pseudomutators.cs
// de133ae  on Dec 31, 2016

import 'dart:async';

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_calendars.dart';
import 'package:time_machine/time_machine_utilities.dart';

import 'package:test/test.dart';
import 'package:matcher/matcher.dart';
import 'package:time_machine/time_machine_timezones.dart';

import 'time_machine_testing.dart';

Future main() async {
  await runTests();
}


@Test()
void PlusHours_Simple()
{
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expectedForward = new LocalTime(14, 15, 8);
  LocalTime expectedBackward = new LocalTime(10, 15, 8);
  expect(expectedForward, start.PlusHours(2));
  expect(expectedBackward, start.PlusHours(-2));
}

@Test()
void PlusHours_CrossingDayBoundary()
{
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expected = new LocalTime(8, 15, 8);
  expect(expected, start.PlusHours(20));
  expect(start, start.PlusHours(20).PlusHours(-20));
}

@Test()
void PlusHours_CrossingSeveralDaysBoundary()
{
  // Christmas day + 10 days and 1 hour
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expected = new LocalTime(13, 15, 8);
  expect(expected, start.PlusHours(241));
  expect(start, start.PlusHours(241).PlusHours(-241));
}

// Having tested that hours cross boundaries correctly, the other time unit
// tests are straightforward
@Test()
void PlusMinutes_Simple()
{
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expectedForward = new LocalTime(12, 17, 8);
  LocalTime expectedBackward = new LocalTime(12, 13, 8);
  expect(expectedForward, start.PlusMinutes(2));
  expect(expectedBackward, start.PlusMinutes(-2));
}

@Test()
void PlusSeconds_Simple()
{
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expectedForward = new LocalTime(12, 15, 18);
  LocalTime expectedBackward = new LocalTime(12, 14, 58);
  expect(expectedForward, start.PlusSeconds(10));
  expect(expectedBackward, start.PlusSeconds(-10));
}

@Test()
void PlusMilliseconds_Simple()
{
  LocalTime start = new LocalTime(12, 15, 8, 300);
  LocalTime expectedForward = new LocalTime(12, 15, 8, 700);
  LocalTime expectedBackward = new LocalTime(12, 15, 7, 900);
  expect(expectedForward, start.PlusMilliseconds(400));
  expect(expectedBackward, start.PlusMilliseconds(-400));
}

@Test()
void PlusTicks_Simple()
{
  LocalTime start = LocalTime.FromHourMinuteSecondMillisecondTick(12, 15, 8, 300, 7500);
  LocalTime expectedForward = LocalTime.FromHourMinuteSecondMillisecondTick(12, 15, 8, 301, 1500);
  LocalTime expectedBackward = LocalTime.FromHourMinuteSecondMillisecondTick(12, 15, 8, 300, 3500);
  expect(expectedForward, start.PlusTicks(4000));
  expect(expectedBackward, start.PlusTicks(-4000));
}

@Test()
void PlusTicks_Long()
{
  expect(TimeConstants.ticksPerDay > Utility.int32MaxValue, isTrue);
  LocalTime start = new LocalTime(12, 15, 8);
  LocalTime expectedForward = new LocalTime(12, 15, 9);
  LocalTime expectedBackward = new LocalTime(12, 15, 7);
  expect(start.PlusTicks(TimeConstants.ticksPerDay + TimeConstants.ticksPerSecond), expectedForward);
  expect(start.PlusTicks(-TimeConstants.ticksPerDay - TimeConstants.ticksPerSecond),  expectedBackward);
}

@Test()
void With()
{
  LocalTime start = LocalTime.FromHourMinuteSecondMillisecondTick(12, 15, 8, 100, 1234);
  LocalTime expected = new LocalTime(12, 15, 8);
  expect(expected, start.With(TimeAdjusters.TruncateToSecond));
}

@Test()
void PlusMinutes_WouldOverflowNaively()
{
  LocalTime start = new LocalTime(12, 34, 56);
  // Very big value, which just wraps round a *lot* and adds one minute.
  // There's no way we could compute that many nanoseconds.
  int value = (TimeConstants.nanosecondsPerDay << 15) + 1;
  LocalTime expected = new LocalTime(12, 35, 56);
  LocalTime actual = start.PlusMinutes(value);
  expect(expected, actual);
}