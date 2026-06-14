import   'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../services/db_provider.dart';
import '../../widgets/key_moves_punish_saved_panel.dart';

class StancesView extends StatefulWidget {
  final String characterName;

  const StancesView({super.key, required this.characterName});

  @override
  State<StancesView> createState() => _StancesViewState();
}

class _StancesViewState extends State<StancesView> {
  /// String actuellement en cours de création
  final List<String> currentInputs = [];

  /// Historique sauvegardé (inputs)
  final List<List<String>> savedStrings = [];

  /// Stance associée à chaque savedStrings (même index)
  List<String> savedStances = [];

  /// Remark associée à chaque savedStrings (même index)
  List<String?> savedRemarks = []; // nouveau : peut être null

  // stances calculées en initState pour éviter doublons sur rebuild
  List<String> stances = [];

  // Sélection courante de stance (valeur par défaut)
  String _selectedStance = "";

  List<InputData> inputs = Helper().inputs;

  // Valeurs autorisées pour Stance (définies ici pour validation)
  List<String> _allowedStances = [];

  final TextEditingController _framesController = TextEditingController();
  final TextEditingController _onHitController = TextEditingController();
  final TextEditingController _onBlockController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // calculer les stances et les ajouter une seule fois aux inputs
    stances = Helper().stancesList
        .where(
          (s) =>
      s['characterName'] == widget.characterName.replaceAll(' ', '-').toLowerCase(),
    )
        .map((s) => s['name'] as String)
        .toList();
    inputs.addAll(stances.map((s) => InputData(s, "-")));
    // safe initialization: avoid index error if no stances are defined
    _selectedStance = stances.isNotEmpty ? stances[0] : '';
    _allowedStances.addAll(stances);
    initStanceMoves();
  }

  Future<void> initStanceMoves() async {
    // charge les stance moves depuis le provider (inputs + stance + remark)
    final res = await DBProvider.instance.getStanceMovesForCharacter(widget.characterName);
    for (var row in res) {
      final inputsStr = (row['inputs'] ?? '') as String;
      final stanceStr = row['stance'] is String
          ? row['stance'] as String
          : (_allowedStances.isNotEmpty ? _allowedStances.first : '');
      final remarkStr = row['remark'] is String ? row['remark'] as String : null;
      List<String> moveList = inputsStr.split('/');
      setState(() {
        savedStrings.add(moveList);
        savedStances.add(stanceStr);
        savedRemarks.add(remarkStr);
      });
    }

    // NOTE: on ne force pas d'unicité ni on ne modifie la sélection courante ici.
  }

  @override
  void dispose() {
    _framesController.dispose();
    _onHitController.dispose();
    _onBlockController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void addInput(String input) {
    setState(() {
      currentInputs.add(input);
    });
  }

  void removeLastInput() {
    if (currentInputs.isEmpty) return;
    setState(() {
      currentInputs.removeLast();
    });
  }

  void clearInputs() {
    setState(() {
      currentInputs.clear();
    });
  }

  // remplace saveString pour écrire directement en base avant d'ajouter à savedStrings/savedStances
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;

    // validation : la stance doit être une valeur autorisée
    if (!_allowedStances.contains(_selectedStance)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid stance value'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final moveJoined = currentInputs.join('/');
    // parse optional numeric fields
    final frames = int.tryParse(_framesController.text.trim());
    final onHit = int.tryParse(_onHitController.text.trim());
    final onBlock = int.tryParse(_onBlockController.text.trim());
    final remark = _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim();
    try {
      // Utiliser la méthode dédiée pour les stance moves (maintenant prend remark)
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving stance move'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
        final res = await DBProvider.instance.deleteStanceMove(widget.characterName, inputsStr, stanceForRow);
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

  // buildCurrentString adapté : current string + actions + dropdown stance + remark
  Widget buildCurrentString() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ligne principale: current string (expand) + actions (à droite)
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(5, 11, 32, 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // zone qui contient la série d'icônes ; utilise SingleChildScrollView horizontal si trop longue
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

              // Actions : save / backspace / clear
              const SizedBox(width: 8),
              Row(
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
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Remark field (same style as in key_moves_view)
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

        // Stance selector (Dropdown) - now works with String values and allows duplicates
        Row(
          children: [
            const Text(
              'Stance:',
              style: TextStyle(color: Colors.white70),
            ),
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
            _numberField('Frames', _framesController),
            const SizedBox(height: 8),
            _numberField('On hit', _onHitController),
            const SizedBox(height: 8),
            _numberField('On block', _onBlockController),
          ],
        ),
      ],
    );
  }

  // Nouveau : construit une carte contenant la ligne + (optionnellement) la remark en dessous
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
          // zone des icônes - essaie d'occuper tout l'espace restant
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
          // badge stance
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stance,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
          ),
          // bouton supprimer
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

  // helper pour un champ numérique avec label (léger ajustement visuel)
  Widget _numberField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white12,
            ), // indique visuellement qu'il s'agit d'un champ
          ),
          // Removed Expanded: TextField must be direct child (Container gives constraints)
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: false,
            ),
            inputFormatters: [
              // autorise un signe "-" initial puis des chiffres (accepte temporairement entrées intermédiaires)
              FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white24),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // reuse HomeView palette
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final accent = const Color.fromRGBO(93, 208, 252, 1);
    return Scaffold(
      // appbar style cohérent avec HomeView
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
                        // Current string + actions + frames selector
                        buildCurrentString(),
                        const SizedBox(height: 12),
                        // ici vous pouvez ajouter autres contrôles spécifiques si besoin
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // GRID D'INPUTS (à droite du contenu principal) - themed
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
                  child: KeyMovesPunishSavedPanel(
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
