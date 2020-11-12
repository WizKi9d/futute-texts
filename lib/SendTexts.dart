import 'package:flutter_sms/flutter_sms.dart';

class SendText {
  SendText._();
  static final SendText st = SendText._();

  void _sendSMS(String message, String recipient) async {
    List<String> s;
    s.add(recipient);
    String _result = await sendSMS(message: message, recipients: s)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}
