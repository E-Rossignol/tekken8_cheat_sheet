import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/services/db_provider.dart';

import '../../models/page_type_model.dart';
import '../../widgets/custom_appbar.dart';

class ExportDbView extends StatefulWidget {
  const ExportDbView({super.key, required this.myCharacters});

  final List<String> myCharacters;

  @override
  State<ExportDbView> createState() => _ExportDbViewState();
}

class _ExportDbViewState extends State<ExportDbView> {
  final List<String> _selectedCharacters = [];
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: customAppBar(PageType.defaultDB, null, context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.myCharacters.length,
                      itemBuilder: (context, index) {
                        final name = widget.myCharacters[index];
                        final isSelected = _selectedCharacters.contains(name);
                        return Card(
                          color: Colors.white10,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  if (!_selectedCharacters.contains(name)) {
                                    _selectedCharacters.add(name);
                                  }
                                } else {
                                  _selectedCharacters.remove(name);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isWriting
                        ? null
                        : () async {
                            if (_selectedCharacters.isEmpty) return;
                            setState(() => _isWriting = true);
                            try {
                              _selectedCharacters.sort();
                              List<String> tmp = _selectedCharacters
                                  .map((c) => c.toLowerCase())
                                  .toList();
                              await DBProvider.instance.writeDefaultDB(tmp);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Export réussi'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isWriting = false);
                            }
                          },
                    child: const Text(
                      'Validate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_isWriting)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Veuillez patienter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
