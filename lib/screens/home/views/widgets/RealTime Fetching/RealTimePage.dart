import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'PlantRealTime.dart'; // For formatting the timestamp

class RealTimePage extends StatefulWidget {
  const RealTimePage({super.key});

  @override
  _RealTimePageState createState() => _RealTimePageState();
}

class _RealTimePageState extends State<RealTimePage> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref('UsersData/o26ixh4N4uURJxDy2vApkDd7Er02/readings');
  late Stream<DatabaseEvent> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = _databaseReference.onValue;
  }

  // Function to convert timestamp to human-readable format
  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Sensor Data', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> widgets = [];

            data.forEach((key, value) {
              final sensorData = SensorData.fromJson(value);

              widgets.add(
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the formatted timestamp
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Timestamp: ${_formatTimestamp(sensorData.timestamp)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Display sensor data
                        _buildSensorRow('Heat Index', sensorData.heatIndex, Icons.thermostat),
                        _buildSensorRow('Humidity', '${sensorData.humidity}%', Icons.water_drop),
                        _buildSensorRow('Temperature', '${sensorData.temperature}°C', Icons.thermostat_outlined),
                        _buildSensorRow('Soil Moisture', '${sensorData.soilMoisture}%', Icons.grass),
                        _buildSensorRow('Rain', sensorData.rain, Icons.cloud),
                     //   _buildSensorRow('Numeric', sensorData.numeric.toString(), Icons.analytics),
                      ],
                    ),
                  ),
                ),
              );
            });

            return ListView(
              padding: const EdgeInsets.all(8),
              children: widgets,
            );
          }
        },
      ),
    );
  }

  // Helper function to build a sensor data row
  Widget _buildSensorRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Class for Sensor Data (Assuming you have the structure ready)
