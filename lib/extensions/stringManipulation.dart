import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    if (this != null) {
      return "${this[0].toUpperCase()}${this.substring(1)}";
    } else {
      return "Sorry";
    }
  }

}