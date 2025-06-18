import 'package:cloud_firestore/cloud_firestore.dart';

class Dochazka {
  final String? firestoreId;
  final Timestamp datumOd; // Změna na Timestamp
  Timestamp? datumDo; // Změna na Timestamp
  final String nazevPodkladu;
  final String podklad;
  final int zamestnanecId;
  final String zamestnanecJmeno;

  Dochazka({
    this.firestoreId,
    required this.datumOd,
    this.datumDo,
    required this.nazevPodkladu,
    required this.podklad,
    required this.zamestnanecId,
    required this.zamestnanecJmeno,
  });

  // Metoda pro vytvoření instance z mapy (z Firestore)
 /* factory Dochazka.fromMap(Map<String, dynamic> map, String id) {

    Timestamp parsedDatumOd;
    if (map['datumOd'] is String) {
      // Pokud je to string, tak ho parsujeme
      parsedDatumOd = Timestamp.fromDate(DateTime.parse(map['datumOd']));
    } else if (map['datumOd'] is Timestamp) {
      // Pokud je to Timestamp, tak ho rovnou použijeme
      parsedDatumOd = map['datumOd'];
    } else {
      // Pokud to není ani String, ani Timestamp, tak vyhodíme chybu
      throw Exception('Neplatný typ pro datumOd: ${map['datumOd'].runtimeType}');
    }

    // Kontrola typu pro datumDo
    Timestamp? parsedDatumDo;
    if (map['datumDo'] != null) {
      if (map['datumDo'] is String) {
        parsedDatumDo = Timestamp.fromDate(DateTime.parse(map['datumDo']));
      } else if (map['datumDo'] is Timestamp) {
        parsedDatumDo = map['datumDo'];
      } else {
        throw Exception('Neplatný typ pro datumDo: ${map['datumDo'].runtimeType}');
      }
    }
*/
  factory Dochazka.fromMap(Map<String, dynamic> map, String id) {
    // Parsování datumOd
    Timestamp parsedDatumOd; // Změna na non-nullable, protože datumOd je required
    if (map['datumOd'] == null) {
      // Pokud je datumOd null v databázi, což by nemělo být, protože je required.
      // Můžete zde vyhodit chybu nebo nastavit výchozí hodnotu.
      // Prozatím vyhodíme chybu, aby se odhalil problém v datech.
      throw Exception('Pole datumOd je null v dokumentu s ID: $id');
      // Alternativně: parsedDatumOd = Timestamp.now();
    } else if (map['datumOd'] is String) {
      try {
        parsedDatumOd = Timestamp.fromDate(DateTime.parse(map['datumOd'] as String));
      } catch (e) {
        throw Exception('Chyba při parsování datumOd (String) pro dokument ID: $id. Hodnota: ${map['datumOd']}. Chyba: $e');
      }
    } else if (map['datumOd'] is Timestamp) {
      parsedDatumOd = map['datumOd'] as Timestamp;
    } else {
      throw Exception('Neplatný typ pro datumOd v dokumentu ID: $id. Typ: ${map['datumOd'].runtimeType}, Hodnota: ${map['datumOd']}');
    }

    // Parsování datumDo
    Timestamp? parsedDatumDo; // Zůstává nullable
    if (map['datumDo'] != null) {
      if (map['datumDo'] is String) {
        try {
          parsedDatumDo = Timestamp.fromDate(DateTime.parse(map['datumDo'] as String));
        } catch (e) {
          throw Exception('Chyba při parsování datumDo (String) pro dokument ID: $id. Hodnota: ${map['datumDo']}. Chyba: $e');
        }
      } else if (map['datumDo'] is Timestamp) {
        parsedDatumDo = map['datumDo'] as Timestamp;
      } else {
        throw Exception('Neplatný typ pro datumDo v dokumentu ID: $id. Typ: ${map['datumDo'].runtimeType}, Hodnota: ${map['datumDo']}');
      }
    }

    // Získání a zabezpečení ostatních hodnot
    String nazevPodkladu = map['nazevPodkladu'] as String? ?? '';
    String podklad = map['podklad'] as String? ?? '';
    String zamestnanecJmeno = map['zamestnanecJmeno'] as String? ?? '';
    int zamestnanecId;

    if (map['zamestnanecId'] == null) {
      // Pokud je zamestnanecId null v databázi, což by nemělo být, protože je required.
      // Můžete zde vyhodit chybu nebo nastavit výchozí hodnotu.
      throw Exception('Pole zamestnanecId je null v dokumentu s ID: $id');
      // Alternativně: zamestnanecId = 0; // Nebo nějaká výchozí neplatná ID
    } else if (map['zamestnanecId'] is int) {
      zamestnanecId = map['zamestnanecId'] as int;
    } else if (map['zamestnanecId'] is String) { // Pokud by náhodou bylo uloženo jako String
      try {
        zamestnanecId = int.parse(map['zamestnanecId'] as String);
      } catch (e) {
        throw Exception('Chyba při parsování zamestnanecId (String) pro dokument ID: $id. Hodnota: ${map['zamestnanecId']}. Chyba: $e');
      }
    }
    else {
      throw Exception('Neplatný typ pro zamestnanecId v dokumentu ID: $id. Typ: ${map['zamestnanecId'].runtimeType}, Hodnota: ${map['zamestnanecId']}');
    }

    return Dochazka(
      firestoreId: id,
      datumOd: parsedDatumOd, // Použití parsované hodnoty
      datumDo: parsedDatumDo, // Použití parsované hodnoty
      nazevPodkladu: nazevPodkladu,
      podklad: podklad,
      zamestnanecId: zamestnanecId,
      zamestnanecJmeno: zamestnanecJmeno,
    );
  }
/*    return Dochazka(
      firestoreId: id,
      datumOd: map['datumOd'], // Už nepotřebujeme toDate()
      datumDo: map['datumDo'], // Už nepotřebujeme toDate()
      nazevPodkladu: map['nazevPodkladu'],
      podklad: map['podklad'],
      zamestnanecId: map['zamestnanecId'],
      zamestnanecJmeno: map['zamestnanecJmeno'],
    );
  }*/

  // Metoda pro konverzi na mapu (pro uložení do Firestore)
  Map<String, dynamic> toMap() {
    return {
      'datumOd': datumOd,
      'datumDo': datumDo,
      'nazevPodkladu': nazevPodkladu,
      'podklad': podklad,
      'zamestnanecId': zamestnanecId,
      'zamestnanecJmeno': zamestnanecJmeno,
    };
  }

  DateTime getDatumOdAsDateTime() {
    return datumOd.toDate();
  }

  DateTime? getDatumDoAsDateTime() {
    return datumDo?.toDate();
  }
}