import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';

class CharacterGalleryView extends StatefulWidget {
  const CharacterGalleryView({super.key});

  @override
  State<CharacterGalleryView> createState() => _CharacterGalleryViewState();
}

class _CharacterGalleryViewState extends State<CharacterGalleryView> {
  List<String> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
  }

  Future<void> _loadAssetImages() async {
    List<String> images = [];
    for (var name in characterNamesList) {
      if (myCharactersList.contains(name)) continue;
      final path = 'assets/images/character_images/$name-portrait.png';
      images.add(path);
    }
    setState(() {
      _images = images;
      _loading = false;
    });
  }

  String _displayNameFromPath(String path) {
    final file = path.split('/').last;
    final name = file.replaceAll(RegExp(r'\.(png|jpg|jpeg)$', caseSensitive: false), '').replaceAll("-portrait", "");
    final parts = name.split(RegExp(r'[-_]'));
    return parts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  int _columnsForWidth(double width) {
    if (width > 1400) return 10;
    if (width > 1000) return 9;
    if (width > 700) return 8;
    if (width > 480) return 7;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select character'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 16, right: 16, bottom: 16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                itemCount: _images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columnsForWidth(MediaQuery.of(context).size.width),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final path = _images[index];
                  final displayName = _displayNameFromPath(path);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.asset(path, fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(3, 36, 101, 1),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.white.withOpacity(0.03)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Text(
                              displayName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

