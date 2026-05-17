import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final String image;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.image = '',
  });
}
