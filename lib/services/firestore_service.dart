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
                    (doc) => Zadanka.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
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
    return _db
        .collection('faktury')
        .where(
          Filter.or(
            Filter('prvniSchvalovatelId', isEqualTo: employeeId),
            Filter('druhySchvalovatelId', isEqualTo: employeeId),
          ),
        )
        .where('stavSchvalovani', isEqualTo: 'Připraveno')
        .snapshots()
        .map((snapshot) {
          final invoices =
              snapshot.docs
                  .map((doc) => Invoice.fromMap(doc.data(), doc.id))
                  .toList();
          return (invoices, snapshot.size);
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

  Future<void> approveInvoice(
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

  Future<int?> getCountInvoices(int employeeId) async {
    print('getCountInvoices called');
    AggregateQuerySnapshot snapshot =
        await _db
            .collection('faktury')
            .where('stavSchvalovani', isEqualTo: 'Připraveno')
            .where(
              Filter.or(
                Filter('prvniSchvalovatelId', isEqualTo: employeeId),
                Filter('druhySchvalovatelId', isEqualTo: employeeId),
              ),
            )
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
  }) async {
    try {
      // 1. Sestavíme dotazy pro jednotlivé kategorie (s logikou OR pro zákazníka, IČO, DIČ a telefon)
      List<Future<QuerySnapshot>> queryFutures = [];

      if (zakaznik != null && zakaznik.isNotEmpty) {
        final zakaznikLower = zakaznik.toLowerCase();
        final zakaznikQuery1 = _db
            .collection('objednavky')
            .where('zakaznik_lower', isGreaterThanOrEqualTo: zakaznikLower)
            .where('zakaznik_lower', isLessThan: '${zakaznikLower}z');
        final zakaznikQuery2 = _db
            .collection('objednavky')
            .where('zakaznik2_lower', isGreaterThanOrEqualTo: zakaznikLower)
            .where('zakaznik2_lower', isLessThan: '${zakaznikLower}z');
        queryFutures.addAll([zakaznikQuery1.get(), zakaznikQuery2.get()]);
      }

      if (ico != null && ico.isNotEmpty) {
        final icoQuery1 = _db
            .collection('objednavky')
            .where('ino_srvszak_hlavicka_organizace_ico', isGreaterThanOrEqualTo: ico)
            .where('ino_srvszak_hlavicka_organizace_ico', isLessThan: '${ico}z');
        final icoQuery2 = _db
            .collection('objednavky')
            .where('organizace_ico', isGreaterThanOrEqualTo: ico)
            .where('organizace_ico', isLessThan: '${ico}z');
        queryFutures.addAll([icoQuery1.get(), icoQuery2.get()]);
      }

      if (dic != null && dic.isNotEmpty) {
        final dicQuery1 = _db
            .collection('objednavky')
            .where('ino_srvszak_hlavicka_organizace_dic', isGreaterThanOrEqualTo: dic)
            .where('ino_srvszak_hlavicka_organizace_dic', isLessThan: '${dic}z');
        final dicQuery2 = _db
            .collection('objednavky')
            .where('organizace_dic', isGreaterThanOrEqualTo: dic)
            .where('organizace_dic', isLessThan: '${dic}z');
        queryFutures.addAll([dicQuery1.get(), dicQuery2.get()]);
      }

      if (model != null && model.isNotEmpty) {
        final modelLower = model.toLowerCase();
        final modelQuery = _db
            .collection('objednavky')
            .where('ino_typ_vozidla_lower', isGreaterThanOrEqualTo: modelLower)
            .where('ino_typ_vozidla_lower', isLessThan: '${modelLower}z');
        queryFutures.add(modelQuery.get());
      }

      if (telefon != null && telefon.isNotEmpty) {
        final telefonQuery1 = _db
            .collection('objednavky')
            .where('ino_srvszak_hlavicka_telefon', isGreaterThanOrEqualTo: telefon)
            .where('ino_srvszak_hlavicka_telefon', isLessThan: '${telefon}z');
        final telefonQuery2 = _db
            .collection('objednavky')
            .where('ino_srvszak_hlavicka_telefon_mobil', isGreaterThanOrEqualTo: telefon)
            .where('ino_srvszak_hlavicka_telefon_mobil', isLessThan: '${telefon}z');
        final telefonQuery3 = _db
            .collection('objednavky')
            .where('organizace_telefon', isGreaterThanOrEqualTo: telefon)
            .where('organizace_telefon', isLessThan: '${telefon}z');
        final telefonQuery4 = _db
            .collection('objednavky')
            .where('organizace_telefon_mobil', isGreaterThanOrEqualTo: telefon)
            .where('organizace_telefon_mobil', isLessThan: '${telefon}z');
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
          objednavky.add(Objednavka.fromFirestore(doc.data() as Map<String, dynamic>));
        }
      }
      return objednavky.toSet().toList();
    } catch (e) {
      print('Error searching objednavky: $e');
      return [];
    }
  }
}

