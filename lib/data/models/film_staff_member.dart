import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class FilmStaffMember extends Equatable {
  const FilmStaffMember({
    required this.id,
    required this.name,
    required this.character,
    required this.urlImage,
    required this.position,
  });

  final String id;
  final String name;
  final String character;
  final String urlImage;
  final String position;

  @override
  List<Object> get props =>
      [
        id,
        name,
        character,
        urlImage,
      ];
}
