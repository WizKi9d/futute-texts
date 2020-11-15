import 'dart:async';
import 'package:dough/dough.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:sms/sms.dart';
import 'SentStatsDatabase.dart';
import 'SentTexts.dart';
import 'extensions/stringManipulation.dart';
import 'SendTexts.dart';
import 'package:flutter/material.dart';
import 'package:future_texts/CreateText.dart';
import 'dart:math';
import 'Database.dart';
import 'Text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Future Texts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Timer timer;

  @override
  void initState() {
    getUnsentCount();
    getSentTexts();
    super.initState();
    Timer.periodic(Duration(seconds: 3), (Timer t) {
      _checkTexts();
      getUnsentCount();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  getUnsentCount() {
    var c = DBProvider.db.getAllClients();
    c.then((g) {
      if (g.length == 0) {
        setState(() => _unsentCount = 0);
      } else {
        setState(() => _unsentCount = g.length);
      }
    });
  }

  int _unsentCount = 0;

  int _sentTexts = 0;

  getSentTexts() {
    var f = SentDb.db.getAllSentTexts();
    f.then((c) {
      setState(() => _sentTexts = c[0].sentNo);
    });
  }

  FutureOr onGoBack(dynamic value) {
    setState(() => _unsentCount = getUnsentCount());
  }

  getId(Client item) {
    print(item.text);
    print(item.lastName);
    return item.id.toString();
  }

  _checkTexts() {
    var people = DBProvider.db.getAllClients();
    people.then((data) {
      var df = DateFormat('yyyy-MM-dd');
      for(int i = 0; i < data.length; i++) {
        if (df.format(DateTime.fromMillisecondsSinceEpoch(data[i].date)) == df.format(DateTime.now())) {
          var userSetTime = data[i].time;
          var timeNow = formatTimeOfDay(TimeOfDay.now());
          //print(userSetTime + " and then " + timeNow);
          if (userSetTime == timeNow) {
            // Send the text to the user!
            print(data[i].firstName);
            print(data[i].number);
            SmsSender sender = new SmsSender();
            sender.sendSms(new SmsMessage(data[i].number, data[i].text));
            DBProvider.db.deleteClient(data[i].id);

            // This will setState too.
            updateSentTextsCount();
          }
        }
      }
    });
  }

  updateSentTextsCount() {
    var f = SentDb.db.getAllSentTexts();
    f.then((c) {
      c[0].sentNo++;
      SentDb.db.updateSentTexts(c[0]);
      setState(() {
        getSentTexts();
      });
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  //"6:00 AM"
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    //_unsentCount = getUnsentCount();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: new EdgeInsets.fromLTRB(24.0, 100.0, 0, 10.0),
            child: Row(
                children: <Widget>[
                  Text("See your stats", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  Icon(Icons.arrow_forward, size: 28.0)
                ]
            ),
          ),
          PressableDough(
          child: Container(
            decoration: BoxDecoration(
              color: HexColor("B5B5B5"),
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 11,
                  offset: Offset(1, 4), // changes position of shadow
                ),
              ],
            ),
            height: 90,
            width: 380,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: new EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(17))
                    ),
                    height: 62,
                    width: 62,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          // DISPLAY NUMBER OF SENT TEXTS HERE -----------------------------------------
                            Text(_sentTexts.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: new EdgeInsets.fromLTRB(0, 22, 0, 5),
                      child: Text("Texts sent", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                    ),
                    Row(
                    children: [
                        Text("$_unsentCount unsent texts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HexColor("7E7E7E"))),
                      ]
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: new EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Icon(Icons.arrow_forward_ios, size: 35, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          Padding(
            padding: new EdgeInsets.fromLTRB(24.0, 40.0, 0, 0),
            child: Row(
                children: <Widget>[
                  Text("Your queue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ]
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: DBProvider.db.getAllClients(),
              builder: (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
                if (snapshot.hasData) {
                  return MediaQuery.removePadding(context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Client item = snapshot.data[index];
                      //DBProvider.db.deleteAll();
                      return Stack(
                          overflow: Overflow.clip,
                          children: <Widget>[
                            Padding(
                              padding: new EdgeInsets.fromLTRB(0, 12, 0, 12),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 90,
                                    width: 380,
                                    decoration: BoxDecoration(
                                      color: HexColor("F0707A"),
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 11,
                                          offset: Offset(1, 4), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: new EdgeInsets.fromLTRB(20, 0, 0, 0),
                                          child: Icon(Icons.delete, color: Colors.white, size: 40),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                            ),
                            Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              DBProvider.db.deleteClient(item.id);
                              // For testing only:
                              //updateSentTextsCount();
                              setState(() => getUnsentCount());
                              snapshot.data.removeAt(index);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: new EdgeInsets.fromLTRB(0, 12, 0, 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: HexColor("FFFFFF"),
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    height: 90,
                                    width: 380,
                                    child: Padding(
                                      padding: const EdgeInsets.all(22.0),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.message, size: 36, color: HexColor("B5B5B5"),),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: new EdgeInsets.fromLTRB(15, 0, 0, 0),
                                                  child: Text(item.firstName.capitalize() + " " + item.lastName.capitalize(), style: TextStyle(color: HexColor("B5B5B5"), fontSize: 20.0),),
                                                ),
                                                Padding(
                                                  padding: new EdgeInsets.fromLTRB(15, 5, 0, 0),
                                                  child: Text(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item.date)).toString() + " " + item.time,
                                                    style: TextStyle(color: HexColor("7A7A7A"), fontSize: 15.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  );
                } else {
                  return Icon(Icons.lens, color: Colors.white);
                }
              },
            ),
          ),
      ]
      ),
      floatingActionButton: PressableDough(child: FloatingActionButton.extended(
        label: Text('New Text'),
        icon: Icon(Icons.add),
        backgroundColor: HexColor("7ACEAF"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateText(title: "Create a text to send!")),
          ).then(onGoBack);
          /*
          Random random = new Random();
          Client rnd = testClients[random.nextInt(testClients.length)];
          await DBProvider.db.newClient(rnd);*/
          //setState(() => getUnsentCount());
        },
      ),
      ),
    );
  }
}
