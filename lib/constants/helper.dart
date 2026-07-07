import 'package:flutter/material.dart';
import '../models/input_data.dart';
import '../models/page_type_model.dart';

/// Helper utility with static-like data and helper methods used across the app.
class Helper {
  /// Embedded default DB dump used by importDefaultDB for testing / seeding.

  final dynamic defaultDB = {
      "my_characters": [
        {
          "id": 8,
          "name": "anna",
          "createdAt": 1780705402287
        },
        {
          "id": 9,
          "name": "reina",
          "createdAt": 1781545722239
        },
        {
          "id": 11,
          "name": "paul",
          "createdAt": 1782117354751
        }
      ],
      "key_moves": [
        {
          "id": 24,
          "characterName": "anna",
          "inputs": "1/2/1/4",
          "frames": 10,
          "onHit": 32,
          "onBlock": 4,
          "remark": "safe launcher",
          "createdAt": 1780705402322
        },
        {
          "id": 25,
          "characterName": "anna",
          "inputs": "df/1/2",
          "frames": 13,
          "onHit": 2,
          "onBlock": -5,
          "remark": "transition to HMC with F",
          "createdAt": 1780705436552
        },
        {
          "id": 26,
          "characterName": "reina",
          "inputs": "f/f/2",
          "frames": 12,
          "onHit": 13,
          "onBlock": -9,
          "remark": "transition to SEN with f",
          "createdAt": 1781545722245
        },
        {
          "id": 27,
          "characterName": "reina",
          "inputs": "f/2/3",
          "frames": 13,
          "onHit": 9,
          "onBlock": -9,
          "remark": "transition to SEN with f",
          "createdAt": 1781545767819
        },
        {
          "id": 28,
          "characterName": "reina",
          "inputs": "1/1/2",
          "frames": 10,
          "onHit": 11,
          "onBlock": -17,
          "remark": "transition to SEN",
          "createdAt": 1781545813680
        },
        {
          "id": 29,
          "characterName": "reina",
          "inputs": "f/4",
          "frames": 19,
          "onHit": 5,
          "onBlock": 2,
          "remark": "Electric war god kick guarranted on CH",
          "createdAt": 1781545962474
        },
        {
          "id": 30,
          "characterName": "reina",
          "inputs": "1/2/2",
          "frames": 10,
          "onHit": 0,
          "onBlock": -14,
          "remark": "transition to UNS with u or d",
          "createdAt": 1781546032657
        },
        {
          "id": 31,
          "characterName": "reina",
          "inputs": "2/2/1",
          "frames": 12,
          "onHit": 12,
          "onBlock": -1,
          "remark": "all string guarranted if first hit",
          "createdAt": 1781546073880
        },
        {
          "id": 32,
          "characterName": "reina",
          "inputs": "2/2/2",
          "frames": 12,
          "onHit": 6,
          "onBlock": -6,
          "remark": "transition to WRA with d",
          "createdAt": 1781546155602
        },
        {
          "id": 33,
          "characterName": "reina",
          "inputs": "1+2",
          "frames": 12,
          "onHit": 24,
          "onBlock": -10,
          "remark": null,
          "createdAt": 1781546174427
        },
        {
          "id": 34,
          "characterName": "reina",
          "inputs": "df/1",
          "frames": 13,
          "onHit": 4,
          "onBlock": -3,
          "remark": "transition to SEN with f",
          "createdAt": 1781546278054
        },
        {
          "id": 35,
          "characterName": "reina",
          "inputs": "df/1/2",
          "frames": 13,
          "onHit": 12,
          "onBlock": -14,
          "remark": "heat engager",
          "createdAt": 1781546302548
        },
        {
          "id": 36,
          "characterName": "reina",
          "inputs": "df/4/2",
          "frames": 15,
          "onHit": 6,
          "onBlock": -8,
          "remark": "transition to WRA  with d",
          "createdAt": 1781546434898
        },
        {
          "id": 37,
          "characterName": "reina",
          "inputs": "d/2",
          "frames": 15,
          "onHit": 3,
          "onBlock": 0,
          "remark": "Electric war god kick guarranted with CH",
          "createdAt": 1781546552457
        },
        {
          "id": 38,
          "characterName": "reina",
          "inputs": "db/2",
          "frames": 20,
          "onHit": 3,
          "onBlock": -16,
          "remark": null,
          "createdAt": 1781546718505
        },
        {
          "id": 39,
          "characterName": "reina",
          "inputs": "db/3/1+2",
          "frames": 16,
          "onHit": 39,
          "onBlock": -12,
          "remark": null,
          "createdAt": 1781546823741
        },
        {
          "id": 40,
          "characterName": "paul",
          "inputs": "3/2",
          "frames": 15,
          "onHit": 7,
          "onBlock": -3,
          "remark": "transitions to SWA with b, CH launcher",
          "createdAt": 1783449795019
        },
        {
          "id": 41,
          "characterName": "paul",
          "inputs": "b/1+2",
          "frames": 24,
          "onHit": 21,
          "onBlock": -9,
          "remark": "safe powercrush",
          "createdAt": 1783449837052
        },
        {
          "id": 42,
          "characterName": "paul",
          "inputs": "b/2/1",
          "frames": 18,
          "onHit": 0,
          "onBlock": -12,
          "remark": "can be charged, guard break in full charge in heat (+12)",
          "createdAt": 1783449908879
        },
        {
          "id": 43,
          "characterName": "paul",
          "inputs": "b/3",
          "frames": 14,
          "onHit": 31,
          "onBlock": -6,
          "remark": "safe close range launcher",
          "createdAt": 1783449928069
        },
        {
          "id": 44,
          "characterName": "paul",
          "inputs": "b/4",
          "frames": 20,
          "onHit": 4,
          "onBlock": -12,
          "remark": "low poke",
          "createdAt": 1783449945708
        },
        {
          "id": 45,
          "characterName": "paul",
          "inputs": "d/1/4/2",
          "frames": 14,
          "onHit": 3,
          "onBlock": -14,
          "remark": null,
          "createdAt": 1783450214572
        },
        {
          "id": 46,
          "characterName": "paul",
          "inputs": "d/1+2",
          "frames": 12,
          "onHit": 16,
          "onBlock": -18,
          "remark": "another d+1+2 guarranteed in CH",
          "createdAt": 1783450257086
        },
        {
          "id": 47,
          "characterName": "paul",
          "inputs": "d/4/2/perfectframe/1+2",
          "frames": 15,
          "onHit": 3,
          "onBlock": -17,
          "remark": "unsafe powerful low option",
          "createdAt": 1783450306702
        },
        {
          "id": 48,
          "characterName": "paul",
          "inputs": "db/1+2",
          "frames": 20,
          "onHit": 30,
          "onBlock": -14,
          "remark": "dash and deathfist guarranteed on hit",
          "createdAt": 1783450340635
        },
        {
          "id": 49,
          "characterName": "paul",
          "inputs": "db/2",
          "frames": 19,
          "onHit": 14,
          "onBlock": -11,
          "remark": "CH launcher",
          "createdAt": 1783450359800
        },
        {
          "id": 50,
          "characterName": "paul",
          "inputs": "df/1",
          "frames": 14,
          "onHit": 4,
          "onBlock": -2,
          "remark": "mid check, transitions to SWA with b",
          "createdAt": 1783450796916
        },
        {
          "id": 51,
          "characterName": "paul",
          "inputs": "df/1/1/2",
          "frames": 14,
          "onHit": 32,
          "onBlock": -9,
          "remark": "safe mid string, CH launcher on last hit",
          "createdAt": 1783450820979
        },
        {
          "id": 52,
          "characterName": "paul",
          "inputs": "df/2",
          "frames": 15,
          "onHit": 33,
          "onBlock": -8,
          "remark": "safe short range launcher",
          "createdAt": 1783450871809
        },
        {
          "id": 53,
          "characterName": "paul",
          "inputs": "df/4",
          "frames": 17,
          "onHit": 8,
          "onBlock": -2,
          "remark": "safe mid, guarranteed f2 heat engager in CH",
          "createdAt": 1783450970861
        },
        {
          "id": 56,
          "characterName": "paul",
          "inputs": "f_h/f/2/perfectframe/1",
          "frames": 15,
          "onHit": 37,
          "onBlock": -1,
          "remark": "only safe with perfect frame, launch punishable if not",
          "createdAt": 1783451112694
        },
        {
          "id": 57,
          "characterName": "paul",
          "inputs": "f_h/f/2/2",
          "frames": 15,
          "onHit": 27,
          "onBlock": -19,
          "remark": "low launcher, not punishable because huge pushback, can be cancelled into FC with b",
          "createdAt": 1783451154792
        },
        {
          "id": 58,
          "characterName": "paul",
          "inputs": "f/f/4",
          "frames": 27,
          "onHit": 18,
          "onBlock": 2,
          "remark": "frame trap launcher",
          "createdAt": 1783451203716
        },
        {
          "id": 59,
          "characterName": "paul",
          "inputs": "f/1+2",
          "frames": 20,
          "onHit": 8,
          "onBlock": 3,
          "remark": "transitions to DPD with df",
          "createdAt": 1783451233105
        },
        {
          "id": 60,
          "characterName": "paul",
          "inputs": "u/1+2",
          "frames": 21,
          "onHit": 41,
          "onBlock": -14,
          "remark": "great evasion tool",
          "createdAt": 1783451254516
        },
        {
          "id": 61,
          "characterName": "paul",
          "inputs": "f/2",
          "frames": 13,
          "onHit": 9,
          "onBlock": -5,
          "remark": "safe heat engager",
          "createdAt": 1783451310919
        },
        {
          "id": 62,
          "characterName": "paul",
          "inputs": "f/3/1",
          "frames": 16,
          "onHit": 12,
          "onBlock": -13,
          "remark": null,
          "createdAt": 1783451331374
        },
        {
          "id": 63,
          "characterName": "paul",
          "inputs": "f/4",
          "frames": 22,
          "onHit": 6,
          "onBlock": -5,
          "remark": "safe heat engager",
          "createdAt": 1783451351420
        },
        {
          "id": 64,
          "characterName": "paul",
          "inputs": "FC/1+2/next/2/d/1/1/1+2",
          "frames": null,
          "onHit": null,
          "onBlock": null,
          "remark": "grab",
          "createdAt": 1783451530644
        },
        {
          "id": 65,
          "characterName": "paul",
          "inputs": "HEAT/f/2/1+2",
          "frames": 15,
          "onHit": 25,
          "onBlock": 1,
          "remark": null,
          "createdAt": 1783451565308
        },
        {
          "id": 66,
          "characterName": "paul",
          "inputs": "SS/1",
          "frames": 20,
          "onHit": 35,
          "onBlock": 8,
          "remark": null,
          "createdAt": 1783451599704
        },
        {
          "id": 67,
          "characterName": "paul",
          "inputs": "SS/3",
          "frames": 19,
          "onHit": 4,
          "onBlock": -12,
          "remark": "low sidestep option",
          "createdAt": 1783451615221
        },
        {
          "id": 68,
          "characterName": "paul",
          "inputs": "ub/2",
          "frames": 18,
          "onHit": 14,
          "onBlock": -5,
          "remark": "tracking mid",
          "createdAt": 1783451639556
        },
        {
          "id": 69,
          "characterName": "paul",
          "inputs": "uf/2",
          "frames": 22,
          "onHit": 17,
          "onBlock": 5,
          "remark": "frame trap heat engager",
          "createdAt": 1783451669434
        },
        {
          "id": 70,
          "characterName": "paul",
          "inputs": "WS/1/2",
          "frames": 15,
          "onHit": 2,
          "onBlock": -11,
          "remark": "transitions to SWA with b",
          "createdAt": 1783451705087
        },
        {
          "id": 71,
          "characterName": "paul",
          "inputs": "WS/2",
          "frames": 15,
          "onHit": 27,
          "onBlock": -14,
          "remark": "launcher",
          "createdAt": 1783451726283
        },
        {
          "id": 72,
          "characterName": "paul",
          "inputs": "WS/3/2",
          "frames": 13,
          "onHit": 17,
          "onBlock": -7,
          "remark": null,
          "createdAt": 1783451744396
        },
        {
          "id": 73,
          "characterName": "paul",
          "inputs": "WS/4",
          "frames": 11,
          "onHit": 5,
          "onBlock": -6,
          "remark": null,
          "createdAt": 1783451754090
        }
      ],
      "punishes": [
        {
          "id": 22,
          "characterName": "anna",
          "inputs": "1/2/1",
          "frames": 11,
          "createdAt": 1780705451587
        },
        {
          "id": 26,
          "characterName": "reina",
          "inputs": "2/2/1",
          "frames": 12,
          "createdAt": 1781546564177
        },
        {
          "id": 27,
          "characterName": "reina",
          "inputs": "df/2",
          "frames": 15,
          "createdAt": 1781546569267
        },
        {
          "id": 28,
          "characterName": "anna",
          "inputs": "df/2",
          "frames": 15,
          "createdAt": 1782212151486
        },
        {
          "id": 29,
          "characterName": "anna",
          "inputs": "2/3/next/CJM",
          "frames": 10,
          "createdAt": 1782212227607
        },
        {
          "id": 30,
          "characterName": "anna",
          "inputs": "df/1/2/next/HMC",
          "frames": 13,
          "createdAt": 1782212244559
        },
        {
          "id": 31,
          "characterName": "anna",
          "inputs": "1/2/1",
          "frames": 12,
          "createdAt": 1782212297767
        },
        {
          "id": 32,
          "characterName": "anna",
          "inputs": "3+4/next/HEATDASH",
          "frames": 14,
          "createdAt": 1782212314216
        },
        {
          "id": 33,
          "characterName": "reina",
          "inputs": "1/1/2/next/SEN",
          "frames": 10,
          "createdAt": 1782212458401
        },
        {
          "id": 34,
          "characterName": "reina",
          "inputs": "1/1/2/next/SEN",
          "frames": 11,
          "createdAt": 1782212471355
        },
        {
          "id": 35,
          "characterName": "reina",
          "inputs": "df/1/2/next/HEATDASH",
          "frames": 13,
          "createdAt": 1782212488437
        },
        {
          "id": 36,
          "characterName": "reina",
          "inputs": "f/f/2/next/SEN",
          "frames": 14,
          "createdAt": 1782212524439
        },
        {
          "id": 37,
          "characterName": "paul",
          "inputs": "2/3",
          "frames": 10,
          "createdAt": 1782213051666
        },
        {
          "id": 38,
          "characterName": "paul",
          "inputs": "2/3",
          "frames": 11,
          "createdAt": 1782213064220
        },
        {
          "id": 39,
          "characterName": "paul",
          "inputs": "b/1/2",
          "frames": 12,
          "createdAt": 1782213074293
        },
        {
          "id": 40,
          "characterName": "paul",
          "inputs": "f/2/next/HEATDASH",
          "frames": 13,
          "createdAt": 1782213088733
        },
        {
          "id": 41,
          "characterName": "paul",
          "inputs": "b/3",
          "frames": 14,
          "createdAt": 1782213098721
        },
        {
          "id": 42,
          "characterName": "paul",
          "inputs": "df/2",
          "frames": 15,
          "createdAt": 1782213213428
        }
      ],
      "combos": [
        {
          "id": 17,
          "characterName": "anna",
          "inputs": "4/next/uf/2/HMC/2/1/next/DASH/b/4/HMC/2/2/TORNADO/next/PLT/3/CJM/uf/3/next/db/2/PLT/2",
          "createdAt": 1781808510628
        },
        {
          "id": 18,
          "characterName": "reina",
          "inputs": "uf/1/WRA/next/df/n/3/4/next/DASH/df/1/next/f/2/3/next/SEN/1+2/TORNADO/next/WRA/d/df/f/n/f/f/3/next/3+4/4",
          "createdAt": 1782114893681
        },
        {
          "id": 19,
          "characterName": "reina",
          "inputs": "f/n/d/perfectframe/df/2/next/df/3/n/3/4/next/DASH/df/1/next/f/2/3/next/SEN/1+2/TORNADO/next/WRA/d/df/f/n/f/f/3/next/3+4/4",
          "createdAt": 1782115007581
        },
        {
          "id": 20,
          "characterName": "reina",
          "inputs": "f/f/f_h/4/d_h/next/WRA/df/n/3/4/next/DASH/df/1/next/f/2/3/f_h/next/df/1/f_h/next/SEN/1/d/df/f/2",
          "createdAt": 1782116156516
        },
        {
          "id": 21,
          "characterName": "anna",
          "inputs": "uf/2/next/HMC/2/1/next/DASH/b/4/db_h/next/WS/1/2/next/PLT/2",
          "createdAt": 1782116925933
        },
        {
          "id": 22,
          "characterName": "paul",
          "inputs": "4/next/df/4/next/2/next/DASH/3/2/b_h/next/SWA/df_h/DPD/2/1/TORNADO/next/d/df/f/df/f/DPD/df_h/1/next/f/f_h/2/perfectframe/1",
          "createdAt": 1782117354758
        },
        {
          "id": 23,
          "characterName": "paul",
          "inputs": "3/next/df/4/next/2/next/DASH/3/2/b_h/next/SWA/df_h/DPD/2/1/TORNADO/next/d/df/f/df/f/DPD/df_h/1/next/f/f_h/2/perfectframe/1",
          "createdAt": 1782117476229
        },
        {
          "id": 24,
          "characterName": "paul",
          "inputs": "d/df/f/1/next/df/4/next/3/2/b_h/next/SWA/df_h/DPD/2/1",
          "createdAt": 1782117896051
        },
        {
          "id": 26,
          "characterName": "paul",
          "inputs": "WALLSPLAT/next/d/db/b/3/2/1/TORNADO/next/d/1/3/2",
          "createdAt": 1782211792533
        },
        {
          "id": 28,
          "characterName": "anna",
          "inputs": "WALLSPLAT/next/f/1+2/TORNADO/next/f/3/next/HMC/2/1/2",
          "createdAt": 1782211918817
        },
        {
          "id": 29,
          "characterName": "anna",
          "inputs": "d/df/perfectframe/f/1/next/uf/2/HMC/2/1/next/DASH/b/4/HMC/2/2/TORNADO/next/PLT/3/CJM/uf/3/next/db/2/PLT/2",
          "createdAt": 1782212103791
        },
        {
          "id": 30,
          "characterName": "reina",
          "inputs": "WALLSPLAT/next/df/4/2/3/TORNADO/next/d/3+4/4",
          "createdAt": 1782782375424
        }
      ],
      "launchers": [
        {
          "id": 33,
          "characterName": "anna",
          "inputs": "uf/4",
          "comboId": 17,
          "createdAt": 1781808521254
        },
        {
          "id": 35,
          "characterName": "reina",
          "inputs": "df/2",
          "comboId": 18,
          "createdAt": 1782114898327
        },
        {
          "id": 36,
          "characterName": "reina",
          "inputs": "f/n/d/perfectframe/df/2",
          "comboId": 19,
          "createdAt": 1782115026378
        },
        {
          "id": 37,
          "characterName": "reina",
          "inputs": "uf/4",
          "comboId": 20,
          "createdAt": 1782116165468
        },
        {
          "id": 38,
          "characterName": "reina",
          "inputs": "df_h/TORNADO",
          "comboId": 20,
          "createdAt": 1782116175331
        },
        {
          "id": 39,
          "characterName": "anna",
          "inputs": "db/3",
          "comboId": 21,
          "createdAt": 1782116930752
        },
        {
          "id": 40,
          "characterName": "anna",
          "inputs": "FC/df/2",
          "comboId": 21,
          "createdAt": 1782116946346
        },
        {
          "id": 41,
          "characterName": "anna",
          "inputs": "df_h/TORNADO",
          "comboId": 21,
          "createdAt": 1782116953187
        },
        {
          "id": 42,
          "characterName": "anna",
          "inputs": "d/df/f/2/1",
          "comboId": 21,
          "createdAt": 1782116977151
        },
        {
          "id": 43,
          "characterName": "anna",
          "inputs": "CJM/uf/4",
          "comboId": 17,
          "createdAt": 1782117132456
        },
        {
          "id": 44,
          "characterName": "paul",
          "inputs": "df/2",
          "comboId": 22,
          "createdAt": 1782117359815
        },
        {
          "id": 46,
          "characterName": "paul",
          "inputs": "uf/4",
          "comboId": 22,
          "createdAt": 1782117386115
        },
        {
          "id": 47,
          "characterName": "paul",
          "inputs": "SWA/1+2",
          "comboId": 22,
          "createdAt": 1782117429180
        },
        {
          "id": 48,
          "characterName": "paul",
          "inputs": "uf/3",
          "comboId": 23,
          "createdAt": 1782117481119
        },
        {
          "id": 49,
          "characterName": "paul",
          "inputs": "WS/2",
          "comboId": 23,
          "createdAt": 1782117487286
        },
        {
          "id": 50,
          "characterName": "paul",
          "inputs": "DPD/df_h/1",
          "comboId": 23,
          "createdAt": 1782117532468
        },
        {
          "id": 51,
          "characterName": "paul",
          "inputs": "b/3",
          "comboId": 23,
          "createdAt": 1782117823454
        },
        {
          "id": 52,
          "characterName": "paul",
          "inputs": "d/df/f/1+2",
          "comboId": 24,
          "createdAt": 1782117901720
        },
        {
          "id": 53,
          "characterName": "paul",
          "inputs": "df_h/TORNADO",
          "comboId": 24,
          "createdAt": 1782117907652
        },
        {
          "id": 54,
          "characterName": "paul",
          "inputs": "d/df/f/1",
          "comboId": 22,
          "createdAt": 1782117982452
        },
        {
          "id": 56,
          "characterName": "paul",
          "inputs": "f/f_h/2/perfectframe/1",
          "comboId": 26,
          "createdAt": 1782211804464
        },
        {
          "id": 57,
          "characterName": "paul",
          "inputs": "b/1+2",
          "comboId": 26,
          "createdAt": 1782211833376
        },
        {
          "id": 59,
          "characterName": "anna",
          "inputs": "f/2/3",
          "comboId": 28,
          "createdAt": 1782211927909
        },
        {
          "id": 60,
          "characterName": "anna",
          "inputs": "b/1+2",
          "comboId": 28,
          "createdAt": 1782211934497
        },
        {
          "id": 61,
          "characterName": "anna",
          "inputs": "df/2",
          "comboId": 29,
          "createdAt": 1782212109046
        },
        {
          "id": 62,
          "characterName": "anna",
          "inputs": "CH/d/df/perfectframe/f/1",
          "comboId": 29,
          "createdAt": 1782212134510
        },
        {
          "id": 63,
          "characterName": "reina",
          "inputs": "b/1+2",
          "comboId": 30,
          "createdAt": 1782782383882
        }
      ],
      "stance_moves": [
        {
          "id": 2,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "1",
          "createdAt": 1782439069808
        },
        {
          "id": 3,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "1+2",
          "createdAt": 1782439116426
        },
        {
          "id": 4,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "1+3",
          "createdAt": 1782439162161
        },
        {
          "id": 5,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "2/1/2",
          "createdAt": 1782439195671
        },
        {
          "id": 6,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "2/2",
          "createdAt": 1782439231793
        },
        {
          "id": 7,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "3",
          "createdAt": 1782439291756
        },
        {
          "id": 8,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "4",
          "createdAt": 1782439314975
        },
        {
          "id": 9,
          "characterName": "anna",
          "stance": "HMC",
          "inputs": "b/3",
          "createdAt": 1782439340370
        },
        {
          "id": 10,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "1",
          "createdAt": 1782439387003
        },
        {
          "id": 12,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "1+2",
          "createdAt": 1782440208628
        },
        {
          "id": 13,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "2/1",
          "createdAt": 1782440230244
        },
        {
          "id": 15,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "3/2",
          "createdAt": 1782440267509
        },
        {
          "id": 16,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "4",
          "createdAt": 1782440285543
        },
        {
          "id": 17,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "d/3/3",
          "createdAt": 1782440310787
        },
        {
          "id": 18,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "uf/1",
          "createdAt": 1782440370620
        },
        {
          "id": 19,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "uf/2",
          "createdAt": 1782440383780
        },
        {
          "id": 20,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "uf/3",
          "createdAt": 1782440409679
        },
        {
          "id": 21,
          "characterName": "anna",
          "stance": "CJM",
          "inputs": "uf/4",
          "createdAt": 1782440425544
        },
        {
          "id": 22,
          "characterName": "anna",
          "stance": "PLT",
          "inputs": "1",
          "createdAt": 1782440457382
        },
        {
          "id": 23,
          "characterName": "anna",
          "stance": "PLT",
          "inputs": "2",
          "createdAt": 1782440462189
        },
        {
          "id": 24,
          "characterName": "anna",
          "stance": "PLT",
          "inputs": "3",
          "createdAt": 1782440496756
        },
        {
          "id": 25,
          "characterName": "anna",
          "stance": "PLT",
          "inputs": "4",
          "createdAt": 1782440519791
        },
        {
          "id": 32,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "1+2",
          "createdAt": 1783184151989
        },
        {
          "id": 33,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "1",
          "createdAt": 1783184189841
        },
        {
          "id": 34,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "2",
          "createdAt": 1783184211169
        },
        {
          "id": 35,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "3/2/1",
          "createdAt": 1783184247634
        },
        {
          "id": 36,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "4",
          "createdAt": 1783184760376
        },
        {
          "id": 37,
          "characterName": "paul",
          "stance": "SWA",
          "inputs": "3/2/3",
          "createdAt": 1783184782623
        },
        {
          "id": 38,
          "characterName": "paul",
          "stance": "DPD",
          "inputs": "df_h/1",
          "createdAt": 1783184850289
        },
        {
          "id": 39,
          "characterName": "paul",
          "stance": "DPD",
          "inputs": "df_h/2/1",
          "createdAt": 1783184873449
        },
        {
          "id": 40,
          "characterName": "paul",
          "stance": "DPD",
          "inputs": "df_h/2/3",
          "createdAt": 1783184894347
        },
        {
          "id": 41,
          "characterName": "paul",
          "stance": "DPD",
          "inputs": "df_h/4",
          "createdAt": 1783184923438
        },
        {
          "id": 42,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "1/comma/d/df/f/2",
          "createdAt": 1783271578921
        },
        {
          "id": 43,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "1+2",
          "createdAt": 1783271602778
        },
        {
          "id": 44,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "1+3",
          "createdAt": 1783271633446
        },
        {
          "id": 45,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "2",
          "createdAt": 1783271662372
        },
        {
          "id": 46,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "3",
          "createdAt": 1783271687138
        },
        {
          "id": 47,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "3+4",
          "createdAt": 1783271714764
        },
        {
          "id": 48,
          "characterName": "reina",
          "stance": "SEN",
          "inputs": "4",
          "createdAt": 1783271729208
        },
        {
          "id": 49,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "HEATDASH/d/3+4",
          "createdAt": 1783271806654
        },
        {
          "id": 50,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "1",
          "createdAt": 1783272084203
        },
        {
          "id": 51,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "1/4",
          "createdAt": 1783272093796
        },
        {
          "id": 52,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "1+2",
          "createdAt": 1783272114744
        },
        {
          "id": 54,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "1+3",
          "createdAt": 1783272159357
        },
        {
          "id": 55,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "2",
          "createdAt": 1783272253758
        },
        {
          "id": 56,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "3/4",
          "createdAt": 1783272276493
        },
        {
          "id": 57,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "3+4",
          "createdAt": 1783272286982
        },
        {
          "id": 58,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "4/2/2/comma/d/df/f/1+2",
          "createdAt": 1783272352267
        },
        {
          "id": 59,
          "characterName": "reina",
          "stance": "WRA",
          "inputs": "d/4/3",
          "createdAt": 1783272382459
        },
        {
          "id": 60,
          "characterName": "reina",
          "stance": "UNS",
          "inputs": "2",
          "createdAt": 1783272585767
        },
        {
          "id": 61,
          "characterName": "reina",
          "stance": "UNS",
          "inputs": "4",
          "createdAt": 1783272607852
        },
        {
          "id": 63,
          "characterName": "reina",
          "stance": "UNS",
          "inputs": "d/4",
          "createdAt": 1783272669500
        },
        {
          "id": 64,
          "characterName": "reina",
          "stance": "CD",
          "inputs": "1/3",
          "createdAt": 1783272696271
        }
      ]
  };

  /// Known character keys used when listing/selecting characters.
  final Set<String> characterNamesList = {
    "alisa",
    "anna",
    "armor-king",
    "asuka",
    "azucena",
    "bob",
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
    "roger",
    "shaheen",
    "steve",
    "victor",
    "xiaoyu",
    "yoshimitsu",
    "yujiro",
    "zafina",
  };

  /// Per-character stance definitions used to augment input grid with tokens.
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

  final List<String> incomingCharacters = ["bob", "roger", "yujiro"];

  /// Build the path to the portrait asset for a character.
  /// @param characterName internal key
  /// @return String asset path
  String getPath(String characterName) {
    return 'assets/images/character_images/${characterName.toLowerCase().replaceAll(' ', '-')}-portrait.png';
  }

  /// Human-friendly formatted name (capitalization and spaces).
  /// @param characterName internal key
  /// @return formatted display name
  String getBeautifulName(String characterName) {
    String tmp = (characterName[0].toUpperCase() + characterName.substring(1))
        .replaceAll('-', ' ');
    String res = tmp;
    if (tmp.contains(' ')) {
      int spaceIndex = tmp.indexOf(' ');
      if (spaceIndex != tmp.length - 1 &&
          RegExp(r'^[a-zA-Z]$').hasMatch(tmp[spaceIndex + 1])) {
        res =
            tmp.substring(0, spaceIndex + 1) +
            tmp[spaceIndex + 1].toUpperCase() +
            tmp.substring(spaceIndex + 2);
      }
    }
    return res;
  }

  /// Quick letter test helper used by internal formatting.
  /// @param c single character
  /// @return bool true if alphabetic
  bool isLetter(String c) {
    return RegExp(r'^[a-zA-Z]$').hasMatch(c);
  }

  /// Master list mapping codes to their input icon asset path.
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

  /// Show contextual help dialog for a page.
  /// @param pageType page identifier
  /// @param context BuildContext
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
      case PageType.stanceMoves:
        openStanceMovesHelpDialog(context);
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          'Here you can browse your saved characters in a responsive grid. '
          '\nUse the left sidebar to create a new character (NEW CHARACTER), open the database explorer (DATABASE) or access options (not implemented); collapse or expand the sidebar with the chevron. '
          '\nClick a character tile to open its detail view, or tap the trash icon on a tile to delete that character after confirmation.',
          style: TextStyle(color: Colors.white70),
        ),
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          'Choose the character you want to view and manage. You can always come back to this page to switch characters or access the home page.',
          style: TextStyle(color: Colors.white70),
        ),
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          'Here you’ll find the portrait, quick actions and a hub to manage data. '
          '\nTap CHEAT SHEET to open the Cheat Sheet. '
          '\nUse the list cards to open Key Moves, Punishes, Combos or Stances editors. '
          '\nClick the trash icon on the portrait to delete the character (confirmation shown).',
          style: TextStyle(color: Colors.white70),
        ),
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          ''
          '-> On this page, you can enter and save your favourite moves.\n'
          '-> On the left side, you can record and save the move/string.\n'
          '-> On the right side, you can manage your saved key moves.\n'
          '          - To delete a key move, click the trash icon on the right.',
          style: TextStyle(color: Colors.white70),
        ),
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          'Here you can compose punish strings using the input grid, choose a frames value from the dropdown and press Save to store the punish for that frame advantage. '
          '\nThe current composition area shows icons and wraps or scrolls when needed. '
          '\nSaved punishes appear in the panel with their frame value and can be deleted with the trash icon after confirmation.',
          style: TextStyle(color: Colors.white70),
        ),
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
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          ''
          'On this page, you can enter and save your favourite combos.\n'
          'On the left side, you can record and save your favourite combos.\n'
          'On the right side, you can manage your saved combos and link them to launchers for quick access.\n'
          '          - Each combo displays its inputs as icons. Below, you can see and manage its launchers.\n'
          '          - To add a launcher, click the "+ Add launcher" button and select from your saved launchers.\n'
          '          - To delete a launcher, click the red "X" on its chip.\n'
          '          - To delete an entire combo, click the trash icon on the right.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void openStanceMovesHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF0E1220),
        title: const Text(
          'HOW TO USE THIS PAGE',
          style: TextStyle(color: Colors.white70),
        ),
        content: const Text(
          'Here you can compose and save stance-specific moves. '
          '\nUse the input grid to build the input sequence, pick the stance from the dropdown and optionally add frames/on-hit/on-block/remark metadata. '
          '\nThe left panel shows the current composition with Save, Remove-last and Clear actions. '
          '\nSaved stance moves appear in the list with a stance badge and optional remark; delete an entry with the trash icon after confirmation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  /// Convert slash-separated inputs string to asset paths for chips.
  /// @param inputs slash-separated string
  /// @return List<String> asset paths
  List<String> pathFromInputs(String inputs) {
    final parts = inputs.split('/');
    var res = <String>[];
    for (var p in parts) {
      res.add('assets/images/inputs/${p.trim().toLowerCase()}.png');
    }
    return res;
  }
}
