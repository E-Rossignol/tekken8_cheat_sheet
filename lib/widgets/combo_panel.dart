import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/views/main_views/cheat_sheet_view.dart';

class ComboPanel extends StatefulWidget {
  final List<Map<String, dynamic>> combos;
  final List<InputData> inputs;
  final Color accent;
  final String characterName;
  final Future<void> Function(int index) onDeleteCombo;
  final Future<void> Function(int comboIndex, int launcherId) onDeleteLauncher;
  final Future<void> Function(int comboId) onAddLauncher;

  const ComboPanel({
    super.key,
    required this.combos,
    required this.inputs,
    required this.accent,
    required this.characterName,
    required this.onDeleteCombo,
    required this.onDeleteLauncher,
    required this.onAddLauncher,
  });

  @override
  State<ComboPanel> createState() => _ComboPanelState();
}

class _ComboPanelState extends State<ComboPanel> {
  Color bg = const Color(0xFF0E1220);

  @override
  Widget build(BuildContext context) {
    if (widget.combos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'SAVED COMBOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.open_in_new, color: widget.accent),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheatSheetView(
                          characterName: widget.characterName,
                          index: 2,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Text(
                  'Aucun combo',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      );
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
          // header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'SAVED COMBOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: widget.accent),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheatSheetView(
                        characterName: widget.characterName,
                        index: 2,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: widget.combos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final combo = widget.combos[index];
                final inputsStr = (combo['inputs'] ?? '') as String;
                final launchers = (combo['launchers'] as List)
                    .cast<Map<String, dynamic>>();
                const double iconSize = 32;
                const double spacing = 6.0;
                List<Widget> launchersInputs = [];
                for (var l in launchers) {
                  final lInputs = (l['inputs'] as String).split('/');
                  var tmpWidgets = <Widget>[];
                  for (var code in lInputs) {
                    tmpWidgets.add(
                      Helper().stancesList
                              .where(
                                (s) =>
                                    s['characterName'] == widget.characterName,
                              )
                              .toList()
                              .map((e) => e['name'] as String)
                              .toList()
                              .contains(code)
                          ? Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Image.asset(
                              'assets/images/inputs/$code.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                    );
                  }
                  launchersInputs.add(
                    Chip(
                      backgroundColor: Color.fromRGBO(1, 28, 115, 1.0),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: tmpWidgets,
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      deleteButtonTooltipMessage: 'Delete launcher',
                      onDeleted: () =>
                          widget.onDeleteLauncher(index, l['id'] as int),
                    ),
                  );
                }
                launchersInputs.add(
                  ActionChip(
                    label: const Text(
                      '+ Add launcher',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Color.fromRGBO(1, 28, 115, 1.0),
                    onPressed: () => widget.onAddLauncher(combo['id'] as int),
                  ),
                );
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(5, 11, 32, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // inputs as small chips/icons (wrap)
                            Wrap(
                              spacing: spacing,
                              runSpacing: 8,
                              children: inputsStr.split('/').map((code) {
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
                                          ),
                                        )
                                      : Image.asset(
                                          data.assetPath,
                                          fit: BoxFit.contain,
                                        ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            // launchers as chips + add button
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: launchersInputs,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Delete combo',
                            onPressed: () => widget.onDeleteCombo(index),
                          ),
                        ],
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
