import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';

class SavedMovesPanel extends StatelessWidget {
  final List<List<String>> savedStrings;
  final List<InputData> inputs;
  final Future<void> Function(int) onDelete;
  final Color accent;

  const SavedMovesPanel({
    super.key,
    required this.savedStrings,
    required this.inputs,
    required this.onDelete,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + icône d'accès aux détails (action à implémenter ultérieurement)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "SAVED MOVES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Icône indiquant que l'on peut cliquer pour voir le détail (placeholder)
              IconButton(
                onPressed: () {
                  // TODO: ouvrir la vue de détail des saved moves
                },
                tooltip: 'Voir détails',
                icon: Icon(
                  Icons.info_outline,
                  color: accent,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: savedStrings.isEmpty
                ? const Center(
                    child: Text(
                      "No moves saved yet.\nBuild your move on the left and save it here!",
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  )
                : LayoutBuilder(builder: (context, constraints) {
                    final panelInnerWidth = constraints.maxWidth;
                    const actionWidth = 48.0;
                    final availableForIcons = max(80.0, panelInnerWidth - actionWidth - 12.0);
                    // taille de base, max 40px par icône
                    const baseIcon = 40.0;
                    const baseSpacing = 8.0;
                    final maxLen = savedStrings.map((s) => s.length).fold<int>(1, (p, c) => max(p, c));
                    final baseNeeded = maxLen * baseIcon + max(0, maxLen - 1) * baseSpacing;
                    final scale = min(1.0, availableForIcons / baseNeeded);
                    final iconSize = (baseIcon * scale).clamp(16.0, baseIcon);
                    final spacing = baseSpacing * scale;

                    return ListView.builder(
                      itemCount: savedStrings.length,
                      itemBuilder: (context, index) {
                        final string = savedStrings[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: string.asMap().entries.map((entry) {
                                    final data = inputs.firstWhere(
                                      (e) => e.code == entry.value,
                                      orElse: () => InputData(entry.value, "-"),
                                    );
                                    return Padding(
                                      padding: EdgeInsets.only(right: entry.key == string.length - 1 ? 0 : spacing),
                                      child: SizedBox(
                                        width: iconSize,
                                        height: iconSize,
                                        child: data.assetPath == "-"
                                            ? Center(
                                                child: Text(
                                                  data.code,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                ),
                                              )
                                            : Image.asset(
                                                data.assetPath,
                                                fit: BoxFit.contain,
                                                width: iconSize,
                                                height: iconSize,
                                              ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete move',
                                onPressed: () async {
                                    await onDelete(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }
}
