import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekken_cheat_sheet/views/main_views/my_character_view.dart';
import 'package:tekken_cheat_sheet/widgets/customAppBar.dart';
import 'package:tekken_cheat_sheet/widgets/key_moves_punish_saved_panel.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../models/pagetype_model.dart';
import '../../services/db_provider.dart';

class KeyMovesView extends StatefulWidget {
  final String characterName;

  const KeyMovesView({super.key, required this.characterName});

  @override
  State<KeyMovesView> createState() => _KeyMovesViewState();
}

class _KeyMovesViewState extends State<KeyMovesView> {
  /// String actuellement en cours de création
  final List<String> currentInputs = [];

  /// Historique sauvegardé
  final List<List<String>> savedStrings = [];

  /// Metadata optionnelle associée à chaque saved string
  final List<int?> savedFrames = [];
  final List<int?> savedOnHit = [];
  final List<int?> savedOnBlock = [];
  final List<String?> savedRemarks = [];

  // stances calculées en initState pour éviter doublons sur rebuild
  List<String> stances = [];

  /// Tous les inputs disponibles (garde la liste de base ici)
  final List<InputData> inputs = [
    InputData("1", "assets/images/inputs/1.png"),
    InputData("2", "assets/images/inputs/2.png"),
    InputData("3", "assets/images/inputs/3.png"),
    InputData("4", "assets/images/inputs/4.png"),
    InputData("1+2", "assets/images/inputs/1+2.png"),
    InputData("1+3", "assets/images/inputs/1+3.png"),
    InputData("1+4", "assets/images/inputs/1+4.png"),
    InputData("2+3", "assets/images/inputs/2+3.png"),
    InputData("2+4", "assets/images/inputs/2+4.png"),
    InputData("3+4", "assets/images/inputs/3+4.png"),
    InputData("1+2+3", "assets/images/inputs/1+2+3.png"),
    InputData("1+2+4", "assets/images/inputs/1+2+4.png"),
    InputData("2+3+4", "assets/images/inputs/2+3+4.png"),
    InputData("1+2+3+4", "assets/images/inputs/1+2+3+4.png"),
    InputData("+", "assets/images/inputs/next.png"),

    InputData("n", "assets/images/inputs/n.png"),
    InputData("f", "assets/images/inputs/f.png"),
    InputData("df", "assets/images/inputs/df.png"),
    InputData("d", "assets/images/inputs/d.png"),
    InputData("db", "assets/images/inputs/db.png"),
    InputData("b", "assets/images/inputs/b.png"),
    InputData("ub", "assets/images/inputs/ub.png"),
    InputData("u", "assets/images/inputs/u.png"),
    InputData("uf", "assets/images/inputs/uf.png"),
    InputData("f_h", "assets/images/inputs/f_h.png"),
    InputData("df_h", "assets/images/inputs/df_h.png"),
    InputData("d_h", "assets/images/inputs/d_h.png"),
    InputData("db_h", "assets/images/inputs/db_h.png"),
    InputData("b_h", "assets/images/inputs/b_h.png"),
    InputData("ub_h", "assets/images/inputs/ub_h.png"),
    InputData("u_h", "assets/images/inputs/u_h.png"),
    InputData("uf_h", "assets/images/inputs/uf_h.png"),

    InputData(",", "assets/images/inputs/comma.png"),
    InputData("~", "assets/images/inputs/tilde.png"),
  ];

  // controllers pour les champs numériques demandés
  final TextEditingController _framesController = TextEditingController();
  final TextEditingController _onHitController = TextEditingController();
  final TextEditingController _onBlockController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // calculer les stances et les ajouter une seule fois aux inputs
    stances = stancesList
        .where(
          (s) =>
              s['characterName'] == widget.characterName.replaceAll(' ', '-'),
        )
        .map((s) => s['name'] as String)
        .toList();
    inputs.addAll(stances.map((s) => InputData(s, "-")));
    initSavedMoves();
  }

  Future<void> initSavedMoves() async {
    final db = DBProvider.instance;
    // getKeyMovesForCharacter now returns List<Map<String,dynamic>> with optional metadata
    final res = await db.getKeyMovesForCharacter(widget.characterName);
    for (var row in res) {
      final inputsStr = (row['inputs'] ?? '') as String;
      final frames = (row['frames'] is int) ? row['frames'] as int : (row['frames'] == null ? null : int.tryParse('${row['frames']}'));
      final onHit = (row['onHit'] is int) ? row['onHit'] as int : (row['onHit'] == null ? null : int.tryParse('${row['onHit']}'));
      final onBlock = (row['onBlock'] is int) ? row['onBlock'] as int : (row['onBlock'] == null ? null : int.tryParse('${row['onBlock']}'));
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

  // remplace saveString pour écrire directement en base avant d'ajouter à savedStrings
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;

    final db = DBProvider.instance;
    final moveJoined = currentInputs.join('/');

    // parse optional numeric fields
    final frames = int.tryParse(_framesController.text.trim());
    final onHit = int.tryParse(_onHitController.text.trim());
    final onBlock = int.tryParse(_onBlockController.text.trim());
    final remark = _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim();

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
        // insertion OK : ajouter en mémoire et vider currentInputs + champs optionnels
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
      } else if(res == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Move already exists'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      else {
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
      var res = await DBProvider.instance.deleteKeyMove(widget.characterName, savedStrings[index].join('/'));
      if (res){
        setState(() {
          savedStrings.removeAt(index);
          // remove metadata at same index if présent
          if (savedFrames.length > index) savedFrames.removeAt(index);
          if (savedOnHit.length > index) savedOnHit.removeAt(index);
          if (savedOnBlock.length > index) savedOnBlock.removeAt(index);
          if (savedRemarks.length > index) savedRemarks.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Move deleted'),
              duration: Duration(seconds: 2),
            ),
        );
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

  // buildCurrentString inchangé (légères adaptations pour utiliser InputData du model)
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
              // zone qui contient la série d'icônes ; bascule dynamique entre 1 ligne (si ça tient)
              // et 2 lignes (Wrap) si la largeur totale dépasse la largeur disponible.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final entries = currentInputs.asMap().entries.toList();
                    // préparer widgets et calculer largeur nécessaire
                    double totalWidth = 0.0;
                    final List<Widget> iconWidgets = entries.map((entry) {
                      final data = inputs.firstWhere(
                        (e) => e.code == entry.value,
                        orElse: () => InputData(entry.value, "-"),
                      );
                      final isComma =
                          data.assetPath != "-" &&
                          data.assetPath.toLowerCase().endsWith('comma.png');
                      final double w = isComma ? 28.0 : 40.0;
                      totalWidth += w + 8; // icône + espacement droit estimé
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

                    // si ça tient sur une seule ligne -> conserver le comportement horizontal (scroll si besoin)
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

                    // sinon : afficher sur deux lignes via Wrap ; limiter la hauteur à deux lignes et permettre le scroll vertical si nécessaire
                    const double twoLineHeight = 40 * 2 + 12; // 2*iconHeight + runSpacing/padding
                    return SizedBox(
                      height: twoLineHeight,
                      child: SingleChildScrollView(
                        // vertical scroll si plus de deux lignes
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

        // Remark field (sous le current input)
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

        // Champs numériques empilés (Frames, On hit, On block)
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
          child: Expanded(
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
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Nouveau : construit une ligne (une seule ligne visuelle) contenant les icônes du string
  Widget buildSavedRow(int index, double iconSize, double spacing) {
    final string = savedStrings[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // bouton supprimer
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete move',
            onPressed: () => _deleteSavedString(index),
          ),
        ],
      ),
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
                      children: [
                        // Current string + actions + remark + numeric fields
                        buildCurrentString(),
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

                // RIGHT PANEL (saved moves) themed
                SizedBox(
                  width: 380,
                  child: KeyMovesPunishSavedPanel(
                    characterName: widget.characterName,
                    savedStrings: savedStrings,
                    inputs: inputs,
                    onDelete: _deleteSavedString,
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
