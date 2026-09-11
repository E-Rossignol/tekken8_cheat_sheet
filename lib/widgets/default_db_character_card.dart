import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/helper.dart';

class DefaultDbCharacterCard extends StatefulWidget {
  const DefaultDbCharacterCard({
    super.key,
    required this.name,
    required this.isLocal,
    required this.onUpdate,
    required this.onDelete,
    required this.onImport,
  });

  final String name;
  final bool isLocal;
  final Function onUpdate;
  final Function onDelete;
  final Function onImport;

  @override
  State<DefaultDbCharacterCard> createState() => _DefaultDbCharacterCardState();
}

class _DefaultDbCharacterCardState extends State<DefaultDbCharacterCard> {
  bool isGod = false;

  @override
  void initState() {
    super.initState();
    checkIsGod();
  }

  Future<void> checkIsGod() async {
    var prefs = await SharedPreferences.getInstance();
    var tmpIsGod = prefs.getBool('isGOD');
    if (tmpIsGod == true) {
      setState(() {
        isGod = true;
      });
    } else {
      setState(() {
        isGod = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgGradient = const LinearGradient(
      colors: [Color.fromRGBO(5, 11, 32, 1), Color.fromRGBO(3, 36, 101, 1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    var path = Helper().getPath(widget.name);
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Image.asset(path),
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                widget.isLocal
                    ? isGod
                          ? IconButton(
                              icon: Icon(
                                Icons.arrow_circle_right_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                await widget.onUpdate(widget.name);
                              },
                            )
                          : SizedBox(width: 0, height: 0)
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await widget.onImport(widget.name);
                            },
                            icon: Icon(Icons.upload, color: Colors.green),
                          ),
                          isGod
                              ? IconButton(
                                  onPressed: () async {
                                    await widget.onDelete(widget.name);
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                )
                              : SizedBox(width: 0, height: 0),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
