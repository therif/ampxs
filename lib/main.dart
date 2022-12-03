import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMPXS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Server Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool blMysql = false;
  bool blNginx = false;
  bool blPhp = false;
  bool blApache = false;
  String phpVersion = '';
  var itemsStrPhpVer = [
    '',
    '7.4',
    '8.1',
  ];

  Future<void> _showPilihanlDialog(BuildContext context, String judul,
      List<DropdownMenuItem<String>> dropdownItems) {
    String tmpisiChange = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(judul),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton(
                    value: phpVersion,
                    dropdownColor: Colors.green,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        Navigator.pop(context);
                        phpVersion = newValue!;
                      });
                    },
                    items: dropdownItems),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getServiceStatusnya() async {
    bool hasilakhir;
    var shell = Shell();
    var result;

    var resultB1 = await shell.run('''
        brew services list
        ''');

    final whitespaceRE = RegExp(r"(?! )\s+| \s+");

    if (resultB1.isNotEmpty) {
      //if not error
      // print('err [$i] -> ${resultB1.errLines}');
      // print('errt [$i] -> ${resultB1.errText}');
      for (var i = 0; i < resultB1.outLines.length; i++) {
        //print('outt [$i] -> ${resultB1.outLines.elementAt(i)}');
        String strPar1 = resultB1.outLines.elementAt(i);
        strPar1 = strPar1.replaceAll(whitespaceRE, " ");

        final strSplitted = strPar1.split(' ');
        if (strSplitted.length > 1) {
          if (strSplitted.elementAt(0) == 'mysql') {
            if (strSplitted.elementAt(1) == 'started') {
              blMysql = true;
            } else {
              blMysql = false;
            }
          } else if (strSplitted.elementAt(0) == 'nginx') {
            if (strSplitted.elementAt(1) == 'started') {
              blNginx = true;
            } else {
              blNginx = false;
            }
          } else if (strSplitted.elementAt(0) == 'php') {
            if (strSplitted.elementAt(1) == 'started') {
              blPhp = true;
            } else {
              blPhp = false;
            }
          } else if (strSplitted.elementAt(0) == 'apache') {
            if (strSplitted.elementAt(1) == 'started') {
              blApache = true;
            } else {
              blApache = false;
            }
          }
        }

        print(strSplitted);
      }

      setState(() {
        _counter++;
      });
    }
  }

  Future<void> _startStopService(String ident, bool bstatus) async {
    bool hasilakhir;
    var shell = Shell();
    var result;
    String iDentVer = '';

    if (ident.toLowerCase() == 'nginx') {
      if (bstatus == true) {
        result = await shell.run('''
        brew services restart nginx
        ''');
        print(result.toString());
        // var process = await Process.start('cat', []);
        // process.stdin.writeln('Hello, world!');
        // process.stdin.writeln('Hello, galaxy!');
        // process.stdin.writeln('Hello, universe!');
      } else {
        result = await shell.run('''
        brew services stop nginx
        ''');
        print(result.toString());
      }
    } else if (ident.toLowerCase() == 'php') {
      if (phpVersion.toLowerCase() == 'default') {
        iDentVer = '';
      } else {
        iDentVer = '@$phpVersion';
      }
      if (bstatus == true) {
        result = await shell.run('''
        brew services restart php$iDentVer
        ''');
        print(result.toString());
        // var process = await Process.start('cat', []);
        // process.stdin.writeln('Hello, world!');
        // process.stdin.writeln('Hello, galaxy!');
        // process.stdin.writeln('Hello, universe!');
      } else {
        result = await shell.run('''
        brew services stop php$iDentVer
        ''');
        print(result.toString());
      }
    } else if (ident.toLowerCase() == 'mysql') {
      if (bstatus == true) {
        result = await shell.run('''
        brew services restart mysql
        ''');
        print(result.toString());
        // var process = await Process.start('cat', []);
        // process.stdin.writeln('Hello, world!');
        // process.stdin.writeln('Hello, galaxy!');
        // process.stdin.writeln('Hello, universe!');
      } else {
        result = await shell.run('''
        brew services stop mysql
        ''');
        print(result.toString());
      }
    } else if (ident.toLowerCase() == 'apache') {
      if (bstatus == true) {
        result = await shell.run('''
        brew services restart apache2
        ''');
        print(result.toString());
        // var process = await Process.start('cat', []);
        // process.stdin.writeln('Hello, world!');
        // process.stdin.writeln('Hello, galaxy!');
        // process.stdin.writeln('Hello, universe!');
      } else {
        result = await shell.run('''
        brew services stop apache2
        ''');
        print(result.toString());
      }
    }

    _getServiceStatusnya();
    // setState(() {
    //   _counter++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: (MainAxisSize.min),
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: (CrossAxisAlignment.center),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //mainAxisSize: (MainAxisSize.max),
              children: [
                const Divider(
                  indent: 5,
                ),
                const Text(
                  'Nginx : ',
                ),
                Switch(
                  value: blNginx,
                  onChanged: (value) {
                    setState(() {
                      blNginx = value;

                      print(blNginx);
                      _startStopService('nginx', blNginx);
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                const Divider(
                  indent: 5,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //mainAxisSize: MainAxisSize.max,
              children: [
                const Divider(
                  indent: 5,
                ),
                const Text(
                  'Apache : ',
                ),
                Switch(
                  value: blApache,
                  onChanged: (value) {
                    setState(() {
                      blApache = value;

                      print(blApache);
                      _startStopService('apache', blApache);
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                const Divider(
                  indent: 5,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Divider(
                  indent: 5,
                ),
                const Text(
                  'MySQL : ',
                ),
                Switch(
                  value: blMysql,
                  onChanged: (value) {
                    setState(() {
                      blMysql = value;

                      print(blMysql);
                      _startStopService('mysql', blMysql);
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                const Divider(
                  indent: 5,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //mainAxisSize: MainAxisSize.max,
              children: [
                const Divider(
                  indent: 5,
                ),
                const Text(
                  'PHP : ',
                ),
                DropdownButton(
                  value: phpVersion,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: itemsStrPhpVer.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      phpVersion = newValue!;
                    });
                  },
                ),
                Switch(
                  value: blPhp,
                  onChanged: (value) {
                    setState(() {
                      blPhp = value;
                      _startStopService('php', blPhp);
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
                const Divider(
                  indent: 5,
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            alignment: MainAxisAlignment.center,
            overflowSpacing: 5.0,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    //shadowColor = !shadowColor;
                  });
                },
                icon: Icon(
                  Icons.info_outline,
                ),
                label: const Text('about'),
              ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  //
                },
                icon: const Icon(Icons.settings),
                label: Text('Install'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getServiceStatusnya,
        tooltip: 'Refresh Service Status',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
