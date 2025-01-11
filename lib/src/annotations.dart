import 'package:meta/meta.dart';

@immutable
class BlocStateGen {
  /// Whether to generate the when method
  final bool when;

  /// Whether to generate the maybeWhen method
  final bool maybeWhen;

  /// Whether to generate the log method
  final bool log;

  const BlocStateGen({
    this.when = true,
    this.maybeWhen = true,
    this.log = true,
  });
}