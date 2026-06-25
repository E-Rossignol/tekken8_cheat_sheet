import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';

import '../../models/page_type_model.dart';

class DefaultDBView extends StatelessWidget {
  final String value;

  const DefaultDBView({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: customAppBar(PageType.home, null, context),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SelectableText(value, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
