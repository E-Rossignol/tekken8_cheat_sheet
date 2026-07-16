import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';

import '../../models/page_type_model.dart';
import '../../services/db_provider.dart';
import '../main_views/home_view.dart';
import 'db_explorer_view.dart';

class DevView extends StatefulWidget {
  const DevView({super.key});

  @override
  State<DevView> createState() => _DevViewState();
}

class _DevViewState extends State<DevView> {
  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      extendBody: true,
      appBar: customAppBar(PageType.characterDetail, 'Anna', context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DBExplorerView()),
                );
              },
              child: const Text(
                'Database',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Exporting default database'),
                    content: const Text(
                      'This will replace the default datas with the current app\'s state. Do you want to proceed?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Close confirmation dialog
                          Navigator.of(context).pop();

                          // Show a modal progress indicator while importing/writing DB
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              content: Row(
                                children: const [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Exporting default database, it might take a while ...',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          try {
                            await DBProvider.instance.writeDefaultDB();
                          } catch (e) {
                            // Close progress dialog
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error exporting default DB: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          // Close progress dialog
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('DEFAULT DATABASE EXPORTED'),
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
              child: const Text(
                'Update default database',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
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
                          // Close confirmation dialog
                          Navigator.of(context).pop();

                          // Show a modal progress indicator while importing/writing DB
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              content: Row(
                                children: const [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Importing default database...',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          try {
                            await DBProvider.instance.importDefaultDB();
                          } catch (e) {
                            // Close progress dialog
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error importing default DB: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          // Close progress dialog
                          Navigator.of(context).pop();
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
              child: const Text(
                'Apply default database',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
