import 'dart:async';

import 'package:bloc_state_gen/bloc_state_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_search_event.dart';

part 'my_search_state.dart';

part 'my_search_state.g.dart';

class MySearchBloc extends Bloc<MySearchEvent, MySearchState> {
  MySearchBloc() : super(const MySearchInitial()) {
    on<SearchStarted>(_searchStarted);
    on<SearchCleared>(_searchCleared);
  }

  Future<void> _searchStarted(
      SearchStarted event, Emitter<MySearchState> emit) async {
    // Reset if empty query
    if (event.query.trim().isEmpty) {
      emit(const MySearchInitial());
      return;
    }

    // Start searching
    emit(MySearching(
      query: event.query,
      filters: event.filters,
    ));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock search results
      if (event.query.toLowerCase().contains('error')) {
        throw Exception('Search failed');
      }

      final results = List.generate(
        event.query.length + 5,
        (i) => 'Result ${i + 1} for "${event.query}"',
      );

      if (results.isEmpty) {
        emit(MyNoResults(
          query: event.query,
          filters: event.filters,
        ));
      } else {
        emit(MySearchResults(
          query: event.query,
          results: results,
          filters: event.filters,
        ));
      }
    } catch (e) {
      emit(MySearchError(
        message: e.toString(),
        query: event.query,
      ));
    }
  }

  void _searchCleared(SearchCleared event, Emitter<MySearchState> emit) =>
      emit(const MySearchInitial());
}
