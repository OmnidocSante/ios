import 'package:flutter/material.dart';

class InterventionModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String date;
  final String location;
  final bool isUrgent;

  const InterventionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.location,
    this.isUrgent = false,
  });

  InterventionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? date,
    String? location,
    bool? isUrgent,
  }) {
    return InterventionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      location: location ?? this.location,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  factory InterventionModel.fromJson(Map<String, dynamic> json) {
    return InterventionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      isUrgent: json['is_urgent'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'date': date,
      'location': location,
      'description': description,
      'is_urgent': isUrgent,
    };
  }
}
