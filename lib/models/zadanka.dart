import 'package:cloud_firestore/cloud_firestore.dart';

class Zadanka {
  final String id;
  final DateTime createdAt;
  final String datumDo;
  final String datumOd;
  final int dnyCerpani;
  final String odeslano;
  final String? poznamka;
  final String pulDneDo;
  final String pulDneOd;
  final String schvaleno;
  final int schvalovateId;
  final String schvalovateJmeno;
  final String typZadanky;
  final String zadankaId;
  final int zamestnanecId;
  final String zamestnanecJmeno;
  final String zruseno;
  final String? poznamkaSchvalovatel;

  Zadanka({
    required this.id,
    required this.createdAt,
    required this.datumDo,
    required this.datumOd,
    required this.dnyCerpani,
    required this.odeslano,
    this.poznamka,
    required this.pulDneDo,
    required this.pulDneOd,
    required this.schvaleno,
    required this.schvalovateId,
    required this.schvalovateJmeno,
    required this.typZadanky,
    required this.zadankaId,
    required this.zamestnanecId,
    required this.zamestnanecJmeno,
    required this.zruseno,
    this.poznamkaSchvalovatel,
  });

  String get status {
    if (zruseno == "Ano") {
      return "zamítnuto";
    } else if (schvaleno == "Ano") {
      return "schváleno";
    } else if(odeslano == "Ano"){
      return "odesláno";
    } else{
      return "neodesláno";
    }
  }

  factory Zadanka.fromMap(Map<String, dynamic> map, String documentId) {
    return Zadanka(
      id: documentId,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      datumDo: map['datumDo'] as String,
      datumOd: map['datumOd'] as String,
      dnyCerpani: map['dnyCerpani'] as int,
      odeslano: map['odeslano'] as String,
      poznamka: map['poznamka'] as String?,
      pulDneDo: map['pulDneDo'] as String,
      pulDneOd: map['pulDneOd'] as String,
      schvaleno: map['schvaleno'] as String,
      schvalovateId: map['schvalovateId'] as int,
      schvalovateJmeno: map['schvalovateJmeno'] as String,
      typZadanky: map['typZadanky'] as String,
      zadankaId: map['zadankaId'] as String,
      zamestnanecId: map['zamestnanecId'] as int,
      zamestnanecJmeno: map['zamestnanecJmeno'] as String,
      zruseno: map['zruseno'] as String,
      poznamkaSchvalovatel: map['poznamkaSchvalovatel'] as String?,
    );
  }
}
