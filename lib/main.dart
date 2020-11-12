import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:sms/sms.dart';
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

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  getId(Client item) {
    print(item.text);
    print(item.lastName);
    return item.id.toString();
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _checkTexts());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
            setState(() {});
          }
        }
      }
    });
  }

  void _sendSMS(String message, String recipient) async {
    List<String> s = new List<String>();
    s.add(recipient);
    String _result = await sendSMS(message: message, recipients: s)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  //"6:00 AM"
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Client>>(
        future: DBProvider.db.getAllClients(),
        builder: (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Client item = snapshot.data[index];
                //DBProvider.db.deleteAll();
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteClient(item.id);
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          title: Text(item.firstName.capitalize() + " " + item.lastName.capitalize()),
                          leading: Text(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item.date)).toString()),
                          trailing: Text(item.text),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateText(title: "Create a text to send!")),
          ).then(onGoBack);
          /*
          Random random = new Random();
          Client rnd = testClients[random.nextInt(testClients.length)];
          await DBProvider.db.newClient(rnd);*/
          setState(() {});
        },
      ),
    );
  }
}
