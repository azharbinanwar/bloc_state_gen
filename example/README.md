# bloc_state_gen

A lightweight Dart package that generates convenient extensions for BLoC state classes, offering pattern matching and logging capabilities through simple annotations.

## Features

### 🎯 Pattern Matching
- **match**: Complete state pattern matching requiring all cases to be handled
- **matchSome**: Partial pattern matching with default case handling
- Compile-time type safety

### 📝 Logging
- Built-in state logging functionality
- Debug-friendly state information

## Installation

1. Add `bloc_state_gen` to your `pubspec.yaml`:

   ```yaml
   dependencies:
     bloc_state_gen: ^latest_version

   dev_dependencies:
     build_runner: ^latest_version
   ```

2. Update your main cubit class to include the generated file:

   ```dart
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:bloc_state_gen/bloc_state_gen.dart';

   part 'search_state.dart';
   part 'search_state.g.dart';

   class SearchCubit extends Cubit<SearchState> {
     SearchCubit() : super(const SearchInitial());
   }
   ```

3. Run the code generator:

   ```bash
   flutter pub run build_runner build
   ```

4. Ignore generated `.g.dart` files in version control by adding the following to your `.gitignore`:

   ```gitignore
   # Ignore generated files
   *.g.dart
   ```

## Usage

### Basic Setup

1. Annotate your state class with `@BlocStateGen`:

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
   ```

2. Run the code generator:

   ```bash
   flutter pub run build_runner build
   ```

### Feature Usage

#### 1. match - Complete Pattern Matching

Requires handling all possible states:

```dart
Widget buildStateWidget(SearchState state) {
  return state.match(
    searchInitial: () => const StartSearch(),
    searching: (query) => const CircularProgressIndicator(),
    searchResults: (query, results) => DisplayList(items: results),
    noResults: (query) => NoResultsWidget(query: query),
    searchError: (message, query) => ErrorMessage(message: message),
  );
}
```

#### 2. matchSome - Partial Pattern Matching

Handle specific states with a default case:

```dart
String getDisplayText(SearchState state) {
  return state.matchSome(
    searchResults: (query, results) => 'Found ${results.length} results for: $query',
    searchError: (message, query) => 'Error${query != null ? " for $query" : ""}: $message',
    orElse: () => 'Idle...',
  );
}
```

#### 3. log - State Logging

Print state information for debugging:

```dart
void debugState(CounterState state) {
  print(state.log());  // Outputs formatted state information
}
```

### Customizing Generation

You can selectively enable/disable features using the `@BlocStateGen` annotation:

```dart
@BlocStateGen(
  match: true,      // Enable complete pattern matching
  matchSome: true,  // Enable partial pattern matching
  log: true,        // Enable logging functionality
)
abstract class SearchState {
  const SearchState();
}
```

## Best Practices

1. **Complete Pattern Matching**
   - Use `match` when you need to handle all possible states
   - Ensures no state is accidentally forgotten
   - Provides compile-time safety

2. **Partial Pattern Matching**
   - Use `matchSome` when you only need to handle specific states
   - Always provide a meaningful `orElse` case
   - Useful for selective state handling

3. **Logging**
   - Enable logging during development for better debugging
   - Use in conjunction with Flutter's debug mode:
     ```dart
     if (kDebugMode) {
       print(state.log());
     }
     ```

## Example Project

For a complete working example, check out our [example project](https://github.com/azharbinanwar/bloc_state_gen/tree/master/example) demonstrating:
- State class definition
- Extension generation
- Usage of all three core features
- Integration with Flutter UI


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.