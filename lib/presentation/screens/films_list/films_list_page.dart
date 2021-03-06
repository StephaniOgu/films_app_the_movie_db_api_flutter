import 'package:films_app_practie/presentation/models/film.dart';
import 'package:films_app_practie/presentation/screens/films_list/cubit/films_list_cubit.dart';
import 'package:films_app_practie/localisation.dart';
import 'package:films_app_practie/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';


class FilmsListPage extends StatefulWidget {
  const FilmsListPage({Key? key, required this.onFilmTap}) : super(key: key);

  final void Function(FilmUIModel film) onFilmTap;

  @override
  _FilmsListPageState createState() => _FilmsListPageState();
}

class _FilmsListPageState extends State<FilmsListPage> {
  late final FilmUIModel? selectedFilm;

  late int _pageNumber;
  late String? _query;
  late List<FilmUIModel>? _films;

  late PageStorageKey _key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildBigSizedBox(),
          _buildSearchField(),
          _buildBigSizedBox(),
        ],
      ),
      body: _buildBlocConsumer(),
    );
  }

  Widget _buildBigSizedBox() {
    return const SizedBox(
      height: 10,
      width: 50,
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          icon: const Icon(Icons.search),
          hintText: FilmsLocalizations.filmListScreenHintText,
          hintStyle: Theme.of(context).textTheme.headline5,
        ),
        onSubmitted: (query) async {
          if (query == '') {
            context.read<FilmsListCubit>().loadFilmsList(page: 1);
          } else {
            context.read<FilmsListCubit>().loadFilmsList(page: 1, query: query);
          }
        },
      ),
    );
  }

  BlocConsumer<FilmsListCubit, FilmsListBaseState> _buildBlocConsumer() {
    return BlocConsumer<FilmsListCubit, FilmsListBaseState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoadingFilmsListState) {
          return buildLoadingScreen();
        } else if (state is ErrorFilmsListState) {
          return _buildErrorScreen(state);
        } else if (state is LoadedFilmsListState) {
          _films = state.films;
          _query = state.query;
          _pageNumber = state.page;
          _key = PageStorageKey(_query);
          return _buildLoadedScreen();
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildErrorScreen(ErrorFilmsListState state) {
    var errorText = state.error == FilmsLocalizations.noResults
        ? FilmsLocalizations.noResults
        : FilmsLocalizations.errorTitle;
    return Center(
        child: Text(
      errorText,
      style: Theme.of(context).textTheme.bodyText1,
    ));
  }

  Widget _buildLoadedScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScreenTitle(),
        Expanded(
          child: _buildFilmsList(),
        ),
      ],
    );
  }

  Widget _buildScreenTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16),
      child: Text(
        FilmsLocalizations.filmListScreenLabel,
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }

  Widget _buildFilmsList() {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (scrollEnd) {
        if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels != 0) {
          context
              .read<FilmsListCubit>()
              .loadFilmsList(page: _pageNumber + 1, query: _query);
        }
        return true;
      },
      child: ListView.builder(
        key: _key,
        itemCount: _films!.length,
        itemBuilder: (context, index) => _buildFilmItem(index),
      ),
    );
  }

  Widget _buildFilmItem(int index) {
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              _buildFilmCard(_films![index]),
              _buildFilmImage(_films![index]),
            ],
          ),
        ),
        onTap: () {
          widget.onFilmTap(_films![index]);
        },
        onLongPress: () => _shareFilmInfo(index));
  }

  Widget _buildFilmCard(FilmUIModel film) {
    return SizedBox(
      height: 135,
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 100),
            _buildFilmInfo(film),
            _buildFilmRating(film),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmInfo(FilmUIModel film) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                film.title,
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Date: ${film.releaseDate}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmRating(FilmUIModel film) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${film.usersFeedback}%',
          style: Theme.of(context).textTheme.subtitle1),
    );
  }

  Widget _buildFilmImage(FilmUIModel film) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        film.urlImage,
        height: 150,
      ),
    );
  }

  _shareFilmInfo(int index) {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text(
                  'Share',
                  style: Theme.of(context).textTheme.headline2,
                ),
                content: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () async {
                    var film = _films![index];
                    final uri = Uri.parse(film.urlImage);
                    final response = await http.get(uri);
                    final bytes = response.bodyBytes;
                    final temp = await getTemporaryDirectory();
                    final path = '${temp.path}/image.jpg';
                    File(path).writeAsBytesSync(bytes);
                    await Share.shareFiles([path], text: 'Title: ${film.title}\n, About:  ${film.overview}');
                  },
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}
