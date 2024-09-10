import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarReplanto extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarReplantoState();
  }
}

class _CalendarReplantoState extends State<CalendarReplanto> {
  bool showEvents = true;

  // Define your list of events
  List<NeatCleanCalendarEvent> _events = [
    NeatCleanCalendarEvent(
      'Watering the plant',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 1)),
      description: 'Water the indoor plants',
      color: Colors.green,
    ),
    NeatCleanCalendarEvent(
      'Fertilizing',
      startTime: DateTime.now().add(Duration(days: 1, hours: 2)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 3)),
      description: 'Add fertilizers to outdoor plants',
      color: Colors.blue,
    ),
    // Add more events if necessary
  ];

  @override
  void initState() {
    super.initState();
    // Automatically handle today's events when the calendar loads
    _handleNewDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Replanto'),
      ),
      body: SafeArea(
        child: Calendar(
          startOnMonday: true,
          weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          eventsList: _events, // You are passing the event list here
          isExpandable: true,
          eventDoneColor: Colors.grey,
          selectedColor: Colors.orange,
          selectedTodayColor: Colors.teal,
          todayColor: Colors.red,
          defaultDayColor: Colors.black,
          datePickerDarkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.yellow,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          datePickerLightTheme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
             // surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          locale: 'en_US', // Adjust locale as necessary
          todayButtonText: 'Today',
          allDayEventText: 'All-day',
          isExpanded: true,
          onEventSelected: (event) {
            print('Event selected: ${event.summary}');
          },
          onDateSelected: (date) {
            print('Date selected: $date');
          },
          dayOfWeekStyle: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          showEventListViewIcon: true,
          showEvents: showEvents,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showEvents = !showEvents;
          });
        },
        child: Icon(showEvents ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }

  void _handleNewDate(DateTime date) {
    print('New date selected: $date');
  }
}
