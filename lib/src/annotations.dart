import 'package:meta/meta.dart';

@immutable
class BlocStateGen {
  /// Whether to generate the when method
  final bool match;

  /// Whether to generate the maybeWhen method
  final bool matchSome;

  /// Whether to generate the log method
  final bool log;

  const BlocStateGen({
    this.match = true,
    this.matchSome = true,
    this.log = true,
  });
}