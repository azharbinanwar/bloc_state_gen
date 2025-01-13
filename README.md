# bloc_state_gen

The `bloc_state_gen` package helps generate extensions for BLoC state classes, making it easier to manage state-specific actions such as UI rendering or state transitions.

This example illustrates:
- Defining state classes and annotating them with `@BlocStateGen`.
- Using the generated extensions in your Flutter app.


### Getting Started with `bloc_state_gen`

This guide will help you set up and use the `bloc_state_gen` package for state management in your Flutter application. It also includes instructions on ignoring generated files like `*.g.dart` to maintain a clean repository.

### Step 1: Add Dependencies

Update your `pubspec.yaml` file to include the necessary dependencies:

```yaml
dependencies:
  bloc_state_gen: ^1.0.0 # Add your generator dependency

dev_dependencies:
  build_runner: 
```

### Step 2: Create a `.gitignore` File

To prevent generated files from being tracked by version control, add the following entry to your `.gitignore` file:

```gitignore
# Ignore generated files
*.g.dart

# Other ignored files...
```

### Step 3: Generate Files

Run the following command to generate the `*.g.dart` files required by the `bloc_state_gen` package:

```bash
dart run build_runner build
```

## How to Run

1. Clone this repository.
2. Ensure you have Flutter installed on your system.
3. Run `flutter pub get` to install dependencies.
4. Run the app using `flutter run`.

## Features

- **State Management**: Clean and scalable state management using BLoC.
- **Generated Extensions**: Simplified state handling through generated extensions.
- **Example Usage**: A complete example demonstrating search functionality.

## Generated Extensions

The `bloc_state_gen` package generates utility extensions for your state classes. Here's an example:

```dart
extension SearchStateExtension on SearchState {
  T match<T>({
    required T Function() searchInitial,
    required T Function(String query, Map<String, dynamic> filters) searching,
    required T Function(String query, List<String> results, Map<String, dynamic> filters) searchResults,
    required T Function(String query, Map<String, dynamic> filters) noResults,
    required T Function(String message, String? query, Map<String, dynamic>? filters) searchError,
  }) {
    // Implementation...
  }
}
```

## Folder Structure

```
lib/
├── bloc/
│   ├── search/
│   │   ├── search_cubit.dart
│   │   ├── search_state.dart
├── main.dart
```

## Annotation Class: `BlocStateGen`

The `BlocStateGen` annotation class is a custom Dart annotation that enables code generation for BLoC state classes. This class allows developers to configure the behavior of the generated extensions.

### Definition

```dart
@const BlocStateGen({
    this.match = true,
    this.matchSome = true,
    this.log = true,
});
```

### Key Properties

1. **`match`**:
    - Type: `bool`
    - Default: `true`
    - **Purpose**: Indicates whether the code generator should create a `match` method for exhaustive pattern matching. This method is used to handle all possible states of the annotated class, ensuring complete state handling.

2. **`matchSome`**:
    - Type: `bool`
    - Default: `true`
    - **Purpose**: Indicates whether the generator should create a `matchSome` method. This method provides optional pattern matching, allowing developers to handle only specific states while skipping others.

3. **`log`**:
    - Type: `bool`
    - Default: `true`
    - **Purpose**: Determines whether a `log` method should be generated. The `log` method helps in debugging by providing detailed information about the current state, such as its type and associated properties.

### How It Works

- When you annotate a BLoC state class with `@BlocStateGen`, the annotation triggers a code generator to create utility methods based on the configured properties.
- By default, all methods (`match`, `matchSome`, and `log`) are generated unless explicitly disabled by setting their respective properties to `false`.

### Example Usage

### `search_state.dart`

```dart
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
```

### `search_cubit.dart`

```dart
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
```

## Example Code: Search Feature

Below is the full example of implementing a search functionality with `bloc_state_gen`:

### `main.dart`

```dart
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
```