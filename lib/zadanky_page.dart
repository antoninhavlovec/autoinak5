import 'package:autoinak5/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:autoinak5/models/zadanka.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'nova_zadanka_page.dart';
import '../services/firestore_service.dart';

class ZadankyPage extends StatefulWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final VoidCallback onRequestsChanged; // Přidán callback

  ZadankyPage({Key? key, required this.onRequestsChanged}) : super(key: key);

  @override
  State<ZadankyPage> createState() => _ZadankyPageState();
}

class _ZadankyPageState extends State<ZadankyPage> {
  final Set<String> _selectedZadanky = {};
  int? _employeeId;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  Future<void> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    if (employeeIdString != null) {
      setState(() {
        _employeeId = int.tryParse(employeeIdString);
      });
    }
  }

  void _showNoteDialog(BuildContext context, Zadanka zadanka, String action) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Poznámka k žádance ${zadanka.zadankaId} - $action'),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Zadejte poznámku'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zrušit'),
              ),
              TextButton(
                onPressed: () {
                  final note = noteController.text;
                  switch (action) {
                    case 'Schvaleno':
                      widget._firestoreService.approveZadanka(zadanka.id, note);
                      break;
                    case 'Zamítnuto':
                      widget._firestoreService.rejectZadanka(zadanka.id, note);
                      break;
                  }
                  Navigator.pop(context);
                },
                child: const Text('Potvrdit'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'schváleno':
        return Colors.green.withAlpha(128); // Zelená s poloviční průhledností
      case 'zamítnuto':
        return Colors.red.withAlpha(128); // Červená s poloviční průhledností
      case 'odesláno':
        return Colors.yellow.withAlpha(50); // Žlutá s poloviční průhledností
      case 'neodesláno':
        return Colors.grey.withAlpha(50); // Šedá s poloviční průhledností
      default:
        return Colors.transparent; // Výchozí je průhledná
    }
  }

  void _showBulkNoteDialog(BuildContext context, String action) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Poznámka k hromadné akci - $action'),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Zadejte poznámku'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zrušit'),
              ),
              TextButton(
                onPressed: () {
                  final note = noteController.text;
                  switch (action) {
                    case 'Schvaleno':
                      _approveSelectedZadanky(note);
                      break;
                    case 'Zamítnuto':
                      _rejectSelectedZadanky(note);
                      break;
                  }
                  Navigator.pop(context);
                },
                child: const Text('Potvrdit'),
              ),
            ],
          ),
    );
  }

  void _approveSelectedZadanky(String note) {
    for (var zadankaId in _selectedZadanky) {
      widget._firestoreService.approveZadanka(zadankaId, note);
    }
    setState(() {
      _selectedZadanky.clear();
    });
    widget.onRequestsChanged(); // Zavolání callbacku
  }

  void _rejectSelectedZadanky(String note) {
    for (var zadankaId in _selectedZadanky) {
      widget._firestoreService.rejectZadanka(zadankaId, note);
    }
    setState(() {
      _selectedZadanky.clear();
    });
    widget.onRequestsChanged(); // Zavolání callbacku
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          //          title: const Text('Žádanky'),
          title: Image.asset('asset/pict/zadanky.png', height: 15),
          //          backgroundColor: Color(0xFFfdf2cf),
          backgroundColor: Color(0xFFCBEAFF),
          bottom: const TabBar(
            tabs: [Tab(text: 'Moje žádanky'), Tab(text: 'Ke schválení')],
          ),
          actions: [
            if (_selectedZadanky.isNotEmpty)
              PopupMenuButton<String>(
                onSelected: (String value) {
                  _showBulkNoteDialog(context, value);
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Schvaleno',
                        child: Text('Schválit vybrané'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Zamítnuto',
                        child: Text('Zamítnout vybrané'),
                      ),
                    ],
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NovaZadankaPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            // Moje žádanky
            _employeeId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Zadanka>>(
                  stream: widget._firestoreService.getMyZadanky(_employeeId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final zadanky = snapshot.data;
                    if (zadanky == null || zadanky.isEmpty) {
                      return const Center(child: Text('Žádné žádanky'));
                    }
                    return ListView.separated(
                      itemCount: zadanky.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 0);
                      },
                      itemBuilder: (context, index) {
                        final zadanka = zadanky[index];
                        final formattedDatumOd = DateFormat(
                          'dd.MM.yyyy',
                        ).format(DateTime.parse(zadanka.datumOd));
                        final formattedDatumDo = DateFormat(
                          'dd.MM.yyyy',
                        ).format(DateTime.parse(zadanka.datumDo));
                        return ListTile(
                          visualDensity: VisualDensity.compact,
                          minVerticalPadding:
                              0, // Přidáno: Minimální vertikální padding
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 06.0,
                            vertical: 2.0,
                          ),
                          title: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 09.0,
                              vertical: 02.0,
                            ), //Zmenšení horizontálního paddingu

                            decoration: BoxDecoration(
                              color: _getStatusColor(zadanka.status),
                              border: Border.all(
                                color: Colors.grey, // Barva okraje
                                width: 1.0, // Šířka okraje
                              ),
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ), // Kulaté rohy
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$formattedDatumOd - $formattedDatumDo',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Typ: ${zadanka.typZadanky}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Poznámka: ${zadanka.poznamka ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Schvalovatel: ${zadanka.schvalovateJmeno}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Dny čerpání: ${zadanka.dnyCerpani}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      zadanka.status,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            // Ke schválení
            _employeeId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<(List<Zadanka>, int)>(
                  stream: widget._firestoreService.getZadankyWithCount(
                    _employeeId!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data =
                        snapshot.data; // Získání dat (tuple: (List<Zadanka>, int))
                    if (data == null || data.$1.isEmpty) {
                      // Kontrola prázdného seznamu
                      return const Center(child: Text('Žádné žádanky'));
                    }
                    final zadanky = data.$1; // Získání seznamu žádostí
                    final count = data.$2; // Získání počtu (pokud chceš zobrazit)
                    return ListView.separated(
                      itemCount: zadanky.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 0);
                      },
                      itemBuilder: (context, index) {
                        final zadanka = zadanky[index];
                        final formattedDatumOd = DateFormat(
                          'dd.MM.yyyy',
                        ).format(DateTime.parse(zadanka.datumOd));
                        final formattedDatumDo = DateFormat(
                          'dd.MM.yyyy',
                        ).format(DateTime.parse(zadanka.datumDo));
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 2.0,
                          ), // Přidali jsme Padding
                          child: GestureDetector(
                            // Přidali jsme GestureDetector
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (detailContext) => AlertDialog(
                                      title: Text(
                                        'Detaily žádanky: ${zadanka.zadankaId}',
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Typ: ${zadanka.typZadanky}'),
                                            Text(
                                              'Zaměstnanec: ${zadanka.zamestnanecJmeno}',
                                            ),
                                            Text('Datum od: $formattedDatumOd'),
                                            Text('Datum do: $formattedDatumDo'),
                                            Text(
                                              'Dny čerpání: ${zadanka.dnyCerpani}',
                                            ),
                                            Text(
                                              'Půl dne od: ${zadanka.pulDneOd}',
                                            ),
                                            Text(
                                              'Půl dne do: ${zadanka.pulDneDo}',
                                            ),
                                            Text(
                                              'Poznámka: ${zadanka.poznamka ?? ''}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Future.delayed(
                                              Duration(milliseconds: 10),
                                              () {
                                                _showNoteDialog(
                                                  context,
                                                  zadanka,
                                                  'Schvaleno',
                                                );
                                              },
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Schválit'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Future.delayed(
                                              Duration(milliseconds: 10),
                                              () {
                                                _showNoteDialog(
                                                  context,
                                                  zadanka,
                                                  'Zamítnuto',
                                                );
                                              },
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Zamítnout'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(detailContext);
                                          },
                                          child: const Text('Zavřít'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: Container(
                              // Přidali jsme Container
                              decoration: BoxDecoration(
//                                color: _getStatusColor(zadanka.status),
                                border: Border.all(
                                  color: Colors.grey, // Barva okraje
                                  width: 1.0, // Šířka okraje
                                ),
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ), // Kulaté rohy
                              ),
                              child: Row(
                                // Přidali jsme Row
                                children: [
                                  Padding(
                                    // Přidali jsme Padding
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                      vertical: 9.0,
                                    ), // Nastavujeme odsazení zleva
                                    child: SizedBox(
                                      width:
                                          40, // Nastavení pevné šířky pro Checkbox
                                      child: Checkbox(
                                        value: _selectedZadanky.contains(
                                          zadanka.id,
                                        ),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedZadanky.add(zadanka.id);
                                            } else {
                                              _selectedZadanky.remove(
                                                zadanka.id,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0,
                                        vertical: 5.0,
                                      ), //Zmenšení horizontálního paddingu
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            zadanka.zamestnanecJmeno,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '$formattedDatumOd - $formattedDatumDo',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Typ: ${zadanka.typZadanky}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Poznámka: ${zadanka.poznamka ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    // Přidali jsme Padding
                                    padding: const EdgeInsets.only(
                                      right: 10.0,
                                    ), // Odsazení zprava
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Dny čerpání: ${zadanka.dnyCerpani}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
