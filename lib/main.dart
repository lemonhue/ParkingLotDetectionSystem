import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled8/pages/feedbackPage.dart';
import 'package:untitled8/widget/parkingOverview.dart';
import 'firebase_options.dart';
import 'constants/colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        FeedbackPage.routeName: (context) => FeedbackPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size using MediaQuery
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: yellow,

      appBar: AppBar(
        title: Text(
          'Parking Overview',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: screenWidth * 0.05, // Responsive font size
              letterSpacing: 3,
              color: Colors.black
          ),
        ),
        toolbarHeight: screenHeight * 0.08,
        // Responsive toolbar height
        backgroundColor: yellow,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/BlueEdge.png',
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.00),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        color: Colors.transparent,
                        // Let the image background show
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        child: ParkingOverview(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),);
  }
}
