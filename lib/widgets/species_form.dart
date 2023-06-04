import 'package:bird_tracker/configuration/codes.dart';
import 'package:bird_tracker/configuration/species.dart';
import 'package:bird_tracker/model/species.dart';
import 'package:bird_tracker/widgets/enum_radio.dart';
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
  final TextEditingController _spicesController = TextEditingController();
  final TextEditingController _countController =
      TextEditingController(text: '1');
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _spicesFocusNode = FocusNode();

  Direction? _direction;
  Stratification? _stratification = Stratification.D;

  int? _code;

  @override
  void initState() {
    // _spicesFocusNode.requestFocus();
    if (widget.species != null) {
      _spicesController.text = widget.species?.species ?? '';
      _countController.text = widget.species!.count.toString();
      _descriptionController.text = widget.species!.description ?? '';
      _direction = widget.species?.direction;
      _stratification = widget.species?.stratification ?? Stratification.D;
      _code = widget.species?.code;
    } else {
      _spicesFocusNode.requestFocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    _spicesController.dispose();
    _countController.dispose();
    _spicesFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _save(bool close) {
    if (_formKey.currentState!.validate()) {
      final species = Species()
        ..species = _spicesController.text
        ..code = _code
        ..count = int.parse(_countController.text)
        ..time = DateFormat.Hms().format(DateTime.now())
        ..direction = _direction
        ..stratification = _stratification
        ..description = _descriptionController.text;
      if (widget.onSaved != null) {
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

  _clear() {
    _spicesController.clear();
    _countController.text = '1';
    _spicesFocusNode.requestFocus();
    _descriptionController.clear();
    _code = null;
    _direction = null;
    _stratification = Stratification.D;
  }

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
                  spicesFocusNode: _spicesFocusNode,
                  spicesController: _spicesController,
                  kOptions: kSpecies,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[ TextButton(
                          onPressed: () {
                            /// show poput to select atlas code
                            showDialogBox(
                              AlertDialog(
                                // icon: const Icon(Icons.code),
                                backgroundColor: Theme.of(context).cardColor,
                                title: const Text('Select atlas code'),
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
                                ? 'Select code: $_code'
                                : 'Select atlas code',
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
                          labelText: 'Count',
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
                              if (_countController.text.isNotEmpty) {
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

                /// Enum to radio buttons widget
                EnumRadio(
                  enumValues: Stratification.values,
                  value: _stratification,
                  onChanged: (val) => _stratification = val,
                ),
                EnumRadio(
                  enumValues: Direction.values,
                  value: _direction,
                  onChanged: (val) => _direction = val,
                ),

                /// description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Behavior',
                    prefixIcon: const Icon(Icons.description),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        _descriptionController.clear();
                      },
                    ),
                  ),
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (_save(false)) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          if (_save(false)) {
                            setState(() {
                              _clear();
                            });
                          }
                        },
                        child: const Text('Save and new')),
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
