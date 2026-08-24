import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorMessage extends StatefulWidget {
  const ErrorMessage({super.key});

  @override
  State<ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.info, color: Colors.redAccent),
          onPressed: () async {
            var prefs = await SharedPreferences.getInstance();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(
                    prefs.getString('errorMessage') ?? 'Unknown error',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Text('Error saving combo'),
      ],
    );
  }
}
