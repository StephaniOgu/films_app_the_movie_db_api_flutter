import 'package:bloc/bloc.dart';
import 'package:films_app_practie/data/models/film.dart';
import 'package:equatable/equatable.dart';
import 'package:films_app_practie/data/repositories/films_repository.dart';
import 'package:films_app_practie/localisation.dart';
import '../../../../data/mappers.dart';
import '../../../models/film.dart';

part '../states/base_film_state.dart';

part '../states/error_state.dart';

part '../states/initial_state.dart';

part '../states/loaded_state.dart';

part '../states/loading_state.dart';

class FilmsListCubit extends Cubit<FilmsListBaseState> {
  FilmsListCubit({required this.filmsRepository})
      : super(const InitialFilmsListState()) {
    loadFilmsList(page: 1);
  }

  final FilmsRepository filmsRepository;
  List<FilmUIModel> _filmList = [];

  void loadFilmsList({required int page, String? query}) async {
    try {
      emit(const LoadingFilmsListState());
      if (page == 1) {
        _filmList = [];
      }

      List<FilmDataModel> films =
          await filmsRepository.getFilms(searchQuery: query, page: page);
      _filmList.addAll(films.map((mapFilmDataModelToUI)));

      if (_filmList.isEmpty) {
        emit(ErrorFilmsListState(error: FilmsLocalizations.noResults));
        return;
      }

      emit(LoadedFilmsListState(films: _filmList, page: page, query: query));
    } catch (e) {
      emit(ErrorFilmsListState(error: e.toString()));
    }
  }

}
