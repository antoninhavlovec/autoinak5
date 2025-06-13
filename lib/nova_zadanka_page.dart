import 'package:autoinak5/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NovaZadankaPage extends StatefulWidget {
  final FirestoreService firestoreService = FirestoreService();

  NovaZadankaPage({super.key});

  @override
  State<NovaZadankaPage> createState() => _NovaZadankaPageState();
}

class _NovaZadankaPageState extends State<NovaZadankaPage> {
  DateTime? _datumOd;
  DateTime? _datumDo;
  bool _pulDneOd = false;
  bool _pulDneDo = false;
  final _poznamkaController = TextEditingController();
  int? _employeeId;
  String? _employeeName;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeId = int.tryParse(prefs.getString('employeeId') ?? '');
      _employeeName = prefs.getString('employeeName');
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDatumOd) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDatumOd) {
          _datumOd = picked;
        } else {
          _datumDo = picked;
        }
      });
    }
  }

  int _calculatePracovniDny(DateTime datumOd, DateTime datumDo) {
    int pracovniDny = 0;
    for (
      DateTime den = datumOd;
      den.isBefore(datumDo.add(const Duration(days: 1)));
      den = den.add(const Duration(days: 1))
    ) {
      if (den.weekday != DateTime.saturday && den.weekday != DateTime.sunday) {
        pracovniDny++;
      }
    }
    return pracovniDny;
  }

  Future<void> _submitZadanka() async {
    if (_datumOd == null || _datumDo == null || _employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyplňte prosím všechna pole.')),
      );
      return;
    }

    int dnyCerpani = _calculatePracovniDny(_datumOd!, _datumDo!);
    if (dnyCerpani < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyberte minimálně jeden pracovný den.')),
      );
      return;
    }

    final zadankaData = {
      'created_at': Timestamp.now(),
      'datumOd': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_datumOd!),
      'datumDo': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_datumDo!),
      'dnyCerpani': dnyCerpani,
      'odeslano': 'Ne',
      'poznamka': _poznamkaController.text,
      'pulDneOd': _pulDneOd ? 'Ano' : 'Ne',
      'pulDneDo': _pulDneDo ? 'Ano' : 'Ne',
      'schvaleno': 'Ne',
      'schvalovateId': 0,
      'schvalovateJmeno': '',
      'typZadanky': 'Dovolená',
      'zamestnanecId': _employeeId,
      'zamestnanecJmeno': "",
      'zruseno': 'Ne',
      'poznamkaSchvalovatel': "",
    };

    try {
      await widget.firestoreService.createZadanka(zadankaData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Žádanka byla úspěšně vytvořena.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba při vytváření žádanky: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nová žádanka'),
        //          backgroundColor: const Color(0xFFCBEAFF)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                _datumOd == null
                    ? 'Datum od'
                    : 'Datum od: ${DateFormat('dd.MM.yyyy').format(_datumOd!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(
                _datumDo == null
                    ? 'Datum do'
                    : 'Datum do: ${DateFormat('dd.MM.yyyy').format(_datumDo!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            Row(
              children: [
                Checkbox(
                  value: _pulDneOd,
                  onChanged: (value) {
                    setState(() {
                      _pulDneOd = value!;
                    });
                  },
                ),
                const Text('Půl dne od'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _pulDneDo,
                  onChanged: (value) {
                    setState(() {
                      _pulDneDo = value!;
                    });
                  },
                ),
                const Text('Půl dne do'),
              ],
            ),
            TextField(
              controller: _poznamkaController,
              decoration: const InputDecoration(
                labelText: 'Poznámka',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitZadanka,
              child: const Text('Vytvořit žádanku'),
            ),
          ],
        ),
      ),
    );
  }
}
