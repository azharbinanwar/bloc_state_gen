part of 'my_search_bloc.dart';

@immutable
@BlocStateGen()
abstract class MySearchState {
  const MySearchState();
}

class MySearchInitial extends MySearchState {
  const MySearchInitial();
}

class MySearching extends MySearchState {
  final String query;
  final Map<String, dynamic> filters;

  const MySearching({
    required this.query,
    required this.filters,
  });
}

class MySearchResults extends MySearchState {
  final String query;
  final List<String> results;
  final Map<String, dynamic> filters;

  const MySearchResults({
    required this.query,
    required this.results,
    required this.filters,
  });
}

class MyNoResults extends MySearchState {
  final String query;
  final Map<String, dynamic> filters;

  const MyNoResults({
    required this.query,
    required this.filters,
  });
}

class MySearchError extends MySearchState {
  final String message;
  final String? query;
  final Map<String, dynamic>? filters;

  const MySearchError({
    required this.message,
    this.query,
    this.filters,
  });
}
