import 'package:flutter/material.dart';
import 'character_gallery_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isSidebarOpen = true;
  final Duration _animDuration = const Duration(milliseconds: 300);

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
                    colors: [Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.15)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(color: accent.withOpacity(0.12), width: 1),
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
                          boxShadow: [BoxShadow(color: accent.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
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
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.notifications, color: accent.withOpacity(0.9)),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white12,
                            child: const Icon(Icons.person, color: Colors.white70, size: 18),
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
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                                  child: Text(
                                    'MENU',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, letterSpacing: 1.2),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _toggleSidebar,
                                  icon: Icon(Icons.chevron_left, color: accent.withOpacity(0.9)),
                                  tooltip: 'Close menu',
                                ),
                              ],
                            )
                          else
                            // Mode réduit : bouton centré (icône seule)
                            Center(
                              child: IconButton(
                                onPressed: _toggleSidebar,
                                icon: Icon(Icons.chevron_right, color: accent.withOpacity(0.9)),
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
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CharacterGalleryView()),
                              );
                            },
                            collapsed: !_isSidebarOpen,
                          ),
                          const SizedBox(height: 8),
                          _SidebarButton(label: 'DATABASE', icon: Icons.storage, accent: accent, onPressed: () {}, collapsed: !_isSidebarOpen),
                          const SizedBox(height: 8),
                          _SidebarButton(label: 'OPTIONS', icon: Icons.settings, accent: accent, onPressed: () {}, collapsed: !_isSidebarOpen),
                          // espaces pour futur contenu
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('v0.1', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
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
                              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12, letterSpacing: 1.4),
                            ),
                            const SizedBox(height: 12),

                            // Zone centrale
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'PLACE HOLDER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
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
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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

Set<String> characterNamesList = {
  "alisa",
  "anna",
  "armor-king",
  "asuka",
  "azucena",
  "bryan",
  "claudio",
  "clive",
  "devil-jin",
  "dragunov",
  "eddy",
  "fahkumram",
  "feng",
  "heihachi",
  "hwoarang",
  "jack-8",
  "jin",
  "jun",
  "kazuya",
  "king",
  "kuma",
  "lars",
  "law",
  "lee",
  "leo",
  "leroy",
  "lidia",
  "lili",
  "miary-zo",
  "nina",
  "panda",
  "paul",
  "raven",
  "reina",
  "shaheen",
  "steve",
  "victor",
  "xiaoyu",
  "yoshimitsu",
  "zafina"
};