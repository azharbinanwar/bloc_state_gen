# bloc_state_gen

A Dart package that generates extension methods for Bloc states to enhance their functionality with pattern matching and logging capabilities.

## Features

- Generate `when` methods for exhaustive state handling
- Generate `maybeWhen` methods for optional state handling
- Generate `log` methods for debugging state changes
- Type-safe state pattern matching
- Support for states with parameters

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_state_gen: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

1. Annotate your state class with `@BlocStateGen`:

```dart
import 'package:bloc_state_gen/bloc_state_gen.dart';

@BlocStateGen()
abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterLoading extends CounterState {}

class CounterLoaded extends CounterState {
  final int value;
  CounterLoaded(this.value);
}

class CounterError extends CounterState {
  final String message;
  CounterError(this.message);
}
```

2. Run the build_runner:

```bash
dart run build_runner build
```

3. Use the generated extensions:

```dart
void handleState(CounterState state) {
  state.when(
    counterInitial: () => Text('Initial'),
    counterLoading: () => CircularProgressIndicator(),
    counterLoaded: (value) => Text('Count: $value'),
    counterError: (message) => Text('Error: $message'),
  );
}

// Or use maybeWhen for partial matching
void handleStatePartially(CounterState state) {
  state.maybeWhen(
    counterLoaded: (value) => print('Count: $value'),
    orElse: () => print('Other state'),
  );
}

// Debug state changes
void debugState(CounterState state) {
  state.log(); // Prints state type and fields
}
```

## Configuration

You can customize the generated code by configuring the annotation:

```dart
@BlocStateGen(
  when: true,      // Generate when method
  maybeWhen: true, // Generate maybeWhen method
  log: true,       // Generate log method
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.