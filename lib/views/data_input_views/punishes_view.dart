import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../services/db_provider.dart';
import '../../widgets/key_moves_punish_stance_saved_panel.dart';

/// PunishesView: manage punish strings associated with a frame value.
/// There is UI logic to keep one punish per frame value.
class PunishesView extends StatefulWidget {
  /// Character scope for punish entries.
  final String characterName;

  const PunishesView({super.key, required this.characterName});

  @override
  State<PunishesView> createState() => _PunishesViewState();
}

class _PunishesViewState extends State<PunishesView> {
  /// Current composition inputs for a punish.
  final List<String> currentInputs = [];

  /// Saved punishes as lists of input codes.
  final List<List<String>> savedStrings = [];

  /// Saved frames value associated to each savedStrings entry.
  final List<int> savedFrames = [];

  /// Local list of stance tokens added to inputs for display (not used for punishes).
  List<String> stances = [];

  /// Selected frames value for the next saved punish.
  int _selectedFrames = 10;

  /// Master input definitions and tokens.
  List<InputData> inputs = Helper().inputs;

  /// Allowed frames values for quick selection.
  static const List<int> _allowedFrames = [10, 11, 12, 13, 14, 15, 16];

  @override
  void initState() {
    super.initState();
    stances = Helper().stancesList
        .where(
          (s) =>
              s['characterName'] == widget.characterName.replaceAll(' ', '-'),
        )
        .map((s) => s['name'] as String)
        .toList();
    inputs.addAll(stances.map((s) => InputData(s, "-")));
    stances.add('SS');
    stances.add('WS');
    stances.add('FC');
    initPunishes();
  }

  /// Load punishes for the character and compute a sensible default frames selection.
  /// @return Future<void>
  Future<void> initPunishes() async {
    final db = DBProvider.instance;
    final res = await db.getPunishesForCharacter(widget.characterName);
    for (var row in res) {
      final inputsStr = (row['inputs'] ?? '') as String;
      final frames = (row['frames'] is int)
          ? row['frames'] as int
          : int.tryParse('${row['frames']}') ?? 10;
      List<String> moveList = inputsStr.split('/');
      setState(() {
        savedStrings.add(moveList);
        savedFrames.add(frames);
      });
    }
    // compute an available frame value to preselect for new punish entries
    final used = savedFrames.toSet();
    final firstAvailable = _allowedFrames.firstWhere(
      (v) => !used.contains(v),
      orElse: () => _allowedFrames.first,
    );
    if (used.contains(_selectedFrames) && firstAvailable != _selectedFrames) {
      setState(() {
        _selectedFrames = firstAvailable;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Append an input code to the current composition.
  void addInput(String input) {
    setState(() {
      currentInputs.add(input);
    });
  }

  /// Remove the last composed input token.
  void removeLastInput() {
    if (currentInputs.isEmpty) return;
    setState(() {
      currentInputs.removeLast();
    });
  }

  /// Clear the current composition list.
  void clearInputs() {
    setState(() {
      currentInputs.clear();
    });
  }

  /// Save selected punish immediately to DB and update UI.
  /// This enforces the one-per-frames constraint in the UI.
  /// @return Future<void>
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;

    if (!_allowedFrames.contains(_selectedFrames)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valeur de frames invalide'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (savedFrames.contains(_selectedFrames)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cette valeur de frames est déjà utilisée. Supprimez d\'abord l\'ancien punish pour la réutiliser.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final db = DBProvider.instance;
    final moveJoined = currentInputs.join('/');

    try {
      await db.insertPunish(widget.characterName, moveJoined, _selectedFrames);
      setState(() {
        savedStrings.add(List<String>.from(currentInputs));
        savedFrames.add(_selectedFrames);
        currentInputs.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Punish saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving punish'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Confirm then delete a saved punish.
  /// @param index index in savedStrings to delete
  /// @return Future<void>
  Future<void> _deleteSavedString(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete punish?'),
        content: const Text(
          'Are you sure you want to delete this punish? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final inputsStr = savedStrings[index].join('/');
      final frames = savedFrames[index];
      try {
        final res = await DBProvider.instance.deletePunish(
          widget.characterName,
          inputsStr,
          frames,
        );
        if (res) {
          setState(() {
            savedStrings.removeAt(index);
            savedFrames.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Punish deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No row deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting punish'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget buildCurrentString() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 11, 32, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final entries = currentInputs.asMap().entries.toList();
                    double totalWidth = 0.0;
                    final List<Widget> iconWidgets = entries.map((entry) {
                      final data = inputs.firstWhere(
                        (e) => e.code == entry.value,
                        orElse: () => InputData(entry.value, "-"),
                      );
                      final double w = 40.0;
                      totalWidth += w + 8;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: w,
                          height: 40,
                          child: data.assetPath == "-"
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.code,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  data.assetPath,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      );
                    }).toList();

                    if (totalWidth <= constraints.maxWidth) {
                      return SizedBox(
                        height: 56,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: iconWidgets,
                          ),
                        ),
                      );
                    }

                    const double twoLineHeight = 40 * 2 + 12;
                    return SizedBox(
                      height: twoLineHeight,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: iconWidgets,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 39, 115, 1.0),
                      Color.fromRGBO(0, 19, 56, 1.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Save',
                      child: IconButton(
                        onPressed: saveString,
                        icon: const Icon(Icons.save, color: Colors.greenAccent),
                      ),
                    ),
                    Tooltip(
                      message: 'Remove last',
                      child: IconButton(
                        onPressed: removeLastInput,
                        icon: const Icon(
                          Icons.backspace,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Clear',
                      child: IconButton(
                        onPressed: clearInputs,
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            const Text('Frames:', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedFrames,
                  dropdownColor: const Color(0xFF11121A),
                  items: _allowedFrames.map((v) {
                    final used = savedFrames.contains(v);
                    return DropdownMenuItem<int>(
                      value: v,
                      enabled: !used,
                      child: Tooltip(
                        message: used ? 'Delete other punish first' : '',
                        child: Text(
                          '$v',
                          style: TextStyle(
                            color: used ? Colors.white24 : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    if (savedFrames.contains(v)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This value of frames is already used. Delete the existing punish first to reuse it.',
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _selectedFrames = v;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSavedRow(int index, double iconSize, double spacing) {
    final string = savedStrings[index];
    final frames = savedFrames[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF23232D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: string.asMap().entries.map((entry) {
                final data = inputs.firstWhere((e) => e.code == entry.value);
                return Padding(
                  padding: EdgeInsets.only(
                    right: entry.key == string.length - 1 ? 0 : spacing,
                  ),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Image.asset(data.assetPath, fit: BoxFit.contain),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              '$frames',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete punish',
            onPressed: () => _deleteSavedString(index),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final accent = const Color.fromRGBO(93, 208, 252, 1);
    return Scaffold(
      appBar: customAppBar(PageType.punish, widget.characterName, context),
      backgroundColor: const Color.fromRGBO(5, 11, 32, 1),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCurrentString(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                SizedBox(
                  width: 260,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: InputGrid(
                      inputs: inputs,
                      onInputTap: addInput,
                      accent: accent,
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                SizedBox(
                  width: 380,
                  child: KeyMovesPunishStanceSavedPanel(
                    characterName: widget.characterName,
                    savedStrings: savedStrings,
                    inputs: inputs,
                    savedFrames: savedFrames,
                    onDelete: _deleteSavedString,
                    accent: accent,
                    pageType: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
