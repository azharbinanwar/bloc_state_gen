import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:state_extension/src/annotations.dart';

class StateExtensionGenerator extends GeneratorForAnnotation<EnhanceState> {
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

    // Generate extension
    buffer.writeln('\nextension ${className}Extension on $className {');

    // Generate when method
    _generateWhenMethod(buffer, className, subclasses);

    // Generate maybeWhen method
    _generateMaybeWhenMethod(buffer, className, subclasses);

    buffer.writeln('}');

    return buffer.toString();
  }

  void _generateWhenMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    buffer.writeln('  Widget when({');

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

  void _generateMaybeWhenMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    buffer.writeln('  R maybeWhen<R>({');

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

  List<ClassElement> _getSubclasses(ClassElement element) {
    return element.library.topLevelElements.whereType<ClassElement>().where((e) => e.supertype?.element == element).toList();
  }

  List<ParameterElement> _getConstructorParameters(ClassElement element) {
    // Get the unnamed constructor
    final constructor = element.constructors.where((c) => c.name.isEmpty).firstOrNull;

    if (constructor == null) return [];

    // Get all constructor parameters
    return constructor.parameters.where((param) => !param.isPrivate).toList();
  }

  String _getParameterName(String className) {
    final name = className.replaceFirst(RegExp(r'^[A-Z][a-z]*'), '').toLowerCase();
    return name.isEmpty ? 'initial' : name;
  }
}

Builder stateExtensionBuilder(BuilderOptions options) => SharedPartBuilder([StateExtensionGenerator()], 'state_extension');
