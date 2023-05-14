import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/utils/location_helper.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../model/transect.dart';
import '../service/data_service.dart';

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

  _getTransects() async {
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
        const Text('History'),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: transects.isNotEmpty ? ListView.builder(
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
                  title: Text('Transect ${transects[index]?.id}: '
                      '${DateFormat('dd.MM.yyyy HH:mm').format(transects[index]!.startDate)} - '
                      '${transects[index]?.endDate != null ? DateFormat('HH:mm').format(transects[index]!.endDate!) : 'in progress'}'),
                  // onTap: () {
                  //   Navigator.of(context).pop();
                  // },
                  subtitle: Text(
                      'Markers: ${transects[index]?.markers?.length ?? 0} '
                          'Distance: ${calculateDistance(transects[index]?.points?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? []).toStringAsFixed(2)}km '
                          'Time: ${getTimeDifference(transects[index]!.startDate, transects[index]?.endDate ?? DateTime.now())}'),
                  trailing: IconButton(
                    onPressed: () {
                      IsarService().deleteTransect(transects[index]!);
                      setState(() {
                        transects.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete),
                  )
                ),
              );
            },
          ) : const Center(child: Text('No transects yet.')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ContextHolder.currentContext),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
