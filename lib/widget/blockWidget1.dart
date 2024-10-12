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
  Map<String, bool> previousStates = {};  // Keep track of previous states of parking spaces

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parking-lot')  // Directly access 'parking-lot' collection
            .where(FieldPath.documentId, whereIn: List.generate(24, (index) => (index + 1).toString()))  // Query documents 1 to 24
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          var documents = snapshot.data!.docs;
          int availableSpots = 0;
          List<Widget> parkingWidgetsA = [];
          List<Widget> parkingWidgetsB = [];
          List<Widget> parkingWidgetsC = [];

          for (int i = 1; i <= 8; i++) {
            String spaceId = i.toString();
            var document = documents.firstWhere(
                  (doc) => doc.id == spaceId,
              orElse: () => throw Exception('Document $spaceId not found'),
            );
            bool isOccupied = document['intersected'] as bool? ?? false;
            if (!isOccupied) availableSpots++;

            // Log the event if state has changed
            _logParkingEvent(spaceId, isOccupied);

            parkingWidgetsA.add(_buildParkingSpace(isOccupied, spaceId, rotationAngle: 0));
          }

          for (int i = 17; i <= 24; i++) {
            String spaceId = i.toString();
            var document = documents.firstWhere(
                  (doc) => doc.id == spaceId,
              orElse: () => throw Exception('Document $spaceId not found'),
            );
            bool isOccupied = document['intersected'] as bool? ?? false;
            if (!isOccupied) availableSpots++;

            // Log the event if state has changed
            _logParkingEvent(spaceId, isOccupied);

            parkingWidgetsB.add(_buildParkingSpace(isOccupied, spaceId, rotationAngle: 0));
          }

          for (int i = 9; i <= 16; i++) {
            String spaceId = i.toString();
            var document = documents.firstWhere(
                  (doc) => doc.id == spaceId,
              orElse: () => throw Exception('Document $spaceId not found'),
            );
            bool isOccupied = document['intersected'] as bool? ?? false;
            if (!isOccupied) availableSpots++;

            // Log the event if state has changed
            _logParkingEvent(spaceId, isOccupied);

            parkingWidgetsC.add(_buildParkingSpace(isOccupied, spaceId, rotationAngle: 0));
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
                        ...parkingWidgetsB.reversed,
                      ],
                    ),
                    SizedBox(width: 60),
                    Column(
                      children: [
                        ...parkingWidgetsC.reversed,
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Text(
                  'Available Spots: $availableSpots',
                  style: TextStyle(fontSize: 20),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ttsEnabled = !ttsEnabled;  // Toggle TTS on button press
                    });
                  },
                  child: Text(ttsEnabled ? 'Disable Announcements' : 'Enable Announcements'),
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

  Future<void> _logParkingEvent(String spaceId, bool isOccupied) async {
    bool previousState = previousStates[spaceId] ?? !isOccupied;  // Set default previous state to the opposite if null
    if (previousState != isOccupied) {
      // Generate a unique field name using the current timestamp
      String eventKey = DateTime.now().millisecondsSinceEpoch.toString();

      // Record the change event to Firebase directly in the document with a unique field for each event
      await FirebaseFirestore.instance
          .collection('parking-events')        // Main collection
          .doc(spaceId)                        // Document with spaceId as the key
          .set({
        eventKey: {
          'isOccupied': isOccupied,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true)); // Merge to add a new event without overwriting other events

      // Update the previous state
      previousStates[spaceId] = isOccupied;
    }
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
