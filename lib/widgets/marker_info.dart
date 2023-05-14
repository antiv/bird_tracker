import 'package:bird_tracker/service/data_service.dart';
import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/widgets/species_form.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/placemark.dart';
import '../utils/ux_builder.dart';

class MarkerInfo extends StatefulWidget {
  const MarkerInfo({
    super.key,
    required this.selected,
  });

  final Placemark? selected;

  @override
  State<MarkerInfo> createState() => _MarkerInfoState();
}

class _MarkerInfoState extends State<MarkerInfo> {
  _addSpecies() {
    showFullScreenDialog(SpeciesForm(
      onSaved: (species) {
        setState(() {
          widget.selected?.species =
              widget.selected?.species?.toList(growable: true) ?? [];
          widget.selected?.species?.add(
            species,
          );
        });
        IsarService().updateTransect(DataService().transect!);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final speciesLength = widget.selected?.species?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Text('Marker ${(widget.selected?.id ?? 0) + 1}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.selected?.startDate != null
                  ? DateFormat('dd.MM.yyyy HH:mm')
                      .format(widget.selected!.startDate!)
                  : ''),
              Text('${widget.selected?.species?.length} species'),
            ],
          ),
          SizedBox(
            height: speciesLength * 80 > 340
                ? 340
                : speciesLength * 80 < 200 ? 200 : speciesLength * 80,
            child: ListView.builder(
              itemCount: speciesLength,
              itemBuilder: (context, index) {
                int revIdx = speciesLength - index - 1;
                return Card(
                child: ListTile(
                  title: Text('${widget.selected?.species?[revIdx].species}'),
                  subtitle: Text(
                      'Count: ${widget.selected?.species?[revIdx].count} '
                      'Time: ${widget.selected?.species?[revIdx].time} '
                      'Direction: ${widget.selected?.species?[revIdx].direction?.toString().split('.').last} '
                      'Strat.: ${widget.selected?.species?[revIdx].stratification?.toString().split('.').last} '),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showYesNoDialog(() => setState(() {
                        widget.selected?.species =
                            widget.selected?.species?.toList(growable: true) ?? [];
                        widget.selected?.species?.removeAt(revIdx);
                      }), () {});

                    },
                  ),
                  onTap: () {
                    showFullScreenDialog(SpeciesForm(
                      species: widget.selected?.species?[revIdx],
                      onSaved: (species) {
                        setState(() {
                          widget.selected?.species?[revIdx] = species;
                        });
                        DataService().transect?.updateMarker(widget.selected!);
                        IsarService().updateTransect(DataService().transect!);
                      },
                    ));
                  }
                ),
              );},
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _addSpecies(),
                child: const Text('ADD SPECIES'),
              ),
              const SizedBox(
                width: 10,
              ),
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
