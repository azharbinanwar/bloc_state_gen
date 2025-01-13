part of 'my_search_bloc.dart';

@immutable
abstract class MySearchEvent {}

final class SearchStarted extends MySearchEvent {
  final String query;
  final Map<String, dynamic> filters;

  SearchStarted({required this.query, this.filters = const {}});
}

class SearchCleared extends MySearchEvent {}
