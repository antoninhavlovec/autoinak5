import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/dochazka.dart';

class DochazkaPage extends StatefulWidget {
  const DochazkaPage({Key? key}) : super(key: key);

  @override
  _DochazkaPageState createState() => _DochazkaPageState();
}

class _DochazkaPageState extends State<DochazkaPage> {
  List<Dochazka> dochazkaList = [];
  int? employeeId;
  final CollectionReference dochazkaCollection = FirebaseFirestore.instance
      .collection('dochazka');
  Map<String, String> podkladMap = {
    '21816396': 'Vedlejší práce/úklid',
    '4350224': 'Oběd',
    '4490151': 'Lékař',
    '4486460': 'Školení',
    '4350225': 'Přestávka',
    '4350223': 'Příchod-Odchod',
  };
  Dochazka? currentDochazka;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
  }

  _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    if (employeeIdString != null) {
      setState(() {
        employeeId = int.tryParse(employeeIdString);
        _loadDochazka();
      });
    }
  }

  _loadDochazka() {
    print('_loadDochazka started');
    if (employeeId != null) {
      dochazkaCollection
          .where('zamestnanecId', isEqualTo: employeeId)
          .orderBy('datumOd', descending: true)
          .snapshots()
          .listen((snapshot) {
            print('snapshot: ${snapshot.docs}');
            for (var doc in snapshot.docs) {
              print('doc.data: ${doc.data()}');
              Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
              print('map[datumOd]: ${map['datumOd']}');
              print('map[datumDo]: ${map['datumDo']}');
              print('map[datumOd] is String: ${map['datumOd'] is String}');
              print(
                'map[datumOd] is Timestamp: ${map['datumOd'] is Timestamp}',
              );
            }
            setState(() {
              dochazkaList =
                  snapshot.docs
                      .map(
                        (doc) => Dochazka.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ),
                      )
                      .toList();
              // Kontrola aktuální docházky
              currentDochazka = dochazkaList.firstWhere(
                (dochazka) => dochazka.datumDo == null,
                orElse:
                    () => Dochazka(
                      datumOd: Timestamp.now(), //Použijeme aktuální datum a čas
                      //                datumOd: Timestamp.fromDate(DateTime(0)),
                      nazevPodkladu: '',
                      podklad: '',
                      zamestnanecId: 0,
                      zamestnanecJmeno: '',
                    ),
              );
            });
            print('_loadDochazka end');
          });
    }
  }

  _startDochazka(String podklad, String nazevPodkladu) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? zamestnanecJmeno = prefs.getString('zamestnanecJmeno');

    if (employeeId != null) {
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      print(
        'startDochazka add data: {datumOd: $timestamp, nazevPodkladu: $nazevPodkladu,podklad: $podklad,zamestnanecId: $employeeId,zamestnanecJmeno: $zamestnanecJmeno}',
      );
      DocumentReference docRef = await dochazkaCollection.add({
        'datumOd': timestamp,
        'nazevPodkladu': nazevPodkladu,
        'podklad': podklad,
        'zamestnanecId': employeeId,
        'zamestnanecJmeno': zamestnanecJmeno,
      });
      setState(() {
        print(
          'startDochazka new data: {firestoreId: ${docRef.id}, datumOd: $timestamp, nazevPodkladu:$nazevPodkladu,podklad: $podklad, zamestnanecId: $employeeId,zamestnanecJmeno: $zamestnanecJmeno}',
        );
        currentDochazka = Dochazka(
          firestoreId: docRef.id,
          datumOd: Timestamp.fromDate(DateTime.now()),
          nazevPodkladu: nazevPodkladu,
          podklad: podklad,
          zamestnanecId: employeeId!,
          zamestnanecJmeno: zamestnanecJmeno!,
        );
      });
    }
  }

  _endDochazka() async {
    if (currentDochazka != null) {
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      await dochazkaCollection.doc(currentDochazka!.firestoreId).update({
        'datumDo': timestamp,
      });
      setState(() {
        currentDochazka = null;
      });
    }
  }

  // Pomocná metoda pro formátování data
  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Docházka')),
      body: Column(
        children: [
          // Zobrazení aktuálního stavu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  currentDochazka?.nazevPodkladu == ''
                      ? 'Zatím nezačala žádná aktivita'
                      : 'Nyní: ${currentDochazka?.nazevPodkladu}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Seznam docházky
          Expanded(
            child: ListView.builder(
              itemCount: dochazkaList.length,
              itemBuilder: (context, index) {
                Dochazka dochazka = dochazkaList[index];
                return ListTile(
                  title: Text(dochazka.nazevPodkladu),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Od: ${formatDate(dochazka.getDatumOdAsDateTime())}'), // Správné volání metody
                      if (dochazka.datumDo != null)
                        Text(
                          'Do: ${formatDate(dochazka.getDatumDoAsDateTime())}',
                        ), // Použijeme metodu formatDate()
                      Text('employeeId: ${dochazka.firestoreId}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children:
            podkladMap.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FloatingActionButton(
                  onPressed: () {
                    if (currentDochazka == null) {
                      _startDochazka(entry.key, entry.value);
                    } else if (currentDochazka!.podklad == entry.key) {
                      _endDochazka();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nejprve ukončete aktuální činnost'),
                        ),
                      );
                    }
                  },
                  child: Text(entry.value),
                  backgroundColor:
                      currentDochazka?.podklad == entry.key
                          ? Colors.red
                          : Colors.green,
                ),
              );
            }).toList(),
      ),
    );
  }
}
