part of 'search_cubit.dart';

@BlocStateGen()
abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class Searching extends SearchState {
  final String query;

  const Searching({
    required this.query,
  });
}

class SearchResults extends SearchState {
  final String query;
  final List<String> results;

  const SearchResults({
    required this.query,
    required this.results,
  });
}

class NoResults extends SearchState {
  final String query;

  const NoResults({
    required this.query,
  });
}

class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError({
    required this.message,
    this.query,
  });
}
