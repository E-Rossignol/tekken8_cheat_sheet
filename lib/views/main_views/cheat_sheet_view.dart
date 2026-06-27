import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/views/data_input_views/combos_view.dart';
import 'package:tekken_cheat_sheet/views/data_input_views/key_moves_view.dart';
import 'package:tekken_cheat_sheet/views/data_input_views/punishes_view.dart';
import 'package:tekken_cheat_sheet/views/data_input_views/stances_view.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import 'package:tekken_cheat_sheet/widgets/my_icons.dart';
import '../../services/db_provider.dart';

enum _Panel { keyMoves, punishes, combo, stances }

/// Dashboard showing key moves, punishes, combos and stance moves for a character.
/// Left panel selects the dataset to display; right area renders modern card list.
class CheatSheetView extends StatefulWidget {
  /// Character this view is about.
  final String characterName;

  /// Initial panel index to display (0=keyMoves,1=punishes,2=combo,3=stances).
  final int index;

  const CheatSheetView({
    super.key,
    required this.characterName,
    required this.index,
  });

  @override
  State<CheatSheetView> createState() => _CheatSheetViewState();
}

class _CheatSheetViewState extends State<CheatSheetView> {
  /// Currently selected panel enum.
  _Panel _selected = _Panel.keyMoves;

  /// Loaded key moves rows.
  List<Map<String, dynamic>> _keyMoves = [];

  /// Loaded punishes rows.
  List<Map<String, dynamic>> _punishes = [];

  /// Loaded combos rows.
  List<Map<String, dynamic>> _combos = [];

  /// Loaded stance moves rows.
  List<Map<String, dynamic>> _stances = [];

  /// Loading indicator while fetching all tables.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  /// Load all relevant tables for the current character (key moves, punishes, combos, stances).
  /// @return Future<void>
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final db = DBProvider.instance;
      final km = await db.getKeyMovesForCharacter(widget.characterName);
      final p = await db.getPunishesForCharacter(widget.characterName);
      final c = await db.getCombosForCharacter(widget.characterName);
      final s = await db.getStanceMovesForCharacter(widget.characterName);
      setState(() {
        _keyMoves = km;
        _punishes = p;
        _combos = c;
        _stances = s;
      });
    } catch (e) {
      // silence UI; optionally log
    } finally {
      setState(() {
        _loading = false;
        switch (widget.index) {
          case 0:
            _selected = _Panel.keyMoves;
            break;
          case 1:
            _selected = _Panel.punishes;
            break;
          case 2:
            _selected = _Panel.combo;
            break;
          case 3:
            _selected = _Panel.stances;
          default:
            _selected = _Panel.keyMoves;
        }
      });
    }
  }

  /// Left panel builder containing modern buttons for switching data sets.
  /// @param ctx BuildContext
  /// @return Widget left panel
  Widget _leftPanel(BuildContext ctx) {
    Color bg = const Color(0xFF0C1530);
    final highlight = const LinearGradient(
      colors: [Color(0xFF5ED0FC), Color(0xFF2BA6F6)],
    );

    Widget btn(
      String title,
      VoidCallback? onIconClick,
      _Panel panel,
      BuildContext ctx,
    ) {
      final bool active = _selected == panel;
      return InkWell(
        onTap: () => setState(() => _selected = panel),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: active ? highlight : null,
            color: active ? null : bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
            border: Border.all(
              color: Colors.white.withOpacity(active ? 0.06 : 0.03),
            ),
          ),
          width: double.infinity,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.mode_edit_outline_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                color: active ? Colors.black : Colors.white70,
                onPressed: onIconClick,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: active ? Colors.black : Colors.white70,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF07102A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          // header
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Text(
                  widget.characterName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Database viewer',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          btn('Key Moves', onKeyMovesEdit, _Panel.keyMoves, ctx),
          btn('Punishes', onPunishEdit, _Panel.punishes, ctx),
          btn('Combos', onComboEdit, _Panel.combo, ctx),
          btn('Stances', onStancesEdit, _Panel.stances, ctx),
          const Spacer(),
        ],
      ),
    );
  }

  /// Navigation helper to open KeyMoves editor.
  void onKeyMovesEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KeyMovesView(characterName: widget.characterName),
      ),
    );
  }

  /// Navigation helper to open Punishes editor.
  void onPunishEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PunishesView(characterName: widget.characterName),
      ),
    );
  }

  /// Navigation helper to open Combos editor.
  void onComboEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CombosView(characterName: widget.characterName),
      ),
    );
  }

  /// Navigation helper to open Stances editor.
  void onStancesEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StancesView(characterName: widget.characterName),
      ),
    );
  }

  /// Convert slash-separated inputs string to asset paths for chips.
  /// @param inputs slash-separated string
  /// @return List<String> asset paths
  List<String> _pathFromInputs(String inputs) {
    final parts = inputs.split('/');
    var res = <String>[];
    for (var p in parts) {
      res.add('assets/images/inputs/${p.trim().toLowerCase()}.png');
    }
    return res;
  }

  /// Render a horizontal collection of input icons for a given inputs string.
  /// @param inputs slash-separated string
  /// @param size icon size in px
  /// @return Widget row/wrap of icons
  Widget _chipsForInputs(String inputs, {double size = 30}) {
    final parts = _pathFromInputs(inputs);
    final spacing = size / 5;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: parts.asMap().entries.map((entry) {
          final p = entry.value;
          final isLast = entry.key == parts.length - 1;
          return Row(
            children: [
              Image.asset(
                p,
                fit: BoxFit.cover,
                height: size,
                errorBuilder: (_, __, ___) => Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      p.split('/').last.split('.').first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isLast) SizedBox(width: spacing),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Render a card for a key move row including inputs, remark and metadata chips.
  /// @param row DB row map
  Widget _keyMoveCard(Map<String, dynamic> row) {
    final inputs = (row['inputs'] ?? '') as String;
    final frames = row['frames']?.toString();
    final onHit = row['onHit']?.toString();
    final onBlock = row['onBlock']?.toString();
    final remark = row['remark'] as String?;
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // big inputs line
            _chipsForInputs(inputs),
            const SizedBox(height: 8),
            // remark displayed under inputs, small & italic (or "No remark")
            Text(
              (remark != null && remark.isNotEmpty) ? remark : '',
              style: const TextStyle(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (frames != null)
                  _metaChip('Frames', frames, FrameIcon(size: Size(30, 20))),
                if (onHit != null) ...[
                  const SizedBox(width: 8),
                  _metaChip('On hit', onHit, OnHitIcon(size: Size(30, 20))),
                ],
                if (onBlock != null) ...[
                  const SizedBox(width: 8),
                  _metaChip(
                    'On block',
                    onBlock,
                    OnBlockIcon(size: Size(30, 20)),
                  ),
                ],
                const Spacer(),
                // remark previously shown as tooltip; removed because remark is now rendered below inputs
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Render a punish card showing inputs and frames.
  /// @param row DB row map
  Widget _punishCard(Map<String, dynamic> row) {
    final inputs = (row['inputs'] ?? '') as String;
    final frames = row['frames']?.toString() ?? '';
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _chipsForInputs(inputs)),
            const SizedBox(width: 12),
            _metaChip('Frames', frames, FrameIcon(size: Size(30, 20))),
          ],
        ),
      ),
    );
  }

  /// Render a combo card including its launchers as chips.
  /// @param row DB row map
  Widget _comboCard(Map<String, dynamic> row) {
    final inputs = (row['inputs'] ?? '') as String;
    final launchers =
        (row['launchers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header : inputs du combo
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pathFromInputs(inputs).map((path) {
                      return Image.asset(
                        path,
                        fit: BoxFit.cover,
                        height: 30,
                        errorBuilder: (_, __, ___) => Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              path
                                  .split('/')
                                  .last
                                  .split('.')
                                  .first
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Combo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // launchers list : chips lisibles
            if (launchers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'No launchers',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: launchers.map((l) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LauncherIcon(size: Size(50, 50)),
                        _chipsForInputs(l['inputs'] as String, size: 25),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Render a stance move card showing stance, inputs and remark.
  /// @param row DB row map
  Widget _stanceCard(Map<String, dynamic> row) {
    final stanceNames = row['stance']?.toString() ?? '';
    final inputs = (row['inputs'] ?? '') as String;
    final frames = row['frames']?.toString();
    final onHit = row['onHit']?.toString();
    final onBlock = row['onBlock']?.toString();
    final remark = row['remark'] as String?;
    return Card(
      color: const Color(0xFF0E1220),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _metaChip(
                  'Stance',
                  stanceNames,
                  StanceIcon(size: Size(30, 20)),
                ),
                const SizedBox(width: 12),
                Expanded(child: _chipsForInputs(inputs)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (remark != null && remark.isNotEmpty) ? remark : '',
              style: const TextStyle(
                color: Colors.white54,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (frames != null)
                  _metaChip('Frames', frames, FrameIcon(size: Size(30, 20))),
                if (onHit != null) ...[
                  const SizedBox(width: 8),
                  _metaChip('On hit', onHit, OnHitIcon(size: Size(30, 20))),
                ],
                if (onBlock != null) ...[
                  const SizedBox(width: 8),
                  _metaChip(
                    'On block',
                    onBlock,
                    OnBlockIcon(size: Size(30, 20)),
                  ),
                ],
                const Spacer(),
                // remark previously shown as tooltip; removed because remark is now rendered below inputs
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Small metadata chip widget used by cards.
  /// @param label metadata label
  /// @param value metadata value
  /// @param icon widget icon to display
  Widget _metaChip(String label, String value, Widget icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build right-side content depending on selected panel.
  /// @return Widget right content
  Widget _rightContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selected == _Panel.keyMoves) {
      if (_keyMoves.isEmpty) {
        return const Center(
          child: Text('No key moves', style: TextStyle(color: Colors.white54)),
        );
      }
      return RefreshIndicator.adaptive(
        onRefresh: _loadAll,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.9,
          ),
          itemCount: _keyMoves.length,
          itemBuilder: (_, i) => _keyMoveCard(_keyMoves[i]),
        ),
      );
    } else if (_selected == _Panel.punishes) {
      if (_punishes.isEmpty) {
        return const Center(
          child: Text('No punishes', style: TextStyle(color: Colors.white54)),
        );
      }
      _punishes.sort((a, b) {
        final fA = a['frames'] as int? ?? 0;
        final fB = b['frames'] as int? ?? 0;
        return fA.compareTo(fB);
      });
      return RefreshIndicator.adaptive(
        onRefresh: _loadAll,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _punishes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _punishCard(_punishes[i]),
        ),
      );
    } else if (_selected == _Panel.combo) {
      if (_combos.isEmpty) {
        return const Center(
          child: Text('No combos', style: TextStyle(color: Colors.white54)),
        );
      }
      return RefreshIndicator.adaptive(
        onRefresh: _loadAll,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _combos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _comboCard(_combos[i]),
        ),
      );
    } else if (_selected == _Panel.stances) {
      if (_stances.isEmpty) {
        return const Center(
          child: Text(
            'No stance moves',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      // Group stance moves by stance name
      final Map<String, List<Map<String, dynamic>>> groupedStances = {};
      for (var stance in _stances) {
        final stanceName = stance['stance'] ?? 'Unknown';
        groupedStances.putIfAbsent(stanceName, () => []).add(stance);
      }

      final stanceNames = groupedStances.keys.toList();

      return RefreshIndicator.adaptive(
        onRefresh: _loadAll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamically calculate the number of columns (max 3)
            final int columnCount = stanceNames.length < 3
                ? stanceNames.length
                : 3;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 0.57, // Adjust height/width ratio
              ),
              itemCount: stanceNames.length,
              itemBuilder: (context, index) {
                final stanceName = stanceNames[index];
                final moves = groupedStances[stanceName]!;
                final scrollController = ScrollController();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stanceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: moves.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) => _stanceCard(moves[i]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: customAppBar(PageType.dbBrowser, widget.characterName, context),
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            _leftPanel(context),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                ),
                child: _rightContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
