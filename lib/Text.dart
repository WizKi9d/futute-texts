/// ClientModel.dart
import 'dart:convert';

Client clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Client.fromMap(jsonData);
}

String clientToJson(Client data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Client {
  int id;
  String firstName;
  String lastName;
  String text;
  int date;
  String time;
  String number;

  Client({
    this.id,
    this.firstName,
    this.lastName,
    this.text,
    this.date,
    this.time,
    this.number
  });

  factory Client.fromMap(Map<String, dynamic> json) => new Client(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    text: json["text"],
    date: json["date"],
    time: json["time"],
    number: json["number"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "text": text,
    "date": date,
    "time": time,
    "number": number
  };
}