import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/combos_view.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/punishes_view.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/stances_view.dart';
import '../../models/page_type_model.dart';
import '../../services/db_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/my_icons.dart';
import '../enter_datas_views/key_moves_view.dart';
import 'cheat_sheet_view.dart';
import 'home_view.dart'; // <--- nouvel import

class MyCharacterView extends StatefulWidget {
  final String characterName;

  const MyCharacterView({super.key, required this.characterName});

  @override
  State<MyCharacterView> createState() => _MyCharacterViewState();
}

class _MyCharacterViewState extends State<MyCharacterView> {
  // flags pour l'animation / hover du bouton "Cheat Sheet"
  bool _cheatHover = false;
  bool _cheatFocus = false;

  Widget cheatButton() {
    final bool activeState = _cheatHover || _cheatFocus;
    final double scale = activeState ? 1.06 : 1.0;
    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _cheatFocus = f),
      onFocusChange: (hasFocus) => setState(() => _cheatFocus = hasFocus),
      child: MouseRegion(
        cursor: SystemMouseCursors.alias,
        // curseur souhaité au survol (visible sur desktop/web)
        onEnter: (_) => setState(() => _cheatHover = true),
        onExit: (_) => setState(() => _cheatHover = false),
        // Utiliser InkWell + Material pour garantir prise en charge native du mouseCursor
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: SystemMouseCursors.cell,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheatSheetView(
                    characterName: widget.characterName,
                    index: 0,
                  ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..scale(scale),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                gradient: activeState
                    ? const LinearGradient(
                        colors: [Color(0xFF5ED0FC), Color(0xFF2BA6F6)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF0094D0), Color(0xFF004E80)],
                      ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: activeState
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: Colors.white.withOpacity(activeState ? 0.06 : 0.03),
                ),
              ),
              child: Center(
                child: Text(
                  'CHEAT SHEET',
                  style: TextStyle(
                    color: const Color(0xFFE0E0E0),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        PageType.characterDetail,
        widget.characterName,
        context,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(5, 11, 32, 1),
              Color.fromRGBO(3, 36, 101, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(
          top: kToolbarHeight + 16,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: image + name (garde l'aspect existant)
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 200,
                              height: 250,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: Image.asset(
                                          Helper().getPath(
                                            widget.characterName,
                                          ),
                                          fit: BoxFit.fill,
                                          errorBuilder: (c, e, s) {
                                            return Container(
                                              color: Colors.white12,
                                              child: Center(
                                                child: Text(
                                                  Helper().getBeautifulName(
                                                    widget.characterName,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            iconSize: 20,
                                            mouseCursor:
                                                MouseCursor.uncontrolled,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.black54,
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                                size: 16,
                                              ),
                                            ),
                                            tooltip: 'Delete',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Delete character?',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete "${widget.characterName}" and all its data? This action cannot be undone.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop(false),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            ctx,
                                                          ).pop(true),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm != true) return;
                                              try {
                                                await DBProvider.instance
                                                    .deleteAllCharacterData(
                                                      widget.characterName,
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Character "${Helper().getBeautifulName(widget.characterName)}" deleted',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                Navigator.of(
                                                  context,
                                                ).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) => HomeView(),
                                                  ),
                                                ); // revenir à la liste des personnages
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Error deleting character',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    duration: Duration(
                                                      seconds: 2,
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
                                  cheatButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Hub menu : accès aux données du personnage
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.03),
                            ),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: KeyMovesIcon(),
                                title: const Text(
                                  'Key Moves',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Accéder aux mouvements clés',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => KeyMovesView(
                                        characterName: widget.characterName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              ListTile(
                                leading: PunishIcon(),
                                title: const Text(
                                  'Punishes',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Voir les punishs',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PunishesView(
                                        characterName: widget.characterName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              ListTile(
                                leading: ComboIcon(),
                                title: const Text(
                                  'Combos',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'Voir / créer / modifier les combos personnalisés',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CombosView(
                                        characterName: widget.characterName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              ListTile(
                                leading: StanceIcon(),
                                title: const Text(
                                  'Stances',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'See stance moves',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => StancesView(
                                        characterName: widget.characterName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: Colors.white12, height: 1),
                            ],
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
      ),
    );
  }
}
