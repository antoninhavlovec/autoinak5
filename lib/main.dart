import 'dart:async';

import 'package:autoinak5/dochazka_page.dart';
import 'package:autoinak5/zadanky_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'invoices_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'objednavky_page.dart';
import 'services/firestore_service.dart';

/// Autor: Antonín Havlovec
///
/// verze 20250317
///   napojení na GIT
///   1.git status (zkontrolovat stav)
///   2.git add . (přidat soubory do staging area)
///   3.git commit -m "20250317" (vytvořit verzi)
///   4.git branch -M main (Nastavit výchozí větev)
///   5.git push -u origin main (nahrát na GitHub)
///
/// verze 20250328
///   přidáno startovací logo, po změně loga je potřeba pustit
///   flutter pub run flutter_native_splash:create
///
/// verze 20250331
/// přidána ikona aplikace
/// při změně je potřeba pustit: flutter pub run flutter_launcher_icons:main
///
/// verze 20250408
/// přidány objednávky, vyhledávání

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestoreService = FirestoreService(); // Vytvoříme instanci
  runApp(MyApp(firestoreService: firestoreService)); // Předáme ji
}

class MyApp extends StatelessWidget {
  final FirestoreService firestoreService;
  const MyApp({super.key, required this.firestoreService}); // Přidána inicializace

  Widget build(BuildContext context) {
    const lightBlue = Colors.lightBlue;
    final colorScheme = ColorScheme.fromSwatch(
      primarySwatch: lightBlue,
      brightness: Brightness.light, // Pro světlé téma,
      //brightness: Brightness.dark, // Pro světlé téma,
    ).copyWith(
      primaryContainer: lightBlue.shade100, // Nebo jiný odstín, který preferuješ
    );

    return MaterialApp(
      title: 'Bottom Navigation Bar Demo',
      theme: ThemeData(
        colorScheme: colorScheme, // Použijeme náš definovaný ColorScheme
        // NEPOUŽÍVEJ primaryChatch, pokud definuješ ColorScheme
      ),
      home: MyHomePage(firestoreService: firestoreService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FirestoreService firestoreService; // Přidali jsme proměnnou

  const MyHomePage({super.key, required this.firestoreService});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<Widget> _children = [];
  List<BottomNavigationBarItem> _bottomNavBarItems = [];
  bool _dataLoaded = false;
  bool _showInvoices = true; // Přidáme proměnnou pro faktury
  bool _showAttendance = true; // Přidáme proměnnou pro docházku
  bool _showObjednavky = true; // Přidání proměnné pro objednávky
  int _unapprovedInvoicesCount = 0; // Počet neschválených faktur
  int _unapprovedRequestsCount = 0; // Počet neschválených žádostí
  StreamSubscription? _invoicesSubscription; // Přidáno
  StreamSubscription? _requestsSubscription; // Přidáno
  Future<int?> _employeeIdFuture = Future.value(null); //

  @override

  void initState() {
    super.initState();
    _employeeIdFuture = _loadEmployeeId(); // Spustíme načítání
    _loadShowOptions().then((_) {
      _loadInitialData(); // Voláme _loadInitialData po načtení nastavení viditelnosti
    });
  }

  Future<int?> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeIdString = prefs.getString('employeeId');
    if (employeeIdString != null) {
      return int.parse(employeeIdString);
    } else {
      return null;
    }
  }

  void _subscribeToInvoiceChanges() async {
    // Odhlásíme případný existující odběr:
    _invoicesSubscription?.cancel();
    String? employeeIdString = await getEmployeeId();
    if (employeeIdString != null) {
      int employeeId = int.parse(employeeIdString);
      _invoicesSubscription = widget.firestoreService
          .getInvoicesWithCount(employeeId)
          .listen((data) {
            setState(() {
              _unapprovedInvoicesCount = data.$2;
              _updateNavigationItems(_showInvoices);
            });
          });
    } else {
      // Pokud není employeeId, nastavíme počet na 0 (nebo jinou vhodnou hodnotu):
      setState(() {
        _unapprovedInvoicesCount = 0;
        _updateNavigationItems(_showInvoices);
      });
    }
  }

  void _subscribeToRequestsChanges() async {
    // Upraveno: employeeId se získává uvnitř
    // Odhlásíme případný existující odběr:
    _requestsSubscription?.cancel();
    String? employeeIdString = await getEmployeeId();
    if (employeeIdString != null) {
      int employeeId = int.parse(employeeIdString);
      _requestsSubscription = widget.firestoreService
          .getZadankyWithCount(employeeId)
          .listen((data) {
            setState(() {
              _unapprovedRequestsCount = data.$2;
              _updateNavigationItems(_showInvoices);
            });
          });
    } else {
      // Pokud není employeeId, nastavíme počet na 0:
      setState(() {
        _unapprovedRequestsCount = 0;
        _updateNavigationItems(_showInvoices);
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadInitialData() async {
    await _loadShowOptions();
    _subscribeToInvoiceChanges(); // Voláme vždy
    _subscribeToRequestsChanges(); // Voláme vždy
    String? employeeIdString = await getEmployeeId();
    if (employeeIdString != null) {
      int employeeId = int.parse(employeeIdString);
      _unapprovedRequestsCount =
          (await widget.firestoreService.getCountRequests(employeeId))!;
    } else {
      _unapprovedRequestsCount = 0; // Nebo jiná výchozí hodnota
    }
    setState(() {
      _dataLoaded = true;
      _updateNavigationItems(_showInvoices);
    });
  }

  @override
  void dispose() {
    _invoicesSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }

  Future<String?> getEmployeeId() async {
    print('getEmployeeId called');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('SharedPreferences instance obtained');
    String? employeeId = prefs.getString('employeeId');
    print('employeeId from prefs: $employeeId');
    return employeeId;
  }

  void _onRequestsChanged() {
    if (_dataLoaded) {
      // Zkontrolujeme, zda jsou data načtena
      _updateRequestCountForBadge(); // Nová metoda
    }
  }

  Future<void> _updateRequestCountForBadge() async {
    if (_dataLoaded) {
      // Znovu zkontrolujeme, zda jsou data načtena
      String? employeeIdString = await getEmployeeId();
      if (employeeIdString != null) {
        int employeeId = int.parse(employeeIdString);
        _unapprovedRequestsCount =
            (await widget.firestoreService.getCountRequests(employeeId))!;
        setState(() {
          _updateNavigationItems(_showInvoices);
        });
      }
    }
  }

  Future<void> _loadShowOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _showInvoices = prefs.getBool('showInvoices') ?? true;
    _showAttendance = prefs.getBool('showAttendance') ?? true;
    _showObjednavky = prefs.getBool('showObjednavky') ?? true; //
    _updateNavigationItems(_showInvoices);
  }

  void _updateNavigationItems(bool showInvoices) {
    print('_updateNavigationItems called');
    print('ShowInvoices: $showInvoices');
    print('ShowAttendance: $_showAttendance');
    List<Widget> newChildren = [];
    List<BottomNavigationBarItem> newBottomNavBarItems = [];

    if (showInvoices) {
      newChildren.add(InvoicesPage());
      newBottomNavBarItems.add(
        BottomNavigationBarItem(
          icon: _buildBadge(
            SvgPicture.asset('asset/icons/invoice.svg', width: 32, height: 32),
            _unapprovedInvoicesCount,
          ), // Použití vlastní ikony a počtu
          label: 'Faktury',
        ),
      );
    }

    if (_showAttendance) {
      newChildren.add(DochazkaPage());
      newBottomNavBarItems.add(
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'asset/icons/availability.svg',
            width: 32,
            height: 32,
          ), // Použití vlastní ikony
          label: 'Docházka',
        ),
      );
    }

    if (_showObjednavky) {
      // Přidání podmínky pro objednávky
      newChildren.add(
        FutureBuilder<int?>(
          future: _employeeIdFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Zobrazíme indikátor načítání, dokud není employeeId známo
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Nepodařilo se načíst ID zaměstnance.')); // Zobrazíme chybovou zprávu
            } else {
              final employeeId = snapshot.data!;
              return ObjednavkyPage(
                employeeId: employeeId,
                firestoreService: widget.firestoreService, // Předáváme instanci FirestoreService
              );
            }
          },
        ),
      );
      newBottomNavBarItems.add(
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'asset/icons/new-car.svg', // Předpokládáme ikonu pro objednávky
            width: 32,
            height: 32,
          ),
          label: 'Objednávky',
        ),
      );
    }

    newChildren.add(ZadankyPage(onRequestsChanged: _onRequestsChanged));
    newBottomNavBarItems.add(
      BottomNavigationBarItem(
        icon: _buildBadge(
          SvgPicture.asset('asset/icons/vacation.svg', width: 32, height: 32),
          _unapprovedRequestsCount,
        ), // Použití vlastní ikony a počtu
        label: 'Žádanky',
      ),
    );
    setState(() {
      _children = newChildren;
      _bottomNavBarItems = newBottomNavBarItems;
      if (_currentIndex >= _children.length) {
        _currentIndex = _children.length - 1;
      }
      if (_selectedIndex >= _children.length) {
        _selectedIndex = _children.length - 1;
      }
    });
  }

  Widget _buildBadge(Widget icon, int count) {
    print('_buildBadge called with count: $count');
    print('_unapprovedInvoicesCount: $_unapprovedInvoicesCount');
    print('_unapprovedRequestsCount: $_unapprovedRequestsCount');
    return Stack(
      children: [
        icon,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 8,
              child: Text(
                count.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  void onTabTapped(int index) {
    print('onTabTapped called with index: $index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MyHomePage build called with _currentIndex: $_currentIndex');

    if (!_dataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'asset/logo/logo_pouze_AUTO_INak_trans.png',
          height: 30,
        ), //logo_pouze_AUTO_INak_trans
        //backgroundColor: Color(0xFFCBEAFF),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          SettingsPage(onEmployeeIdChanged: _loadInitialData),
                ), // Předání callbacku
              );
            },
          ),
        ],
      ),
      //      body: _children[_currentIndex],
      body: _children[_selectedIndex],
      bottomNavigationBar:
          _bottomNavBarItems.length >= 2
              ? BottomNavigationBar(
//                backgroundColor: const Color(0xFFCBEAFF), // Nastavení barvy
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                //        currentIndex: _currentIndex,
                currentIndex: _selectedIndex,
                items: _bottomNavBarItems,
                //        onTap: (index) {
                //          setState(() {
                //            _currentIndex = index;
                //          });
                //        },
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.black, //Barva ikony při výběru
                unselectedItemColor:
                    Colors.grey, //Barva ikony, která není vybraná
              )
              : null,
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  const PlaceholderWidget(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: color);
  }
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onEmployeeIdChanged; // Přidáno: callback funkce

  const SettingsPage({
    super.key,
    required this.onEmployeeIdChanged,
  }); // Upravený konstruktor

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _employeeIdController = TextEditingController();
  bool _showInvoices = true;
  bool _showAttendance = true;
  bool _showObjednavky = true; // Přidání proměnné pro objednávky

  @override
  void initState() {
    super.initState();
    print('initState called');
    _loadEmployeeId();
    _loadShowInvoices();
    _loadShowAttendance(); // Načtení stavu docházky
    _loadShowObjednavky(); // Načtení stavu objednávek
  }

  _loadShowInvoices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showInvoices = prefs.getBool('showInvoices');
    if (showInvoices != null) {
      setState(() {
        _showInvoices = showInvoices;
      });
    }
  }

  _saveShowInvoices(bool showInvoices) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showInvoices', showInvoices);
  }

  _loadShowAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showAttendance = prefs.getBool('showAttendance'); // Změněný klíč
    if (showAttendance != null) {
      setState(() {
        _showAttendance = showAttendance;
      });
    }
  }

  _loadShowObjednavky() async {
    // Funkce pro načtení stavu objednávek
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showObjednavky = prefs.getBool('showObjednavky');
    if (showObjednavky != null) {
      setState(() {
        _showObjednavky = showObjednavky;
      });
    }
  }

  _saveShowObjednavky(bool showObjednavky) async {
    // Funkce pro uložení stavu objednávek
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showObjednavky', showObjednavky);
  }

  // Funkce pro uložení stavu docházky
  _saveShowAttendance(bool showAttendance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAttendance', showAttendance); // Změněný klíč
  }

  _loadEmployeeId() async {
    print('_loadEmployeeId called');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('SharedPreferences instance obtained');
    String? employeeId = prefs.getString('employeeId');
    print('employeeId from prefs: $employeeId');
    if (employeeId != null) {
      setState(() {
        print('setState called');
        _employeeIdController.text = employeeId;
      });
    }
  }

  _saveEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'employeeId',
      _employeeIdController.text,
    ); // Uložení zadaného ID
    // await widget.onEmployeeIdChanged(); // Zavoláme callback funkci - PŘESUNUTO ZA Navigator.pop
    Navigator.pop(context); // Vrátíme se na předchozí obrazovku
    widget.onEmployeeIdChanged(); // Zavoláme callback funkci po návratu
    /*    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID zaměstnance bylo uloženo')),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
//        backgroundColor: Color(0xFFCBEAFF),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Číslo zaměstnance 32890125, 21677, 18684263',
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                _saveEmployeeId();
              },
            ),
            const SizedBox(height: 16.0),
            /*            ElevatedButton(
              onPressed: () {
                _saveEmployeeId();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID zaměstnance bylo uloženo ')),
                );
              },
              child: const Text('Uložit'),
            ),*/
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Zobrazit Faktury'),
                Switch(
                  value: _showInvoices,
                  onChanged: (value) {
                    _saveShowInvoices(value);
                    setState(() {
                      _showInvoices = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              // Nový řádek pro Switch docházky
              children: [
                const Text('Zobrazit Docházku'), // Text pro přepínač docházky
                Switch(
                  // Nový Switch pro docházku
                  value: _showAttendance, // Aktuální stav zobrazení docházky
                  onChanged: (value) {
                    _saveShowAttendance(
                      value,
                    ); // Uložení stavu do SharedPreferences
                    setState(() {
                      _showAttendance = value; // Změna stavu přepínače
                    });
                  },
                ),
              ],
            ),
            Row(
              // Nový řádek pro Switch objednávek
              children: [
                const Text('Zobrazit objednávky'), // Text pro přepínač docházky
                Switch(
                  // Nový Switch pro docházku
                  value: _showObjednavky, // Aktuální stav zobrazení docházky
                  onChanged: (bool value) {
                    setState(() {
                      _showObjednavky = value;
                      _saveShowObjednavky(value); // Uložení stavu objednávek
                      // Nepředáváme onEmployeeIdChanged, protože se to netýká ID zaměstnance
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _saveEmployeeId();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID zaměstnance bylo uloženo ')),
                );
              },
              child: const Text('Uložit'),
            ),
          ],
        ),
      ),
    );
  }
}
