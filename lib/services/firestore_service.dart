import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice.dart';
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

  Stream<List<Invoice>> getInvoices(int employeeId) {
    print('getInvoices called');
    try {
      return _db
          .collection('faktury')
          .where('stavSchvalovani', isEqualTo: 'Připraveno')
          .where(
            Filter.or(
              Filter('prvniSchvalovatelId', isEqualTo: employeeId),
              Filter('druhySchvalovatelId', isEqualTo: employeeId),
            ),
          )
          .snapshots()
          .map((snapshot) {
            print('snapshot received, ${snapshot.docs.length} documents');
            if (snapshot.docs.isEmpty) {
              print('no documents found');
            }
            return snapshot.docs.map((doc) {
              print('mapping document: ${doc.id}');
              try {
                final invoice = Invoice.fromMap(doc.data(), doc.id);
                print('mapped invoice: ${invoice.interniCislo}');
                return invoice;
              } catch (e) {
                print('error mapping document: ${doc.id}, error: $e');
                rethrow;
              }
            }).toList();
          });
    } catch (e) {
      print('error getting invoices: $e');
      rethrow;
    }
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
        'stavSchvalovani': 'Schvaleno',
        'poznamkaSchvalovatele': poznamkaSchvalovatele,
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
      });
    } catch (e) {
      print('Error returning invoice: $e');
      rethrow;
    }
  }

  Future<String> createZadanka(Map<String, dynamic> zadankaData) async {
    print('createZadanka called with data: $zadankaData');
    try {
      DocumentReference docRef = await _db.collection('zadanky').add(zadankaData);
      String zadankaId = docRef.id;
      await docRef.update({'zadankaId': zadankaId});
      return zadankaId;
    } catch (e) {
      print('Error creating zadanka: $e');
      rethrow;
    }
  }
}
