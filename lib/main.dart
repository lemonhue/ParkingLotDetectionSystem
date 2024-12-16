import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled8/widget/parkingOverview.dart';
import 'firebase_options.dart';
import 'constants/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled8/widget/formWidget.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true, // This allows the body to extend behind the AppBar
        appBar: AppBar(
          title: Text(
            'PARKING APP',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: screenWidth * 0.06, // Responsive font size
              letterSpacing: 10,
              color: indigo,
            ),
          ),
          toolbarHeight: screenHeight * 0.08, // Responsive toolbar height
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0, // Remove shadow from the AppBar
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: indigo,
            indicatorWeight: 3,
            labelColor: indigo,
            unselectedLabelColor: indigo,
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding to make it circular
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50) // Border color
                  ),
                  child: Text('OVERVIEW', style: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 2)),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding to make it circular
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50) // Border color
                  ),
                  child: Text('FEEDBACK', style: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 2)) ,
                ),
              ),
            ],
            dividerColor: Colors.transparent,
          ),
        ),
        body: Stack(
          fit: StackFit.expand, // Makes the stack expand to fill the entire screen
          children: [
            Lottie.asset(
              'assets/gradient.json', // Path to your Lottie animation file
              fit: BoxFit.cover, // Make the animation cover the whole screen
              height: double.infinity,
              width: double.infinity,
            ),
            // Column to arrange TabBar and content
            Column(
              children: [
                // Use Expanded to allow TabBarView to take available space
                Expanded(
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.17),  // Add top padding to lower ParkingOverview
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Align(
                                    alignment: Alignment.topCenter,  // Align ParkingOverview to the top
                                    child: ParkingOverview(),  // Ensure this is below the TabBar
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.17, right: screenWidth * .05, left: screenWidth * .05),  // Add top padding to lower ParkingOverview
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight
                                ),
                                child: IntrinsicHeight(
                                  child: Align(
                                    alignment: Alignment.topCenter,  // Align ParkingOverview to the top
                                    child: MyCustomForm(),  // Ensure this is below the TabBar
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
