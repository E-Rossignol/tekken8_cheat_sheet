import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';
import 'package:tekken_cheat_sheet/services/db_provider.dart';
import 'home_view.dart';
import 'my_character_view.dart';

class CharacterGalleryView extends StatefulWidget {
  const CharacterGalleryView({super.key});

  @override
  State<CharacterGalleryView> createState() => _CharacterGalleryViewState();
}

class _CharacterGalleryViewState extends State<CharacterGalleryView> {
  List<String> _images = [];
  bool _loading = true;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
  }

  Future<void> _loadAssetImages() async {
    final existingCharacters = await DBProvider.instance.getAllMyCharacters();
    final existingNames = existingCharacters.map((c) => c['name'].toLowerCase()).toSet();
    List<String> images = [];
    for (var name in characterNamesList) {
      if (existingNames.contains(name)) continue;
      images.add(getPath(name));
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
    return 6;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          ),
          tooltip: 'Back',
        ),
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
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = -1),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MyCharacterView(characterName: displayName.toLowerCase())),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        transform: _hoveredIndex == index ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                          boxShadow: _hoveredIndex == index
                              ? [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Column(
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
                                    color: const Color.fromRGBO(3, 36, 101, 1),
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
                            // Overlay visible au hover pour indiquer l'action clic
                            if (_hoveredIndex == index)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.add_circle, color: Colors.white70, size: 36),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
