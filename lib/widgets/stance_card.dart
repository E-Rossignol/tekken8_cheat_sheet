import 'package:flutter/material.dart';

import 'inputs_chip.dart';
import 'meta_chip.dart';
import 'my_icons.dart';

class StanceCard extends StatefulWidget {
  final Map<String, dynamic> row;
  const StanceCard({super.key, required this.row});

  @override
  State<StanceCard> createState() => _StanceCardState();
}

class _StanceCardState extends State<StanceCard> {
  @override
  Widget build(BuildContext context) {
    final stanceNames = widget.row['stance']?.toString() ?? '';
    final inputs = (widget.row['inputs'] ?? '') as String;
    final frames = widget.row['frames']?.toString();
    final onHit = widget.row['onHit']?.toString();
    final onBlock = widget.row['onBlock']?.toString();
    final remark = widget.row['remark'] as String?;
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MetaChip(
                  label: 'Stance',
                  value: stanceNames,
                  icon: StanceIcon(size: Size(30, 20)),
                ),
                const SizedBox(width: 12),
                Expanded(child: InputsChip(inputs: inputs)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (remark != null && remark.isNotEmpty) ? remark : '',
              style: const TextStyle(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (frames != null)
                  MetaChip(
                    label: 'Frames',
                    value: frames,
                    icon: FrameIcon(size: Size(20, 20)),
                  ),
                if (onHit != null) ...[
                  const SizedBox(width: 8),
                  MetaChip(
                    label: 'Hit',
                    value: onHit,
                    icon: OnHitIcon(size: Size(20, 20)),
                  ),
                ],
                if (onBlock != null) ...[
                  const SizedBox(width: 8),
                  MetaChip(
                    label: 'Block',
                    value: onBlock,
                    icon: OnBlockIcon(size: Size(20, 20)),
                  ),
                ],
                const Spacer(),
                // remark previously shown as tooltip; removed because remark is now rendered below inputs
              ],
            ),
          ],
        ),
      ),
    );
  }
}
