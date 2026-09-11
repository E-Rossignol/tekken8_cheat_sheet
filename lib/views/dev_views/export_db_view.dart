import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/services/db_provider.dart';
import 'package:tekken_cheat_sheet/widgets/default_db_character_card.dart';

import '../../models/page_type_model.dart';
import '../../widgets/custom_appbar.dart';

class ExportDbView extends StatefulWidget {
  const ExportDbView({super.key, required this.myCharacters});

  final List<String> myCharacters;

  @override
  State<ExportDbView> createState() => _ExportDbViewState();
}

class _ExportDbViewState extends State<ExportDbView> {
  bool _isWriting = false;
  final List<String> _onlineCharacters = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initOnlineCharacters();
  }

  Future<void> initOnlineCharacters() async {
    try {
      final onlineChars = await DBProvider.instance.getOnlineCharacters();
      setState(() {
        _onlineCharacters.addAll(onlineChars);
      });
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
                                  itemCount: widget.myCharacters.length,
                                  itemBuilder: (context, index) {
                                    final name = widget.myCharacters[index];
                                    return DefaultDbCharacterCard(
                                      name: name,
                                      isLocal: true,
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
}
