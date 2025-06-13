import 'package:autoinak5/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_objednavky_page.dart';
import 'models/objednavka.dart';

class ObjednavkyPage extends StatefulWidget {
  final int employeeId;
  final FirestoreService
  firestoreService; // Přidali jsme final FirestoreService firestoreService;

  const ObjednavkyPage({
    super.key,
    required this.employeeId,
    required this.firestoreService, // a required this.firestoreService,
  });

  @override
  State<ObjednavkyPage> createState() => _ObjednavkyPageState();
}

class _ObjednavkyPageState extends State<ObjednavkyPage> {
  final _zakaznikController = TextEditingController();
  final _icoController = TextEditingController();
  final _dicController = TextEditingController();
  final _modelController = TextEditingController();
  final _telefonController = TextEditingController();
  int? _employeeId;

  FirestoreService get _firestoreService => widget.firestoreService;
  List<Objednavka> _searchResults = [];

  Future<int?> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    _employeeId = int.tryParse(
      employeeIdString ?? '',
    ); // Použij prázdný řetězec pro tryParse, pokud je null
    print(
      'objednavka_page _loadEmployeeId called with employeeIdString: $employeeIdString',
    );
    if (employeeIdString == null) {
      return null;
    }
    final intEmployeeId = int.tryParse(employeeIdString);
    print('intEmployeeId: $intEmployeeId');
    return intEmployeeId;
  }

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  @override
  void dispose() {
    _zakaznikController.dispose();
    _icoController.dispose();
    _dicController.dispose();
    _modelController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  //void _onSearchChanged() {
  //  _searchObjednavky();
  //}

  Future<void> _searchObjednavky() async {
    final zakaznik = _zakaznikController.text;
    final ico = _icoController.text;
    final dic = _dicController.text;
    final model = _modelController.text;
    final telefon = _telefonController.text;

    final results = await _firestoreService.searchObjednavky(
      zakaznik: zakaznik,
      ico: ico,
      dic: dic,
      model: model,
      telefon: telefon,
      employeeId: _employeeId,
    );
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('asset/pict/objednavky.png', height: 20),
        //backgroundColor: Color(0xFFCBEAFF),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            kToolbarHeight * 5,
          ), // Zvětšíme prostor pro tlačítko
          child: Container(
            // Obalíme Padding do Containeru
            color:
                Theme.of(
                  context,
                ).scaffoldBackgroundColor, // Barva pozadí stránky
            //            color: const Color(0xFFF0F0F0),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 8.0,
                right: 8.0,
                bottom: 30.0,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _zakaznikController,
                    decoration: const InputDecoration(hintText: 'Zákazník'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _icoController,
                          decoration: const InputDecoration(hintText: 'IČO'),
                        ),
                      ),
                      const SizedBox(width: 8), // Mezera mezi poli
                      Expanded(
                        child: TextField(
                          controller: _dicController,
                          decoration: const InputDecoration(hintText: 'DIČ'),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(hintText: 'Model'),
                  ),
                  TextField(
                    controller: _telefonController,
                    decoration: const InputDecoration(hintText: 'Telefon'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        _searchObjednavky, // Voláme _searchObjednavky po stisknutí
                    child: const Text('Vyhledat'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body:
          _searchResults.isEmpty
              ? const Center(
                child: Text(
                  'Zadejte kritéria vyhledávání a stiskněte "Vyhledat"...',
                ),
              )
              : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final objednavka = _searchResults[index];
                  final datumSepsani =
                      objednavka.udaInoZavaznaObjednavkaDatumSepsani;
                  final formattedDatumSepsani =
                      datumSepsani != null
                          ? DateFormat('dd.MM.yyyy').format(
                            DateTime.parse(datumSepsani),
                          ) // Převod
                          : 'Není k dispozici';
                  final formattedCenaCelkem =
                      objednavka.inoSrvszakHlavickaCenaCelkem != null
                          ? NumberFormat("#,###", "cs_CZ")
                              .format(objednavka.inoSrvszakHlavickaCenaCelkem)
                              .replaceAll(",", " ")
                          : "N/A"; //Kód pro formátování
                  return GestureDetector(
                    onTap: () {
                      // Zde implementuj navigaci na stránku s detaily objednávky
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailObjednavkyPage(
                                objednavka: objednavka,
                              ), // Předpokládáme, že máš stránku DetailObjednavkyPage
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Zákazník: ${objednavka.subjektyNazevSubjektu.isEmpty ? '' : objednavka.subjektyNazevSubjektu}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6), // Mezera mezi poli
                                Text(
                                  '${objednavka.organizaceNazevSubjektu == null || objednavka.organizaceNazevSubjektu!.isEmpty ? '' : objednavka.organizaceNazevSubjektu}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'IČO: ${objednavka.inoSrvszakHlavickaOrganizaceIco.isEmpty ? '' : objednavka.inoSrvszakHlavickaOrganizaceIco}',
                                ),
                                const SizedBox(width: 8), // Mezera mezi poli
                                Text(
                                  'DIČ: ${objednavka.inoSrvszakHlavickaOrganizaceDic.isEmpty ? '' : objednavka.inoSrvszakHlavickaOrganizaceDic}',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Model: ${objednavka.inoTypVozidlaInoNazevNad}',
                                ),
                                const SizedBox(width: 6), // Mezera mezi poli
                                Text(objednavka.inoZnackamodelExp48481880),
                                const SizedBox(width: 6), // Mezera mezi poli
                              ],
                            ),
                            Text('Motor: ${objednavka.inoZnackamodelMotor}'),
                            Text(
                              'Cena: $formattedCenaCelkem Kč',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Objednávka č.: ${objednavka.inoSrvszakHlavickaReferenceSubjektu}',
                            ),
                            Text('Stav: ${objednavka.inoSrvszakHlavickaStav}'),
                            Text('Datum sepsaní: $formattedDatumSepsani'),
                            // ... Další pole podle potřeby ...
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
