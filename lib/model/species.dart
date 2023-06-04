import 'package:isar/isar.dart';
import 'package:collection/collection.dart';

part 'species.g.dart';

@embedded
class Species {
  late String species;
  late String time; // hh:mm:ss
  late int count;
  late int? code;

  late String? description;

  @Enumerated(EnumType.ordinal32)
  Stratification? stratification;
  @Enumerated(EnumType.ordinal32)
  Direction? direction;

  String get speciesString {
    return '$species: $count, ${code ?? '-'}, $time, ${stratification?.toShortString() ?? ''}, ${direction?.toShortString() ?? ''}; ${description ?? ''}';
  }

  List<Species>? listFromString(List<String> species) {
    return species.map((e) => Species.fromSpeciesString(e)).toList().whereType<Species>().toList();
  }

  static Species? fromSpeciesString(String e) {
    List<String> test = e.split(': ');
    if (test.length < 2) {
      return null;
    }
    if (test[1].split('; ').length < 5) {
      return null;
    }
    String species = e.split(': ')[0];
    String rest = e.split(': ')[1];
    List<String> parts = rest.split(', ');
    return Species()
      ..species = species
      ..count = int.tryParse(parts[0]) ?? 1
      ..code = int.tryParse(parts[1])
      ..time = parts[2]
      ..stratification = Stratification.values
          .firstWhereOrNull((element) => element.toShortString() == parts[3])
      ..direction = Direction.values
          .firstWhereOrNull((element) => element.toShortString() == parts[4])
      ..description = parts.length < 6 ? null : '"${parts.sublist(5).join(', ')}"';
  }
}

enum Stratification {
  D,
  S,
  G,
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

extension DirectionExt on Direction {
  String toShortString() {
    return toString().split('.').last;
  }
}
