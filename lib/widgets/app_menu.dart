import 'package:bird_tracker/widgets/transect_info.dart';
import 'package:bird_tracker/widgets/transects_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../configuration/constants.dart';
import '../service/data_service.dart';
import '../utils/ux_builder.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({Key? key}) : super(key: key);

  _showTracksHistory() =>
    showBottomModal(const TransectsHistory());

  _showTrackInfo() {
    if (DataService().transect != null) {
      showBottomModal(const TransectInfo());
    } else {
      showSnackBar('No transect selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 94,
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
                  height: 48,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      kAppIcon2,
                      semanticsLabel: 'Bird Tracker Logo',
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(kAppTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
                    Text('v$kAppVersion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade300,)),
                  ],
                ),
              ],
            ),
          ),
        ),
        ListTile(
          leading: const MenuIcon(asset: 'blackbird',),
          title: const Text('Current track'),
          onTap: () {
            Navigator.pop(context);
            _showTrackInfo();
          },
        ),
        ListTile(
          leading: const MenuIcon(asset: 'owl', height: 36),
          title: const Text('Saved tracks'),
          onTap: () {
            Navigator.pop(context);
            _showTracksHistory();

          },
        ),
        ExpansionTile(
          leading: const MenuIcon(asset: 'raven', height: 28),
          title: const Text('Settings'),
          // subtitle: Text(''),
          children: <Widget>[
            ListTile(
              title: const Text('Select map type'),
              leading: const Icon(Icons.layers,),
              subtitle: Row(
                children: [
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.normal);
                    Navigator.pop(context);
                  }, child: const Text('Map')),
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.satellite);
                    Navigator.pop(context);
                  }, child: const Text('Satellite')),
                  TextButton(onPressed: () {
                    DataService().setMapType(MapType.hybrid);
                    Navigator.pop(context);
                  }, child: const Text('Hybrid'))
                ],
              ),
            ),
            ListTile(
                title: const Text('Set email address'),
              leading: const Icon(Icons.email,),
              onTap: () {
                  Navigator.pop(context);
                  showTextInputDialog(
                    'Enter email address to send track data',
                    'Enter email address',
                    DataService().getEmailPreference(),
                      (value) {
                        DataService().setEmailPreference(value);
                        // Navigator.pop(context);
                      }
                  );
              },
            ),
          ],
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
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );
  }
}
