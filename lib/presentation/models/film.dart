import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class FilmUIModel extends Equatable {
  const FilmUIModel({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.usersFeedback,
    required this.overview,
    required this.urlImage,
  });

  final String id;
  final String title;
  final String releaseDate;
  final String usersFeedback;
  final String overview;
  final String urlImage;

  @override
  List<Object> get props => [
        id,
        title,
        releaseDate,
        usersFeedback,
        overview,
        urlImage,
      ];

  FilmUIModel copyWith({
    String? id,
    String? title,
    String? releaseDate,
    String? usersFeedback,
    String? overview,
    String? urlImage,
  }) {
    return FilmUIModel(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      usersFeedback: usersFeedback ?? this.usersFeedback,
      overview: overview ?? this.overview,
      urlImage: urlImage ?? this.urlImage,
    );
  }
}
