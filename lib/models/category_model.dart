import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final Color bgColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgColor,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🍽',
      bgColor: json['bg_color'] != null
          ? Color(json['bg_color'] as int)
          : const Color(0xFFFFE8DC),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'bg_color': bgColor.toARGB32(),
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? bgColor,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}
