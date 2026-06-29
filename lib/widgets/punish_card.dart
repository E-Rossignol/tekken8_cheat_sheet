import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/meta_chip.dart';
import 'package:tekken_cheat_sheet/widgets/my_icons.dart';

import 'inputs_chip.dart';

class PunishCard extends StatefulWidget {
  final Map<String, dynamic> row;
  const PunishCard({super.key, required this.row});

  @override
  State<PunishCard> createState() => _PunishCardState();
}

class _PunishCardState extends State<PunishCard> {
  @override
  Widget build(BuildContext context) {
    final inputs = (widget.row['inputs'] ?? '') as String;
    final frames = widget.row['frames']?.toString() ?? '';
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: InputsChip(inputs: inputs)),
            const SizedBox(width: 12),
            MetaChip(
              label: 'Frames',
              value: frames,
              icon: FrameIcon(size: Size(30, 20)),
            ),
          ],
        ),
      ),
    );
  }
}
