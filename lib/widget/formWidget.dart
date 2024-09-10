import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'General'; // Default value

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: ['General', 'Suggestion', 'Complaint'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            value: _selectedCategory,
            hint: const Text('Select Category'),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: SizedBox(
              height: 450,
              child: TextFormField(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Save the text to Firestore
                await _firestore.collection('feedback').add({
                  'text': _controller.text,
                  'category': _selectedCategory,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Show a snackbar to indicate successful submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your feedback!')),
                );

                // Clear the text field
                _controller.clear();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
