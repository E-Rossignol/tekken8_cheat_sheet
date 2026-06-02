import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/views/main_views/db_browser_view.dart';

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

  void _openHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text(''
        '-> On this page, you can enter and save your favourite combos.\n'
        '-> On the left side, you can record and save the combo (NO LAUNCHER NEEDED).\n'
        '-> On the right side, you can manage your saved combos and link them to launchers for quick access.\n'
            '          - Each combo displays its inputs as icons. Below, you can see and manage its launchers.\n'
          '          - To add a launcher, click the "+ Add launcher" button and select from your saved launchers.\n'
          '          - To delete a launcher, click the red "X" on its chip.\n'
          '          - To delete an entire combo, click the trash icon on the right.',
        style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
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
                    const Text('SAVED COMBOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.info_outline, color: Colors.white), tooltip: 'How to use this panel')
                  ],
                )),
                IconButton(
                  icon: Icon(Icons.open_in_new, color: widget.accent),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DBBrowserView(characterName: widget.characterName, index: 2)));
                  },
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(child: Text('Aucun combo', style: TextStyle(color: Colors.white54))),
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
                    const Text('SAVED COMBOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: _openHelpDialog, icon: const Icon(Icons.info_outline, color: Colors.white), tooltip: 'How to use this panel')
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new, color: widget.accent),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DBBrowserView(characterName: widget.characterName, index: 2)));
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
                final launchers = (combo['launchers'] as List).cast<Map<String, dynamic>>();
                const double iconSize = 32;
                const double spacing = 6.0;

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23232D),
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
                                final data = widget.inputs.firstWhere((e) => e.code == code, orElse: () => InputData(code, '-'));
                                return SizedBox(
                                  width: iconSize,
                                  height: iconSize,
                                  child: data.assetPath == '-' ? Center(child: Text(data.code, style: const TextStyle(color: Colors.white70, fontSize: 12))) : Image.asset(data.assetPath, fit: BoxFit.contain),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            // launchers as chips + add button
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...launchers.map((l) {
                                  return Chip(
                                    backgroundColor: bg,
                                    label: Text((l['inputs'] as String).replaceAll('/', ''), style: const TextStyle(color: Colors.white70)),
                                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                    onDeleted: () => widget.onDeleteLauncher(index, l['id'] as int),
                                  );
                                }),
                                ActionChip(
                                  label: const Text('+ Add launcher', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFF232D4F),
                                  onPressed: () => widget.onAddLauncher(combo['id'] as int),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
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
