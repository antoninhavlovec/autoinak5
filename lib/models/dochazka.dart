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
  factory Dochazka.fromMap(Map<String, dynamic> map, String id) {

    Timestamp? parsedDatumOd;
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

    return Dochazka(
      firestoreId: id,
      datumOd: map['datumOd'], // Už nepotřebujeme toDate()
      datumDo: map['datumDo'], // Už nepotřebujeme toDate()
      nazevPodkladu: map['nazevPodkladu'],
      podklad: map['podklad'],
      zamestnanecId: map['zamestnanecId'],
      zamestnanecJmeno: map['zamestnanecJmeno'],
    );
  }

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