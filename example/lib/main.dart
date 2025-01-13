import 'package:example/bloc/search/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SearchPage());
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search Example'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (query) {
                          context.read<SearchCubit>().search(query);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        context.read<SearchCubit>().search(_searchController.text);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchCubit>().clear();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    state.log(showTime: true);
                    state.log(onLog: (state) => print('My state: $state'));
                    return state.match(
                      searchInitial: () => const Center(
                        child: Text('Enter a search term'),
                      ),
                      searching: (query, filters) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      searchResults: (query, results, filters) => ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(results[index]),
                          );
                        },
                      ),
                      noResults: (query, filters) => Center(
                        child: Text('No results found for "$query"'),
                      ),
                      searchError: (message, query, filters) => Center(
                        child: Text('Error: $message'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
