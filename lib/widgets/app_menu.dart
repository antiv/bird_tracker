import 'package:bird_tracker/widgets/transect_info.dart';
import 'package:bird_tracker/widgets/transects_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configuration/constants.dart';
import '../service/data_service.dart';
import '../utils/ux_builder.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  void _showTracksHistory() => showBottomModal(const TransectsHistory());

  void _showTrackInfo() {
    if (DataService().transect != null) {
      showBottomModal(const TransectInfo());
    } else {
      showSnackBar('No transect selected');
    }
  }

  void _openPrivacyPolicy() async {
    final url = dotenv.env['PRIVACY_POLICY_URL'];
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
              height: 110,
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
                          kAppIcon,
                          semanticsLabel: 'Bird Tracker Logo',
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(kAppTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: Colors.white)),
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              return Text(
                                'v${snapshot.hasData ? snapshot.data!.version : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade300,
                                    ),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fmd_bad_outlined),
              title: const Text('Current track'),
              onTap: () {
                Navigator.pop(context);
                _showTrackInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Saved tracks'),
              onTap: () {
                Navigator.pop(context);
                _showTracksHistory();
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.tune),
              title: const Text('Settings'),
              // subtitle: Text(''),
              children: <Widget>[
                ListTile(
                  title: const Text('Select map type'),
                  leading: const Icon(
                    Icons.layers_outlined,
                  ),
                  subtitle: Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            DataService().setMapType(MapType.normal);
                            Navigator.pop(context);
                          },
                          child: const Text('Map')),
                      TextButton(
                          onPressed: () {
                            DataService().setMapType(MapType.satellite);
                            Navigator.pop(context);
                          },
                          child: const Text('Satellite')),
                      TextButton(
                          onPressed: () {
                            DataService().setMapType(MapType.hybrid);
                            Navigator.pop(context);
                          },
                          child: const Text('Hybrid'))
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Set email address'),
                  leading: const Icon(
                    Icons.email_outlined,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showTextInputDialog(
                        'Enter email address to send track data',
                        'Enter email address',
                        DataService().getEmailPreference(), (value) {
                      DataService().setEmailPreference(value);
                      // Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: const Text('Import KML'),
              onTap: () {
                Navigator.pop(context);
                showImportKMLDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Backup Data'),
              onTap: () {
                Navigator.pop(context);
                backupData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Restore Data'),
              onTap: () {
                Navigator.pop(context);
                restoreData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                _openPrivacyPolicy();
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
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );
  }
}
