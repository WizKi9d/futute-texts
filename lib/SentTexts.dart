import 'dart:convert';

SentTexts sentTextsFromJson(String str) {
  final jsonData = json.decode(str);
  return SentTexts.fromMap(jsonData);
}

String clientToJson(SentTexts data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SentTexts {
  int id;
  int sentNo;

  SentTexts({
    this.id,
    this.sentNo
  });

  factory SentTexts.fromMap(Map<String, dynamic> json) => new SentTexts(
      id: json["id"],
      sentNo: json["sentNo"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "sentNo": sentNo
  };
}
