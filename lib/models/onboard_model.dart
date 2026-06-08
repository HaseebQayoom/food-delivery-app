import 'package:flutter/widgets.dart';

class OnboardModel {
  final Image img;
  final String title;
  final String body;
  final Color color;
  final String badge;
  final String bName;
  final Color bColor;

  OnboardModel({
    required this.img,
    required this.title,
    required this.body,
    required this.color,
    required this.badge,
    required this.bName,
    required this.bColor,
  });
}
