import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/services/db_provider.dart';
import 'package:window_manager/window_manager.dart';
import '../constants/helper.dart';
import '../models/page_type_model.dart';
import '../views/main_views/home_view.dart';
import '../views/main_views/my_character_view.dart';

PreferredSizeWidget customAppBar(
  PageType pageType,
  String? characterName,
  BuildContext context,
) {
  return AppBar(
    title: Row(
      children: [
        pageType != PageType.home
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: () {
                  if (characterName == null ||
                      pageType == PageType.characterDetail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Returning to home page'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeView()),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Returning to character list'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          MyCharacterView(characterName: characterName),
                    ),
                  );
                },
                tooltip: 'Back',
              )
            : const SizedBox(),
        SizedBox(width: 20),
        IconButton(
          onPressed: () {
            Helper().onHelpButtonClick(pageType, context);
          },
          icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
          tooltip: 'How to use this page',
        ),
        SizedBox(width: 30),
        Container(
          width: 64,
          alignment: Alignment.centerLeft,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
          ),
        ),
        Container(
          color: Colors.blueGrey,
          width: 100,
          child: TextButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Importing default database'),
                  content: Text(
                    'This will import the default database with all characters and moves. Do you want to proceed?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
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
                          MaterialPageRoute(builder: (_) => HomeView()),
                        );
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'DB EXAMPLE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              characterName == null
                  ? 'TEKKEN 8 CHEAT SHEET'
                  : Helper().getBeautifulName(characterName).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
    leading: const SizedBox(),
    backgroundColor: Color.fromRGBO(5, 11, 32, 1),
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(Icons.close, color: Colors.redAccent, size: 30),
        tooltip: 'Close app',
        onPressed: () => WindowManager.instance.close(),
      ),
    ],
  );
}
