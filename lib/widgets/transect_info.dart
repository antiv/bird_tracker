import 'package:bird_tracker/service/isar_service.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';

import '../service/data_service.dart';
import '../utils/location_helper.dart';
import '../utils/ux_builder.dart';

class TransectInfo extends StatefulWidget {
  const TransectInfo({Key? key}) : super(key: key);

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
            height: 20,
          ),
          const Text('Transect Info'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current?.dateRange ?? ''),
              Text('${current?.markers?.length} points'),
            ],
          ),
          Text('Duration: ${current?.duration ?? ''}'),
          Text('Distance: ${current?.distanceString ?? ''}'),
          SizedBox(
            height: 340,
            child: ListView.builder(
              itemCount: current?.markers?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                      title: Text('Marker ${(current?.markers?[index].id ?? 0)+ 1}'),
                      subtitle: Text(
                          'Spices: ${current?.markers?[index].species?.length} '
                              'Time: ${current?.markers?[index].duration} '),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          /// Ask for confirmation, and delete the marker
                          showYesNoDialog(() => setState(() {
                            current?.markers = current.markers?.toList(growable: true) ?? [];
                            current?.markers?.removeAt(index);
                            IsarService().updateTransect(current!);
                            DataService().notify();
                          }), () {});
                        },
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        showMarkerInfo(current?.markers?[index].id  ?? 0);
                      }
                  ),
                );},
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(
                  ContextHolder.currentContext,
                ).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
