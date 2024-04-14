import 'package:ciconia_tracker/service/isar_service.dart';
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
            height: 18,
          ),
          const Center(child: Text('Trenutni popis', style: TextStyle(fontSize: 20))),
          const SizedBox(
            height: 8,
          ),
          // Wrap(
          //   alignment: WrapAlignment.spaceBetween,
          //   children: [
          //     Text(current?.dateRange ?? '', overflow: TextOverflow.ellipsis,),
          //     Text('Upisano gnezda: ${current?.markers?.length}', overflow: TextOverflow.ellipsis,),
          //   ],
          // ),
          Text(current?.dateRange ?? '', overflow: TextOverflow.ellipsis,),
          Text('Upisano gnezda: ${current?.markers?.length}', overflow: TextOverflow.ellipsis,),
          Text('Duration: ${current?.duration ?? ''}'),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            // height: 340,
            child: ListView.builder(
              itemCount: current?.markers?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.location_pin, color: Theme.of(context).primaryColor),
                      title: Text('Gnezdo ${(current?.markers?[index].id ?? 0)+ 1}'),
                      subtitle: Text(
                              'Broj mladunaca: ${current?.markers?[index].species?.count ?? 0} '
                              'Vreme: ${current?.markers?[index].duration} '),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
                onPressed: () {
                  Navigator.of(ContextHolder.currentContext,).pop();
                  DataService().clearTransect();
                  },
                child: const Text('UKLONI SA MAPE'),
              ),
              TextButton(
                onPressed: () => Navigator.of(
                  ContextHolder.currentContext,
                ).pop(),
                child: const Text('ZATVORI'),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
