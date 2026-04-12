import 'package:bird_tracker/widgets/transect_info.dart';
import 'package:bird_tracker/widgets/transects_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:easy_localization/easy_localization.dart';
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
      showSnackBar('no_transect_selected'.tr());
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
                        Text('app_title'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: Colors.white)),
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              return Text(
                                'app_version'.tr(args: [snapshot.hasData ? snapshot.data!.version : '']),
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
              title: Text('current_track'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showTrackInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text('saved_tracks'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showTracksHistory();
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.tune),
              title: Text('settings'.tr()),
              // subtitle: Text(''),
              children: <Widget>[
                ListTile(
                  title: Text('select_map_type'.tr()),
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
                          child: Text('map'.tr())),
                      TextButton(
                          onPressed: () {
                            DataService().setMapType(MapType.satellite);
                            Navigator.pop(context);
                          },
                          child: Text('satellite'.tr())),
                      TextButton(
                          onPressed: () {
                            DataService().setMapType(MapType.hybrid);
                            Navigator.pop(context);
                          },
                          child: Text('hybrid'.tr()))
                    ],
                  ),
                ),
                ListTile(
                  title: Text('set_email'.tr()),
                  leading: const Icon(
                    Icons.email_outlined,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showTextInputDialog(
                        'email_dialog_title'.tr(),
                        'email_dialog_hint'.tr(),
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
              title: Text('import_kml'.tr()),
              onTap: () {
                Navigator.pop(context);
                showImportKMLDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: Text('backup_data'.tr()),
              onTap: () {
                Navigator.pop(context);
                backupData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: Text('restore_data'.tr()),
              onTap: () {
                Navigator.pop(context);
                restoreData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text('privacy_policy'.tr()),
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
