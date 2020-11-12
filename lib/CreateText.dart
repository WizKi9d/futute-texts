import 'dart:async';
import 'package:contacts_plugin/contacts_plugin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'Database.dart';
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
      setState(() {});
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
      firstname = details.firstName;
      lastname = details.lastName;
      _number = details.number;
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
      appBar: AppBar(title: Text(widget.title)),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Form(
          key: formKey,
          child: new Column(
            children: [
              new RaisedButton(onPressed: () {
                  _navigateAndTakeSelection(context);
                },
                  child: new Text('Choose who to send text to'),
              ),
              new RaisedButton(onPressed: () {
                _pickDate();
              },
                child: new Text('Choose date'),
              ),
              new RaisedButton(onPressed: () {
                _pickTime();
              },
                child: new Text('Choose time'),
              ),
              new TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(labelText: "Text"),
                  validator: (val) =>
                  val.length == 0 ? "Enter your text" : null,
                  onSaved: (val) => this.text = val,
              ),
              new Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: new RaisedButton(onPressed: _submit,
                    child: new Text('Submit')
                  )
              ),
            ],
          ),
        ),
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ContactsPlugin().getContacts(),
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children:
            snapshot.data.map((contact) => ContactWidget(contact, context)).toList(),
        );
      },
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
    _firstName = _contact.firstName;
    _lastName = _contact.lastName;
    _number = _contact.phoneNumbers.first.number;

    var contact = Client(firstName: _firstName, lastName: _lastName, text: "text", number: _number);

    Navigator.pop(_context, contact);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () => _returnContact(),
        child:ListTile(
          leading: CircleAvatar(
              backgroundColor:
              Colors.primaries[Random().nextInt(Colors.primaries.length - 1)],
              child:
              Text(_contact.displayName?.substring(0, 1)?.toUpperCase() ?? "")),
          title: Text(_contact.displayName ?? "<null>"),
        ),
      ),
    );
  }
}