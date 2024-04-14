import 'package:isar/isar.dart';

part 'species.g.dart';

@embedded
class Species {
  // late String species;
  late String time; // hh:mm:ss
  late int count;
  late int? code;
  late String position; // bandera, dimnjak ...
  late String? state;
  late String? description;
  late String? municipality;
  late String? place;

  // @Enumerated(EnumType.ordinal32)
  // Stratification? stratification;
  // @Enumerated(EnumType.ordinal32)
  // Direction? direction;

  String get speciesString {
    return '$count, $position, $state, ${code ?? '-'}, $time, $municipality, $place, ${description ?? ''}';
  }

  // List<Species>? listFromString(List<String> species) {
  //   return species.map((e) => Species.fromSpeciesString(e)).toList().whereType<Species>().toList();
  // }

  static Species? fromSpeciesString(String e) {
    if (e.split(', ').length < 8) {
      return null;
    }
    List<String> parts = e.split(', ');
    return Species()
      // ..species = species
      ..count = int.tryParse(parts[0]) ?? 0
      ..position = parts[1]
      ..state = parts[2]
      ..code = int.tryParse(parts[3])
      ..time = parts[4]
      ..municipality = parts[5]
      ..place = parts[6]
      ..description = parts.length < 8 ? null : '"${parts.sublist(7).join(', ')}"';
  }
}
