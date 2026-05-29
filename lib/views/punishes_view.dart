import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/views/my_character_view.dart';
import '../constants/helper.dart';
import 'package:tekken_cheat_sheet/models/input_data.dart';
import 'package:tekken_cheat_sheet/widgets/input_grid.dart';
import 'package:tekken_cheat_sheet/widgets/saved_moves_panel.dart';
import '../services/db_provider.dart';

class PunishesView extends StatefulWidget {
  final String characterName;

  const PunishesView({super.key, required this.characterName});

  @override
  State<PunishesView> createState() => _PunishesViewState();
}

class _PunishesViewState extends State<PunishesView> {
  /// String actuellement en cours de création
  final List<String> currentInputs = [];

  /// Historique sauvegardé (inputs)
  final List<List<String>> savedStrings = [];

  /// Frames associés à chaque savedStrings (même index)
  final List<int> savedFrames = [];

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

  // Sélection courante de frames (valeur par défaut)
  int _selectedFrames = 10;

  // Valeurs autorisées pour Frames (définies ici pour validation)
  static const List<int> _allowedFrames = [10, 11, 12, 13, 14, 15, 16];

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
    initPunishes();
  }

  Future<void> initPunishes() async {
    final db = DBProvider.instance;
    // charge les punishes (inputs + frames) pour ce personnage
    final res = await db.getPunishesForCharacter(widget.characterName);
    for (var row in res) {
      final inputsStr = (row['inputs'] ?? '') as String;
      final frames = (row['frames'] is int) ? row['frames'] as int : int.tryParse('${row['frames']}') ?? 10;
      List<String> moveList = inputsStr.split('/');
      setState(() {
        savedStrings.add(moveList);
        savedFrames.add(frames);
      });
    }

    // si la frame sélectionnée par défaut est déjà utilisée, choisir la première disponible
    final used = savedFrames.toSet();
    final firstAvailable = _allowedFrames.firstWhere((v) => !used.contains(v), orElse: () => _allowedFrames.first);
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

  // remplace saveString pour écrire directement en base avant d'ajouter à savedStrings/savedFrames
  Future<void> saveString() async {
    if (currentInputs.isEmpty) return;

    // validation : n'autorise la sauvegarde que si la valeur de frames sélectionnée
    // fait partie des frames autorisées (sécurité supplémentaire).
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

    // validation : n'autorise pas de créer un nouveau string pour une frame déjà présente
    if (savedFrames.contains(_selectedFrames)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette valeur de frames est déjà utilisée. Supprimez d\'abord l\'ancien punish pour la réutiliser.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final db = DBProvider.instance;
    final moveJoined = currentInputs.join('/');

    try {
      final res = await db.insertPunish(widget.characterName, moveJoined, _selectedFrames);
      // insertPunish ne renvoie pas explicitement int dans l'implémentation actuelle,
      // mais si insertPunish est asynchrone void, on peut considérer le try comme succès.
      // Ici on vérifie simplement l'absence d'exception pour succès.
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
      final db = await DBProvider.instance.database;
      final inputsStr = savedStrings[index].join('/');
      final frames = savedFrames[index];
      try {
        final res = await db.delete(
          'punishes',
          where: 'characterName = ? AND inputs = ? AND frames = ?',
          whereArgs: [widget.characterName, inputsStr, frames],
        );
        if (res > 0) {
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

  // buildCurrentString adapté : current string + actions + dropdown frames (plus pas de remark / onHit / onBlock)
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
                child: SizedBox(
                  height: 56,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: currentInputs.asMap().entries.map((entry) {
                        final data = inputs.firstWhere(
                          (e) => e.code == entry.value,
                          orElse: () => InputData(entry.value, "-"),
                        );
                        final isComma =
                            data.assetPath != "-" &&
                            data.assetPath.toLowerCase().endsWith('comma.png');
                        final w = isComma ? 28.0 : 40.0;
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
                      }).toList(),
                    ),
                  ),
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

        // Frames selector (Dropdown)
        Row(
          children: [
            const Text(
              'Frames:',
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
                child: DropdownButton<int>(
                  value: _selectedFrames,
                  dropdownColor: const Color(0xFF11121A),
                  items: _allowedFrames.map((v) {
                    final used = savedFrames.contains(v);
                    return DropdownMenuItem<int>(
                      value: v,
                      // disabled visuel et tooltip explicatif si déjà utilisé
                      enabled: !used,
                      child: Tooltip(
                        message: used
                            ? 'Delete other punish first'
                            : '',
                        child: Text(
                          '$v',
                          style: TextStyle(color: used ? Colors.white24 : Colors.white70),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    // empêche la sélection d'une valeur déjà utilisée (sécurité côté UI)
                    if (savedFrames.contains(v)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This value of frames is already used. Delete the existing punish first to reuse it.'),
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

  // Nouveau : construit une ligne (une seule ligne visuelle) contenant les icônes du string
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
          // affichage frames
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              '$frames',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
          // bouton supprimer
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
    // reuse HomeView palette
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final accent = const Color.fromRGBO(93, 208, 252, 1);
    return Scaffold(
      // appbar style cohérent avec HomeView
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MyCharacterView(characterName: widget.characterName)),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              widget.characterName.toUpperCase(),
              style: const TextStyle(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
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

                // RIGHT PANEL (saved punishes) themed
                SizedBox(
                  width: 380,
                  child: SavedMovesPanel(
                    savedStrings: savedStrings,
                    savedFrames: savedFrames, // <-- passe les frames pour affichage
                    inputs: inputs,
                    onDelete: _deleteSavedString,
                    accent: accent,
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
