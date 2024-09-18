import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';  // Add this import

import '../pages/feedbackPage.dart';

class ParkingOverview extends StatefulWidget {
  @override
  _ParkingOverviewState createState() => _ParkingOverviewState();
}

class _ParkingOverviewState extends State<ParkingOverview> {
  FlutterTts flutterTts = FlutterTts();  // Initialize FlutterTts
  bool ttsEnabled = false;  // Flag to track if TTS is enabled
  int previousAvailableSpots = -1;  // Keep track of previous available spots

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parking-space')
            .doc('spaces')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(child: Text('No data available'));
          }

          int availableSpots = 0;
          List<Widget> parkingWidgetsA = [];
          List<Widget> parkingWidgetsB = [];
          List<Widget> parkingWidgetsC = [];

          for (int i = 1; i <= 7; i++) {
            bool isOccupied = data['${i.toString().padLeft(2, '0')}'] as bool? ?? false;
            if (!isOccupied) availableSpots++;
            parkingWidgetsA.add(_buildParkingSpace(isOccupied, '$i', rotationAngle: 0));
          }

          for (int i = 8; i <= 15; i++) {
            bool isOccupied = data['${i.toString().padLeft(2, '0')}'] as bool? ?? false;
            if (!isOccupied) availableSpots++;
            parkingWidgetsB.add(_buildParkingSpace(isOccupied, '$i', rotationAngle: 0));
          }

          for (int i = 16; i <= 21; i++) {
            bool isOccupied = data['${i.toString().padLeft(2, '0')}'] as bool? ?? false;
            if (!isOccupied) availableSpots++;
            parkingWidgetsC.add(_buildParkingSpace(isOccupied, '$i', rotationAngle: 0));
          }

          // If TTS is enabled and availableSpots have changed, speak the new count
          if (ttsEnabled && availableSpots != previousAvailableSpots) {
            _speakAvailableSpots(availableSpots);
            previousAvailableSpots = availableSpots;  // Update the previous count
          }

          return Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [

                        ...parkingWidgetsA,
                      ],
                    ),
                    SizedBox(width: 60),
                    Column(
                      children: [

                        ...parkingWidgetsB,
                      ],
                    ),
                    SizedBox(width: 60),
                    Column(
                      children: [
                        ...parkingWidgetsC,
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Text(
                  'Available Spots: $availableSpots',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.feedback),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ttsEnabled = !ttsEnabled;  // Toggle TTS on button press
                    });
                  },
                  child: Text(ttsEnabled ? 'Disable Announcements' : 'Enable Announcements'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _speakAvailableSpots(int availableSpots) async {
    String text = "There are $availableSpots available parking spots.";
    await flutterTts.speak(text);  // Use Flutter TTS to speak the text
  }

  @override
  void dispose() {
    flutterTts.stop();  // Stop TTS when the widget is disposed
    super.dispose();
  }

  Widget _buildParkingSpace(bool isOccupied, String label, {double rotationAngle = 0}) {
    return Container(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..rotateZ(rotationAngle * 3.1415927 / 180),
      decoration: BoxDecoration(
        color: isOccupied ? Colors.red : Colors.green,
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      width: 80,
      height: 40,
      margin: EdgeInsetsDirectional.only(top: 10),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
