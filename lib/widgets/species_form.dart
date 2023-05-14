import 'package:bird_tracker/configuration/species.dart';
import 'package:bird_tracker/model/species.dart';
import 'package:bird_tracker/widgets/enum_radio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpeciesForm extends StatefulWidget {
  const SpeciesForm({Key? key, this.onSaved, this.species }) : super(key: key);

  final Function? onSaved;
  final Species? species;

  @override
  State<SpeciesForm> createState() => _SpeciesFormState();
}

class _SpeciesFormState extends State<SpeciesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _spicesController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _spicesFocusNode = FocusNode();

  Direction _direction = Direction.N;
  Stratification _stratification = Stratification.D;

  @override
  void initState() {
    // _spicesFocusNode.requestFocus();
    if (widget.species != null) {
      _spicesController.text = widget.species?.species ?? '';
      _countController.text = widget.species!.count.toString();
      _descriptionController.text = widget.species!.description ?? '';
      _direction = widget.species!.direction!;
      _stratification = widget.species!.stratification!;
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

  _save() {
    if (_formKey.currentState!.validate()) {
      final species = Species()
        ..species = _spicesController.text
        ..count = int.parse(_countController.text)
        ..time = DateFormat.Hms().format(DateTime.now())
        ..direction = _direction
        ..stratification = _stratification
        ..description = _descriptionController.text
      ;
      if (widget.onSaved != null) {
        widget.onSaved!(species);
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
    _countController.clear();
    _spicesFocusNode.requestFocus();
    _descriptionController.clear();
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
              children: [
                RawAutocomplete(
                  key: const ValueKey('autocomplete_text_field'),
                  focusNode: _spicesFocusNode,
                  textEditingController: _spicesController,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      decoration: InputDecoration(
                        labelText: 'Specie',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: InkWell(
                          child: const Icon(Icons.clear),
                          onTap: () {
                            _spicesController.clear();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter specie';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 200.0,
                          child: ListView(
                            padding: const EdgeInsets.all(8.0),
                            children: options
                                .map((String option) => GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    } else {
                      return kSpecies.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    }
                  },
                ),
                // Autocomplete(optionsBuilder: (TextEditingValue textEditingValue) {
                //   if (textEditingValue.text == '') {
                //     return const Iterable<String>.empty();
                //   }
                //   return kSpecies.where((String option) {
                //     return option
                //         .toLowerCase()
                //         .contains(textEditingValue.text.toLowerCase());
                //   });
                // },),
                TextFormField(
                  controller: _countController,
                  decoration: InputDecoration(
                    labelText: 'Count',
                    prefixIcon: InkWell(onTap: () {
                      if (_countController.text.isNotEmpty) {
                        _countController.text =
                            (int.parse(_countController.text) + 1).toString();
                      } else {
                        _countController.text = '1';
                      }
                    }, child: const Icon(Icons.add)),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.remove),
                      onTap: () {
                        if (_countController.text.isNotEmpty) {
                          _countController.text =
                              (int.parse(_countController.text) - 1).toString();
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
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        _descriptionController.clear();
                      },
                  ),),
                  maxLines: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (_save()) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          _save();
                          _clear();
                        },
                        child: const Text('Sava and new')),
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
