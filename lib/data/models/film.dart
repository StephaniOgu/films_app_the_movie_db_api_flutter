import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class FilmDataModel extends Equatable {
  const FilmDataModel({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.usersFeedback,
    required this.urlImage,
  });

  final String id;
  final String title;
  final String releaseDate;
  final String overview;
  final String usersFeedback;
  final String urlImage;

  @override
  List<Object> get props => [
        id,
        title,
        releaseDate,
        overview,
        usersFeedback,
        urlImage,
      ];

  FilmDataModel copyWith({
    String? id,
    String? title,
    String? releaseDate,
    String? overview,
    String? usersFeedback,
    String? urlImage,
  }) {
    return FilmDataModel(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      overview: overview ?? this.overview,
      usersFeedback: usersFeedback ?? this.usersFeedback,
      urlImage: urlImage ?? this.urlImage,
    );
  }
}
