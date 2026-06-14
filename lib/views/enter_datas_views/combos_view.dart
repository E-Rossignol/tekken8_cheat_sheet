import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/widgets/combo_panel.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import '../../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import '../../services/db_provider.dart';

class CombosView extends StatefulWidget {
  final String characterName;

  const CombosView({super.key, required this.characterName});

  @override
  State<CombosView> createState() => _CombosViewState();
}

class _CombosViewState extends State<CombosView> {
  final List<String> currentInputs = [];

  List<InputData> inputs = Helper().inputs;

  /// savedCombos : chaque élément = { id: int, inputs: String, launchers: List<Map{id,inputs}}
  final List<Map<String, dynamic>> savedCombos = [];

  // stances calculées en initState pour éviter doublons sur rebuild
  List<String> stances = [];

  // controllers pour les champs numériques demandés
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
              s['characterName'] == widget.characterName.replaceAll(' ', '-'),
        )
        .map((s) => s['name'] as String)
        .toList();
    inputs.addAll(stances.map((s) => InputData(s, "-")));
    initSavedMoves();
  }

  Future<void> initSavedMoves() async {
    final db = DBProvider.instance;
    final res = await db.getCombosForCharacter(widget.characterName);
    setState(() {
      savedCombos.clear();
      // each row already contains 'id','inputs','launchers'
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
    final comboJoined = currentInputs.join('/');

    try {
      final newId = await db.insertCombo(widget.characterName, comboJoined);
      if (newId > 0) {
        // ajouter en mémoire
        setState(() {
          savedCombos.add({'id': newId, 'inputs': comboJoined, 'launchers': <Map>[]});
          currentInputs.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Combo saved'), duration: Duration(seconds: 2)),
        );
        // proposer d'ajouter immédiatement des launchers
        _showAddLauncherDialog(newId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving combo'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving combo'), duration: Duration(seconds: 2)),
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
      // suppression d'un combo complet
      final combo = savedCombos[index];
      final okDel = await DBProvider.instance.deleteCombo(widget.characterName, combo['inputs']);
      if (okDel) {
        setState(() {
          savedCombos.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Combo deleted'), duration: Duration(seconds: 2)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting combo'), duration: Duration(seconds: 2)));
      }
    }
  }

  // Dialog pour ajouter un launcher à un combo existant
  Future<void> _showAddLauncherDialog(int comboId) async {
    List<String> tmp = [];
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState2) {
          Widget buildCurrent() {
            return SizedBox(
              height: 64,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tmp.map((code) {
                    final data = inputs.firstWhere((e) => e.code == code, orElse: () => InputData(code, '-'));
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(width: 40, height: 40, child: data.assetPath == '-' ? Center(child: Text(data.code, style: const TextStyle(color: Colors.white))) : Image.asset(data.assetPath)),
                    );
                  }).toList(),
                ),
              ),
            );
          }

          // dialogue sombre thématisé
          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF0E1220)),
            ),
            child: AlertDialog(
              backgroundColor: const Color(0xFF0E1220),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
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
                      TextButton(onPressed: () => setState2(() => tmp.isNotEmpty ? tmp.removeLast() : null), child: const Text('Back', style: TextStyle(color: Colors.white70))),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => setState2(() => tmp.clear()), child: const Text('Clear', style: TextStyle(color: Colors.white70))),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(93, 208, 252, 1)),
                        onPressed: tmp.isEmpty
                            ? null
                            : () async {
                                final insertId = await DBProvider.instance.insertLauncher(widget.characterName, tmp.join('/'), comboId);
                                if (insertId > 0) {
                                  // mettre à jour l'état local : ajouter launcher à la combo
                                  final idx = savedCombos.indexWhere((c) => c['id'] == comboId);
                                  if (idx >= 0) {
                                    setState(() {
                                      (savedCombos[idx]['launchers'] as List).add({'id': insertId, 'inputs': tmp.join('/')});
                                    });
                                  }
                                  Navigator.of(ctx2).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launcher added'), duration: Duration(seconds: 2)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error adding launcher'), duration: Duration(seconds: 2)));
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
        });
      },
    );
  }

  Future<void> _deleteLauncher(int comboIndex, int launcherId) async {
    final ok = await DBProvider.instance.deleteLauncher(widget.characterName, launcherId);
    if (ok) {
      setState(() {
        savedCombos[comboIndex]['launchers'] = (savedCombos[comboIndex]['launchers'] as List).where((l) => l['id'] != launcherId).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launcher deleted'), duration: Duration(seconds: 2)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting launcher'), duration: Duration(seconds: 2)));
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
                      final double w = 40.0;
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
      ],
    );
  }

  // Nouveau : construit une ligne (une seule ligne visuelle) contenant les icônes du string
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
          // zone des icônes - essaie d'occuper tout l'espace restant
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // combo inputs
                Wrap(
                  spacing: spacing,
                  runSpacing: 8,
                  children: string.split('/').map((code) {
                    final data = inputs.firstWhere((e) => e.code == code, orElse: () => InputData(code, '-'));
                    return SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: data.assetPath == '-' ? Center(child: Text(data.code, style: const TextStyle(color: Colors.white70))) : Image.asset(data.assetPath),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // launchers list as chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: launchers.map((l) {
                    return Chip(
                      backgroundColor: Colors.white10,
                      label: Text((l['inputs'] as String).replaceAll('/', ' • '), style: const TextStyle(color: Colors.white70)),
                      deleteIcon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                      onDeleted: () => _deleteLauncher(index, l['id'] as int),
                    );
                  }).toList()
                    ..add(
                      Chip(
                        label: const Text('+ Add', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.transparent,
                      )
                    ),
                ),
              ],
            ),
          ),
          // bouton supprimer combo
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), tooltip: 'Delete combo', onPressed: () => _deleteSavedString(index)),
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
                      // corrected: withOpacity instead of withValues
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
                      // corrected: withOpacity instead of withValues
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
                  child: ComboPanel(
                    combos: savedCombos,
                    inputs: inputs,
                    accent: accent,
                    characterName: widget.characterName,
                    onDeleteCombo: (i) async => await _deleteSavedString(i),
                    onDeleteLauncher: (comboIndex, launcherId) async => await _deleteLauncher(comboIndex, launcherId),
                    onAddLauncher: (comboId) async => await _showAddLauncherDialog(comboId),
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
