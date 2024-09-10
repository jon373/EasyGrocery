import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'categories.dart';

class SmartCalendarPage extends StatefulWidget {
  final List<quantityItem> addedItems;

  SmartCalendarPage({required this.addedItems});

  @override
  _SmartCalendarPageState createState() => _SmartCalendarPageState();
}

class _SmartCalendarPageState extends State<SmartCalendarPage> {
  CalendarView _calendarView = CalendarView.month;
  DateTime? _selectedDate;

  final Color _defaultAppBarColor =
      const Color(0xFFEEECE6); // Default AppBar color

  void _changeCalendarView(CalendarView view) {
    setState(() {
      _calendarView = view;
    });
  }

  void _onTapCalendar(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: GoogleFonts.dmSerifText(
            color: const Color(0xFF313638),
            fontSize: 25,
          ),
        ),
        backgroundColor: _getAppBarColor(),
      ),
      body: Container(
        color: const Color(0xFFECECE6),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _changeCalendarView(CalendarView.day);
                    },
                    child: const Text('Day'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _changeCalendarView(CalendarView.week);
                    },
                    child: const Text('Week'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _changeCalendarView(CalendarView.month);
                    },
                    child: const Text('Month'),
                  ),
                ],
              ),
            ),
            // Container for rounded square background
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.all(16.0), // Padding around the calendar
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the calendar
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // _buildCustomHeader(), // Custom header widget
                    Expanded(
                      child: SfCalendar(
                        key: ValueKey(_calendarView),
                        view: _calendarView,
                        backgroundColor: Colors.transparent,
                        headerHeight: 60, // Set to 0 to hide the default header
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: false,
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.indicator,
                          navigationDirection:
                              MonthNavigationDirection.horizontal,
                          dayFormat:
                              'EEE', // Use three-letter day abbreviations
                          monthCellStyle: MonthCellStyle(
                            backgroundColor: Colors.transparent,
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                            leadingDatesTextStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                            trailingDatesTextStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        dataSource: MeetingDataSource(_getDataSource()),
                        onTap: (details) {
                          if (details.targetElement ==
                              CalendarElement.calendarCell) {
                            _onTapCalendar(details.date!);
                          }
                        },
                        selectionDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        monthCellBuilder:
                            (BuildContext context, MonthCellDetails details) {
                          final bool isCurrentMonth = details.date.month ==
                              details
                                  .visibleDates[
                                      details.visibleDates.length ~/ 2]
                                  .month;

                          final bool isSelected = _selectedDate != null &&
                              details.date.isSameDate(_selectedDate);

                          TextStyle textStyle = TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isCurrentMonth ? Colors.black : Colors.grey),
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          );

                          Color containerColor = isSelected
                              ? const Color(0xFF313638)
                              : Colors.transparent;

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: containerColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    details.date.day.toString(),
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        headerDateFormat: 'MMMM yyyy',
                      ),
                    ),
                    if (_calendarView == CalendarView.month)
                      _buildAgendaOrMessages()
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    DateTime now = DateTime.now();
    String month = DateFormat('MMMM').format(now);
    String year = DateFormat('yyyy').format(now);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              year,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAppBarColor() {
    switch (_calendarView) {
      case CalendarView.day:
      case CalendarView.week:
        return const Color(0xFFEEECE6);
      case CalendarView.month:
      default:
        return _defaultAppBarColor;
    }
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();

    for (var cartItem in widget.addedItems) {
      int totalQuantity = cartItem.quantity;
      int day = 0;

      while (totalQuantity > 0) {
        DateTime date = today.add(Duration(days: day));

        if (totalQuantity > 0) {
          meetings.add(
            Meeting(
              '${cartItem.item.name} (1x)',
              DateTime(date.year, date.month, date.day, 7, 0),
              DateTime(date.year, date.month, date.day, 9, 0),
              Colors.green,
              false,
            ),
          );
          totalQuantity--;
        }

        if (totalQuantity > 0) {
          meetings.add(
            Meeting(
              '${cartItem.item.name} (1x)',
              DateTime(date.year, date.month, date.day, 12, 0),
              DateTime(date.year, date.month, date.day, 14, 30),
              Colors.yellow,
              false,
            ),
          );
          totalQuantity--;
        }

        if (totalQuantity > 0) {
          meetings.add(
            Meeting(
              '${cartItem.item.name} (1x)',
              DateTime(date.year, date.month, date.day, 19, 0),
              DateTime(date.year, date.month, date.day, 21, 0),
              Colors.red,
              false,
            ),
          );
          totalQuantity--;
        }

        day++;
      }
    }

    return meetings;
  }

  Widget _buildAgendaOrMessages() {
    final double agendaHeight = 300; // Fixed height for the agenda container

    if (_selectedDate == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEECE6), // Background color
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        height: agendaHeight,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text(
            'No Selected Date',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    final meetings = _getDataSource();
    final hasMeetings = meetings.any((meeting) {
      DateTime meetingDate =
          DateTime(meeting.from.year, meeting.from.month, meeting.from.day);
      return meetingDate.isSameDate(_selectedDate);
    });

    if (hasMeetings) {
      return _buildCustomAgenda(); // Build custom agenda with rounded corners
    } else {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEECE6), // Background color
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        height: agendaHeight,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text(
            'No Item Present',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _buildCustomAgenda() {
    if (_selectedDate == null) return SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEECE6), // Background color
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      padding: const EdgeInsets.all(16.0),
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMealContainer('Breakfast', _getMealItemsForTime('Breakfast')),
            SizedBox(height: 8),
            _buildMealContainer('Lunch', _getMealItemsForTime('Lunch')),
            SizedBox(height: 8),
            _buildMealContainer('Dinner', _getMealItemsForTime('Dinner')),
          ],
        ),
      ),
    );
  }

  Widget _buildMealContainer(String mealTitle, String mealItems) {
    if (mealItems.isEmpty) return SizedBox.shrink();

    Color dotColor;
    String timeText;
    switch (mealTitle) {
      case 'Breakfast':
        dotColor = Colors.green;
        timeText = '7:00 AM - 9:00 AM';
        break;
      case 'Lunch':
        dotColor = Colors.yellow;
        timeText = '12:00 PM - 2:30 PM';
        break;
      case 'Dinner':
        dotColor = Colors.red;
        timeText = '7:00 PM - 9:00 PM';
        break;
      default:
        dotColor = Colors.grey;
        timeText = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHollowDot(dotColor),
                SizedBox(width: 8),
                Text(
                  timeText,
                  style: GoogleFonts.robotoSerif(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              mealTitle,
              style: GoogleFonts.robotoSerif(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              mealItems,
              style: GoogleFonts.robotoSerif(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHollowDot(Color color) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 5),
        color: Colors.transparent,
      ),
    );
  }

  String _getMealItemsForTime(String mealTime) {
    if (_selectedDate == null) return '';

    List<String> mealItems = [];
    final meetings = _getDataSource();

    final selectedMeetings = meetings.where((meeting) {
      DateTime meetingDate =
          DateTime(meeting.from.year, meeting.from.month, meeting.from.day);
      if (meetingDate != _selectedDate) return false;

      switch (mealTime) {
        case 'Breakfast':
          return meeting.from.hour == 7;
        case 'Lunch':
          return meeting.from.hour == 12;
        case 'Dinner':
          return meeting.from.hour == 19;
        default:
          return false;
      }
    }).toList();

    for (var meeting in selectedMeetings) {
      mealItems.add(meeting.eventName.split(' ')[0]);
    }

    return mealItems.join(', ');
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime? other) {
    if (other == null) return false;
    return year == other.year && month == other.month && day == other.day;
  }
}
