import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';  // Add this import
import '../pages/feedbackPage.dart';
import 'package:untitled8/constants/colors.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double spaceWidth = screenWidth * 0.20;  // Adjust width based on screen size
    double spaceHeight = screenHeight * 0.05; // Adjust height based on screen size

    return Scaffold(
      backgroundColor: Color.fromRGBO(24,233, 111, 0.0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parking-lot')
            .where(FieldPath.documentId, whereIn: List.generate(24, (index) => (index + 1).toString()))
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

            _logParkingEvent(spaceId, isOccupied);
            parkingWidgetsA.add(_buildParkingSpace(isOccupied, spaceId, spaceWidth, spaceHeight));
          }

          for (int i = 17; i <= 24; i++) {
            String spaceId = i.toString();
            var document = documents.firstWhere(
                  (doc) => doc.id == spaceId,
              orElse: () => throw Exception('Document $spaceId not found'),
            );
            bool isOccupied = document['intersected'] as bool? ?? false;
            if (!isOccupied) availableSpots++;

            _logParkingEvent(spaceId, isOccupied);
            parkingWidgetsB.add(_buildParkingSpace(isOccupied, spaceId, spaceWidth, spaceHeight));
          }

          for (int i = 9; i <= 16; i++) {
            String spaceId = i.toString();
            var document = documents.firstWhere(
                  (doc) => doc.id == spaceId,
              orElse: () => throw Exception('Document $spaceId not found'),
            );
            bool isOccupied = document['intersected'] as bool? ?? false;
            if (!isOccupied) availableSpots++;

            _logParkingEvent(spaceId, isOccupied);
            parkingWidgetsC.add(_buildParkingSpace(isOccupied, spaceId, spaceWidth, spaceHeight));
          }

          if (ttsEnabled && availableSpots != previousAvailableSpots) {
            _speakAvailableSpots(availableSpots);
            previousAvailableSpots = availableSpots;
          }

          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: parkingWidgetsA,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.12),
                    Flexible(
                      child: Column(
                        children: parkingWidgetsB.reversed.toList(),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.12),
                    Flexible(
                      child: Column(
                        children: parkingWidgetsC.reversed.toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'Available Spots: $availableSpots',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
                FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      ttsEnabled = !ttsEnabled;
                      if (ttsEnabled) {
                        _speakAvailableSpots(availableSpots);
                      }
                    });
                  },
                  backgroundColor: ttsEnabled ? indigo : Colors.white,
                  label: Text(
                    ttsEnabled ? 'Disable Announcements' : 'Enable Announcements',
                    style: TextStyle(color: ttsEnabled ? yellow : indigo),
                  ),
                  icon: Icon(
                    ttsEnabled ? Icons.volume_off : Icons.volume_up,
                    color: ttsEnabled ? yellow : indigo,
                  ),
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
    await flutterTts.speak(text);
  }

  Future<void> _logParkingEvent(String spaceId, bool isOccupied) async {
    bool previousState = previousStates[spaceId] ?? !isOccupied;
    if (previousState != isOccupied) {
      String eventKey = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance
          .collection('parking-events')
          .doc(spaceId)
          .set({
        eventKey: {
          'isOccupied': isOccupied,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      previousStates[spaceId] = isOccupied;
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Widget _buildParkingSpace(bool isOccupied, String label, double width, double height, {double rotationAngle = 0}) {
    return Container(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..rotateZ(rotationAngle * 3.1415927 / 180),
      decoration: BoxDecoration(
        color: isOccupied ? indigo : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      width: width,
      height: height,
      margin: EdgeInsetsDirectional.only(top: 10),
      child: Center(
      child: Text(
      label,
      style: TextStyle(
          color: isOccupied ? yellow : indigo, // Text color inverts the container's color
          fontWeight: FontWeight.bold,
          fontSize: width * 0.15
      ),
    ),),);
  }
}
