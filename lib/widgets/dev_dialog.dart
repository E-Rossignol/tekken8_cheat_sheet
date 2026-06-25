import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';

import '../models/page_type_model.dart';
import '../services/db_provider.dart';
import '../views/main_views/home_view.dart';
import '../views/test_views/db_explorer_view.dart';
import '../views/test_views/default_db_view.dart'; // Import the new view

class DevDialog extends StatefulWidget {
  const DevDialog({super.key});

  @override
  State<DevDialog> createState() => _DevDialogState();
}

class _DevDialogState extends State<DevDialog> {
  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: customAppBar(PageType.characterChoice, null, context),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DBExplorerView()),
                );
              },
              child: const Text('Database'),
            ),
            TextButton(
              onPressed: () async {
                String value = await DBProvider.instance
                    .exportAllTablesAsJsonString();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => DefaultDBView(value: value),
                  ),
                );
              },
              child: const Text('Generate default database'),
            ),
            TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Importing default database'),
                    content: const Text(
                      'This will import the default database with all characters and moves. Do you want to proceed?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await DBProvider.instance.importDefaultDB();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('DEFAULT DATABASE IMPORTED'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeView()),
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Apply default database'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
