import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_state_gen/src/annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class StateExtensionGenerator extends GeneratorForAnnotation<BlocStateGen> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'EnhanceState can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final subclasses = _getSubclasses(element);
    final buffer = StringBuffer();

    // Get annotation configurations
    final generateMatch = annotation.read('match').boolValue;
    final generateMatchSome = annotation.read('matchSome').boolValue;
    final generateLog = annotation.read('log').boolValue;

    // Generate extension
    buffer.writeln('\nextension ${className}Extension on $className {');

    // Generate methods based on configuration
    if (generateMatch) {
      _generateMatchMethod(buffer, className, subclasses);
    }

    if (generateMatchSome) {
      _generateMatchSomeMethod(buffer, className, subclasses);
    }

    if (generateLog) {
      _generateLogMethod(buffer, className);
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  void _generateMatchMethod(StringBuffer buffer, String className, List<ClassElement> subclasses) {
    buffer.writeln('  Widget match({');

    // Generate required parameters
    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      if (fields.isEmpty) {
        buffer.writeln('    required Widget Function() $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    required Widget Function($params) $paramName,');
      }
    }

    buffer.writeln('  }) {');

    // Generate conditions
    for (final subclass in subclasses) {
      final subclassName = subclass.name;
      final paramName = _getParameterName(subclassName);
      final fields = _getConstructorParameters(subclass);

      buffer.writeln('    if (this is $subclassName) {');
      if (fields.isEmpty) {
        buffer.writeln('      return $paramName();');
      } else {
        final params = fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
        buffer.writeln('      return $paramName($params);');
      }
      buffer.writeln('    }');
    }

    buffer.writeln('    throw Exception(\'Unknown state: \$this\');');
    buffer.writeln('  }');
  }

  void _generateMatchSomeMethod(StringBuffer buffer, String className, List<ClassElement> subclasses) {
    buffer.writeln('  R matchSome<R>({');

    // Generate optional parameters
    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      if (fields.isEmpty) {
        buffer.writeln('    R Function()? $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    R Function($params)? $paramName,');
      }
    }

    buffer.writeln('    required R Function() orElse,');
    buffer.writeln('  }) {');

    // Generate conditions
    for (final subclass in subclasses) {
      final subclassName = subclass.name;
      final paramName = _getParameterName(subclassName);
      final fields = _getConstructorParameters(subclass);

      buffer.writeln('    if (this is $subclassName) {');
      buffer.write('      return $paramName != null ? ');
      if (fields.isEmpty) {
        buffer.write('$paramName()');
      } else {
        final params = fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
        buffer.write('$paramName($params)');
      }
      buffer.writeln(' : orElse();');
      buffer.writeln('    }');
    }

    buffer.writeln('    throw Exception(\'Unknown state: \$this\');');
    buffer.writeln('  }');
  }

  void _generateLogMethod(StringBuffer buffer, String className) {
    buffer.writeln('''
  void log({bool showTime = false, void Function(Object state)? onChanged}) {
    /// Use the provided logger or default to print
    onChanged ??= print;

    /// Prepare the log message
    final logMessage = showTime
        ? '[\${DateTime.now().toIso8601String()}] Current State: \$runtimeType'
        : '\$runtimeType';

    // Invoke the logger
    onChanged(logMessage);
  }
''');
  }

  List<ClassElement> _getSubclasses(ClassElement element) {
    return element.library.topLevelElements.whereType<ClassElement>().where((e) => e.supertype?.element == element).toList();
  }

  List<ParameterElement> _getConstructorParameters(ClassElement element) {
    final constructor = element.constructors.where((c) => c.name.isEmpty).firstOrNull;
    if (constructor == null) return [];
    return constructor.parameters.where((param) => !param.isPrivate).toList();
  }

  String _getParameterName(String className) {
    // Convert to camelCase
    final firstChar = className[0].toLowerCase();
    return firstChar + className.substring(1);
  }
}

Builder stateExtensionBuilder(BuilderOptions options) => SharedPartBuilder([StateExtensionGenerator()], 'state_extension');
