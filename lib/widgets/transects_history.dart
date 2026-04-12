import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/utils/location_helper.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../model/transect.dart';
import '../service/data_service.dart';
import '../utils/ux_builder.dart';

class TransectsHistory extends StatefulWidget {
  const TransectsHistory({
    super.key,
  });

  @override
  State<TransectsHistory> createState() => _TransectsHistoryState();
}

class _TransectsHistoryState extends State<TransectsHistory> {
  List<Transect?> transects = [];

  @override
  void initState() {
    _getTransects();
    super.initState();
  }

  Future<void> _getTransects() async {
    final List<Transect?> transects = await IsarService().getAllTransects();
    setState(() {
      this.transects = transects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text('history_title'.tr()),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: transects.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: transects.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                          onTap: () {
                            DataService().setTransect(transects[index]!);
                            Navigator.pop(ContextHolder.currentContext);
                          },
                          // leading: const Icon(Icons.map_outlined),
                          title: Text(transects[index]?.name ??
                              'Transect ${transects[index]?.id}: '
                                  '${DateFormat('dd.MM.yyyy HH:mm').format(transects[index]!.startDate)} - '
                                  '${transects[index]?.endDate != null ? DateFormat('HH:mm').format(transects[index]!.endDate!) : 'in_progress'.tr()}'),
                          // onTap: () {
                          //   Navigator.of(context).pop();
                          // },
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${'markers'.tr()}: ${transects[index]?.markers?.length ?? 0} '
                                  '${'distance'.tr()}: ${calculateDistance(transects[index]?.points?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? []).toStringAsFixed(2)}km '
                                  '${'time'.tr()}: ${getTimeDifference(transects[index]!.startDate, transects[index]?.endDate ?? DateTime.now())}'),
                              Row(children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    transects[index]?.shareCSV();
                                  },
                                  icon: const Icon(Icons.share),
                                  label: Text('csv'.tr()),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    transects[index]?.shareKML();
                                  },
                                  icon: const Icon(Icons.share),
                                  label: Text('kml'.tr()),
                                ),
                              ]),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            onPressed: () {
                              showYesNoDialog(() {
                                IsarService().deleteTransect(transects[index]!);
                                setState(() {
                                  transects.removeAt(index);
                                });
                              }, () {});
                            },
                            icon: const Icon(Icons.delete),
                          )),
                    );
                  },
                )
              : Center(child: Text('no_transects_yet'.tr())),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ContextHolder.currentContext),
          child: Text('close'.tr()),
        ),
      ],
    );
  }
}
