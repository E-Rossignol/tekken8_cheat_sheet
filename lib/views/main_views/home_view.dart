import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import 'character_gallery_view.dart';
import '../test_views/db_explorer_view.dart';
import 'my_character_view.dart';
import '../../models/character_model.dart';
import '../../constants/helper.dart';
import '../../services/db_provider.dart';

/// Home view that lists the user's characters and provides navigation to other tools.
/// Contains an animated sidebar and grid of characters.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  /// Sidebar open flag controlling width and content.
  bool _isSidebarOpen = true;

  /// Animation duration used for sidebar transitions.
  final Duration _animDuration = const Duration(milliseconds: 300);

  /// List of characters loaded from the DB.
  List<Character> _myCharacters = [];

  /// Loading flag while characters are loaded.
  bool _loadingCharacters = true;

  /// Hovered index in the grid for hover effects.
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadMyCharacters();
  }

  /// Load the user's saved characters from DB and populate model list.
  /// @return Future<void>
  Future<void> _loadMyCharacters() async {
    setState(() => _loadingCharacters = true);
    try {
      var list = await DBProvider.instance.getAllMyCharacters();
      setState(() {
        for (var c in list) {
          _myCharacters.add(
            Character(
              name: c['name'] as String,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                c['createdAt'] as int,
              ),
            ),
          );
        }
      });
    } catch (_) {
      setState(() {
        _myCharacters = [];
      });
    } finally {
      setState(() => _loadingCharacters = false);
    }
  }

  /// Compute number of columns to display depending on width.
  /// @param width available width
  /// @return int columns count
  int _columnsForWidth(double width) {
    if (width > 1400) return 8;
    if (width > 1000) return 7;
    if (width > 700) return 6;
    if (width > 480) return 5;
    return 4;
  }

  /// Derive an asset path for a character; fallback to Helper path when no explicit image.
  /// @param c Character model
  /// @return String asset path
  String _assetPathForCharacter(Character c) {
    if (c.imagePath != null && c.imagePath!.isNotEmpty) return c.imagePath!;
    // essayer de dériver un slug à partir du nom (ex: "Alisa" -> "alisa-portrait.png")
    final slug = c.name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return Helper().getPath(slug);
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
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
      appBar: customAppBar(PageType.home, null, context),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
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
                    right: BorderSide(color: Colors.white.withOpacity(0.03)),
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
                              ? const Center(child: CircularProgressIndicator())
                              : _myCharacters.isEmpty
                              ? Center(
                                  child: Text(
                                    'Aucun personnage',
                                    style: TextStyle(color: Colors.white70),
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
                                        final name = Helper().getBeautifulName(
                                          c.name,
                                        );
                                        return MouseRegion(
                                          cursor: SystemMouseCursors.click,
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
                                                        characterName: c.name,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 160,
                                              ),
                                              curve: Curves.easeOut,
                                              transform: _hoveredIndex == index
                                                  ? (Matrix4.identity()
                                                      ..scale(1.03))
                                                  : Matrix4.identity(),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.03,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.03),
                                                ),
                                                boxShadow:
                                                    _hoveredIndex == index
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.35,
                                                              ),
                                                          blurRadius: 12,
                                                          offset: const Offset(
                                                            0,
                                                            6,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                          child: Image.asset(
                                                            assetPath,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Container(
                                                                    color: Colors
                                                                        .white12,
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
                                                            color: Colors
                                                                .transparent,
                                                            child: IconButton(
                                                              iconSize: 20,
                                                              mouseCursor:
                                                                  MouseCursor
                                                                      .uncontrolled,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              icon: const CircleAvatar(
                                                                radius: 14,
                                                                backgroundColor:
                                                                    Colors
                                                                        .black54,
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .redAccent,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              tooltip: 'Delete',
                                                              onPressed: () async {
                                                                final confirm = await showDialog<bool>(
                                                                  context:
                                                                      context,
                                                                  builder: (ctx) => AlertDialog(
                                                                    title: const Text(
                                                                      'Delete character?',
                                                                    ),
                                                                    content: Text(
                                                                      'Are you sure you want to delete "$name" and all its data? This action cannot be undone.',
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.of(
                                                                              ctx,
                                                                            ).pop(
                                                                              false,
                                                                            ),
                                                                        child: const Text(
                                                                          'Cancel',
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.of(
                                                                              ctx,
                                                                            ).pop(
                                                                              true,
                                                                            ),
                                                                        child: const Text(
                                                                          'Delete',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                                if (confirm !=
                                                                    true)
                                                                  return;
                                                                try {
                                                                  await DBProvider
                                                                      .instance
                                                                      .deleteAllCharacterData(
                                                                        c.name,
                                                                      );
                                                                  setState(() {
                                                                    _myCharacters
                                                                        .removeAt(
                                                                          index,
                                                                        );
                                                                  });
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                        'Character "$name" deleted',
                                                                      ),
                                                                      duration: const Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } catch (e) {
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        'Error deleting character',
                                                                      ),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      duration: Duration(
                                                                        seconds:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromRGBO(
                                                            3,
                                                            36,
                                                            101,
                                                            1,
                                                          ),
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.03),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                            horizontal: 8,
                                                          ),
                                                      child: Text(
                                                        name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
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
      ),
    );
  }
}

/// Composant réutilisable pour les boutons du menu gauche (supporte mode réduit)
class _SidebarButton extends StatelessWidget {
  /// Label displayed next to the icon in expanded mode.
  final String label;

  /// IconData shown in the button.
  final IconData icon;

  /// Callback triggered when button is pressed.
  final VoidCallback onPressed;

  /// Accent color used for icon highlighting.
  final Color accent;

  /// Whether the sidebar is collapsed (icon-only) mode.
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
