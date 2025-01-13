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
  final Map<String, dynamic> filters;

  const Searching({
    required this.query,
    required this.filters,
  });
}

class SearchResults extends SearchState {
  final String query;
  final List<String> results;
  final Map<String, dynamic> filters;

  const SearchResults({
    required this.query,
    required this.results,
    required this.filters,
  });
}

class NoResults extends SearchState {
  final String query;
  final Map<String, dynamic> filters;

  const NoResults({
    required this.query,
    required this.filters,
  });
}

class SearchError extends SearchState {
  final String message;
  final String? query;
  final Map<String, dynamic>? filters;

  const SearchError({
    required this.message,
    this.query,
    this.filters,
  });
}
