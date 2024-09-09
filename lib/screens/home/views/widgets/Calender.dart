import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarReplanto extends StatelessWidget {
  const CalendarReplanto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Watering Calendar'),
        backgroundColor: Colors.green.shade700, // Darker shade for better contrast
        elevation: 5, // Add some elevation for a shadow effect
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show information or help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Calendar Information'),
                  content: const Text('This calendar helps you manage plant watering schedules.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 16.0),
              Expanded(
                child: Calendar(
                  startOnMonday: true,
                  weekDays: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
                  isExpandable: true,
                  eventDoneColor: Colors.green.shade600,
                  selectedColor: Colors.pink.shade300,
                  selectedTodayColor: Colors.red.shade300,
                  todayColor: Colors.blue.shade300,
                  eventColor: Colors.orange.shade300,
                  locale: 'de_DE',
                  todayButtonText: 'Heute',
                  allDayEventText: 'Ganztägig',
                  multiDayEndText: 'Ende',
                  isExpanded: true,
                  expandableDateFormat: 'EEEE, dd. MMMM yyyy',
                  datePickerType: DatePickerType.date,
                  dayOfWeekStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your event creation logic here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new event feature coming soon!')),
          );
        },
        backgroundColor: Colors.green.shade700,
        tooltip: 'Add Event',
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
