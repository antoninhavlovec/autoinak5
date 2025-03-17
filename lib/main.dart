import 'package:autoinak5/dochazka_page.dart';
import 'package:autoinak5/zadanky_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'invoices_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Bar Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<Widget> _children = [];
  List<BottomNavigationBarItem> _bottomNavBarItems = [];
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadShowInvoices().then((_) {
      setState(() {
        _dataLoaded = true;
      });
    });
  }

  Future<void> _loadShowInvoices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showInvoices = prefs.getBool('showInvoices') ?? true;
    _updateNavigationItems(showInvoices);
  }

  void _updateNavigationItems(bool showInvoices) {
    List<Widget> newChildren = [];
    List<BottomNavigationBarItem> newBottomNavBarItems = [];

    if (showInvoices) {
      newChildren.add(InvoicesPage());
      newBottomNavBarItems.add(
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Faktury'),
      );
    }

    newChildren.add(ZadankyPage());
    newBottomNavBarItems.add(
      const BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Žádanky'),
    );

    newChildren.add(DochazkaPage());
    newBottomNavBarItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Docházka',
      ),
    );

    setState(() {
      _children = newChildren;
      _bottomNavBarItems = newBottomNavBarItems;
      if (_currentIndex >= _children.length) {
        _currentIndex = _children.length - 1;
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTO IŇák'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ).then((_) => _loadShowInvoices());
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: _bottomNavBarItems,
      ),
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
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _employeeIdController = TextEditingController();
  bool _showInvoices = true;

  @override
  void initState() {
    super.initState();
    print('initState called');
    _loadEmployeeId();
    _loadShowInvoices();
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

  _saveEmployeeId(String employeeId) async {
    print('_saveEmployeeId called with: $employeeId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('employeeId', employeeId);
    print('employeeId saved to prefs');
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Číslo zaměstnance 32890125',
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                _saveEmployeeId(value);
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveEmployeeId(_employeeIdController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID zaměstnance bylo uloženo')),
                );
              },
              child: const Text('Uložit'),
            ),
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
          ],
        ),
      ),
    );
  }
}
