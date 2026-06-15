import 'package:flutter/material.dart';

import '../models/input_data.dart';
import '../views/main_views/cheat_sheet_view.dart';

/// Panel used to display saved moves, punishes or stance moves depending on pageType.
/// Supports optional savedFrames (punishes) or savedStances (stances) metadata per entry.
class KeyMovesPunishStanceSavedPanel extends StatefulWidget {
  /// Saved move strings; each entry is a list of token codes.
  final List<List<String>> savedStrings;

  /// Master inputs list mapping code->asset.
  final List<InputData> inputs;

  /// Callback invoked to delete a saved entry by index.
  final Future<void> Function(int) onDelete;

  /// Accent color used in the panel for icons/highlights.
  final Color accent;

  /// Optional frames per saved entry (punishes view).
  final List<int>? savedFrames;

  /// Optional stance per saved entry (stances view).
  final List<String>? savedStances;

  /// Character name scope used for navigation to detailed cheat sheet.
  final String characterName;

  /// Page type hint: 0=key moves,1=punishes,2=combos,3=stances (used for behavior/labels).
  final int pageType;

  const KeyMovesPunishStanceSavedPanel({
    super.key,
    required this.savedStrings,
    required this.inputs,
    required this.onDelete,
    required this.accent,
    this.savedStances,
    required this.characterName,
    required this.pageType,
    this.savedFrames,
  });

  @override
  State<KeyMovesPunishStanceSavedPanel> createState() =>
      _KeyMovesPunishStanceSavedPanelState();
}

class _KeyMovesPunishStanceSavedPanelState extends State<KeyMovesPunishStanceSavedPanel> {
  @override
  Widget build(BuildContext context) {
    late String title;
    switch (widget.pageType) {
      case 0:
        title = "SAVED MOVES";
        break;
      case 1:
        title = "SAVED PUNISHES";
        break;
      default:
        title = "SAVED MOVES";
    }
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: widget.accent),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheatSheetView(
                        characterName: widget.characterName,
                        index: widget.pageType,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.savedStrings.isEmpty
                ? Center(
                    child: Text(
                      "Aucun",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.savedStrings.length,
                    itemBuilder: (context, index) {
                      final string = widget.savedStrings[index];
                      final frames =
                          (widget.savedFrames != null &&
                              widget.savedFrames!.length > index)
                          ? widget.savedFrames![index]
                          : null;
                      final stance =
                          (widget.savedStances != null &&
                              widget.savedStances!.length > index)
                          ? widget.savedStances![index]
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
                            // icônes du string -> remplaçé par un LayoutBuilder qui bascule sur 1 ou 2 lignes
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // estimation largeur nécessaire
                                  final int count = string.length;
                                  final double totalWidth =
                                      count * (iconSize + spacing) - spacing;
                                  // réserver de la place pour la zone métadonnée (frames ou stance) + bouton delete
                                  final double metaReserved = (frames != null
                                      ? 64.0
                                      : (stance != null ? 84.0 : 0.0));
                                  final double reserved = metaReserved + 48.0;
                                  // si ça tient -> une ligne scrollable
                                  if (totalWidth <=
                                      constraints.maxWidth - reserved) {
                                    return SizedBox(
                                      height: iconSize + 8,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: string.asMap().entries.map((
                                            entry,
                                          ) {
                                            final code = entry.value;
                                            final data = widget.inputs
                                                .firstWhere(
                                                  (e) => e.code == code,
                                                  orElse: () =>
                                                      InputData(code, '-'),
                                                );
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                right:
                                                    entry.key ==
                                                        string.length - 1
                                                    ? 0
                                                    : spacing,
                                              ),
                                              child: SizedBox(
                                                width: iconSize,
                                                height: iconSize,
                                                child: data.assetPath == '-'
                                                    ? Center(
                                                        child: Text(
                                                          data.code,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 12,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        data.assetPath,
                                                        fit: BoxFit.contain,
                                                      ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }

                                  // sinon : afficher sur deux lignes via Wrap ; hauteur limitée à 2 lignes
                                  const double twoLineHeight = (32 + 8) * 2;
                                  return SizedBox(
                                    height: twoLineHeight,
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: spacing,
                                        runSpacing: 8,
                                        children: string.map((code) {
                                          final data = widget.inputs.firstWhere(
                                            (e) => e.code == code,
                                            orElse: () => InputData(code, '-'),
                                          );

                                          return SizedBox(
                                            width: iconSize,
                                            height: iconSize,
                                            child: data.assetPath == '-'
                                                ? Center(
                                                    child: Text(
                                                      data.code,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    data.assetPath,
                                                    fit: BoxFit.contain,
                                                  ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // si frames ou stance présent(e), l'afficher(-e) (priorité frames si présent)
                            if (frames != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$frames',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (stance != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    stance,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // bouton supprimer
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Supprimer',
                              onPressed: () async {
                                await widget.onDelete(index);
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
