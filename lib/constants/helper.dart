import 'package:flutter/material.dart';
import '../models/input_data.dart';
import '../models/page_type_model.dart';

class Helper{

  final Set<String> characterNamesList = {
    "alisa",
    "anna",
    "armor-king",
    "asuka",
    "azucena",
    "bryan",
    "claudio",
    "clive",
    "devil-jin",
    "dragunov",
    "eddy",
    "fahkumram",
    "feng",
    "heihachi",
    "hwoarang",
    "jack-8",
    "jin",
    "jun",
    "kazuya",
    "king",
    "kuma",
    "kunimitsu",
    "lars",
    "law",
    "lee",
    "leo",
    "leroy",
    "lidia",
    "lili",
    "miary-zo",
    "nina",
    "panda",
    "paul",
    "raven",
    "reina",
    "shaheen",
    "steve",
    "victor",
    "xiaoyu",
    "yoshimitsu",
    "zafina"
  };

  final List<Map<String, dynamic>> stancesList = [
    {'characterName': 'alisa', 'name': 'DES'},
    {'characterName': 'alisa', 'name': 'SBT'},
    {'characterName': 'alisa', 'name': 'DBT'},
    {'characterName': 'alisa', 'name': 'BKP'},
    {'characterName': 'anna', 'name': 'HMC'},
    {'characterName': 'anna', 'name': 'CJM'},
    {'characterName': 'anna', 'name': 'PLT'},
    {'characterName': 'armor-king', 'name': 'BJ'},
    {'characterName': 'armor-king', 'name': 'BAD'},
    {'characterName': 'asuka', 'name': 'NWG'},
    {'characterName': 'azucena', 'name': 'LIB'},
    {'characterName': 'azucena', 'name': 'BT'},
    {'characterName': 'bryan', 'name': 'SNE'},
    {'characterName': 'bryan', 'name': 'SWA'},
    {'characterName': 'bryan', 'name': 'CD'},
    {'characterName': 'claudio', 'name': 'STB'},
    {'characterName': 'clive', 'name': 'PHX'},
    {'characterName': 'clive', 'name': 'WOL'},
    {'characterName': 'clive', 'name': 'GAR'},
    {'characterName': 'devil-jin', 'name': 'MCR'},
    {'characterName': 'devil-jin', 'name': 'FLY'},
    {'characterName': 'devil-jin', 'name': 'CD'},
    {'characterName': 'dragunov', 'name': 'SNK'},
    {'characterName': 'eddy', 'name': 'RLX'},
    {'characterName': 'eddy', 'name': 'HSP'},
    {'characterName': 'fahkumram', 'name': 'RAM'},
    {'characterName': 'fahkumram', 'name': 'GAR'},
    {'characterName': 'feng', 'name': 'STC'},
    {'characterName': 'feng', 'name': 'BKP'},
    {'characterName': 'feng', 'name': 'BT'},
    {'characterName': 'heihachi', 'name': 'RAI'},
    {'characterName': 'heihachi', 'name': 'FUJ'},
    {'characterName': 'heihachi', 'name': 'WGK'},
    {'characterName': 'heihachi', 'name': 'TGK'},
    {'characterName': 'hwoarang', 'name': 'LFS'},
    {'characterName': 'hwoarang', 'name': 'RFS'},
    {'characterName': 'hwoarang', 'name': 'RFF'},
    {'characterName': 'hwoarang', 'name': 'LFF'},
    {'characterName': 'jack-8', 'name': 'GMH'},
    {'characterName': 'jack-8', 'name': 'SIT'},
    {'characterName': 'jack-8', 'name': 'GMC'},
    {'characterName': 'jin', 'name': 'ZEN'},
    {'characterName': 'jin', 'name': 'CD'},
    {'characterName': 'jun', 'name': 'IZU'},
    {'characterName': 'jun', 'name': 'GEN'},
    {'characterName': 'jun', 'name': 'MIA'},
    {'characterName': 'kazuya', 'name': 'CD'},
    {'characterName': 'king', 'name': 'JAG'},
    {'characterName': 'king', 'name': 'JGC'},
    {'characterName': 'king', 'name': 'ISW'},
    {'characterName': 'king', 'name': 'GS'},
    {'characterName': 'kuma', 'name': 'HBS'},
    {'characterName': 'kuma', 'name': 'SIT'},
    {'characterName': 'kuma', 'name': 'ROLL'},
    {'characterName': 'kunimistu', 'name': 'BT'},
    {'characterName': 'kunimistu', 'name': 'KT'},
    {'characterName': 'kunimistu', 'name': 'SSG'},
    {'characterName': 'lars', 'name': 'DEN'},
    {'characterName': 'lars', 'name': 'SEN'},
    {'characterName': 'lars', 'name': 'LEN'},
    {'characterName': 'law', 'name': 'DSS'},
    {'characterName': 'lee', 'name': 'HMS'},
    {'characterName': 'leroy', 'name': 'HRM'},
    {'characterName': 'lidia', 'name': 'HAE'},
    {'characterName': 'lidia', 'name': 'CAT'},
    {'characterName': 'lidia', 'name': 'WLF'},
    {'characterName': 'lidia', 'name': 'HRS'},
    {'characterName': 'lili', 'name': 'DEW'},
    {'characterName': 'lili', 'name': 'RAB'},
    {'characterName': 'lili', 'name': 'BT'},
    {'characterName': 'nina', 'name': 'CD'},
    {'characterName': 'nina', 'name': 'SWA'},
    {'characterName': 'panda', 'name': 'HBS'},
    {'characterName': 'paul', 'name': 'DPD'},
    {'characterName': 'paul', 'name': 'SWA'},
    {'characterName': 'raven', 'name': 'SZN'},
    {'characterName': 'raven', 'name': 'BT'},
    {'characterName': 'reina', 'name': 'WRA'},
    {'characterName': 'reina', 'name': 'SEN'},
    {'characterName': 'reina', 'name': 'UNS'},
    {'characterName': 'reina', 'name': 'CD'},
    {'characterName': 'shaheen', 'name': 'SNK'},
    {'characterName': 'steve', 'name': 'PAB'},
    {'characterName': 'steve', 'name': 'FLK'},
    {'characterName': 'steve', 'name': 'DCK'},
    {'characterName': 'steve', 'name': 'EXT'},
    {'characterName': 'steve', 'name': 'SWY'},
    {'characterName': 'steve', 'name': 'LNH'},
    {'characterName': 'victor', 'name': 'PRF'},
    {'characterName': 'victor', 'name': 'IAI'},
    {'characterName': 'yoshimitsu', 'name': 'FLE'},
    {'characterName': 'yoshimitsu', 'name': 'CD'},
    {'characterName': 'xiaoyu', 'name': 'AOP'},
    {'characterName': 'xiaoyu', 'name': 'RDS'},
    {'characterName': 'xiaoyu', 'name': 'HYP'},
    {'characterName': 'yoshimitsu', 'name': 'NSS'},
    {'characterName': 'yoshimitsu', 'name': 'BT'},
    {'characterName': 'yoshimitsu', 'name': 'KIN'},
    {'characterName': 'yoshimitsu', 'name': 'MED'},
    {'characterName': 'yoshimitsu', 'name': 'IND'},
    {'characterName': 'yoshimitsu', 'name': 'DGF'},
    {'characterName': 'yoshimitsu', 'name': 'FLEA'},
    {'characterName': 'zafina', 'name': 'SCR'},
    {'characterName': 'zafina', 'name': 'MNT'},
    {'characterName': 'zafina', 'name': 'TRT'},
    {'characterName': 'miary-zo', 'name': 'MMO'},
    {'characterName': 'miary-zo', 'name': 'KMH'},
  ];

  String getPath(String characterName){
    return 'assets/images/character_images/${characterName.toLowerCase().replaceAll(' ', '-')}-portrait.png';
  }

  String getBeautifulName(String characterName){
    String tmp = (characterName[0].toUpperCase() + characterName.substring(1)).replaceAll('-',' ');
    String res = tmp;
    if (tmp.contains(' ')){
      int spaceIndex = tmp.indexOf(' ');
      if (spaceIndex != tmp.length -1 && RegExp(r'^[a-zA-Z]$').hasMatch(tmp[spaceIndex + 1])){
        res = tmp.substring(0, spaceIndex + 1) + tmp[spaceIndex + 1].toUpperCase() + tmp.substring(spaceIndex + 2);
      }
    }
    return res;
  }

  bool isLetter(String c){
    return RegExp(r'^[a-zA-Z]$').hasMatch(c);
  }

  /// Tous les inputs disponibles (garde la liste de base ici)
  final List<InputData> inputs = [
    InputData("1", "assets/images/inputs/1.png"),
    InputData("2", "assets/images/inputs/2.png"),
    InputData("3", "assets/images/inputs/3.png"),
    InputData("4", "assets/images/inputs/4.png"),
    InputData("1+2", "assets/images/inputs/1+2.png"),
    InputData("3+4", "assets/images/inputs/3+4.png"),
    InputData("1+3", "assets/images/inputs/1+3.png"),
    InputData("2+4", "assets/images/inputs/2+4.png"),
    InputData("1+4", "assets/images/inputs/1+4.png"),
    InputData("2+3", "assets/images/inputs/2+3.png"),
    InputData("1+2+3", "assets/images/inputs/1+2+3.png"),
    InputData("1+2+4", "assets/images/inputs/1+2+4.png"),
    InputData("2+3+4", "assets/images/inputs/2+3+4.png"),
    InputData("1+2+3+4", "assets/images/inputs/1+2+3+4.png"),
    InputData("next", "assets/images/inputs/next.png"),
    InputData("comma", "assets/images/inputs/comma.png"),

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
    InputData("n", "assets/images/inputs/n.png"),

    InputData("tilde", "assets/images/inputs/tilde.png"),
    InputData("perfectframe", "assets/images/inputs/perfectframe.png"),
    InputData("HEAT", "assets/images/inputs/heat.png"),
    InputData("CH", "assets/images/inputs/ch.png"),
    InputData("CC", "assets/images/inputs/cc.png"),
    InputData("DASH", "assets/images/inputs/dash.png"),
    InputData("FC", "assets/images/inputs/fc.png"),
    InputData("SS", "assets/images/inputs/ss.png"),
    InputData("SSL", "assets/images/inputs/ssl.png"),
    InputData("SSR", "assets/images/inputs/ssr.png"),
    InputData("WS", "assets/images/inputs/ws.png"),
    InputData("WR", "assets/images/inputs/wr.png"),
    InputData("TORNADO", "assets/images/inputs/tornado.png"),
    InputData("WALLSPLAT", "assets/images/inputs/wallsplat.png"),
    InputData("HEATDASH", "assets/images/inputs/heatdash.png"),
  ];

  void onHelpButtonClick(PageType pageType, BuildContext context) {
    switch (pageType) {
      case PageType.home:
        openHomeHelpDialog(context);
        break;
      case PageType.characterDetail:
        openMyCharacterHelpDialog(context);
        break;
      case PageType.characterChoice:
        openChooseCharacterHelpDialog(context);
        break;
      case PageType.keyMoves:
        openKeyMovesHelpDialog(context);
        break;
      case PageType.punish:
        openPunishesHelpDialog(context);
        break;
      case PageType.combos:
        openComboHelpDialog(context);
        break;
      default:
        openKeyMovesHelpDialog(context);
    }
  }
  void openHomeHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text('',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openChooseCharacterHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text(''
            'Choose the character you want to view and manage. You can always come back to this page to switch characters or access the home page.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openMyCharacterHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text('',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openKeyMovesHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text(''
            '-> On this page, you can enter and save your favourite moves.\n'
            '-> On the left side, you can record and save the move/string.\n'
            '-> On the right side, you can manage your saved key moves.\n'
            '          - To delete a key move, click the trash icon on the right.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openPunishesHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text('',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  void openComboHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
            'HOW TO USE THIS PAGE',
            style: TextStyle(color: Colors.white70)),
        content: const Text(''
            '-> On this page, you can enter and save your favourite combos.\n'
            '-> On the left side, you can record and save the combo (NO LAUNCHER NEEDED).\n'
            '-> On the right side, you can manage your saved combos and link them to launchers for quick access.\n'
            '          - Each combo displays its inputs as icons. Below, you can see and manage its launchers.\n'
            '          - To add a launcher, click the "+ Add launcher" button and select from your saved launchers.\n'
            '          - To delete a launcher, click the red "X" on its chip.\n'
            '          - To delete an entire combo, click the trash icon on the right.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}