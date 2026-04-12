import 'package:bird_tracker/service/isar_service.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../service/data_service.dart';
import '../utils/location_helper.dart';
import '../utils/ux_builder.dart';

class TransectInfo extends StatefulWidget {
  const TransectInfo({super.key});

  @override
  State<TransectInfo> createState() => _TransectInfoState();
}

class _TransectInfoState extends State<TransectInfo> {
  @override
  Widget build(BuildContext context) {
    final current = DataService().transect;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 18,
          ),
          Text('transect_info'.tr()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current?.dateRange ?? ''),
              Text('${current?.markers?.length} ${'points'.tr()}'),
            ],
          ),
          Text('${'duration'.tr()}: ${current?.duration ?? ''}'),
          Text('${'distance'.tr()}: ${current?.distanceString ?? ''}'),
          Expanded(
            // height: 340,
            child: ListView.builder(
              itemCount: current?.markers?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                      title: Text(
                          '${'marker'.tr()} ${(current?.markers?[index].id ?? 0) + 1}'),
                      subtitle: Text(
                          '${'species_title'.tr()}: ${current?.markers?[index].species?.length} '
                          '${'time'.tr()}: ${current?.markers?[index].duration} '),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          /// Ask for confirmation, and delete the marker
                          showYesNoDialog(
                              () => setState(() {
                                    current?.markers = current.markers
                                            ?.toList(growable: true) ??
                                        [];
                                    current?.markers?.removeAt(index);
                                    IsarService().updateTransect(current!);
                                    DataService().notify();
                                  }),
                              () {});
                        },
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        showMarkerInfo(current?.markers?[index].id ?? 0);
                      }),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    ContextHolder.currentContext,
                  ).pop();
                  DataService().clearTransect();
                },
                child: Text('clear_map'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(
                  ContextHolder.currentContext,
                ).pop(),
                child: Text('close'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
