import 'package:flutter/material.dart';

import '../constants/helper.dart';

class InputsChip extends StatefulWidget {
  final double size;
  final String inputs;
  const InputsChip({super.key, required this.inputs, this.size = 30});

  @override
  State<InputsChip> createState() => _InputsChipState();
}

class _InputsChipState extends State<InputsChip> {
  @override
  Widget build(BuildContext context) {
    /// Render a horizontal collection of input icons for a given inputs string.
    /// @param inputs slash-separated string
    /// @param size icon size in px
    /// @return Widget row/wrap of icons
    final parts = Helper().pathFromInputs(widget.inputs);
    final spacing = widget.size / 5;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: parts.asMap().entries.map((entry) {
          final p = entry.value;
          final isLast = entry.key == parts.length - 1;
          return Row(
            children: [
              Image.asset(
                p,
                fit: BoxFit.cover,
                height: widget.size,
                errorBuilder: (_, __, ___) => Container(
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      p.split('/').last.split('.').first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isLast) SizedBox(width: spacing),
            ],
          );
        }).toList(),
      ),
    );
  }
}
