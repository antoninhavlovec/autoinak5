import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Invoice {
  final double? cenaCelkem;
  final DateTime? created_at;
  final String datumDuzp;
  final String datumPripadu;
  final DateTime? datumSplatnosti;
  final int? druhySchvalovatelId;
  final String? druhySchvalovatelJmeno;
  final String interniCislo;
  final int invoiceId;
  final String orgIco;
  final String orgNazev;
  final String? poznamka;
  final int? prvniSchvalovatelId;
  final String? prvniSchvalovatelJmeno;
  final String stavSchvalovani;
  final String timestampPrenosu;
  final String variabilniCislo;
  final String id;
  final String? poznamkaSchvalovatele; // Přidané pole

  Invoice({
    this.cenaCelkem,
    this.created_at,
    required this.datumDuzp,
    required this.datumPripadu,
    required this.datumSplatnosti,
    this.druhySchvalovatelId,
    this.druhySchvalovatelJmeno,
    required this.interniCislo,
    required this.invoiceId,
    required this.orgIco,
    required this.orgNazev,
    this.poznamka,
    this.prvniSchvalovatelId,
    this.prvniSchvalovatelJmeno,
    required this.stavSchvalovani,
    required this.timestampPrenosu,
    required this.variabilniCislo,
    required this.id,
    this.poznamkaSchvalovatele, // Přidané pole
  });

  /// ✅ Bezpečné načítání dat z Firestore
  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    if (kDebugMode) {
      print('Invoice.fromMap called with: $map, id: $id');
    }
    try {
      return Invoice(
        cenaCelkem:
            (map['cenaCelkem'] is double)
                ? map['cenaCelkem'] as double
                : (map['cenaCelkem'] as int?)?.toDouble(), // Upravený řádek
        created_at: (map['created_at'] as Timestamp?)?.toDate(),
        datumDuzp: map['datumDuzp'] as String? ?? '',
        datumPripadu: map['datumPripadu'] as String? ?? '',
        datumSplatnosti:
            map['datumSplatnosti'] != null
                ? DateTime.parse(map['datumSplatnosti'])
                : null, // Upravený řádek
        druhySchvalovatelId: map['druhySchvalovatelId'] as int?,
        druhySchvalovatelJmeno: map['druhySchvalovatelJmeno'] as String?,
        interniCislo: map['interniCislo'] as String? ?? '',
        invoiceId: (map['invoiceId'] as num?)?.toInt() ?? 0,
        orgIco: map['orgIco'] as String? ?? '',
        orgNazev: map['orgNazev'] as String? ?? '',
        poznamka: map['poznamka'] as String?,
        prvniSchvalovatelId: map['prvniSchvalovatelId'] as int?,
        prvniSchvalovatelJmeno: map['prvniSchvalovatelJmeno'] as String?,
        stavSchvalovani: map['stavSchvalovani'] as String? ?? '',
        timestampPrenosu: map['timestamp_prenosu'] as String? ?? '',
        variabilniCislo: map['variabilniCislo'] as String? ?? '',
        poznamkaSchvalovatele:
            map['poznamkaSchvalovatele'] as String?, // Přidané pole
        id: id,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in Invoice.fromMap: $e');
      }
      rethrow;
    }
  }

  /// ✅ Oprava `created_at` na `Timestamp` při ukládání do Firestore
  Map<String, dynamic> toMap() {
    if (kDebugMode) {
      print('Invoice.toMap called');
    }
    return {
      'cenaCelkem': cenaCelkem,
      'created_at': created_at != null ? Timestamp.fromDate(created_at!) : null,
      'datumDuzp': datumDuzp,
      'datumPripadu': datumPripadu,
      'datumSplatnosti': datumSplatnosti,
      'druhySchvalovatelId': druhySchvalovatelId,
      'druhySchvalovatelJmeno': druhySchvalovatelJmeno,
      'interniCislo': interniCislo,
      'invoiceId': invoiceId,
      'orgIco': orgIco,
      'orgNazev': orgNazev,
      'poznamka': poznamka,
      'prvniSchvalovatelId': prvniSchvalovatelId,
      'prvniSchvalovatelJmeno': prvniSchvalovatelJmeno,
      'stavSchvalovani': stavSchvalovani,
      'timestamp_prenosu': timestampPrenosu,
      'variabilniCislo': variabilniCislo,
      'poznamkaSchvalovatele': poznamkaSchvalovatele, // Přidané pole
      'id': id,
    };
  }

  /// ✅ Přidání `copyWith()` pro snadnou změnu hodnot
  Invoice copyWith({
    double? cenaCelkem,
    DateTime? created_at,
    String? datumDuzp,
    String? datumPripadu,
    DateTime? datumSplatnosti,
    int? druhySchvalovatelId,
    String? druhySchvalovatelJmeno,
    String? interniCislo,
    int? invoiceId,
    String? orgIco,
    String? orgNazev,
    String? poznamka,
    int? prvniSchvalovatelId,
    String? prvniSchvalovatelJmeno,
    String? stavSchvalovani,
    String? timestampPrenosu,
    String? variabilniCislo,
    String? id,
    String? poznamkaSchvalovatele, // Přidané pole
  }) {
    return Invoice(
      cenaCelkem: cenaCelkem ?? this.cenaCelkem,
      created_at: created_at ?? this.created_at,
      datumDuzp: datumDuzp ?? this.datumDuzp,
      datumPripadu: datumPripadu ?? this.datumPripadu,
      datumSplatnosti: datumSplatnosti ?? this.datumSplatnosti,
      druhySchvalovatelId: druhySchvalovatelId ?? this.druhySchvalovatelId,
      druhySchvalovatelJmeno:
          druhySchvalovatelJmeno ?? this.druhySchvalovatelJmeno,
      interniCislo: interniCislo ?? this.interniCislo,
      invoiceId: invoiceId ?? this.invoiceId,
      orgIco: orgIco ?? this.orgIco,
      orgNazev: orgNazev ?? this.orgNazev,
      poznamka: poznamka ?? this.poznamka,
      prvniSchvalovatelId: prvniSchvalovatelId ?? this.prvniSchvalovatelId,
      prvniSchvalovatelJmeno:
          prvniSchvalovatelJmeno ?? this.prvniSchvalovatelJmeno,
      stavSchvalovani: stavSchvalovani ?? this.stavSchvalovani,
      timestampPrenosu: timestampPrenosu ?? this.timestampPrenosu,
      variabilniCislo: variabilniCislo ?? this.variabilniCislo,
      poznamkaSchvalovatele:
          poznamkaSchvalovatele ?? this.poznamkaSchvalovatele, // Přidané pole
      id: id ?? this.id,
    );
  }
}
