import 'package:ciconia_tracker/configuration/codes.dart';
import 'package:ciconia_tracker/configuration/constants.dart';
import 'package:ciconia_tracker/model/species.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/ux_builder.dart';
import 'bt_autocomplete.dart';

class SpeciesForm extends StatefulWidget {
  const SpeciesForm({Key? key, this.onSaved, this.species}) : super(key: key);

  final Function? onSaved;
  final Species? species;

  @override
  State<SpeciesForm> createState() => _SpeciesFormState();
}

class _SpeciesFormState extends State<SpeciesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countController =
      TextEditingController(text: '0');
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _positionFocusNode = FocusNode();
  final FocusNode _stateFocusNode = FocusNode();

  int? _code;

  @override
  void initState() {
    // _spicesFocusNode.requestFocus();
    if (widget.species != null) {
      _positionController.text = widget.species?.position ?? '';
      _stateController.text = widget.species?.state ?? '';
      _countController.text = widget.species!.count.toString();
      _descriptionController.text = widget.species!.description ?? '';
      _placeController.text = widget.species?.place ?? '';
      _municipalityController.text = widget.species?.municipality ?? '';
      // _direction = widget.species?.direction;
      // _stratification = widget.species?.stratification ?? Stratification.D;
      _code = widget.species?.code;
    } else {
      _positionFocusNode.requestFocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _countController.dispose();
    _positionFocusNode.dispose();
    _descriptionController.dispose();
    _stateController.dispose();
    _stateFocusNode.dispose();
    _placeController.dispose();
    _municipalityController.dispose();
    super.dispose();
  }

  _save(bool close) {
    if (_formKey.currentState!.validate()) {
      final species = Species()
        // ..species = _spicesController.text
        ..code = _code
        ..count = int.parse(_countController.text)
        ..position = _positionController.text.trim()
        ..state = _stateController.text.trim()
        ..place = _placeController.text.trim()
        ..municipality = _municipalityController.text.trim()
        ..time = DateFormat.Hms().format(DateTime.now())
        ..description = _descriptionController.text;
      if (widget.onSaved != null) {
        print('save species: ${species.count}');
        widget.onSaved!(species, close);
      }
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid data'),
        ),
      );
      return false;
    }
  }

  // _clear() {
  //   setState(() {
  //     _positionController.clear();
  //     _countController.text = '0';
  //     _positionFocusNode.requestFocus();
  //     _descriptionController.clear();
  //     _code = null;
  //     _position = '';
  //     _placeController.clear();
  //     _municipalityController.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    /// Create form to add species data
    return SingleChildScrollView(
      key: const ValueKey('species_form'),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BtAutocomplete(
                  btFocusNode: _positionFocusNode,
                  btController: _positionController,
                  kOptions: kPositions,
                  label: 'Položaj gnezda',
                ),
                const SizedBox(height: 10,),
                BtAutocomplete(
                  btFocusNode: _stateFocusNode,
                  btController: _stateController,
                  kOptions: kStates,
                  label: 'Stanje u gnezdu',
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[ ElevatedButton(
                          onPressed: () {
                            /// show poput to select atlas code
                            showDialogBox(
                              AlertDialog(
                                // icon: const Icon(Icons.code),
                                backgroundColor: Theme.of(context).cardColor,
                                title: const Text('Izaberi Atlas kod'),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (var code in kCodes.keys)
                                        Card(
                                          child: ListTile(
                                            leading: Text('$code.'),
                                            dense: true,
                                            title: Text(kCodes[code]!),
                                            onTap: () {
                                              setState(() {
                                                _code = code;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            _code != null
                                ? 'Izabran kod: $_code'
                                : 'Izaberi Atlas kod',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        InkWell(onTap:() => setState(() {
                          _code = null;
                        }),child: const Icon(Icons.clear, color: Colors.grey, size: 20,)),
                      ],
                    ),
                    SizedBox(
                      width: 160,
                      child: TextFormField(
                        controller: _countController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'Mladunaca',
                          suffixIcon: InkWell(
                              onTap: () {
                                if (_countController.text.isNotEmpty) {
                                  _countController.text =
                                      (int.parse(_countController.text) + 1)
                                          .toString();
                                } else {
                                  _countController.text = '1';
                                }
                              },
                              child: const Icon(Icons.add)),
                          prefixIcon: InkWell(
                            child: const Icon(Icons.remove),
                            onTap: () {
                              if (_countController.text.isNotEmpty &&
                                  int.parse(_countController.text) > 0) {
                                _countController.text =
                                    (int.parse(_countController.text) - 1)
                                        .toString();
                              } else {
                                _countController.text = '0';
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter count';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                /// description field
                TextFormField(
                  controller: _placeController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Naselje',
                    // prefixIcon: const Icon(Icons.location),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        _placeController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                /// description field
                TextFormField(
                  controller: _municipalityController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Opština',
                    // prefixIcon: const Icon(Icons.description),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        _municipalityController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                /// description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    labelText: 'Napomena',
                    // prefixIcon: const Icon(Icons.description),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        _descriptionController.clear();
                      },
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (_save(false)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Sačuvaj')),
                    // if (!_isEdit)
                    const SizedBox(width: 10),
                    // if (!_isEdit)
                    ElevatedButton(
                        onPressed: () {
                            Navigator.pop(context);
                        },
                        child: const Text('Odustani')),
                    // const SizedBox(width: 10),
                    // ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
