import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_state_gen/src/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// A code generator that creates state management extensions for Bloc classes.
///
/// This generator processes classes annotated with [BlocStateGen] and generates
/// helper methods for state handling, including pattern matching and logging.
class StateExtensionGenerator extends GeneratorForAnnotation<BlocStateGen> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    try {
      _validateElement(element);
      final className = element.name;
      final buffer = StringBuffer();

      _writeFileHeader(buffer, buildStep.inputId.pathSegments.last);
      _generateExtension(
        buffer: buffer,
        element: element as ClassElement,
        className: className!,
        annotation: annotation,
      );

      return buffer.toString();
    } catch (e) {
      throw InvalidGenerationSourceError(
        'Failed to generate extension for ${element.name}: $e',
        element: element,
        todo: 'Check the class structure and annotation parameters',
      );
    }
  }

  /// Validates that the annotated element is a class.
  void _validateElement(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'BlocStateGen can only be applied to classes.',
        element: element,
        todo: 'Apply @BlocStateGen annotation to a class instead',
      );
    }

    if (element.isPrivate) {
      throw InvalidGenerationSourceError(
        'BlocStateGen cannot be applied to private classes.',
        element: element,
        todo: 'Make the class public by removing the underscore prefix',
      );
    }
  }

  /// Writes the file header with necessary imports and part declarations.
  void _writeFileHeader(StringBuffer buffer, String fileName) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln(
        '// ignore_for_file: unused_element, deprecated_member_use, unused_local_variable');
    buffer.writeln();
    buffer.writeln('part of \'$fileName\';');
    buffer.writeln();
  }

  /// Generates the main extension class with all requested methods.
  void _generateExtension({
    required StringBuffer buffer,
    required ClassElement element,
    required String className,
    required ConstantReader annotation,
  }) {
    final subclasses = _getSubclasses(element);

    if (subclasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No subclasses found for $className.',
        element: element,
        todo:
            'Create at least one subclass of $className to represent different states',
      );
    }

    buffer.writeln('/// Extension methods for $className state management');
    buffer.writeln('extension ${className}Extension on $className {');

    _generateRequestedMethods(
      buffer: buffer,
      className: className,
      subclasses: subclasses,
      annotation: annotation,
    );

    buffer.writeln('}');
  }

  /// Generates the matchSome method for partial pattern matching.
  void _generateMatchSomeMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    buffer.writeln('''
  /// Pattern matches on the state type with optional handlers.
  ///
  /// Allows partial matching with a required [orElse] handler for unhandled cases.
  T matchSome<T>({''');

    // Generate optional parameters with documentation
    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      buffer.writeln('    /// Optional handler for ${subclass.name} state');
      if (fields.isEmpty) {
        buffer.writeln('    T Function()? $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    T Function($params)? $paramName,');
      }
    }

    buffer.writeln('''
    /// Handler for unmatched states
    required T Function() orElse,
  }) {''');

    // Generate pattern matching logic
    for (final subclass in subclasses) {
      _generateMatchSomeCase(buffer, subclass);
    }

    buffer.writeln('''
    return orElse();
  }''');
  }

  /// Generates a single case for the matchSome method.
  void _generateMatchSomeCase(StringBuffer buffer, ClassElement subclass) {
    final subclassName = subclass.name;
    final paramName = _getParameterName(subclassName);
    final fields = _getConstructorParameters(subclass);

    buffer.writeln('    if (this is $subclassName && $paramName != null) {');
    if (fields.isEmpty) {
      buffer.writeln('      return $paramName();');
    } else {
      final params =
          fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
      buffer.writeln('      return $paramName($params);');
    }
    buffer.writeln('    }');
  }

  /// Generates the log method for state logging.
  void _generateLogMethod(StringBuffer buffer, String className) {
    buffer.writeln('''
  /// Logs the current state with optional timestamp.
  ///
  /// [showTime] - Whether to include timestamp in the log
  /// [onLog] - Custom log handler (defaults to print)
  void log({
    bool showTime = false,
    void Function(String message)? onLog,
  }) {
    final logger = onLog ?? print;
    final timestamp = showTime ? '[\${DateTime.now().toIso8601String()}] ' : '';
    final stateInfo = toString();
    
    logger('\${timestamp}Current State: \$stateInfo');
  }''');
  }

  /// Gets all subclasses of the annotated class.
  List<ClassElement> _getSubclasses(ClassElement element) {
    return element.library.topLevelElements
        .whereType<ClassElement>()
        .where((e) {
      final supertype = e.supertype;
      return supertype != null && supertype.element == element;
    }).toList();
  }

  /// Gets the constructor parameters for a class.
  List<ParameterElement> _getConstructorParameters(ClassElement element) {
    final constructor =
        element.constructors.where((c) => c.name.isEmpty).firstOrNull;
    return constructor?.parameters
            .where((param) => !param.isPrivate)
            .toList() ??
        [];
  }

  /// Converts a class name to a parameter name in camelCase.
  String _getParameterName(String className) {
    if (className.isEmpty) return '';
    return className[0].toLowerCase() + className.substring(1);
  }

  /// Generates methods based on annotation configurations.
  void _generateRequestedMethods({
    required StringBuffer buffer,
    required String className,
    required List<ClassElement> subclasses,
    required ConstantReader annotation,
  }) {
    if (annotation.read('match').boolValue) {
      _generateMatchMethod(buffer, className, subclasses);
    }

    if (annotation.read('matchSome').boolValue) {
      _generateMatchSomeMethod(buffer, className, subclasses);
    }

    if (annotation.read('log').boolValue) {
      _generateLogMethod(buffer, className);
    }
  }

  /// Generates the match method for exhaustive pattern matching.
  void _generateMatchMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    // Write method documentation
    buffer.writeln('''
  /// Matches the current state against provided handlers and returns a value of type [T].
  ///
  /// Requires handlers for all possible state types. This ensures exhaustive pattern matching.
  /// Throws [StateError] if an unknown state is encountered.
  ///
  /// Example:
  /// ```dart
  /// final result = state.match(
  ///   initial: () => 'Initial State',
  ///   loading: (progress) => 'Loading: \$progress%',
  ///   success: (data) => 'Success: \$data',
  ///   error: (message) => 'Error: \$message',
  /// );
  /// ```
  T match<T>({''');

    // Generate required parameters
    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      // Add parameter documentation
      buffer.writeln('    /// Handler for ${subclass.name} state');
      if (fields.isEmpty) {
        buffer.writeln('    required T Function() $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    required T Function($params) $paramName,');
      }
    }

    // Close parameter list and start method body
    buffer.writeln('  }) {');

    // Generate pattern matching logic
    for (final subclass in subclasses) {
      final subclassName = subclass.name;
      final paramName = _getParameterName(subclassName);
      final fields = _getConstructorParameters(subclass);

      buffer.writeln('    if (this is $subclassName) {');

      // For empty parameter list
      if (fields.isEmpty) {
        buffer.writeln('      return $paramName();');
      } else {
        // For states with parameters, cast and extract fields
        final params =
            fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
        buffer.writeln('      return $paramName($params);');
      }

      buffer.writeln('    }');
    }

    // Add error handling for unknown states
    buffer.writeln('''
    throw StateError(
      'Unknown state type: \$runtimeType. '
      'This might happen if you forgot to handle a state type in the match method.'
    );
  }''');
  }
}
