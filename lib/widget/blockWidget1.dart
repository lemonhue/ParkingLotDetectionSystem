// parking_overview.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/feedbackPage.dart';

class ParkingOverview extends StatelessWidget {
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

          for (int i = 1; i <= 10; i++) {
            bool isOccupied =
                data['${i.toString().padLeft(2, '0')}'] as bool? ?? false;
            if (!isOccupied) availableSpots++;
            parkingWidgetsA.add(_buildParkingSpace(isOccupied, '$i'));
          }

          for (int i = 11; i <= 20; i++) {
            bool isOccupied =
                data['${i.toString().padLeft(2, '0')}'] as bool? ?? false;
            if (!isOccupied) availableSpots++;
            parkingWidgetsB.add(_buildParkingSpace(isOccupied, '$i'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(child: Text('A')),
                        ...parkingWidgetsA,
                      ],
                    ),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        CircleAvatar(child: Text('B')),
                        ...parkingWidgetsB,
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10
                ),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParkingSpace(bool isOccupied, String label) {
    return Container(
      decoration: BoxDecoration(
        color: isOccupied ? Colors.red : Colors.green,
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      width: 100,
      height: 45,
      // Rectangle shape with fixed height
      margin: EdgeInsetsDirectional.only(top: 2),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
