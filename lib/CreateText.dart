import 'dart:async';
//import 'package:contacts_plugin/contacts_plugin.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'Database.dart';
import 'SentStatsDatabase.dart';
import 'SentTexts.dart';
import 'Text.dart';

class CreateText extends StatefulWidget {
  CreateText({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CreateTextState createState() => _CreateTextState();
}

class _CreateTextState extends State<CreateText> {
  String firstname;
  String lastname;
  String text;
  int _date;
  String _time;
  String _number;

  String setTime = "Not set";
  String setDate = "Not set";
  String setUser = "Select contact";

  Client getClientDetails;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  void _submit() {
    if (this.formKey.currentState.validate())
      formKey.currentState.save();

    var db = DBProvider.db;

    if (firstname == null || lastname == null || text == null || _date == null || _time == null || _number == null) {
       _showSnackBar("Please fill in the fields correctly");
    } else {
      if (lastname.isEmpty)
        lastname = " ";
      var fullText = Client(firstName: firstname, lastName: lastname, text: text, date: _date, time: _time, number: _number);
      _showSnackBar("Saved!");
      db.newClient(fullText);

      var duration = new Duration(seconds: 2);
      new Timer(duration, route);
    }
  }

  void route() {
    Navigator.pop(context);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  _navigateAndTakeSelection(BuildContext context) async {
    final Future<Client> result = Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseContact(title: "Choose who to send text to", context: context)),
    );

    result.then((details) {
      setState(() {
        if (details != null) {
          firstname = details.firstName;
          lastname = details.lastName;
          _number = details.number;
          setUser = firstname + " " + lastname;
        }
      });
    });
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2)
    );

    if (date != null) {
      setState(() {
        _date = date.millisecondsSinceEpoch;
        setDate = DateFormat('yyyy-MM-dd').format(date).toString();
      });
    }
  }

  _pickTime() async {
    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );

    if (time != null) {
      setState(() {
        _time = formatTimeOfDay(time);
        setTime = formatTimeOfDay(time);
      });
    }
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
      key: scaffoldKey,
      //appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 16.0),
        child: new Form(
          key: formKey,
          child: new Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: new EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: Text("Create your new text", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
              Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 15),
                  child: Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all((Radius.circular(15))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(1, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: new EdgeInsets.fromLTRB(20, 15, 0, 0),
                            child: Text("Date", style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                      FlatButton(onPressed: () {
                      _pickDate();
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all((Radius.circular(5))),
                            border: Border.all(color: HexColor("D2D2D2")),
                          ),
                          child: Padding(
                            padding: new EdgeInsets.fromLTRB(7, 8, 0, 8),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: HexColor("A1A1A1"),),
                                Padding(
                                  padding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text('$setDate', style: TextStyle(fontSize: 16.0, color: HexColor("BABABA")),),
                                ),
                              ]
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: new EdgeInsets.fromLTRB(20, 15, 0, 0),
                            child: Text("Time", style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                      FlatButton(onPressed: () {
                        _pickTime();
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all((Radius.circular(5))),
                            border: Border.all(color: HexColor("D2D2D2")),
                          ),
                          child: Padding(
                            padding: new EdgeInsets.fromLTRB(7, 8, 0, 8),
                            child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 20, color: HexColor("A1A1A1"),),
                                  Padding(
                                    padding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text('$setTime', style: TextStyle(fontSize: 16.0, color: HexColor("BABABA")),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: Container(
                  height: 70.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all((Radius.circular(15))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(1, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Spacer(),
                      FlatButton(onPressed: () {
                        _navigateAndTakeSelection(context);
                      },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all((Radius.circular(5))),
                            border: Border.all(color: HexColor("D2D2D2")),
                          ),
                          child: Padding(
                            padding: new EdgeInsets.fromLTRB(7, 8, 0, 8),
                            child: Row(
                                children: [
                                  Icon(Icons.person, size: 20, color: HexColor("A1A1A1"),),
                                  Padding(
                                    padding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text('$setUser', style: TextStyle(fontSize: 16.0, color: HexColor("BABABA")),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: new EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all((Radius.circular(15))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(1, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: new EdgeInsets.fromLTRB(20, 15, 0, 5),
                            child: Text("Message", style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: new EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextFormField(
                          maxLines: 5,
                          decoration: new InputDecoration(
                              labelText: "Enter your message",
                              alignLabelWithHint: false,
                              prefixIcon: Icon(Icons.message, size: 20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: HexColor("D2D2D2"))
                              ),
                          ),
                          onSaved: (val) => this.text = val,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Spacer(flex: 2,),
          PressableDough(
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: HexColor("f0707a"),
              onPressed: () {
                route();
              },
              child: Icon(Icons.close, size: 30, color: Colors.white),
            ),
          ),
          Spacer(),
          PressableDough(
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: HexColor("7aceaf"),
              onPressed: () {
                _submit();
              },
              child: Icon(Icons.check, size: 30, color: Colors.white),
            ),
          ),
          Spacer(flex: 2,),
        ]
      ),
    );
  }
}

class ChooseContact extends StatefulWidget {
  ChooseContact({Key key, this.title, this.context}) : super(key: key);

  final BuildContext context;
  final String title;

  @override
  _chooseContactState createState() => _chooseContactState();
}

class _chooseContactState extends State<ChooseContact> {

  String _searchTerm = "";

  Future<Iterable<Contact>> _contacts = ContactsService.getContacts();

  //var _contacts = ContactsPlugin().getContacts().then((value) => value.toSet().toList());
  Future<Iterable<Contact>> chosenContacts;

  updateSearchTerm(String val) {
    setState(() {
      _searchTerm = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: new EdgeInsets.fromLTRB(10, 70, 0, 10),
                child: Text("Choose contact", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          Padding( 
            padding: new EdgeInsets.fromLTRB(0, 0, 0, 25),
            child: Container(
              height: 70.0,
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all((Radius.circular(15))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 5,
                    offset: Offset(1, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: new EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: TextFormField(
                  onChanged: (str) {
                    setState(() {
                      chosenContacts = _contacts.then((value) =>
                          value.where((element) => element.givenName != null
                              ? element.displayName != null ? element.displayName.toLowerCase().contains(str.toLowerCase()) : false : false));
                      /*
                      chosenContacts = _contacts.then((value) =>
                          value.where((element) => element.givenName != null
                              ? element.familyName != null ? (element.givenName.toLowerCase() + " " +  element.familyName.toLowerCase()).contains(str.toLowerCase()) : element.givenName.toLowerCase().contains(str.toLowerCase())
                              : element.familyName != null ? (element.familyName.toLowerCase()).contains(str.toLowerCase()) : false));*/
                    });
                  },
                  maxLines: 1,
                  decoration: new InputDecoration(
                    labelText: "Search contact",
                    alignLabelWithHint: false,
                    prefixIcon: Icon(Icons.person, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: HexColor("D2D2D2"))
                    ),
                  ),
                  validator: (val) =>
                  val.length == 0 ? "Enter a contact name" : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: chosenContacts ?? _contacts,
                builder: (BuildContext context, AsyncSnapshot<Iterable<Contact>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return MediaQuery.removePadding(context: context,
                    removeTop: true,
                    child: ListView(
                      children:
                        snapshot.data.map((contact) => ContactWidget(contact, context)).toList(),
                    ),
                  );
               },
            ),
          ),
      ]
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Spacer(flex: 2,),
            PressableDough(
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: HexColor("f0707a"),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close, size: 30, color: Colors.white),
              ),
            ),

            Spacer(flex: 2,),
          ]
      ),
    );
  }
}

class ContactWidget extends StatelessWidget {
  final Contact _contact;
  final BuildContext _context;

  ContactWidget(this._contact, this._context);

  String _firstName;
  String _lastName;
  String _number;

  _returnContact() {
    _firstName = _contact.givenName;
    _lastName = _contact.familyName;
    _number = _contact.phones.first.value;

    var contact = Client(firstName: _firstName, lastName: _lastName, text: "text", number: _number);

    Navigator.pop(_context, contact);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _returnContact(),
        child: Padding(
          padding: new EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Container(
            height: 70.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all((Radius.circular(15))),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(1, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: new EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: CircleAvatar(
                  backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length - 1)],
                  child: Text(_contact.displayName?.substring(0, 1)?.toUpperCase() ?? "")
                ),
                ),
                Text(_contact.displayName ?? "No name"),
              ],
            ),
          ),
        ),
      );
  }
}