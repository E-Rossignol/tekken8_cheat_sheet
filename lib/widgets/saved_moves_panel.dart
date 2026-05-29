import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';

class SavedMovesPanel extends StatelessWidget {
  final List<List<String>> savedStrings;
  final List<InputData> inputs;
  final Future<void> Function(int) onDelete;
  final Color accent;
  final List<int>? savedFrames; // optionnel : frames associés (punishes)

  const SavedMovesPanel({
    super.key,
    required this.savedStrings,
    required this.inputs,
    required this.onDelete,
    required this.accent,
    this.savedFrames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre + icône d'accès aux détails (action à implémenter ultérieurement)
          Row(
            children: [
              const Expanded(
                child: Text(
                  "SAVED MOVES",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: accent),
                onPressed: () {
                  // TODO: ouvrir la vue de détail des saved moves
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: savedStrings.isEmpty
                ? Center(
                    child: Text(
                      "Aucun",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: savedStrings.length,
                    itemBuilder: (context, index) {
                      final string = savedStrings[index];
                      final frames = (savedFrames != null && savedFrames!.length > index)
                          ? savedFrames![index]
                          : null;
                      // calcul simple de la taille d'icone (ici on laisse la taille gérée
                      // par le parent / style global) ; on utilise 32 par défaut
                      final double iconSize = 32;
                      final double spacing = 6;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(5, 11, 32, 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            // icônes du string
                            Expanded(
                              child: Row(
                                children: string.asMap().entries.map((entry) {
                                  final code = entry.value;
                                  final data = inputs.firstWhere(
                                    (e) => e.code == code,
                                    orElse: () => InputData(code, '-'),
                                  );
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: entry.key == string.length - 1 ? 0 : spacing,
                                    ),
                                    child: SizedBox(
                                      width: iconSize,
                                      height: iconSize,
                                      child: data.assetPath == '-'
                                          ? Center(
                                              child: Text(
                                                data.code,
                                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          : Image.asset(data.assetPath, fit: BoxFit.contain),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // si frames présent, l'afficher
                            if (frames != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$frames',
                                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],

                            // bouton supprimer
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              tooltip: 'Supprimer',
                              onPressed: () async {
                                await onDelete(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
