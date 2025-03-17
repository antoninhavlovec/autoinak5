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

  Future<int?> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    print('employeeIdString: $employeeIdString');
    if (employeeIdString == null) {
      return null;
    }
    final intEmployeeId = int.tryParse(employeeIdString);
    print('intEmployeeId: $intEmployeeId');
    return intEmployeeId;
  }

  void _showNoteDialog(BuildContext context, Invoice invoice, String action) {
    final noteController = TextEditingController();
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
                      widget._firestoreService.approveInvoice(invoice.id, note);
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
      widget._firestoreService.approveInvoice(invoiceId, note);
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
        title: const Text('Faktury'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              widget._firestoreService.debugInvoices();
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
              return const Center(child: Text('Employee ID not set'));
            }
            return StreamBuilder<List<Invoice>>(
              stream: widget._firestoreService.getInvoices(employeeId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final invoices = snapshot.data;
                if (invoices == null || invoices.isEmpty) {
                  return const Center(child: Text('Žádné faktury nenalezeny'));
                }
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
                    return ListTile(
                      leading: Checkbox(
                        value: _selectedInvoices.contains(invoice.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedInvoices.add(invoice.id);
                            } else {
                              _selectedInvoices.remove(invoice.id);
                            }
                          });
                        },
                      ),
                      title: Text(invoice.interniCislo),
                      subtitle: Text(
                        '${invoice.orgNazev} - $formattedDatumSplatnosti',
                      ),
                      trailing: Text(
                        '${invoice.cenaCelkem != null ? invoice.cenaCelkem.toString() : "N/A"} Kč',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                                        'Datum splatnosti: ${formattedDatumSplatnosti}',
                                      ),
                                      Text(
                                        'Stav schvalování: ${invoice.stavSchvalovani}',
                                      ),
                                      Text(
                                        'Cena: ${invoice.cenaCelkem != null ? invoice.cenaCelkem.toString() : "N/A"}',
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
                                      Navigator.pop(context);
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
                                      Navigator.pop(context);
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
                    );
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
