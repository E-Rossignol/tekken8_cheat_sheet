import 'package:flutter/material.dart';
import '../constants/helper.dart';
import '../models/pagetype_model.dart';
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
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () {
            if (characterName == null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeView()),
              );
              return;
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MyCharacterView(characterName: characterName),
              ),
            );
          },
          tooltip: 'Back',
        ),
        SizedBox(width: 20),
            IconButton(
          onPressed: () {
            onHelpButtonClick(pageType, context);
          },
          icon: const Icon(Icons.info_outline, color: Colors.white, size : 30),
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
        // centre : prend l'espace restant et centre le titre
        Expanded(
          child: Center(
            child: Text(
              characterName == null
                  ? 'TEKKEN 8 CHEAT SHEET'
                  : getBeautifulName(characterName).toUpperCase(),
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
    // pour éviter que le titre ne soit décalé à gauche
    backgroundColor: Color.fromRGBO(5, 11, 32, 1),
    elevation: 0,
  );
}
