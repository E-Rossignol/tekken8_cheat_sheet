import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/meta_chip.dart';

import 'inputs_chip.dart';
import 'my_icons.dart';

class KeyMoveCard extends StatefulWidget {
  final Map<String, dynamic> keyMove;
  const KeyMoveCard({super.key, required this.keyMove});

  @override
  State<KeyMoveCard> createState() => _KeyMoveCardState();
}

class _KeyMoveCardState extends State<KeyMoveCard> {
  @override
  Widget build(BuildContext context) {
    final inputs = (widget.keyMove['inputs'] ?? '') as String;
    final frames = widget.keyMove['frames']?.toString();
    final onHit = widget.keyMove['onHit']?.toString();
    final onBlock = widget.keyMove['onBlock']?.toString();
    final remark = widget.keyMove['remark'] as String?;
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // big inputs line
              InputsChip(inputs: inputs),
              const SizedBox(height: 8),
              // remark displayed under inputs, small & italic (or "No remark")
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
