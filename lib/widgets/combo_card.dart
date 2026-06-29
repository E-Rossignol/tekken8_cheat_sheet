import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/constants/helper.dart';
import 'package:tekken_cheat_sheet/widgets/inputs_chip.dart';

import 'my_icons.dart';

class ComboCard extends StatefulWidget {
  final Map<String, dynamic> combo;
  const ComboCard({super.key, required this.combo});

  @override
  State<ComboCard> createState() => _ComboCardState();
}

class _ComboCardState extends State<ComboCard> {
  @override
  Widget build(BuildContext context) {
    final inputs = (widget.combo['inputs'] ?? '') as String;
    final launchers =
        (widget.combo['launchers'] as List?)?.cast<Map<String, dynamic>>() ??
        [];
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header : inputs du combo
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Helper().pathFromInputs(inputs).map((path) {
                      return Image.asset(
                        path,
                        fit: BoxFit.cover,
                        height: 30,
                        errorBuilder: (_, __, ___) => Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              path
                                  .split('/')
                                  .last
                                  .split('.')
                                  .first
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Combo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // launchers list : chips lisibles
            if (launchers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'No launchers',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: launchers.map((l) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LauncherIcon(size: Size(50, 50)),
                        InputsChip(inputs: l['inputs'] as String, size: 25),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
