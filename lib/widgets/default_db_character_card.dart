import 'package:flutter/material.dart';

import '../constants/helper.dart';

class DefaultDbCharacterCard extends StatefulWidget {
  const DefaultDbCharacterCard({
    super.key,
    required this.name,
    required this.isLocal,
  });
  final String name;
  final bool isLocal;

  @override
  State<DefaultDbCharacterCard> createState() => _DefaultDbCharacterCardState();
}

class _DefaultDbCharacterCardState extends State<DefaultDbCharacterCard> {
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
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () {},
                      )
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.upload, color: Colors.green),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
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
