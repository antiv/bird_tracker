import 'dart:convert';

import 'package:bird_tracker/model/placemark.dart';
import 'package:bird_tracker/model/point.dart';
import 'package:bird_tracker/model/species.dart';
import 'package:bird_tracker/model/transect.dart';
import 'package:bird_tracker/utils/kml_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

const String photo = 'BT_20260504_211530_0a1b.jpg';

Transect buildTransect() {
  final record = Species()
    ..species = 'Parus major'
    ..time = '21:15:30'
    ..count = 3
    ..code = 12
    ..stratification = Stratification.g
    ..direction = Direction.nne
    ..description = 'pevanje, čučanje'
    ..photos = [photo, 'weird, name.jpg'];

  final second = Species()
    ..species = 'Sitta europaea'
    ..time = '21:40:00'
    ..count = 1
    ..code = null
    ..description = null;

  return Transect()
    ..id = 1
    ..name = 'Test transekt'
    ..startDate = DateTime(2026, 5, 4, 20)
    ..endDate = DateTime(2026, 5, 4, 22)
    ..points = [
      Point()
        ..latitude = 44.8
        ..longitude = 20.36
    ]
    ..markers = [
      Placemark(
        id: 0,
        startDate: DateTime(2026, 5, 4, 21, 15),
        endDate: DateTime(2026, 5, 4, 21, 45),
        latitude: 44.812345,
        longitude: 20.361234,
        species: [record, second],
      )
    ];
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('the KML payload carries every record field, photos included', () {
    final kml = buildTransect().toKML();
    final placemark = XmlDocument.parse(kml)
        .findAllElements('Placemark')
        .firstWhere((p) => p.getAttribute('id') == 'marker0');

    /// namespaced, so a viewer skips it rather than printing the JSON at the
    /// user the way a plain <Data name="records"> would
    final payload = placemark
        .findAllElements(kRecordsDataName, namespaceUri: kBtNamespace)
        .single;
    final records = jsonDecode(payload.innerText) as Map<String, dynamic>;

    expect(records['startDate'], '2026-05-04T21:15:00.000');
    final species = records['species'] as List<dynamic>;
    expect(species.length, 2);
    expect(species.first['species'], 'Parus major');
    expect(species.first['code'], 12);
    expect(species.first['stratification'], 'g');
    expect(species.first['direction'], 'nne');
    expect(species.first['photos'], [photo, 'weird, name.jpg']);

    /// the description stays the human-readable one-line summary
    expect(placemark.findElements('description').single.innerText,
        contains('Parus major'));
  });

  test('a KML round trip restores the records through the payload', () {
    final transect = buildTransect();
    final restored =
        KMLUtils().kmlToTransect(transect.toKML(), DateTime(2026, 5, 4));

    final marker = restored.markers!.single;
    expect(marker.latitude, closeTo(44.812345, 0.000001));
    expect(marker.startDate, DateTime(2026, 5, 4, 21, 15));
    expect(marker.endDate, DateTime(2026, 5, 4, 21, 45));
    expect(marker.species!.length, 2);

    final record = marker.species!.first;
    expect(record.species, 'Parus major');
    expect(record.count, 3);
    expect(record.code, 12);
    expect(record.time, '21:15:30');
    expect(record.stratification, Stratification.g);
    expect(record.direction, Direction.nne);

    /// the diacritics in the behaviour note used to be mangled by .codeUnits
    expect(record.description, 'pevanje, čučanje');
    expect(record.photos, [photo, 'weird, name.jpg']);

    /// the path comes back too
    expect(restored.points!.single.latitude, closeTo(44.8, 0.000001));
  });

  test('a KML from before the payload still imports off its description', () {
    /// exports already shared with colleagues have no ExtendedData at all —
    /// the records were re-parsed out of the description prose, and that
    /// fallback has to keep working
    const legacy = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>Stari transekt</name>
<Placemark id="marker0">
<name>Point 1</name>
<description>Parus major: 3, 12, 21:15:30, G, NNE; pevanje</description>
<Point><coordinates>20.361234,44.812345</coordinates></Point>
</Placemark>
</Document>
</kml>''';

    final imported = KMLUtils().kmlToTransect(legacy, DateTime(2026, 8, 30));
    expect(imported.name, 'Stari transekt');

    final record = imported.markers!.single.species!.single;
    expect(record.species, 'Parus major');
    expect(record.count, 3);
    expect(record.code, 12);
    expect(record.time, '21:15:30');
    expect(record.stratification, Stratification.g);
    expect(record.direction, Direction.nne);

    /// nothing named a photo back then, and an absent list must not be null
    expect(record.photos, isEmpty);
  });

  test('a legacy import with no timestamps still exports to CSV', () {
    /// markers imported from a description-only KML carry no startDate, and
    /// the date cell used to force-unwrap it — sharing CSV for an imported
    /// transect threw on the way to the share sheet
    const legacy = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>Stari transekt</name>
<Placemark id="marker0">
<name>Point 1</name>
<description>Parus major: 3, 12, 21:15:30, G, NNE; pevanje</description>
<Point><coordinates>20.361234,44.812345</coordinates></Point>
</Placemark>
</Document>
</kml>''';

    final imported = KMLUtils().kmlToTransect(legacy, DateTime(2026, 8, 30));
    expect(imported.markers!.single.startDate, isNull);

    final lines = const LineSplitter().convert(imported.toCSV());
    expect(lines.length, 2);

    /// the date and the time range come back empty rather than crashing
    expect(lines[1], startsWith('Parus major,,,21:15:30,'));
  });

  test('CSV carries every record field', () {
    final csv = buildTransect().toCSV();
    final lines = const LineSplitter().convert(csv);
    expect(lines.length, 3);

    expect(lines[1], contains('Parus major'));
    expect(lines[1], contains('44.812345'));
    expect(lines[1], contains('20.361234'));
    expect(lines[1], contains('"pevanje, čučanje"'));
    expect(lines[1], endsWith(',G,NNE,12'));

    /// a record with only the required fields must still line up
    expect(lines[2], contains('Sitta europaea'));
    expect(lines[2], endsWith(',,,'));
  });

  testWidgets('the share button labels are plain keys, not blocks',
      (tester) async {
    await tester.pumpWidget(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('sr', 'Latn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: Builder(
        builder: (context) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const SizedBox(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    /// .tr() on a block key hands back a Map and the widget throws at build
    expect('csv'.tr(), 'CSV');
    expect('kml'.tr(), 'KML');
    expect('kmz'.tr(), 'KMZ');

    /// these two were referenced in code but missing from both locales, so
    /// the user saw the raw key in the snackbar
    expect('import_success'.tr(), isNot('import_success'));
    expect('invalid_file_format'.tr(), isNot('invalid_file_format'));
  });
}
