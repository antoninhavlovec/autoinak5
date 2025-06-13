import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice.dart';
import '../models/objednavka.dart';
import '../models/zadanka.dart';
import '../models/dochazka.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Zadanka>> getMyZadanky(int employeeId) {
    print('getMyZadanky called');
    try {
      return _db
          .collection('zadanky')
          .where('zamestnanecId', isEqualTo: employeeId)
          .snapshots()
          .map((snapshot) {
            print('snapshot received, ${snapshot.docs.length} documents');
            if (snapshot.docs.isEmpty) {
              print('no documents found');
            }
            return snapshot.docs.map((doc) {
              print('mapping document: ${doc.id}');
              try {
                final zadanka = Zadanka.fromMap(doc.data(), doc.id);
                print('mapped zadanka: ${zadanka.zadankaId}');
                return zadanka;
              } catch (e) {
                print('error mapping document: ${doc.id}, error: $e');
                rethrow;
              }
            }).toList();
          });
    } catch (e) {
      print('error getting zadanky: $e');
      rethrow;
    }
  }

  /*nové metody*/
  Stream<(List<Zadanka>, int)> getZadankyWithCount(int employeeId) {
    return _db
        .collection('zadanky')
        .where('schvalovateId', isEqualTo: employeeId)
        .where('odeslano', isEqualTo: 'Ano')
        .where('schvaleno', isEqualTo: 'Ne')
        .where('zruseno', isEqualTo: 'Ne')
        .snapshots()
        .map((snapshot) {
          final zadanky =
              snapshot.docs
                  .map(
                    (doc) => Zadanka.fromMap(doc.data(), doc.id),
                  ) // Přidáno explicitní přetypování
                  .toList();
          return (zadanky, snapshot.size);
        });
  }

  /*Stara metoda*/
  Stream<List<Zadanka>> getZadankyToApprove(int employeeId) {
    print('getZadankyToApprove called');
    try {
      return _db
          .collection('zadanky')
          .where('schvalovateId', isEqualTo: employeeId)
          .where('odeslano', isEqualTo: 'Ano')
          .where('schvaleno', isEqualTo: 'Ne')
          .where('zruseno', isEqualTo: 'Ne')
          .snapshots()
          .map((snapshot) {
            print('snapshot received, ${snapshot.docs.length} documents');
            if (snapshot.docs.isEmpty) {
              print('no documents found');
            }
            return snapshot.docs.map((doc) {
              print('mapping document: ${doc.id}');
              try {
                final zadanka = Zadanka.fromMap(doc.data(), doc.id);
                print('mapped zadanka: ${zadanka.zadankaId}');
                return zadanka;
              } catch (e) {
                print('error mapping document: ${doc.id}, error: $e');
                rethrow;
              }
            }).toList();
          });
    } catch (e) {
      print('error getting zadanky to approve: $e');
      rethrow;
    }
  }

  Stream<List<Dochazka>> getDochazka(int employeeId) {
    print('getDochazka called');
    try {
      return _db
          .collection('dochazka')
          .where('zamestnanecId', isEqualTo: employeeId)
          .orderBy('datumOd', descending: true)
          .snapshots()
          .map((snapshot) {
            print('snapshot received, ${snapshot.docs.length} documents');
            if (snapshot.docs.isEmpty) {
              print('no documents found');
            }
            return snapshot.docs.map((doc) {
              print('mapping document: ${doc.id}');
              try {
                final dochazka = Dochazka.fromMap(doc.data(), doc.id);
                print('mapped dochazka: ${dochazka.firestoreId}');
                return dochazka;
              } catch (e) {
                print('error mapping document: ${doc.id}, error: $e');
                rethrow;
              }
            }).toList();
          });
    } catch (e) {
      print('error getting dochazka: $e');
      rethrow;
    }
  }

  Future<void> startDochazka(Dochazka dochazka) async {
    print('startDochazka called with data: ${dochazka.toMap()}');
    try {
      await _db.collection('dochazka').add(dochazka.toMap());
    } catch (e) {
      print('Error starting dochazka: $e');
      rethrow;
    }
  }

  Future<void> endDochazka(String dochazkaId) async {
    print('endDochazka called with id: $dochazkaId');
    try {
      await _db.collection('dochazka').doc(dochazkaId).update({
        'datumDo': DateTime.now(),
      });
    } catch (e) {
      print('Error ending dochazka: $e');
      rethrow;
    }
  }

  Future<void> approveZadanka(
    String zadankaId,
    String poznamkaSchvalovatele,
  ) async {
    print(
      'approveZadanka called with zadankaId: $zadankaId, poznamkaSchvalovatele: $poznamkaSchvalovatele',
    );
    try {
      await _db.collection('zadanky').doc(zadankaId).update({
        'schvaleno': 'Ano',
        'poznamkaSchvalovatel': poznamkaSchvalovatele,
      });
    } catch (e) {
      print('Error approving zadanka: $e');
      rethrow;
    }
  }

  Future<void> rejectZadanka(
    String zadankaId,
    String poznamkaSchvalovatele,
  ) async {
    print(
      'rejectZadanka called with zadankaId: $zadankaId, poznamkaSchvalovatele: $poznamkaSchvalovatele',
    );
    try {
      await _db.collection('zadanky').doc(zadankaId).update({
        'zruseno': 'Ano',
        'poznamkaSchvalovatel': poznamkaSchvalovatele,
      });
    } catch (e) {
      print('Error rejecting zadanka: $e');
      rethrow;
    }
  }

  Stream<(List<Invoice>, int)> getInvoicesWithCount(int employeeId) {
    final invoicesCollection = _db.collection('faktury');

    // Dotaz pro faktury, kde je uživatel PRVNÍM schvalovatelem a stav je "Připraveno":
    final prvniSchvalovatelQuery = invoicesCollection.where(
      Filter.or(
        Filter.and(
          Filter('prvniSchvalovatelId', isEqualTo: employeeId),
          Filter('stavSchvalovani', isEqualTo: 'Připraveno'),
        ),
        Filter.and(
          Filter('druhySchvalovatelId', isEqualTo: employeeId),
          Filter('stavSchvalovani', isEqualTo: 'Akceptováno'),
        ),
      ),
    );

    /*       .where('prvniSchvalovatelId', isEqualTo: employeeId)
        .where('stavSchvalovani', isEqualTo: 'Připraveno');*/

    return prvniSchvalovatelQuery.snapshots().map((snapshot) {
      final invoices =
          snapshot.docs
              .map(
                (doc) =>
                    Invoice.fromMap(doc.data(), doc.id),
              )
              .toList();
      print(
        "getInvoicesWithCount: Nová data vydána - ${invoices.length} faktur",
      );
      return (invoices, invoices.length);
    });
  }

  /// 🔍 **Debugovací metoda pro ruční kontrolu dat**
  Future<void> debugInvoices() async {
    try {
      var snapshot = await _db.collection('faktury').get();
      if (snapshot.docs.isEmpty) {
        print('🔥 Žádné dokumenty ve sbírce "faktury"');
      } else {
        for (var doc in snapshot.docs) {
          print('📄 Dokument: ${doc.id} → ${doc.data()}');
          print(
            'prvniSchvalovatelId: ${doc.data()['prvniSchvalovatelId']}',
          ); // Přidaný print
          print(
            'druhySchvalovatelId: ${doc.data()['druhySchvalovatelId']}',
          ); // Přidaný pri
        }
      }
    } catch (e) {
      print('❌ Chyba při načítání faktur: $e');
    }
  }

 /* Future<void> approveInvoice(
    String invoiceId,
    String poznamkaSchvalovatele,
  ) async {
    print(
      'approveInvoice called with invoiceId: $invoiceId, poznamkaSchvalovatele: $poznamkaSchvalovatele',
    );
    try {
      await _db.collection('faktury').doc(invoiceId).update({
        'stavSchvalovani': 'Schváleno',
        'poznamkaSchvalovatele': poznamkaSchvalovatele,
        'datumSchvaleni': FieldValue.serverTimestamp(), // Přidání timestampu
      });
    } catch (e) {
      print('Error approving invoice: $e');
      rethrow;
    }
  }*/

  Future<void> approveInvoice(
      String invoiceId,
      String poznamkaSchvalovatele,
      int employeeId, // Přidáno ID přihlášeného uživatele
      ) async {
    print(
      'approveInvoice called with invoiceId: $invoiceId, poznamkaSchvalovatele: $poznamkaSchvalovatele, employeeId: $employeeId',
    );
    try {
      final invoiceDoc = await _db.collection('faktury').doc(invoiceId).get();
      if (!invoiceDoc.exists) {
        throw Exception('Faktura s ID $invoiceId nebyla nalezena.');
      }
      final invoiceData = invoiceDoc.data() as Map<String, dynamic>;
      final prvniSchvalovatelId = invoiceData['prvniSchvalovatelId'];
      final druhySchvalovatelId = invoiceData['druhySchvalovatelId'];
      String novyStav = 'Schváleno'; // Výchozí stav (pro jednoho schvalovatele)

      if (prvniSchvalovatelId == employeeId) {
        if (druhySchvalovatelId != null) {
          novyStav = 'Akceptováno'; // První schvalovatel, existuje druhý
        }
      } else if (druhySchvalovatelId == employeeId) {
        novyStav = 'Schváleno'; // Druhý schvalovatel schvaluje
      } else {
        throw Exception(
          'Uživatel $employeeId není schvalovatelem faktury $invoiceId.',
        );
      }
      await _db.collection('faktury').doc(invoiceId).update({
        'stavSchvalovani': novyStav,
        'poznamkaSchvalovatele': poznamkaSchvalovatele,
        'datumSchvaleni': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error approving invoice: $e');
      rethrow;
    }
  }

  Future<void> rejectInvoice(
    String invoiceId,
    String poznamkaSchvalovatele,
  ) async {
    print(
      'rejectInvoice called with invoiceId: $invoiceId, poznamkaSchvalovatele: $poznamkaSchvalovatele',
    );
    try {
      await _db.collection('faktury').doc(invoiceId).update({
        'stavSchvalovani': 'Zamítnuto',
        'poznamkaSchvalovatele': poznamkaSchvalovatele,
        'datumZamintnuti': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error rejecting invoice: $e');
      rethrow;
    }
  }

  Future<void> returnInvoice(
    String invoiceId,
    String poznamkaSchvalovatele,
  ) async {
    print(
      'returnInvoice called with invoiceId: $invoiceId, poznamkaSchvalovatele: $poznamkaSchvalovatele',
    );
    try {
      await _db.collection('faktury').doc(invoiceId).update({
        'stavSchvalovani': 'Vráceno',
        'poznamkaSchvalovatele': poznamkaSchvalovatele,
        'datumVraceni': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error returning invoice: $e');
      rethrow;
    }
  }

  Future<String> createZadanka(Map<String, dynamic> zadankaData) async {
    print('createZadanka called with data: $zadankaData');
    try {
      DocumentReference docRef = await _db
          .collection('zadanky')
          .add(zadankaData);
      String zadankaId = docRef.id;
      await docRef.update({'zadankaId': zadankaId});
      return zadankaId;
    } catch (e) {
      print('Error creating zadanka: $e');
      rethrow;
    }
  }

  /*Future<int?> getCountInvoices(int employeeId) async {
    print('getCountInvoices called');
    final invoicesCollection = _db.collection('faktury');
    // 1. Dotaz pro faktury, kde je uživatel PRVNÍM schvalovatelem a stav je "Připraveno":
    final prvniSchvalovatelQuery = invoicesCollection
        .where('prvniSchvalovatelId', isEqualTo: employeeId)
        .where('stavSchvalovani', isEqualTo: 'Připraveno');
    // 2. Dotaz pro faktury, kde je uživatel DRUHÝM schvalovatelem a stav je "Akceptováno":
    final druhySchvalovatelQuery = invoicesCollection
        .where('druhySchvalovatelId', isEqualTo: employeeId)
        .where('stavSchvalovani', isEqualTo: 'Akceptováno');
    // Provedeme oba dotazy paralelně a sečteme výsledky:
    final results = await Future.wait([
      prvniSchvalovatelQuery.count().get(),
      druhySchvalovatelQuery.count().get(),
    ]);
    final count = (results[0].count ?? 0) + (results[1].count ?? 0);
    print('Count: $count');
    return count;
  }*/

  Future<int?> getCountInvoices(int employeeId) async {
    print('getCountInvoices called');
    AggregateQuerySnapshot snapshot =
        await _db
            .collection('faktury')
            .where('prvniSchvalovatelId', isEqualTo: employeeId)
            .where('stavSchvalovani', isEqualTo: 'Připraveno')
            .count()
            .get();
    print('Count: ${snapshot.count}');
    return snapshot.count;
  }

  Future<int?> getCountRequests(int employeeId) async {
    print('getCountRequests called');
    AggregateQuerySnapshot snapshot =
        await _db
            .collection('zadanky')
            .where('schvalovateId', isEqualTo: employeeId)
            .where('odeslano', isEqualTo: 'Ano')
            .where('schvaleno', isEqualTo: 'Ne')
            .where('zruseno', isEqualTo: 'Ne')
            .count()
            .get(); // Změna zde
    print('Count: ${snapshot.count}');
    return snapshot.count;
  }

  Future<List<Objednavka>> searchObjednavky({
    String? zakaznik,
    String? ico,
    String? dic,
    String? model,
    String? telefon,
    int? employeeId,
  }) async {
    print(
      'Hledám objednávky pro employeeId: $employeeId',
    ); // Přidáno pro kontrolu
    try {
      // 1. Sestavíme dotazy pro jednotlivé kategorie (s logikou OR pro zákazníka, IČO, DIČ a telefon)
      List<Future<QuerySnapshot>> queryFutures = [];

      if (zakaznik != null && zakaznik.isNotEmpty) {
        final zakaznikLower = zakaznik.toLowerCase();
        var zakaznikQuery1 = _db
            .collection('objednavky')
            .where('zakaznik_lower', isGreaterThanOrEqualTo: zakaznikLower)
            .where('zakaznik_lower', isLessThan: '${zakaznikLower}z');
        var zakaznikQuery2 = _db
            .collection('objednavky')
            .where('zakaznik2_lower', isGreaterThanOrEqualTo: zakaznikLower)
            .where('zakaznik2_lower', isLessThan: '${zakaznikLower}z');
        if (employeeId != null) {
          zakaznikQuery1 = zakaznikQuery1.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          zakaznikQuery2 = zakaznikQuery2.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
        }
        queryFutures.addAll([zakaznikQuery1.get(), zakaznikQuery2.get()]);
      }

      if (ico != null && ico.isNotEmpty) {
        var icoQuery1 = _db
            .collection('objednavky')
            .where(
              'ino_srvszak_hlavicka_organizace_ico',
              isGreaterThanOrEqualTo: ico,
            )
            .where(
              'ino_srvszak_hlavicka_organizace_ico',
              isLessThan: '${ico}z',
            );
        var icoQuery2 = _db
            .collection('objednavky')
            .where('organizace_ico', isGreaterThanOrEqualTo: ico)
            .where('organizace_ico', isLessThan: '${ico}z');
        if (employeeId != null) {
          icoQuery1 = icoQuery1.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          icoQuery2 = icoQuery2.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
        }
        queryFutures.addAll([icoQuery1.get(), icoQuery2.get()]);
      }

      if (dic != null && dic.isNotEmpty) {
        var dicQuery1 = _db
            .collection('objednavky')
            .where(
              'ino_srvszak_hlavicka_organizace_dic',
              isGreaterThanOrEqualTo: dic,
            )
            .where(
              'ino_srvszak_hlavicka_organizace_dic',
              isLessThan: '${dic}z',
            );
        var dicQuery2 = _db
            .collection('objednavky')
            .where('organizace_dic', isGreaterThanOrEqualTo: dic)
            .where('organizace_dic', isLessThan: '${dic}z');
        if (employeeId != null) {
          dicQuery1 = dicQuery1.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          dicQuery2 = dicQuery2.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
        }
        queryFutures.addAll([dicQuery1.get(), dicQuery2.get()]);
      }

      if (model != null && model.isNotEmpty) {
        final modelLower = model.toLowerCase();
        var modelQuery = _db
            .collection('objednavky')
            .where('ino_typ_vozidla_lower', isGreaterThanOrEqualTo: modelLower)
            .where('ino_typ_vozidla_lower', isLessThan: '${modelLower}z');
        if (employeeId != null) {
          modelQuery = modelQuery.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
        }
        queryFutures.add(modelQuery.get());
      }

      if (telefon != null && telefon.isNotEmpty) {
        var telefonQuery1 = _db
            .collection('objednavky')
            .where(
              'ino_srvszak_hlavicka_telefon',
              isGreaterThanOrEqualTo: telefon,
            )
            .where('ino_srvszak_hlavicka_telefon', isLessThan: '${telefon}z');
        var telefonQuery2 = _db
            .collection('objednavky')
            .where(
              'ino_srvszak_hlavicka_telefon_mobil',
              isGreaterThanOrEqualTo: telefon,
            )
            .where(
              'ino_srvszak_hlavicka_telefon_mobil',
              isLessThan: '${telefon}z',
            );
        var telefonQuery3 = _db
            .collection('objednavky')
            .where('organizace_telefon', isGreaterThanOrEqualTo: telefon)
            .where('organizace_telefon', isLessThan: '${telefon}z');
        var telefonQuery4 = _db
            .collection('objednavky')
            .where('organizace_telefon_mobil', isGreaterThanOrEqualTo: telefon)
            .where('organizace_telefon_mobil', isLessThan: '${telefon}z');

        if (employeeId != null) {
          telefonQuery1 = telefonQuery1.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          telefonQuery2 = telefonQuery2.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          telefonQuery3 = telefonQuery3.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
          telefonQuery4 = telefonQuery4.where(
            'subjekty_cislo_subjektu',
            isEqualTo: employeeId,
          );
        }
        queryFutures.addAll([
          telefonQuery1.get(),
          telefonQuery2.get(),
          telefonQuery3.get(),
          telefonQuery4.get(),
        ]);
      }

      // 2. Spustíme všechny dotazy paralelně
      final results = await Future.wait(queryFutures);

      // 3. Zpracujeme výsledky a spojíme je do jednoho seznamu (odstraníme duplicity)
      final objednavky = <Objednavka>[];
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          objednavky.add(
            Objednavka.fromFirestore(doc.data() as Map<String, dynamic>),
          );
        }
      }
      return objednavky.toSet().toList();
    } catch (e) {
      print('Error searching objednavky: $e');
      return [];
    }
  }
}
