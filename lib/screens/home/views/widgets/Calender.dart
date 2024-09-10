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

// Define your list of plant events
  final List<NeatCleanCalendarEvent> _events = [
    // Peas
    NeatCleanCalendarEvent(
      'Peas: Seedling to Flower Bud Formation',
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
      description: 'Transition from seedling to flower bud formation for Peas. Expected duration: 6.4 hours.',
      color: Colors.green,
    ),
    NeatCleanCalendarEvent(
      'Peas: Flowering',
      startTime: DateTime.now().add(Duration(days: 7)),
      endTime: DateTime.now().add(Duration(days: 7, hours: 1)),
      description: 'Flowering stage of Peas. Expected duration: 8.5 hours.',
      color: Colors.yellow,
    ),
    NeatCleanCalendarEvent(
      'Peas: Pod Formation',
      startTime: DateTime.now().add(Duration(days: 14)),
      endTime: DateTime.now().add(Duration(days: 14, hours: 1)),
      description: 'Pod formation stage for Peas. Expected duration: 10.7 hours.',
      color: Colors.blue,
    ),
    NeatCleanCalendarEvent(
      'Peas: Grain Filling',
      startTime: DateTime.now().add(Duration(days: 21)),
      endTime: DateTime.now().add(Duration(days: 21, hours: 1)),
      description: 'Grain filling stage for Peas. Expected duration: 12.8 hours.',
      color: Colors.purple,
    ),

    // Strawberry
    NeatCleanCalendarEvent(
      'Strawberry: From Bud Break to First Flower',
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 2)),
      description: 'Transition from bud break to the first flower for Strawberries. Expected duration: 4.3 hours.',
      color: Colors.red,
    ),
    NeatCleanCalendarEvent(
      'Strawberry: From Flowering to 3/4 of Flowers Open',
      startTime: DateTime.now().add(Duration(days: 7)),
      endTime: DateTime.now().add(Duration(days: 7, hours: 2)),
      description: 'Transition from flowering to 3/4 of flowers open for Strawberries. Expected duration: 5.3 hours.',
      color: Colors.pink,
    ),
    NeatCleanCalendarEvent(
      'Strawberry: Fruit Enlargement',
      startTime: DateTime.now().add(Duration(days: 14)),
      endTime: DateTime.now().add(Duration(days: 14, hours: 2)),
      description: 'Fruit enlargement stage for Strawberries. Expected duration: 7.5 hours.',
      color: Colors.orange,
    ),
    NeatCleanCalendarEvent(
      'Strawberry: Green to White Fruit Transition',
      startTime: DateTime.now().add(Duration(days: 21)),
      endTime: DateTime.now().add(Duration(days: 21, hours: 2)),
      description: 'Transition from green to white fruit for Strawberries. Expected duration: 9.6 hours.',
      color: Colors.greenAccent,
    ),
    NeatCleanCalendarEvent(
      'Strawberry: Early Harvest',
      startTime: DateTime.now().add(Duration(days: 28)),
      endTime: DateTime.now().add(Duration(days: 28, hours: 2)),
      description: 'Early harvest stage for Strawberries. Expected duration: 8.5 hours.',
      color: Colors.redAccent,
    ),

    // Sweet Corn
    NeatCleanCalendarEvent(
      'Sweet Corn: 6-8 Leaves',
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
      description: 'Sweet Corn growth stage: 6-8 leaves. Expected duration: 5.3 hours.',
      color: Colors.yellow,
    ),
    NeatCleanCalendarEvent(
      'Sweet Corn: 8-10 Leaves',
      startTime: DateTime.now().add(Duration(days: 7)),
      endTime: DateTime.now().add(Duration(days: 7, hours: 1)),
      description: 'Sweet Corn growth stage: 8-10 leaves. Expected duration: 6.4 hours.',
      color: Colors.amber,
    ),
    NeatCleanCalendarEvent(
      'Sweet Corn: 10-12 Leaves',
      startTime: DateTime.now().add(Duration(days: 14)),
      endTime: DateTime.now().add(Duration(days: 14, hours: 1)),
      description: 'Sweet Corn growth stage: 10-12 leaves. Expected duration: 7.4 hours.',
      color: Colors.orange,
    ),
    NeatCleanCalendarEvent(
      'Sweet Corn: 12-14 Leaves',
      startTime: DateTime.now().add(Duration(days: 21)),
      endTime: DateTime.now().add(Duration(days: 21, hours: 1)),
      description: 'Sweet Corn growth stage: 12-14 leaves. Expected duration: 8.5 hours.',
      color: Colors.deepOrange,
    ),
    NeatCleanCalendarEvent(
      'Sweet Corn: Male Flowering to Dry Silk',
      startTime: DateTime.now().add(Duration(days: 28)),
      endTime: DateTime.now().add(Duration(days: 28, hours: 1)),
      description: 'Transition from male flowering to dry silk for Sweet Corn. Expected duration: 9.6 hours.',
      color: Colors.red,
    ),

    // Precessing Tomatoes
    NeatCleanCalendarEvent(
      'Tomatoes: Planting to Third Visible Flower Cluster',
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
      description: 'Growth stage from planting to the third visible flower cluster for Tomatoes. Expected duration: 4.3 hours.',
      color: Colors.red,
    ),
    NeatCleanCalendarEvent(
      'Tomatoes: Third Cluster to Two Clusters Set',
      startTime: DateTime.now().add(Duration(days: 7)),
      endTime: DateTime.now().add(Duration(days: 7, hours: 1)),
      description: 'Growth stage from third cluster to two clusters set for Tomatoes. Expected duration: 7.5 hours.',
      color: Colors.orange,
    ),
    NeatCleanCalendarEvent(
      'Tomatoes: Two Clusters Set to First Ripe Fruit',
      startTime: DateTime.now().add(Duration(days: 14)),
      endTime: DateTime.now().add(Duration(days: 14, hours: 1)),
      description: 'Growth stage from two clusters set to the first ripe fruit for Tomatoes. Expected duration: 12.8 hours.',
      color: Colors.redAccent,
    ),
    NeatCleanCalendarEvent(
      'Tomatoes: First Ripe Fruit to 25% Maturity',
      startTime: DateTime.now().add(Duration(days: 21)),
      endTime: DateTime.now().add(Duration(days: 21, hours: 1)),
      description: 'Growth stage from first ripe fruit to 25% maturity for Tomatoes. Expected duration: 8.5 hours.',
      color: Colors.orangeAccent,
    ),
    NeatCleanCalendarEvent(
      'Tomatoes: 25% to 50% Maturity',
      startTime: DateTime.now().add(Duration(days: 28)),
      endTime: DateTime.now().add(Duration(days: 28, hours: 1)),
      description: 'Growth stage from 25% to 50% maturity for Tomatoes. Expected duration: 5.3 hours.',
      color: Colors.red,
    ),

    // Tomato
    NeatCleanCalendarEvent(
      'Tomato: Planting to Establishment',
      startTime: DateTime.now().add(Duration(days: 1)),
      endTime: DateTime.now().add(Duration(days: 1, hours: 1)),
      description: 'Growth stage from planting to establishment for Tomato. Expected duration: 2.1 hours.',
      color: Colors.red,
    ),
    NeatCleanCalendarEvent(
      'Tomato: Establishment to Third Flower Cluster',
      startTime: DateTime.now().add(Duration(days: 7)),
      endTime: DateTime.now().add(Duration(days: 7, hours: 1)),
      description: 'Growth stage from establishment to the third flower cluster for Tomato. Expected duration: 6.4 hours.',
      color: Colors.orange,
    ),
    NeatCleanCalendarEvent(
      'Tomato: Third Flower Cluster to Mid-Harvest',
      startTime: DateTime.now().add(Duration(days: 14)),
      endTime: DateTime.now().add(Duration(days: 14, hours: 1)),
      description: 'Growth stage from the third flower cluster to mid-harvest for Tomato. Expected duration: 9.6 hours.',
      color: Colors.redAccent,
    ),
    NeatCleanCalendarEvent(
      'Tomato: Mid-Harvest to End of Season',
      startTime: DateTime.now().add(Duration(days: 21)),
      endTime: DateTime.now().add(Duration(days: 21, hours: 1)),
      description: 'Growth stage from mid-harvest to the end of the season for Tomato. Expected duration: 12.8 hours.',
      color: Colors.deepOrange,
    ),
    NeatCleanCalendarEvent(
      'Tomato: End of Season to Final Harvest',
      startTime: DateTime.now().add(Duration(days: 28)),
      endTime: DateTime.now().add(Duration(days: 28, hours: 1)),
      description: 'Growth stage from the end of the season to the final harvest for Tomato. Expected duration: 7.5 hours.',
      color: Colors.red,
    ),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Calendar(
          startOnMonday: true,
          weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          eventsList: _events,
          isExpandable: true,
          eventDoneColor: Colors.grey,
          selectedColor: Colors.orange,
          selectedTodayColor: Colors.teal,
          todayColor: Colors.red,
          defaultDayColor: Colors.black,
          datePickerDarkTheme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.yellow,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          datePickerLightTheme: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          locale: 'en_US',
          todayButtonText: 'Today',
          allDayEventText: 'All-day',
          isExpanded: true,
          onEventSelected: (event) {
            print('Event selected: ${event.summary}');
          },
          onDateSelected: (date) {
            print('Date selected: $date');
          },
          dayOfWeekStyle: const TextStyle(
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
