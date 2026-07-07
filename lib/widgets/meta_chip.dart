import 'package:flutter/material.dart';

class MetaChip extends StatefulWidget {
  final String label;
  final String value;
  final Widget icon;
  const MetaChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  State<MetaChip> createState() => _MetaChipState();
}

class _MetaChipState extends State<MetaChip> {
  @override
  Widget build(BuildContext context) {
    String value = widget.value;
    widget.label != "Frames" && widget.label != "Stance"
        ? ((int.parse(value) > 0 ? value = "+$value" : value = value))
        : value = value;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          widget.icon,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white54, fontSize: 6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
