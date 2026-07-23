import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import 'package:tekken_cheat_sheet/widgets/custom_number_field.dart';
import 'package:tekken_cheat_sheet/widgets/key_moves_punish_stance_saved_panel.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../models/page_type_model.dart';
import '../../services/db_provider.dart';

/// KeyMovesView: record and manage key moves for a character.
/// Each saved move stores optional frames/onHit/onBlock/remark metadata.
class KeyMovesView extends StatefulWidget {
  /// Character for which key moves are managed.
  final String characterName;

  const KeyMovesView({super.key, required this.characterName});

  @override
  State<KeyMovesView> createState() => _KeyMovesViewState();
}

class _KeyMovesViewState extends State<KeyMovesView> {
  /// Current composition of inputs.
  final List<String> currentInputs = [];

  /// Saved moves as lists of input codes.
  final List<List<String>> savedStrings = [];

  /// Optional frames metadata for each saved move.
  final List<int?> savedFrames = [];

  /// Optional onHit metadata for each saved move.
  final List<int?> savedOnHit = [];

  /// Optional onBlock metadata for each saved move.
  final List<int?> savedOnBlock = [];

  /// Optional remark metadata for each saved move.
  final List<String?> savedRemarks = [];

  /// Master inputs list (icons + codes).
  List<InputData> inputs = Helper().inputs;

  /// Local stance tokens appended to inputs.
  List<String> stances = [];

  final TextEditingController _framesController = TextEditingController();
  final TextEditingController _onHitController = TextEditingController();
  final TextEditingController _onBlockController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

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
    initSavedMoves();
  }

  /// Load key moves for the character; convert DB row types safely.
  /// @return Future<void>
  Future<void> initSavedMoves() async {
    final db = DBProvider.instance;
    final res = await db.getKeyMovesForCharacter(widget.characterName);
    for (var row in res) {
      final inputsStr = (row['inputs'] ?? '') as String;
      final frames = (row['frames'] is int)
          ? row['frames'] as int
          : (row['frames'] == null ? null : int.tryParse('${row['frames']}'));
      final onHit = (row['onHit'] is int)
          ? row['onHit'] as int
          : (row['onHit'] == null ? null : int.tryParse('${row['onHit']}'));
      final onBlock = (row['onBlock'] is int)
          ? row['onBlock'] as int
          : (row['onBlock'] == null ? null : int.tryParse('${row['onBlock']}'));
      final remark = row['remark'] is String ? row['remark'] as String : null;
      List<String> moveList = inputsStr.split('/');
      setState(() {
        savedStrings.add(moveList);
        savedFrames.add(frames);
        savedOnHit.add(onHit);
        savedOnBlock.add(onBlock);
        savedRemarks.add(remark);
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

  /// Append an input code to the current composition.
  /// @param input token code
  void addInput(String input) {
    setState(() {
      currentInputs.add(input);
    });
  }

  /// Remove last token from composition.
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

  /// Insert a key move and its optional metadata into DB.
  /// Returns: Future<void> completing after DB write and UI update.
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;
    final db = DBProvider.instance;
    final moveJoined = currentInputs.join('/');

    final frames = int.tryParse(_framesController.text.trim());
    final onHit = int.tryParse(_onHitController.text.trim());
    final onBlock = int.tryParse(_onBlockController.text.trim());
    final remark = _remarkController.text.trim().isEmpty
        ? null
        : _remarkController.text.trim();

    try {
      final res = await db.insertKeyMove(
        widget.characterName,
        moveJoined,
        frames: frames,
        onHit: onHit,
        onBlock: onBlock,
        remark: remark,
      );
      if (res > 0) {
        setState(() {
          savedStrings.add(List<String>.from(currentInputs));
          savedFrames.add(frames);
          savedOnHit.add(onHit);
          savedOnBlock.add(onBlock);
          savedRemarks.add(remark);
          currentInputs.clear();
          _framesController.clear();
          _onHitController.clear();
          _onBlockController.clear();
          _remarkController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Move saved'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (res == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Move already exists'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving move'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving move'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editSavedString(int index) async {
    currentInputs.clear();
    currentInputs.addAll(savedStrings[index]);
    _framesController.text = savedFrames[index]?.toString() ?? '';
    _onHitController.text = savedOnHit[index]?.toString() ?? '';
    _onBlockController.text = savedOnBlock[index]?.toString() ?? '';
    _remarkController.text = savedRemarks[index] ?? '';
    await _deleteSavedString(index, isEditing: true);
    setState(() {});
  }

  /// Confirm and remove a saved move from DB and UI.
  /// @param index index in savedStrings
  /// @return Future<void>
  Future<void> _deleteSavedString(int index, {bool isEditing = false}) async {
    final ok = !isEditing
        ? await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete move?'),
              content: const Text(
                'Are you sure you want to delete this move? This action cannot be undone.',
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
          )
        : true;
    if (ok == true) {
      var res = await DBProvider.instance.deleteKeyMove(
        widget.characterName,
        savedStrings[index].join('/'),
      );
      if (res) {
        setState(() {
          savedStrings.removeAt(index);
          if (savedFrames.length > index) savedFrames.removeAt(index);
          if (savedOnHit.length > index) savedOnHit.removeAt(index);
          if (savedOnBlock.length > index) savedOnBlock.removeAt(index);
          if (savedRemarks.length > index) savedRemarks.removeAt(index);
        });
        if (!isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Move deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting move'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// The current-string layout uses a LayoutBuilder to avoid overflow:
  /// compute available width and constrain action area, letting input icons wrap if needed.
  Widget buildCurrentString() {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
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
                            icon: const Icon(
                              Icons.save,
                              color: Colors.greenAccent,
                            ),
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
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomNumberField(
                  label: 'Frames',
                  controller: _framesController,
                ),
                const SizedBox(height: 8),
                CustomNumberField(
                  label: 'On Hit',
                  controller: _onHitController,
                ),
                const SizedBox(height: 8),
                CustomNumberField(
                  label: 'On Block',
                  controller: _onBlockController,
                ),
              ],
            ),
          ],
        );
      },
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
      appBar: customAppBar(PageType.keyMoves, widget.characterName, context),
      backgroundColor: Color.fromRGBO(5, 11, 32, 1),
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
                      children: [buildCurrentString()],
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
                    onDelete: _deleteSavedString,
                    onEdit: _editSavedString,
                    accent: accent,
                    pageType: 0,
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
