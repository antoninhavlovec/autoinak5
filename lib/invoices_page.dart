import 'package:autoinak5/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:autoinak5/models/invoice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class InvoicesPage extends StatefulWidget {
  final FirestoreService _firestoreService = FirestoreService();

  InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  // Definice _selectedInvoices
  final Set<String> _selectedInvoices = {};
  bool _selectAll = false;
  List<Invoice> _allInvoices = []; // Přidáno: Pro uložení všech faktur

  Future<int?> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    print('invoices_page _loadEmployeeId called with employeeIdString: $employeeIdString');
    if (employeeIdString == null) {
      return null;
    }
    final intEmployeeId = int.tryParse(employeeIdString);
    print('intEmployeeId: $intEmployeeId');
    return intEmployeeId;
  }

  Future<void> _showNoteDialog(BuildContext context, Invoice invoice, String action) async {
    final noteController = TextEditingController();
    final employeeId = await _loadEmployeeId(); // Použij await pro získání hodnoty
    if (employeeId == null) {
      // Zpracování případu, kdy se ID nepodařilo načíst (např. zobraz hlášku)
      print('Chyba: Nepodařilo se načíst ID zaměstnance.');
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('Poznámka k faktuře ${invoice.interniCislo} - $action'),
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
                case 'Schváleno':
                  widget._firestoreService.approveInvoice(invoice.id, note,employeeId);
                  break;
                case 'Zamítnuto':
                  widget._firestoreService.rejectInvoice(invoice.id, note);
                  break;
                case 'Vráceno':
                  widget._firestoreService.returnInvoice(invoice.id, note);
                  break;
              }
              Navigator.pop(context); // Zavření dialogu s poznámkou
            },
            child: const Text('Potvrdit'),
          ),
        ],
      ),
    );
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
                  _approveSelectedInvoices(note);
                  break;
                case 'Zamítnuto':
                  _rejectSelectedInvoices(note);
                  break;
                case 'Vráceno':
                  _returnSelectedInvoices(note);
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

  void _approveSelectedInvoices(String note) {
    for (var invoiceId in _selectedInvoices) {
      widget._firestoreService.approveInvoice(invoiceId, note,_loadEmployeeId() as int);
    }
    setState(() {
      _selectedInvoices.clear();
    });
  }

  void _rejectSelectedInvoices(String note) {
    for (var invoiceId in _selectedInvoices) {
      widget._firestoreService.rejectInvoice(invoiceId, note);
    }
    setState(() {
      _selectedInvoices.clear();
    });
  }

  void _returnSelectedInvoices(String note) {
    for (var invoiceId in _selectedInvoices) {
      widget._firestoreService.returnInvoice(invoiceId, note);
    }
    setState(() {
      _selectedInvoices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        title: const Text('Faktury'),
        title: Image.asset('asset/pict/faktury.png', height: 18),
        //backgroundColor: Color(0xFFCBEAFF),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
/*          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              widget._firestoreService.debugInvoices();
            },
          ),*/
          Checkbox(
            value: _selectAll,
            onChanged: (bool? value) {
              setState(() {
                _selectAll = value ?? false;
                _selectedInvoices.clear(); // Vždy vyčistíme před aktualizací
                if (_selectAll) {
                  _selectedInvoices.addAll(_allInvoices.map((invoice) => invoice.id));
                }
              });
            },
          ),

          if (_selectedInvoices.isNotEmpty)
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
                const PopupMenuItem<String>(
                  value: 'Vráceno',
                  child: Text('Vrátit vybrané'),
                ),
              ],
            ),
        ],
      ),
      body: FutureBuilder<int?>(
        future: _loadEmployeeId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final employeeId = snapshot.data;
            if (employeeId == null) {
              return const Center(child: Text('Zaměstnanec nenalezen'));
            }
            return StreamBuilder<(List<Invoice>, int)>(
              stream: widget._firestoreService.getInvoicesWithCount(employeeId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data;
                if (data == null || data.$1.isEmpty) {
                  return const Center(child: Text('Žádné faktury nenalezeny'));
                }
                final invoices = data.$1; // Přístup k seznamu faktur pomocí data.$1
                print("Invoicec_page - Seznam faktur aktualizován - ${invoices.length} faktur");
                _allInvoices = invoices; // Uložíme všechny faktury
                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final formattedDatumSplatnosti =
                    invoice.datumSplatnosti != null
                        ? DateFormat(
                      'dd.MM.yyyy',
                    ).format(invoice.datumSplatnosti!)
                        : 'N/A';
                    final formattedCenaCelkem = invoice.cenaCelkem != null
                        ? NumberFormat("#,###", "cs_CZ")
                        .format(invoice.cenaCelkem)
                        .replaceAll(",", " ")
                        : "N/A"; //Kód pro formátování
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 04.0, vertical: 02.0), //Zmenšení horizontálního paddingu
                      child: Card(//Container(
                        margin: EdgeInsets.symmetric(horizontal: 02.0, vertical: 0.0), // Zde nastavíme odsazení okraje
/*                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // Barva okraje
                            width: 1.0, // Šířka okraje
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Kulaté rohy
                      ),*/
                      child: Column( // Zde jsme obalili GestureDetector a Divider do Column
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Kliknutí na fakturu pro zobrazení detailů
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                  title: Text(
                                    'Detaily faktury: ${invoice.interniCislo}',
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('Organizace: ${invoice.orgNazev}'),
                                        Text('IČO: ${invoice.orgIco}'),
                                        Text(
                                          'Datum splatnosti: $formattedDatumSplatnosti',
                                        ),
                                        Text(
                                          'Stav schvalování: ${invoice.stavSchvalovani}',
                                        ),
                                        Text(
                                          '1. schvalovatel: ${invoice.prvniSchvalovatelJmeno}',
                                        ),
                                        Text(
                                          '2. schvalovatel: ${invoice.druhySchvalovatelJmeno}',
                                        ),
                                        Text(
                                          'Cena: $formattedCenaCelkem Kč',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Poznámka: ${invoice.poznamka ?? ''}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Future.delayed(
                                          Duration(milliseconds: 100),
                                              () {
                                            _showNoteDialog(
                                              context,
                                              invoice,
                                              'Schváleno',
                                            );
                                          },
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Schválit'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        //                                      Navigator.pop(context);
                                        Future.delayed(
                                          Duration(milliseconds: 100),
                                              () {
                                            _showNoteDialog(
                                              context,
                                              invoice,
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
                                        //                                      Navigator.pop(context);
                                        Future.delayed(
                                          Duration(milliseconds: 100),
                                              () {
                                            _showNoteDialog(
                                              context,
                                              invoice,
                                              'Vráceno',
                                            );
                                          },
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Vrátit'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Row( // Zde je kód pro Row
                              children: [
                                Padding( // Zde přidáváme odsazení checkboxu
                                  padding: EdgeInsets.only(left: 0.0), //Nastavujeme odsazení zleva
                                  child: SizedBox(
                                    width: 40, // Nastavení pevné šířky pro Checkbox
                                    child: Checkbox(
                                      value: _selectedInvoices.contains(invoice.id),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedInvoices.add(invoice.id);
                                          } else {
                                            _selectedInvoices.remove(invoice.id);
                                          }
                                          _selectAll = _selectedInvoices.length == _allInvoices.length;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(// Obalení Columnu widgetem Padding
                                    padding: const EdgeInsets.only(left: 0.0), // Odsazení z leva
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(invoice.orgNazev,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            )
                                        ),
                                        Text('Č. fak.: ${invoice.interniCislo}'),
                                        Text(
                                          'Splat.: $formattedDatumSplatnosti',
                                        ),
                                        if (invoice.poznamka != null && invoice.poznamka!.isNotEmpty)
                                          Text('Poz: ${invoice.poznamka}'),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding( // Přidali jsme Padding
                                  padding: const EdgeInsets.only(right: 15.0), // Upravujeme odsazení zprava na 0.0
                                  child:Text(
                                    '$formattedCenaCelkem Kč',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
//                          Divider(), // Přidali jsme Divider
                        ],
                      ),
                      )
                    );
                    return null;
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
