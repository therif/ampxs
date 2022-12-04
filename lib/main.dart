import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:logger/logger.dart';

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
  static const double defTblHeight = 40;
  String serviceCtlPath = "/opt/homebrew/bin/brew";

  bool blProsesRefresh = false;
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

  String osPlatformInfo = Platform.operatingSystem; //in your code
  String osPlatformDetailInfo = Platform.operatingSystemVersion;

  Future<void> setExePath() async {
    if (kIsWeb) {
      serviceCtlPath = '';
      print('is a WEB');
    } else {
      if (Platform.isMacOS) {
        //if M1
        serviceCtlPath = "/opt/homebrew/bin/brew";
        //serviceCtlPath = "/usr/local/bin/brew"; //for intel
      }
      if (Platform.isWindows) {
        serviceCtlPath = "/windows/cmd";
      }
      if (Platform.isLinux) {
        serviceCtlPath = "/bin/bash";
      }
    }
  }

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<void> _getServiceStatusnya() async {
    if (blProsesRefresh == false) {
      blProsesRefresh = true;
      setState(() {
        blProsesRefresh;
      });
      var shell = Shell();
      late List<ProcessResult> resultB1;

      try {
        resultB1 = await shell.run('''
        $serviceCtlPath services list
        ''');
      } catch (e) {
        logger.e(e);
        print(e.toString());
      }

      final whitespaceRE = RegExp(r"(?! )\s+| \s+");

      if (resultB1.isNotEmpty) {
        //if not error
        if (resultB1.errText.isNotEmpty) {
          print(resultB1.errText.toString());
          exit;
        }

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

          //(strSplitted);
        }

        setState(() {
          blApache;
          blMysql;
          blNginx;
          blPhp;
        });
      }

      blProsesRefresh = false;
      setState(() {
        blProsesRefresh;
      });
    }
  }

  Future<void> _startStopService(String ident, bool bstatus) async {
    var shell = Shell();
    List<ProcessResult> result;
    String iDentVer = '';

    if (ident.toLowerCase() == 'nginx') {
      if (bstatus == true) {
        result = await shell.run('''
        $serviceCtlPath services restart nginx
        ''');
      } else {
        result = await shell.run('''
        $serviceCtlPath services stop nginx
        ''');
      }
    } else if (ident.toLowerCase() == 'php') {
      if (phpVersion.toLowerCase() == 'default') {
        iDentVer = '';
      } else {
        iDentVer = '@$phpVersion';
      }
      if (bstatus == true) {
        result = await shell.run('''
        $serviceCtlPath services restart php$iDentVer
        ''');
      } else {
        result = await shell.run('''
        $serviceCtlPath services stop php$iDentVer
        ''');
      }
    } else if (ident.toLowerCase() == 'mysql') {
      if (bstatus == true) {
        result = await shell.run('''
        $serviceCtlPath services restart mysql
        ''');
      } else {
        result = await shell.run('''
        $serviceCtlPath services stop mysql
        ''');
      }
    } else if (ident.toLowerCase() == 'apache') {
      if (bstatus == true) {
        result = await shell.run('''
        $serviceCtlPath services restart apache2
        ''');
      } else {
        result = await shell.run('''
        $serviceCtlPath services stop apache2
        ''');
      }
    }

    _getServiceStatusnya();
  }

  Widget listAppMng() {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            const SizedBox(
              height: defTblHeight,
            ),
            const SizedBox(
              child: Text(
                'Nginx',
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(),
            ),
            SizedBox(
              child: Switch(
                value: blNginx,
                onChanged: (value) {
                  setState(() {
                    blNginx = value;
                    _startStopService('nginx', blNginx);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(),
          ],
        ),
        TableRow(
          children: <Widget>[
            const SizedBox(
              height: defTblHeight,
            ),
            const SizedBox(
              child: Text(
                'Apache',
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(),
            ),
            SizedBox(
              child: Switch(
                value: blApache,
                onChanged: (value) {
                  setState(() {
                    blApache = value;
                    _startStopService('apache', blApache);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(),
          ],
        ),
        TableRow(
          children: <Widget>[
            const SizedBox(
              height: defTblHeight,
            ),
            const SizedBox(
              child: Text(
                'MySQL',
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Container(),
            ),
            SizedBox(
              child: Switch(
                value: blMysql,
                onChanged: (value) {
                  setState(() {
                    blMysql = value;
                    _startStopService('mysql', blMysql);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(),
          ],
        ),
        TableRow(
          children: <Widget>[
            const SizedBox(
              height: defTblHeight,
            ),
            const SizedBox(
              child: Text(
                'PHP',
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: DropdownButton(
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
            ),
            SizedBox(
              child: Switch(
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
            ),
            const SizedBox(),
          ],
        ),
      ],
    );
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
            Column(
              children: [
                Text(
                  'OS : $osPlatformInfo',
                ),
                Text(
                  'Detail : $osPlatformDetailInfo',
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),

            //
            listAppMng(),
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
                icon: const Icon(
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
                label: const Text('Install'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getServiceStatusnya,
        tooltip: blProsesRefresh
            ? 'Processing, Please Wait...'
            : 'Refresh Service Status',
        child: blProsesRefresh
            ? const Icon(Icons.update)
            : const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
