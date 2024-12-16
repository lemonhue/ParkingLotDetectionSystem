import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';  // Add this import
import 'package:untitled8/constants/colors.dart';
class ParkingOverview extends StatefulWidget {
  @override
  _ParkingOverviewState createState() => _ParkingOverviewState();
}

class _ParkingOverviewState extends State<ParkingOverview> {
  FlutterTts flutterTts = FlutterTts(); // Initialize FlutterTts
  bool ttsEnabled = false; // Flag to track if TTS is enabled
  int previousAvailableSpots = -1; // Keep track of previous available spots
  Map<String, bool> previousStates = {}; // Keep track of previous states of parking spaces

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double spaceWidth = screenWidth * 0.20; // Adjust width based on screen size
    double spaceHeight = screenHeight * 0.05; // Adjust height based on screen size

    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 233, 111, 0.0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parking-lot')
            .where(FieldPath.documentId, whereIn: List.generate(24, (index) => (index + 1).toString()))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
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
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add your legend row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendBox(Colors.indigo, 'OCCUPIED'),
                    const SizedBox(width: 10),
                    _buildLegendBox(Colors.white, 'AVAILABLE'),
                  ],
                ),
                const SizedBox(height: 20),
                // Parking layout
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
                // Available spots
                Text(
                  'AVAILABLE SPOTS',
                  style: TextStyle(
                    fontSize: screenWidth * 0.039,
                    letterSpacing: 2,
                    color: Colors.indigo,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  '$availableSpots',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    letterSpacing: 2,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // TTS Toggle Button
                FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      ttsEnabled = !ttsEnabled;
                      if (ttsEnabled) {
                        _speakAvailableSpots(availableSpots);
                      }
                    });
                  },
                  backgroundColor: ttsEnabled ? Colors.indigo : Colors.white,
                  label: Text(
                    ttsEnabled ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: ttsEnabled ? Colors.white : Colors.indigo,
                      letterSpacing: 1,
                      fontSize: 13,
                    ),
                  ),
                  icon: Icon(
                    ttsEnabled ? Icons.volume_up : Icons.volume_off,
                    color: ttsEnabled ? Colors.white : Colors.indigo,
                  ),
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

      await FirebaseFirestore.instance.collection('parking-events').doc(spaceId).set({
        eventKey: {
          'isOccupied': isOccupied,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      previousStates[spaceId] = isOccupied;
    }
  }

  Widget _buildParkingSpace(bool isOccupied, String label, double width, double height) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isOccupied ? Colors.indigo : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(7.0)),
      ),
      width: width,
      height: height,
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        label,
        style: TextStyle(
          color: isOccupied ? Colors.white : Colors.indigo,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.15,
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: indigo, letterSpacing: 2 ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}