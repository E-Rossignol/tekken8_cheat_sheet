import 'package:flutter/material.dart';
import 'character_gallery_view.dart';
import 'db_explorer_view.dart';
import 'my_character_view.dart';
import '../repositories/character_repository.dart';
import '../models/character_model.dart';
import '../constants/helper.dart';
import '../services/db_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isSidebarOpen = true;
  final Duration _animDuration = const Duration(milliseconds: 300);

  // ---- nouveau état pour charger les characters depuis la DB ----
  final CharacterRepository _characterRepo = CharacterRepository();
  List<Character> _myCharacters = [];
  bool _loadingCharacters = true;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    // SystemChrome moved to main.dart to set fullscreen at app startup.
    _loadMyCharacters();
  }

  Future<void> _loadMyCharacters() async {
    setState(() => _loadingCharacters = true);
    try {
      final list = await _characterRepo.fetchAllCharacters();
      setState(() {
        _myCharacters = list;
      });
    } catch (_) {
      setState(() {
        _myCharacters = [];
      });
    } finally {
      setState(() => _loadingCharacters = false);
    }
  }

  int _columnsForWidth(double width) {
    if (width > 1400) return 8;
    if (width > 1000) return 7;
    if (width > 700) return 6;
    if (width > 480) return 5;
    return 4;
  }

  String _assetPathForCharacter(Character c) {
    if (c.imagePath != null && c.imagePath!.isNotEmpty) return c.imagePath!;
    // essayer de dériver un slug à partir du nom (ex: "Alisa" -> "alisa-portrait.png")
    final slug = c.name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return getPath(slug);
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  // Helper confirmation (si HomeView n'en possède pas déjà un)
  Future<bool> _confirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirmer')),
        ],
      ),
    );
    return result == true;
  }

  // Remplacez ici le builder de chaque tuile personnage par cette version
  Widget _buildCharacterTile(Map<String, dynamic> character) {
    final int? id = character['id'] as int?;
    final String name = (character['name'] as String?) ?? 'Unknown';
    final assetPath = 'assets/images/character_images/${name.toLowerCase()}.png';
    return GestureDetector(
      onTap: () {
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image card (garder votre style existant)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset('assets/images/anna.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(name, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          // Bouton delete placé en haut à droite de l'image
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Palette moderne / "tech"
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final accent = const Color.fromRGBO(93, 208, 252, 1); // cyan néon
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête moderne
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.15),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: accent.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // gauche : logo aligné contre le bord (largeur fixe)
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
                              color: accent.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // centre : prend l'espace restant et centre le titre
                    Expanded(
                      child: Center(
                        child: const Text(
                          'TEKKEN 8 CHEAT SHEET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // droite : icônes alignées contre le bord (largeur fixe)
                    Container(
                      width: 140,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white12,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Corps : menu gauche + contenu central
              Expanded(
                child: Row(
                  children: [
                    // Menu vertical gauche (animé)
                    AnimatedContainer(
                      duration: _animDuration,
                      width: _isSidebarOpen ? 220 : 72,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header du menu : affiche "MENU" seulement si ouvert,
                          // et ajoute un bouton de bascule collé au menu.
                          if (_isSidebarOpen)
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    'MENU',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _toggleSidebar,
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: accent.withOpacity(0.9),
                                  ),
                                  tooltip: 'Close menu',
                                ),
                              ],
                            )
                          else
                            // Mode réduit : bouton centré (icône seule)
                            Center(
                              child: IconButton(
                                onPressed: _toggleSidebar,
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: accent.withOpacity(0.9),
                                ),
                                tooltip: 'Open menu',
                              ),
                            ),
                          const SizedBox(height: 8),
                          // Boutons du menu (s'adaptent au mode réduit)
                          _SidebarButton(
                            label: 'NEW CHARACTER',
                            icon: Icons.add,
                            accent: accent,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const CharacterGalleryView(),
                                ),
                              );
                            },
                            collapsed: !_isSidebarOpen,
                          ),
                          const SizedBox(height: 8),
                          _SidebarButton(
                            label: 'DATABASE',
                            icon: Icons.storage,
                            accent: accent,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DBExplorerView(),
                                ),
                              );
                            },
                            collapsed: !_isSidebarOpen,
                          ),
                          const SizedBox(height: 8),
                          _SidebarButton(
                            label: 'OPTIONS',
                            icon: Icons.settings,
                            accent: accent,
                            onPressed: () {},
                            collapsed: !_isSidebarOpen,
                          ),
                          // espaces pour futur contenu
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'v0.1',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // (optionnel) petit fil d'ariane ou sous-titre
                            Text(
                              'MY CHARACTERS',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 12,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Zone centrale -> remplacer le placeholder par la grille de la DB
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.03),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: _loadingCharacters
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _myCharacters.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Aucun personnage',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      )
                                    : LayoutBuilder(
                                        builder: (context, constraints) {
                                          final cols = _columnsForWidth(
                                            constraints.maxWidth,
                                          );
                                          return GridView.builder(
                                            itemCount: _myCharacters.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: cols,
                                                  crossAxisSpacing: 12,
                                                  mainAxisSpacing: 12,
                                                  childAspectRatio: 0.78,
                                                ),
                                            itemBuilder: (context, index) {
                                              final c = _myCharacters[index];
                                              final assetPath =
                                                  _assetPathForCharacter(c);
                                              final name = getBeautifulName(c.name);
                                              return MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                onEnter: (_) => setState(
                                                  () => _hoveredIndex = index,
                                                ),
                                                onExit: (_) => setState(
                                                  () => _hoveredIndex = -1,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            MyCharacterView(
                                                              characterName:
                                                                  c.name,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 160,
                                                    ),
                                                    curve: Curves.easeOut,
                                                    transform:
                                                        _hoveredIndex == index
                                                        ? (Matrix4.identity()
                                                            ..scale(1.03))
                                                        : Matrix4.identity(),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.03),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.03),
                                                      ),
                                                      boxShadow:
                                                          _hoveredIndex == index
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.35,
                                                                    ),
                                                                blurRadius: 12,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      6,
                                                                    ),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          child: Stack(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: const BorderRadius.vertical(
                                                                  top: Radius.circular(10),
                                                                ),
                                                                child: Image.asset(
                                                                  assetPath,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    return Container(
                                                                      color: Colors.white12,
                                                                      child: Center(
                                                                        child: Text(
                                                                          name,
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white70,
                                                                            fontSize:
                                                                                28,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              // Bouton delete en haut à droite
                                                              Positioned(
                                                                top: 8,
                                                                right: 8,
                                                                child: Material(
                                                                  color: Colors.transparent,
                                                                  child: IconButton(
                                                                    iconSize: 20,
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: const BoxConstraints(),
                                                                    icon: const CircleAvatar(
                                                                      radius: 14,
                                                                      backgroundColor: Colors.black54,
                                                                      child: Icon(Icons.delete, color: Colors.redAccent, size: 16),
                                                                    ),
                                                                    tooltip: 'Supprimer ce personnage',
                                                                    onPressed: () async {
                                                                      DBProvider.instance.deleteAllCharacterData(c.name);
                                                                    },

                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: const Color.fromRGBO(3, 36, 101, 1),
                                                            borderRadius: const BorderRadius.only(
                                                              bottomLeft: Radius.circular(10),
                                                              bottomRight: Radius.circular(10),
                                                            ),
                                                            border: Border.all(
                                                              color: Colors.white.withOpacity(0.03),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                              horizontal: 8,
                                                            ),
                                                            child: Text(
                                                              name,
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w600,
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
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Composant réutilisable pour les boutons du menu gauche (supporte mode réduit)
class _SidebarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accent;
  final bool collapsed;

  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.accent,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      // Mode réduit : afficher uniquement l'icône avec Tooltip
      return Center(
        child: Tooltip(
          message: label,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: accent, size: 24),
            splashRadius: 26,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: accent, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        backgroundColor: Colors.white.withOpacity(0.03),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
