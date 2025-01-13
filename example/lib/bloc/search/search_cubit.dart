import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_state_gen/bloc_state_gen.dart';

part 'search_state.dart';
part 'search_state.g.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  Future<void> search(String query, {Map<String, dynamic>? filters}) async {
    // Reset if empty query
    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Start searching
    emit(Searching(
      query: query,
      filters: filters ?? {},
    ));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock search results
      if (query.toLowerCase().contains('error')) {
        throw Exception('Search failed');
      }

      final results = List.generate(
        query.length + 5,
            (i) => 'Result ${i + 1} for "$query"',
      );

      if (results.isEmpty) {
        emit(NoResults(
          query: query,
          filters: filters ?? {},
        ));
      } else {
        emit(SearchResults(
          query: query,
          results: results,
          filters: filters ?? {},
        ));
      }
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        query: query,
        filters: filters,
      ));
    }
  }

  void clear() {
    emit(const SearchInitial());
  }
}
