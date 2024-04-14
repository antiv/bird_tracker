import 'package:ciconia_tracker/widgets/transect_info.dart';
import 'package:ciconia_tracker/widgets/transects_history.dart';
import 'package:ciconia_tracker/widgets/user_details_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../configuration/constants.dart';
import '../service/data_service.dart';
import '../utils/ux_builder.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  _showTracksHistory() =>
    showBottomModal(const TransectsHistory());

  _showTrackInfo() {
    if (DataService().transect != null) {
      showBottomModal(const TransectInfo());
    } else {
      showSnackBar('Ne postoji trenutni popis',);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 120,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      kAppIcon,
                      semanticsLabel: 'Ciconia Tracker Logo',
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kAppTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
                    Text('v$kAppVersion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade300,)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (DataService().transect != null)
        ListTile(
          leading: const Icon(Icons.fmd_bad_outlined),
          title: const Text('Current track').tr(),
          onTap: () {
            Navigator.pop(context);
            _showTrackInfo();
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Saved tracks').tr(),
          onTap: () {
            Navigator.pop(context);
            _showTracksHistory();
          },
        ),
        ExpansionTile(
          leading: const Icon(Icons.tune),
          title: const Text('Settings').tr(),
          // subtitle: Text(''),
          children: <Widget>[
            ListTile(
              title: const Text('Select map type').tr(),
              leading: const Icon(Icons.layers_outlined,),
              subtitle: Row(
                children: [
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.normal);
                    Navigator.pop(context);
                  }, child: Text('Map',
                      style: TextStyle(color: DataService().mapType == MapType.normal
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color)).tr(),
                  ),
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.satellite);
                    Navigator.pop(context);
                  }, child: Text('Satellite',
                      style: TextStyle(color: DataService().mapType == MapType.satellite
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color)).tr()),
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.hybrid);
                    Navigator.pop(context);
                  }, child: Text('Hybrid',
                      style: TextStyle(color: DataService().mapType == MapType.hybrid
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color)).tr())
                ],
              ),
            ),
            ListTile(
                title: const Text('Podaci o popisivaču').tr(),
              leading: const Icon(Icons.email_outlined,),
              onTap: () {
                  Navigator.pop(context);
                  showFullScreenDialog(
                    const UserDetailsForm(),
                    title: 'Podaci o popisivaču',
                  );
              },
            ),
          ],
        ),
        ListTile(
          leading: const Icon(Icons.file_open_outlined),
          title: const Text('Import KML').tr(),
          onTap: () {
            Navigator.pop(context);
            showImportKMLDialog();
          },
        ),
      ],
    ));
  }
}

class MenuIcon extends StatelessWidget {
  const MenuIcon({
    super.key,
    this.asset,
    this.height,
  });

  final String? asset;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/${asset ?? 'eagle'}.svg',
      height: height ?? 24,
      semanticsLabel: 'Bird Tracker Logo',
      // colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );
  }
}
