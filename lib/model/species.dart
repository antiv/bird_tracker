import 'package:isar/isar.dart';

part 'species.g.dart';

@embedded
class Species {
  late String species;
  late String time; // hh:mm:ss
  late int count;

  late String? description;

  @Enumerated(EnumType.ordinal32)
  Stratification? stratification;
  @Enumerated(EnumType.ordinal32)
  Direction? direction;
}

enum Stratification {
  G,
  S,
  D,
}
extension StratificationExt on Stratification {
  String toShortString() {
    return toString().split('.').last;
  }
}


enum Direction {
  N,
  NE,
  E,
  SE,
  S,
  SW,
  W,
  NW,
}