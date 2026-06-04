import 'package:flutter/material.dart';
import 'package:tekken_cheat_sheet/models/page_type_model.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/combos_view.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/key_moves_view.dart';
import 'package:tekken_cheat_sheet/views/enter_datas_views/punishes_view.dart';
import 'package:tekken_cheat_sheet/widgets/custom_appbar.dart';
import '../../services/db_provider.dart';

enum _Panel { keyMoves, punishes, combo }

class DBBrowserView extends StatefulWidget {
  final String characterName;
  final int index;

  const DBBrowserView({
    super.key,
    required this.characterName,
    required this.index,
  });

  @override
  State<DBBrowserView> createState() => _DBBrowserViewState();
}

class _DBBrowserViewState extends State<DBBrowserView> {
  _Panel _selected = _Panel.keyMoves;
  List<Map<String, dynamic>> _keyMoves = [];
  List<Map<String, dynamic>> _punishes = [];
  List<Map<String, dynamic>> _combos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final db = DBProvider.instance;
      final km = await db.getKeyMovesForCharacter(widget.characterName);
      final p = await db.getPunishesForCharacter(widget.characterName);
      final c = await db.getCombosForCharacter(widget.characterName);
      setState(() {
        _keyMoves = km;
        _punishes = p;
        _combos = c;
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
          default:
            _selected = _Panel.keyMoves;
        }
      });
    }
  }

  Widget _leftPanel(BuildContext ctx) {
    Color bg = const Color(0xFF0C1530);
    final highlight = const LinearGradient(
      colors: [Color(0xFF5ED0FC), Color(0xFF2BA6F6)],
    );

    Widget btn(String title, VoidCallback? onIconClick, _Panel panel, BuildContext ctx) {
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
                  Icons.mode_edit_outline_outlined, color: Colors.white, size: 18
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
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              side: BorderSide(color: Colors.white.withOpacity(0.04)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void onKeyMovesEdit() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => KeyMovesView(characterName: widget.characterName)));
  }

  void onPunishEdit() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PunishesView(characterName: widget.characterName)));
  }

  void onComboEdit() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CombosView(characterName: widget.characterName)));
  }

  List<String> _pathFromInputs(String inputs) {
    final parts = inputs.split('/');
    var res = <String>[];
    for (var p in parts) {
      res.add('assets/images/inputs/${p.trim().toLowerCase()}.png');
    }
    return res;
  }

  Widget _chipsForInputs(String inputs, {double size = 30}) {
    final parts = _pathFromInputs(inputs);
    return Wrap(
      spacing: size/5,
      runSpacing: size/5,
      children: parts.map((p) {
        return Image.asset(
          p,
          fit: BoxFit.cover,
          height: size,
          errorBuilder: (_, __, ___) => Container(
            height: size,
            width:size,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                p.split('/').last.split('.').first.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // big inputs line
            _chipsForInputs(inputs),
            const SizedBox(height: 12),
            Row(
              children: [
                if (frames != null) _metaChip('Frames', frames, Icons.timer),
                if (onHit != null) ...[
                  const SizedBox(width: 8),
                  _metaChip('On hit', onHit, Icons.flash_on),
                ],
                if (onBlock != null) ...[
                  const SizedBox(width: 8),
                  _metaChip('On block', onBlock, Icons.shield),
                ],
                const Spacer(),
                if (remark != null && remark.isNotEmpty)
                  Tooltip(
                    message: remark,
                    child: const Icon(Icons.note, color: Colors.white24),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            _metaChip('Frames', frames, Icons.timer),
          ],
        ),
      ),
    );
  }

  // Affichage d'un combo avec tous ses launchers (joli + moderne)
  Widget _comboCard(Map<String, dynamic> row) {
    final inputs = (row['inputs'] ?? '') as String;
    final launchers = (row['launchers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
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
                Expanded(child: _chipsForInputs(inputs)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Combo', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // launchers list : chips lisibles
            if (launchers.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('No launchers', style: TextStyle(color: Colors.white54)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: launchers.map((l) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFFB86B)),
                        _chipsForInputs(l['inputs'] as String, size: 20),
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

  Widget _metaChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
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
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _keyMoves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
