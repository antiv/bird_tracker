import 'package:ciconia_tracker/service/isar_service.dart';
import 'package:ciconia_tracker/utils/location_helper.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        const Text('Sačuvni podaci', style: TextStyle(fontSize: 20)),
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
                          title: Text(transects[index]?.name ?? 'Posmatranje ${transects[index]?.id}: '
                              '${DateFormat('dd.MM.yyyy HH:mm').format(transects[index]!.startDate)} - '
                              '${transects[index]?.endDate != null ? DateFormat('HH:mm').format(transects[index]!.endDate!) : 'u toku'}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor),),
                          // onTap: () {
                          //   Navigator.of(context).pop();
                          // },
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Upisano gnezda: ${transects[index]?.markers?.length ?? 0} '
                                  // 'Distance: ${calculateDistance(transects[index]?.points?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? []).toStringAsFixed(2)}km '
                                  'Trajanje: ${getTimeDifference(transects[index]!.startDate, transects[index]?.endDate ?? DateTime.now())}'),
                              Row(children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    /// Check if tee user data is not empty
                                    if (DataService().getNamePreference()?.isEmpty ?? true) {
                                      // showSnackBar('Unesite podatke o popisivaču!', duration: 5);
                                      /// show alert message
                                      showAlertDialog(
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Wrap(
                                                  children: [
                                                    const Icon(Icons.warning, color: Colors.red, size: 30,),
                                                    const SizedBox(width: 10),
                                                    Text('Unesite podatke o popisivaču!',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: Theme.of(context).textTheme.titleMedium),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              const Text('Podaci o popisivaču nisu uneti.\nDa bi izvezli podatke potrebno je da unesete podatke o popisivaču u postavkama aplikacije.'),
                                            ],
                                          ),
                                          [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ContextHolder.currentContext).pop();
                                            },
                                            child: const Text('Zatvori'),
                                          ),
                                        ],);
                                      return;
                                    }
                                    transects[index]?.shareCSV();
                                  },
                                  icon: const Icon(Icons.share), label: const Text('CSV'),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    transects[index]?.shareKML();
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text('KML'),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                          )),
                    );
                  },
                )
              : const Center(child: Text('Još uvek nema sačuvanih podataka.')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ContextHolder.currentContext),
          child: const Text('ZATVORI'),
        ),
      ],
    );
  }
}
