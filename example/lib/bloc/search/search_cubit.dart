import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_state_gen/bloc_state_gen.dart';

part 'search_state.dart';
part 'search_cubit.s.dart';

@BlocStateGen()
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
        ));
      } else {
        emit(SearchResults(
          query: query,
          results: results,
        ));
      }
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        query: query,
      ));
    }
  }

  void clear() {
    emit(const SearchInitial());
  }
}
