import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';

class InputGrid extends StatelessWidget {
  final List<InputData> inputs;
  final void Function(String) onInputTap;
  final Color accent;

  const InputGrid({
    super.key,
    required this.inputs,
    required this.onInputTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        // Expanded attendu par le parent ; si parent ne fournit pas de contrainte,
        // GridView sera contenu par son parent. Ici on fournit Expanded dans l'usage.
        Expanded(
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(6),
            itemCount: inputs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final item = inputs[index];
              if (item.assetPath == "-") {
                return InkWell(
                  mouseCursor: SystemMouseCursors.cell,
                  onTap: () => onInputTap(item.code),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.code,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () => onInputTap(item.code),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.01),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      item.assetPath,
                      fit: BoxFit.contain,
                      width: 40, // ne dépasse jamais 40x40
                      height: 40,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
