import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/services/db_provider.dart';
import 'package:tekken_cheat_sheet/widgets/default_db_character_card.dart';

import '../../models/page_type_model.dart';
import '../../widgets/custom_appbar.dart';

class ExportDbView extends StatefulWidget {
  const ExportDbView({super.key});

  @override
  State<ExportDbView> createState() => _ExportDbViewState();
}

class _ExportDbViewState extends State<ExportDbView> {
  bool _isWriting = false;
  List<String> _onlineCharacters = [];
  List<String> _localCharacters = [];

  @override
  void initState() {
    super.initState();
    initOnlineCharacters();
    initLocalCharacters();
  }

  Future<void> initOnlineCharacters() async {
    try {
      _onlineCharacters.clear();
      final onlineChars = await DBProvider.instance.getOnlineCharacters();
      setState(() {
        _onlineCharacters.addAll(onlineChars);
        for (String char in _onlineCharacters) {
          char = char.replaceAll(" ", "-");
        }
      });
      _onlineCharacters.sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la récupération des personnages en ligne: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> initLocalCharacters() async {
    var chars = await DBProvider.instance.getAllMyCharacters();
    setState(() {
      _localCharacters.clear();
      for (var char in chars) {
        _localCharacters.add(char['name']);
      }
      for (String char in _localCharacters) {
        char = char.replaceAll(" ", "-");
      }
      _localCharacters.sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: customAppBar(PageType.defaultDB, null, context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Each ListView must have bounded height; wrap them in Expanded
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              Text(
                                "LOCAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _localCharacters.length,
                                  itemBuilder: (context, index) {
                                    final name = _localCharacters[index];
                                    return DefaultDbCharacterCard(
                                      name: name,
                                      isLocal: true,
                                      onDelete: deleteCharacter,
                                      onImport: importCharacter,
                                      onUpdate: updateCharacter,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              Text(
                                "ONLINE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _onlineCharacters.length,
                                  itemBuilder: (context, index) {
                                    final name = _onlineCharacters[index];
                                    return DefaultDbCharacterCard(
                                      name: name,
                                      isLocal: false,
                                      onUpdate: updateCharacter,
                                      onDelete: deleteCharacter,
                                      onImport: importCharacter,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isWriting)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Veuillez patienter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateCharacter(String name) async {
    var db = DBProvider.instance;
    setState(() {
      _isWriting = true;
    });
    await db.saveCharacterToFirebase(name);
    await initOnlineCharacters();
    await initLocalCharacters();
    setState(() {
      _isWriting = false;
      _onlineCharacters = _onlineCharacters;
      _localCharacters = _localCharacters;
    });
  }

  Future<void> deleteCharacter(String name) async {
    setState(() {
      _isWriting = true;
    });
    var db = DBProvider.instance;
    await db.deleteCharacterFromFirebase(name.toLowerCase());
    await initOnlineCharacters();
    await initLocalCharacters();
    setState(() {
      _isWriting = false;
      _onlineCharacters = _onlineCharacters;
      _localCharacters = _localCharacters;
    });
  }

  Future<void> importCharacter(String name) async {
    var db = DBProvider.instance;
    setState(() {
      _isWriting = true;
    });
    await db.importCharacterFromFirebase(name);
    await initOnlineCharacters();
    await initLocalCharacters();
    setState(() {
      _isWriting = false;
      _onlineCharacters = _onlineCharacters;
      _localCharacters = _localCharacters;
    });
  }
}
