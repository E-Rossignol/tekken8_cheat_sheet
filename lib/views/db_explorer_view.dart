import 'package:flutter/material.dart';
import '../services/db_provider.dart';
import 'home_view.dart';

class DBExplorerView extends StatefulWidget {
  const DBExplorerView({super.key});

  @override
  State<DBExplorerView> createState() => _DBExplorerViewState();
}

class _DBExplorerViewState extends State<DBExplorerView> {
  final _db = DBProvider.instance;
  List<String> _tables = [];
  String? _selectedTable;
  List<String> _columns = [];
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // Demande de confirmation générique
  Future<bool> _confirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirmer')),
        ],
      ),
    );
    return result == true;
  }

  // Supprime la table puis rafraîchit
  Future<void> _dropTable(String table) async {
    final ok = await _confirmDialog('Supprimer la table', 'Voulez-vous vraiment supprimer la table "$table" ? Cette opération est irréversible.');
    if (!ok) return;
    final db = await _db.database;
    try {
      await db.execute('DROP TABLE IF EXISTS "$table"');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Table "$table" supprimée'), duration: const Duration(seconds: 2)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression de "$table"'), backgroundColor: Colors.red));
    }
    await _refresh();
  }

  // Supprime une ligne identifiée par pkColumn/pkValue dans la table sélectionnée
  Future<void> _deleteRow(String table, String pkColumn, dynamic pkValue) async {
    final ok = await _confirmDialog('Supprimer l\'entrée', 'Supprimer cette entrée de "$table" ?');
    if (!ok) return;
    final db = await _db.database;
    try {
      await db.delete(table, where: '"$pkColumn" = ?', whereArgs: [pkValue]);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Entrée supprimée'), duration: const Duration(seconds: 2)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Erreur lors de la suppression'), backgroundColor: Colors.red));
    }
    // recharger la table courante
    if (_selectedTable != null) await _loadTable(_selectedTable!);
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });

    final db = await _db.database;
    // Récupère les tables utilisateur (ignore sqlite_*)
    final tablesQuery = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name");
    final tables = tablesQuery.map((e) => e['name'] as String).toList();

    setState(() {
      _tables = tables;
      if (_selectedTable == null && _tables.isNotEmpty) _selectedTable = _tables.first;
    });

    if (_selectedTable != null) {
      await _loadTable(_selectedTable!);
    } else {
      setState(() {
        _columns = [];
        _rows = [];
        _loading = false;
      });
    }
  }

  Future<void> _loadTable(String table) async {
    setState(() {
      _loading = true;
      _selectedTable = table;
    });
    final db = await _db.database;
    // colonnes via PRAGMA
    final pragma = await db.rawQuery("PRAGMA table_info('$table')");
    final cols = pragma.map((c) => (c['name'] as String)).toList();

    // quelques lignes (limite pour éviter freeze)
    List<Map<String, dynamic>> rows = [];
    try {
      rows = await db.query(table, limit: 200); // limite configurable
    } catch (e) {
      rows = [];
    }

    setState(() {
      _columns = cols;
      _rows = rows;
      _loading = false;
    });
  }

  Widget _buildLeftPane() {
    return Container(
      width: 220,
      color: Colors.white.withOpacity(0.03),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Text('Tables', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _tables.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final t = _tables[index];
                final selected = t == _selectedTable;
                return ListTile(
                  dense: true,
                  title: Text(t, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
                  tileColor: selected ? Colors.white10 : null,
                  onTap: () => _loadTable(t),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    tooltip: 'Supprimer la table',
                    onPressed: () => _dropTable(t),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedTable == null) {
      return const Center(child: Text('No tables found', style: TextStyle(color: Colors.white70)));
    }
    if (_columns.isEmpty) {
      return Center(child: Text('Table "$_selectedTable" : no columns', style: const TextStyle(color: Colors.white70)));
    }

    // Limiter affichage colonnes si très nombreuses
    final displayCols = _columns.length > 10 ? _columns.sublist(0, 10) : _columns;

    // déterminer colonne clé primaire à utiliser pour suppression (id si présent sinon première colonne affichée)
    final pkColumn = _columns.contains('id') ? 'id' : _columns.first;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Table: $_selectedTable', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    ...displayCols.map((c) => DataColumn(label: Text(c, style: const TextStyle(color: Colors.white70)))),
                    const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white70))),
                  ],
                  rows: _rows.map((r) {
                    final cells = displayCols.map((c) {
                      final v = r.containsKey(c) ? r[c] : null;
                      return DataCell(Container(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(v?.toString() ?? 'NULL', style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis),
                      ));
                    }).toList();

                    // PK value pour suppression
                    final pkValue = r.containsKey(pkColumn) ? r[pkColumn] : null;
                    cells.add(
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                              tooltip: 'Supprimer cette entrée',
                              onPressed: pkValue == null
                                  ? null
                                  : () => _deleteRow(_selectedTable!, pkColumn, pkValue),
                            ),
                          ],
                        ),
                      ),
                    );

                    return DataRow(cells: cells);
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${_rows.length} ligne(s) affichées (limité)', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Database Explorer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          ),
        ),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Row(
          children: [
            _buildLeftPane(),
            Expanded(child: _buildRightPane()),
          ],
        ),
      ),
    );
  }
}
