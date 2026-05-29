import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';
import 'package:tekken_cheat_sheet/views/punishes_view.dart';
import 'home_view.dart';
import 'key_moves_view.dart';

class MyCharacterView extends StatelessWidget {
  final String characterName;
  const MyCharacterView({super.key, required this.characterName});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          ),
        ),
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
        padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 24, right: 24, bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: image + name (garde l'aspect existant)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.asset(getPath(characterName), fit: BoxFit.fill, errorBuilder: (c,e,s){
                                  return Container(
                                    color: Colors.white12,
                                    child: Center(
                                      child: Text(
                                        getBeautifulName(characterName),
                                        style: const TextStyle(color: Colors.white70, fontSize: 28, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  );
                                }),
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
                                  getBeautifulName(characterName),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Hub menu : accès aux données du personnage
                      Card(
                        color: Colors.white.withOpacity(0.03),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.white.withOpacity(0.03))),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.star_border, color: Colors.white70),
                              title: const Text('Key Moves', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('Accéder aux mouvements clés', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) =>
                                      KeyMovesView(characterName: characterName)),
                                );
                              }
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            ListTile(
                              leading: const Icon(Icons.punch_clock, color: Colors.white70),
                              title: const Text('Punishes', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('Voir les punishs', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) =>
                                        PunishesView(characterName: characterName)),
                                  );
                                }
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            ListTile(
                              leading: const Icon(Icons.auto_fix_high, color: Colors.white70),
                              title: const Text('Combos', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('Voir / créer / modifier les combos personnalisés', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {

                              },
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            const Divider(color: Colors.white12, height: 1),
                            ListTile(
                              leading: const Icon(Icons.note_alt_outlined, color: Colors.white70),
                              title: const Text('Stances', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('Voir les stance moves', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {

                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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