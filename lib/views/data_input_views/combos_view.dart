import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/combo_panel.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../services/db_provider.dart';

/// CombosView allows creating combos and linking launchers to them.
/// Combo persists once; launchers reference a combo by foreign key.
class CombosView extends StatefulWidget {
  /// Character scope used to filter combos and launchers.
  final String characterName;

  const CombosView({super.key, required this.characterName});

  @override
  State<CombosView> createState() => _CombosViewState();
}

class _CombosViewState extends State<CombosView> {
  /// Currently composed input tokens for the combo being authored.
  final List<String> currentInputs = [];

  /// Master input definitions (icons + codes), extended per-character with stance tokens.
  List<InputData> inputs = Helper().inputs;

  /// Saved combos fetched from DB; each item is a Map {id, inputs, launchers}.
  final List<Map<String, dynamic>> savedCombos = [];

  /// Local stance list for the character (appended to inputs as tokens).
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

  /// Load combos (with their launchers) from DB for this character.
  /// @return Future<void>
  Future<void> initSavedMoves() async {
    final db = DBProvider.instance;
    final res = await db.getCombosForCharacter(widget.characterName);
    setState(() {
      savedCombos.clear();
      savedCombos.addAll(res);
    });
  }

  @override
  void dispose() {
    _framesController.dispose();
    _onHitController.dispose();
    _onBlockController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  /// Append an input token to the current combo composition.
  /// @param input token code
  void addInput(String input) {
    setState(() {
      currentInputs.add(input);
    });
  }

  /// Remove last token from current composition.
  void removeLastInput() {
    if (currentInputs.isEmpty) return;
    setState(() {
      currentInputs.removeLast();
    });
  }

  /// Clear current composition.
  void clearInputs() {
    setState(() {
      currentInputs.clear();
    });
  }

  /// Save composed combo to DB and prompt to add a launcher.
  /// @return Future<void>
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;
    final db = DBProvider.instance;
    final comboJoined = currentInputs.join('/');

    try {
      final newId = await db.insertCombo(widget.characterName, comboJoined);
      if (newId > 0) {
        setState(() {
          savedCombos.add({
            'id': newId,
            'inputs': comboJoined,
            'launchers': <Map>[],
          });
          currentInputs.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combo saved'),
            duration: Duration(seconds: 2),
          ),
        );
        // immediately propose to add a launcher for convenience
        _showAddLauncherDialog(newId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving combo'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving combo'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Confirm and delete a saved combo.
  /// @param index index in savedCombos
  /// @return Future<void>
  Future<void> _deleteSavedString(int index) async {
    final ok = await showDialog<bool>(
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
    );
    if (ok == true) {
      final combo = savedCombos[index];
      final okDel = await DBProvider.instance.deleteCombo(
        widget.characterName,
        combo['inputs'],
      );
      if (okDel) {
        setState(() {
          savedCombos.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combo deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting combo'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Dialog to compose a launcher and attach it to comboId.
  /// @param comboId id of the combo to attach the launcher to
  /// @return Future<void>
  Future<void> _showAddLauncherDialog(int comboId) async {
    List<String> tmp = [];
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            Widget buildCurrent() {
              return SizedBox(
                height: 64,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tmp.map((code) {
                      final data = inputs.firstWhere(
                        (e) => e.code == code,
                        orElse: () => InputData(code, '-'),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: data.assetPath == '-'
                              ? Center(
                                  child: Text(
                                    data.code,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              : Image.asset(data.assetPath),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }

            return Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(bodyColor: Colors.white),
                dialogTheme: DialogThemeData(
                  backgroundColor: const Color(0xFF0E1220),
                ),
              ),
              child: AlertDialog(
                backgroundColor: const Color(0xFF0E1220),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                contentTextStyle: const TextStyle(color: Colors.white70),
                title: const Text('Add launcher'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildCurrent(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 260,
                      height: 200,
                      child: InputGrid(
                        inputs: inputs,
                        onInputTap: (code) {
                          setState2(() => tmp.add(code));
                        },
                        accent: const Color.fromRGBO(93, 208, 252, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setState2(
                            () => tmp.isNotEmpty ? tmp.removeLast() : null,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => setState2(() => tmp.clear()),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              93,
                              208,
                              252,
                              1,
                            ),
                          ),
                          onPressed: tmp.isEmpty
                              ? null
                              : () async {
                                  final insertId = await DBProvider.instance
                                      .insertLauncher(
                                        widget.characterName,
                                        tmp.join('/'),
                                        comboId,
                                      );
                                  if (insertId > 0) {
                                    final idx = savedCombos.indexWhere(
                                      (c) => c['id'] == comboId,
                                    );
                                    if (idx >= 0) {
                                      setState(() {
                                        (savedCombos[idx]['launchers'] as List)
                                            .add({
                                              'id': insertId,
                                              'inputs': tmp.join('/'),
                                            });
                                      });
                                    }
                                    Navigator.of(ctx2).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Launcher added'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error adding launcher'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Save launcher'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Delete a launcher by id and update local state.
  /// @param comboIndex index of parent combo in savedCombos
  /// @param launcherId id of the launcher row to remove
  /// @return Future<void>
  Future<void> _deleteLauncher(int comboIndex, int launcherId) async {
    final ok = await DBProvider.instance.deleteLauncher(
      widget.characterName,
      launcherId,
    );
    if (ok) {
      setState(() {
        savedCombos[comboIndex]['launchers'] =
            (savedCombos[comboIndex]['launchers'] as List)
                .where((l) => l['id'] != launcherId)
                .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Launcher deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting launcher'),
          duration: Duration(seconds: 2),
        ),
      );
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
                    final List<Widget> iconWidgets = entries.map((entry) {
                      final data = inputs.firstWhere(
                        (e) => e.code == entry.value,
                        orElse: () => InputData(entry.value, "-"),
                      );
                      final double w = 40.0;
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
                    return SizedBox(
                      height: 300,
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
      ],
    );
  }

  Widget buildComboCard(int index, double iconSize, double spacing) {
    final combo = savedCombos[index];
    final string = (combo['inputs'] ?? '') as String;
    final launchers = (combo['launchers'] as List).cast<Map<String, dynamic>>();

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: spacing,
                  runSpacing: 8,
                  children: string.split('/').map((code) {
                    final data = inputs.firstWhere(
                      (e) => e.code == code,
                      orElse: () => InputData(code, '-'),
                    );
                    return SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: data.assetPath == '-'
                          ? Center(
                              child: Text(
                                data.code,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                          : Image.asset(data.assetPath),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      launchers.map((l) {
                        return Chip(
                          backgroundColor: Colors.white10,
                          label: Text(
                            (l['inputs'] as String).replaceAll('/', ' • '),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onDeleted: () =>
                              _deleteLauncher(index, l['id'] as int),
                        );
                      }).toList()..add(
                        Chip(
                          label: const Text(
                            '+ Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete combo',
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
      appBar: customAppBar(PageType.combos, widget.characterName, context),
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
                  child: ComboPanel(
                    combos: savedCombos,
                    inputs: inputs,
                    accent: accent,
                    characterName: widget.characterName,
                    onDeleteCombo: (i) async => await _deleteSavedString(i),
                    onDeleteLauncher: (comboIndex, launcherId) async =>
                        await _deleteLauncher(comboIndex, launcherId),
                    onAddLauncher: (comboId) async =>
                        await _showAddLauncherDialog(comboId),
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
