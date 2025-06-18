import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/objednavka.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailObjednavkyPage extends StatelessWidget {
  final Objednavka objednavka;

  const DetailObjednavkyPage({super.key, required this.objednavka});

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final formattedCenaCelkem =
        objednavka.inoSrvszakHlavickaCenaCelkem != null
            ? NumberFormat("#,###", "cs_CZ")
                .format(objednavka.inoSrvszakHlavickaCenaCelkem)
                .replaceAll(",", " ")
            : "N/A"; //Kód pro formátování
    final datumVzniku = objednavka.subjektyDatumVzniku0001;
    final formattedDatumVzniku =
        datumVzniku != null
            ? DateFormat('dd.MM.yyyy').format(
              DateTime.parse(datumVzniku),
            ) // Převod na DateTime
            : 'Není k dispozici';

    final datumZavaznaObjednavka = objednavka.udaInoZavaznaObjednavkaDatumFa;
    final formattedDatumZavaznaObjednavka =
        datumZavaznaObjednavka != null
            ? DateFormat('dd.MM.yyyy').format(
              DateTime.parse(datumZavaznaObjednavka),
            ) // Převod
            : 'Není k dispozici';

    final datumSepsani = objednavka.udaInoZavaznaObjednavkaDatumSepsani;
    final formattedDatumSepsani =
        datumSepsani != null
            ? DateFormat('dd.MM.yyyy').format(
              DateTime.parse(datumSepsani),
            ) // Převod
            : 'Není k dispozici';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail objednávky')),
      body: SingleChildScrollView(
        // Obalíme obsah do SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Objednávka č.: ${objednavka.inoSrvszakHlavickaReferenceSubjektu}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Stav: ${objednavka.inoSrvszakHlavickaStav}'),
              Text(
                'Zákazník: ${objednavka.subjektyNazevSubjektu.isEmpty ? '' : objednavka.subjektyNazevSubjektu}',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              Text(
                'Ulice: ${objednavka.inoSrvszakHlavickaUlice.isEmpty ? '' : objednavka.inoSrvszakHlavickaUlice} ${objednavka.inoSrvszakHlavickaCisloCp.isEmpty ? '' : objednavka.inoSrvszakHlavickaCisloCp}',
              ),
              Text(
                'Misto: ${objednavka.inoSrvszakHlavickaMisto.isEmpty ? '' : objednavka.inoSrvszakHlavickaMisto} ${objednavka.inoSrvszakHlavickaPsc.isEmpty ? '' : objednavka.inoSrvszakHlavickaPsc}',
              ),
              GestureDetector(
                onTap: () async {
                  final email = objednavka.inoSrvszakHlavickaEmail;
                  if (email.isNotEmpty) {
                    final url = Uri(
                      scheme: 'mailto',
                      path: email,
                      query: encodeQueryParameters(<String, String>{
                        'subject':
                            'Objednávka č. ${objednavka.inoSrvszakHlavickaReferenceSubjektu}',
                      }),
                    );
                    print('URL pro email: $url'); // Přidáno pro výpis URL
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nepodařilo se otevřít emailového klienta.',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emailová adresa není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Email: ${objednavka.inoSrvszakHlavickaEmail}',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final telefon = objednavka.inoSrvszakHlavickaTelefonMobil;
                  if (telefon.isNotEmpty) {
                    final url = Uri.parse('tel:$telefon');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      // Zpracuj případ, kdy se volání nepodaří (např. zobraz chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nepodařilo se zahájit hovor.'),
                        ),
                      );
                    }
                  } else {
                    // Zpracuj případ, kdy telefonní číslo není k dispozici
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telefonní číslo není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Telefon mobil: ${objednavka.inoSrvszakHlavickaTelefonMobil ?? 'Není k dispozici'}',
                  style: TextStyle(
                    color:
                        Colors
                            .blue, // Nebo jiná barva pro zvýraznění klikatelnosti
                    decoration:
                        TextDecoration
                            .underline, // Podtržení pro indikaci klikatelnosti
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final telefon = objednavka.inoSrvszakHlavickaTelefon;
                  if (telefon != null && telefon.isNotEmpty) {
                    final url = Uri.parse('tel:$telefon');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      // Zpracuj případ, kdy se volání nepodaří (např. zobraz chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nepodařilo se zahájit hovor.'),
                        ),
                      );
                    }
                  } else {
                    // Zpracuj případ, kdy telefonní číslo není k dispozici
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telefonní číslo není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Telefon mobil: ${objednavka.inoSrvszakHlavickaTelefon ?? ''}',
                  style: TextStyle(
                    color:
                        Colors
                            .blue, // Nebo jiná barva pro zvýraznění klikatelnosti
                    decoration:
                        TextDecoration
                            .underline, // Podtržení pro indikaci klikatelnosti
                  ),
                ),
              ),
              Divider(),
              Text(
                'Zákazník 2: ${objednavka.organizaceNazevSubjektu == null || objednavka.organizaceNazevSubjektu!.isEmpty ? '' : objednavka.organizaceNazevSubjektu}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'IČO: ${objednavka.organizaceIco == null || objednavka.organizaceIco!.isEmpty ? '' : objednavka.organizaceIco}',
                  ),
                  const SizedBox(width: 8), // Mezera mezi poli
                  Text(
                    'DIČ: ${objednavka.organizaceDic == null || objednavka.organizaceDic!.isEmpty ? '' : objednavka.organizaceDic}',
                  ),
                ],
              ),
              Text(
                'Ulice: ${objednavka.organizaceUliceDs == null || objednavka.organizaceUliceDs!.isEmpty ? '' : objednavka.organizaceUliceDs} ${objednavka.organizaceCisloCp == null || objednavka.organizaceCisloCp!.isEmpty ? '' : objednavka.organizaceCisloCp}',
              ),
              Text(
                'Misto: ${objednavka.organizaceMisto == null || objednavka.organizaceMisto!.isEmpty ? '' : objednavka.organizaceMisto} ${objednavka.organizacePsc == null || objednavka.organizacePsc!.isEmpty ? '' : objednavka.organizacePsc}',
              ),
              GestureDetector(
                onTap: () async {
                  final email = objednavka.organizaceEmail;
                  if (email != null && email.isNotEmpty) {
                    final url = Uri(
                      scheme: 'mailto',
                      path: email,
                      query: encodeQueryParameters(<String, String>{
                        'subject':
                            'Objednávka č. ${objednavka.inoSrvszakHlavickaReferenceSubjektu}',
                        //                        'body': 'Dobrý den,\n\nOdpovídám na Vaši objednávku číslo ${objednavka.objednavkaId}.\n\nS pozdravem,\n[Tvoje jméno]',
                      }),
                    );
                    print('URL pro email: $url'); // Přidáno pro výpis URL
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nepodařilo se otevřít emailového klienta.',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emailová adresa není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Email: ${objednavka.organizaceEmail ?? ''}',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final telefon = objednavka.organizaceTelefonMobil;
                  if (telefon != null && telefon.isNotEmpty) {
                    final url = Uri.parse('tel:$telefon');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      // Zpracuj případ, kdy se volání nepodaří (např. zobraz chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nepodařilo se zahájit hovor.'),
                        ),
                      );
                    }
                  } else {
                    // Zpracuj případ, kdy telefonní číslo není k dispozici
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telefonní číslo není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Telefon mobil: ${objednavka.organizaceTelefonMobil ?? ''}',
                  style: TextStyle(
                    color:
                        Colors
                            .blue, // Nebo jiná barva pro zvýraznění klikatelnosti
                    decoration:
                        TextDecoration
                            .underline, // Podtržení pro indikaci klikatelnosti
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final telefon = objednavka.organizaceTelefon;
                  if (telefon != null && telefon.isNotEmpty) {
                    final url = Uri.parse('tel:$telefon');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      // Zpracuj případ, kdy se volání nepodaří (např. zobraz chybovou zprávu)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nepodařilo se zahájit hovor.'),
                        ),
                      );
                    }
                  } else {
                    // Zpracuj případ, kdy telefonní číslo není k dispozici
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Telefonní číslo není k dispozici.'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Telefon mobil: ${objednavka.organizaceTelefon ?? ''}',
                  style: TextStyle(
                    color:
                        Colors
                            .blue, // Nebo jiná barva pro zvýraznění klikatelnosti
                    decoration:
                        TextDecoration
                            .underline, // Podtržení pro indikaci klikatelnosti
                  ),
                ),
              ),
              Divider(),
              Text(
                'Model: ${objednavka.inoTypVozidlaInoNazevNad}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('VIN: ${objednavka.inoSrvszakHlavickaVin1}'),
              Text('Karosérie: ${objednavka.inoZnackamodelExp10306329}'),
              Text('Motor: ${objednavka.inoZnackamodelMotor}'),
              Text('Vykon: ${objednavka.inoZnackamodelVykonHp}'),
              Text('Výbava: ${objednavka.inoZnackamodelExp48481880}'),
              Text('Převodovka: ${objednavka.udaInoZnackamodelPrevodovka}'),
              Text('Rok: ${objednavka.udaInoZnackamodelRok}'),
              Text(
                'Barva: ${objednavka.inoSrvszakBarvyVozuNazevSubjektu == null || objednavka.inoSrvszakBarvyVozuNazevSubjektu!.isEmpty ? '' : objednavka.inoSrvszakBarvyVozuNazevSubjektu}',
              ),
              Text(
                'Cena: $formattedCenaCelkem Kč',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text('Č.obj.: ${objednavka.inoSrvszakHlavickaKomise}'),
              Text('Typ prodeje: ${objednavka.inoSrvszakHlavickaHodnoceni}'),
              Text(
                'Statut: ${objednavka.inoSrvszakHlavickaPneuVyrobce.isEmpty ? '' : objednavka.inoSrvszakHlavickaPneuVyrobce}',
              ),
              Text(
                'Rezervováno do: ${objednavka.inoSrvszakHlavickaPneuVydanoDne == null || objednavka.inoSrvszakHlavickaPneuVydanoDne!.isEmpty ? '' : objednavka.inoSrvszakHlavickaPneuVydanoDne}',
              ),
              Text(
                'Pojistka: ${objednavka.inoSrvszakHlavickaPojistka2 == null || objednavka.inoSrvszakHlavickaPojistka2!.isEmpty ? '' : objednavka.inoSrvszakHlavickaPojistka2}',
              ),
              Text('Datum vzniku: $formattedDatumVzniku'),
              Text(
                'Datum Zavazné objednávky: $formattedDatumZavaznaObjednavka',
              ),
              Text(
                'Zavazná objednávka: ${objednavka.udaInoZavaznaObjednavkaZavaznaObjednavka}',
              ),
              Text(
                'Financování AIN: ${objednavka.udaInoZavaznaObjednavkaZfinancovani}',
              ),
              Text(
                'Leasing: ${objednavka.udaInoZavaznaObjednavkaLeasingSmlouvaCislo == null || objednavka.udaInoZavaznaObjednavkaLeasingSmlouvaCislo!.isEmpty ? '' : objednavka.udaInoZavaznaObjednavkaLeasingSmlouvaCislo}',
              ),
              Text('Lokace: ${objednavka.udaInoZavaznaObjednavkaLokaceVozu}'),
              Text(
                'Self-registrace: ${objednavka.udaInoZavaznaObjednavkaSelfRegistraceDatum == null || objednavka.udaInoZavaznaObjednavkaSelfRegistraceDatum!.isEmpty ? '' : objednavka.udaInoZavaznaObjednavkaSelfRegistraceDatum}',
              ),
              Text('Datum sepsání: $formattedDatumSepsani'),
              // ... Zobraz další detaily podle potřeby ...
            ],
          ),
        ),
      ),
    );
  }
}
