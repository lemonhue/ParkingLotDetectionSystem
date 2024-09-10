
import 'package:flutter/material.dart';

import '../widget/formWidget.dart';


class FeedbackPage extends StatelessWidget {
  static const routeName = '/feedback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 100,
        title: Text("FEEDBACK",style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            letterSpacing: 3
        ), ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

         child: MyCustomForm()),
    );
  }
}
