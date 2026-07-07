import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import 'package:tekken_cheat_sheet/widgets/custom_number_field.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../services/db_provider.dart';
import '../../widgets/key_moves_punish_stance_saved_panel.dart';

/// Screen to record stance-specific moves for a character.
/// Shows an input grid, current composition area, metadata fields and a saved moves panel.
class StancesView extends StatefulWidget {
  /// Character identifier used to scope DB queries and display.
  final String characterName;

  const StancesView({super.key, required this.characterName});

  @override
  State<StancesView> createState() => _StancesViewState();
}

class _StancesViewState extends State<StancesView> {
  /// Currently composed inputs (codes) in order, used to render current string.
  final List<String> currentInputs = [];

  /// Saved moves for this character, each entry is a list of input codes.
  final List<List<String>> savedStrings = [];

  /// For each savedStrings entry, the stance name associated to the saved move.
  List<String> savedStances = [];

  /// For each savedStrings entry, optional remark text.
  List<String?> savedRemarks = [];

  /// Local list of stance names available for this character (populates dropdown).
  List<String> stances = [];

  /// Currently selected stance in the UI for new saves.
  String _selectedStance = "";

  /// Master list of InputData mapping codes to assets; extended with stance tokens.
  List<InputData> inputs = Helper().inputs;

  /// Allowed stance values (same as stances but kept explicit for readability).
  final List<String> _allowedStances = [];

  /// Controller for frames numeric field (optional metadata).
  final TextEditingController _framesController = TextEditingController();

  /// Controller for onHit numeric field (optional metadata).
  final TextEditingController _onHitController = TextEditingController();

  /// Controller for onBlock numeric field (optional metadata).
  final TextEditingController _onBlockController = TextEditingController();

  /// Controller for optional remark text.
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    stances = Helper().stancesList
        .where(
          (s) =>
              s['characterName'] ==
              widget.characterName.replaceAll(' ', '-').toLowerCase(),
        )
        .map((s) => s['name'] as String)
        .toList();
    inputs.addAll(stances.map((s) => InputData(s, "-")));
    stances.add('SS');
    stances.add('WS');
    stances.add('FC');
    _selectedStance = stances.isNotEmpty ? stances[0] : '';
    _allowedStances.addAll(stances);
    initStanceMoves();
  }

  /// Load stance moves for the character from DB and populate local lists.
  /// @return Future<void> when loading completes.
  Future<void> initStanceMoves() async {
    final res = await DBProvider.instance.getStanceMovesForCharacter(
      widget.characterName,
    );
    for (var row in res) {
      // inputs stored as slash-separated string in DB -> split to list for UI rendering
      final inputsStr = (row['inputs'] ?? '') as String;
      // stance may be missing in older rows; fallback to first allowed stance if available
      final stanceStr = row['stance'] is String
          ? row['stance'] as String
          : (_allowedStances.isNotEmpty ? _allowedStances.first : '');
      final remarkStr = row['remark'] is String
          ? row['remark'] as String
          : null;
      List<String> moveList = inputsStr.split('/');
      setState(() {
        savedStrings.add(moveList);
        savedStances.add(stanceStr);
        savedRemarks.add(remarkStr);
      });
    }
  }

  @override
  void dispose() {
    _framesController.dispose();
    _onHitController.dispose();
    _onBlockController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  /// Add a single input code to the current composition.
  /// @param input code string to append.
  void addInput(String input) {
    setState(() {
      currentInputs.add(input);
    });
  }

  /// Remove the last input from the current composition.
  void removeLastInput() {
    if (currentInputs.isEmpty) return;
    setState(() {
      currentInputs.removeLast();
    });
  }

  /// Clear all inputs in the current composition.
  void clearInputs() {
    setState(() {
      currentInputs.clear();
    });
  }

  /// Persist the composed move together with the selected stance and optional metadata.
  /// @return Future<void> completes after DB operation and UI update.
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;
    if (!_allowedStances.contains(_selectedStance)) {
      // UX: inform user why save failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid stance value'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // prepare metadata to persist
    final moveJoined = currentInputs.join('/');
    final frames = int.tryParse(_framesController.text.trim());
    final onHit = int.tryParse(_onHitController.text.trim());
    final onBlock = int.tryParse(_onBlockController.text.trim());
    final remark = _remarkController.text.trim().isEmpty
        ? null
        : _remarkController.text.trim();
    try {
      // insert into DB and return row id / -1 on duplicate
      final int res = await DBProvider.instance.insertStanceMove(
        widget.characterName,
        moveJoined,
        _selectedStance,
        frames: frames,
        onHit: onHit,
        onBlock: onBlock,
        remark: remark,
      );
      if (res == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This stance move already exists'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        savedStrings.add(List<String>.from(currentInputs));
        savedStances.add(_selectedStance);
        savedRemarks.add(remark);
        currentInputs.clear();
        _remarkController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stance move saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // log / notify on unexpected error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving stance move'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Prompt user for confirmation then delete the saved stance move from DB and UI.
  /// @param index position in savedStrings to delete
  /// @return Future<void>
  Future<void> _deleteSavedString(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete stance move?'),
        content: const Text(
          'Are you sure you want to delete this stance move? This action cannot be undone.',
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
      final stanceForRow = savedStances[index];
      try {
        final res = await DBProvider.instance.deleteStanceMove(
          widget.characterName,
          inputsStr,
          stanceForRow,
        );
        if (res) {
          setState(() {
            savedStrings.removeAt(index);
            savedStances.removeAt(index);
            savedRemarks.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stance move deleted'),
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
            content: Text('Error deleting stance move'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Builds the UI block that displays the current composed move and action buttons.
  /// @return Widget the composed-area widget.
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

        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 11, 32, 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _remarkController,
            style: const TextStyle(color: Colors.white70),
            decoration: const InputDecoration(
              hintText: 'Remark (optional)',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            const Text('Stance:', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStance,
                  dropdownColor: const Color(0xFF11121A),
                  items: _allowedStances.map((v) {
                    return DropdownMenuItem<String>(
                      value: v,
                      child: Text(
                        v,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _selectedStance = v;
                    });
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomNumberField(label: 'Frames', controller: _framesController),
            const SizedBox(height: 8),
            CustomNumberField(label: 'On Hit', controller: _onHitController),
            const SizedBox(height: 8),
            CustomNumberField(
              label: 'On Block',
              controller: _onBlockController,
            ),
          ],
        ),
      ],
    );
  }

  /// Render one saved row showing inputs, stance badge and optional remark.
  /// @param index index of saved move
  /// @param iconSize size used for input icons
  /// @param spacing spacing between icons
  Widget buildSavedRow(int index, double iconSize, double spacing) {
    final string = savedStrings[index];
    final stance = savedStances[index];
    final remark = savedRemarks[index];
    final rowCard = Container(
      margin: const EdgeInsets.only(bottom: 6),
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stance,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete stance move',
            onPressed: () => _deleteSavedString(index),
          ),
        ],
      ),
    );

    if (remark == null || remark.isEmpty) {
      return rowCard;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowCard,
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            remark,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
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
      appBar: customAppBar(PageType.stanceMoves, widget.characterName, context),
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
                    savedStances: savedStances,
                    onDelete: _deleteSavedString,
                    accent: accent,
                    pageType: 3,
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
