import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BtAutocomplete extends StatelessWidget {
  const BtAutocomplete({
    super.key,
    required this.speciesFocusNode,
    required this.speciesController,
    required this.kOptions,
  }) : _btFocusNode = speciesFocusNode, _btController = speciesController;

  final FocusNode _btFocusNode;
  final TextEditingController _btController;
  final TextEditingController speciesController;
  final FocusNode speciesFocusNode;
  final List<String> kOptions;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      key: const ValueKey('autocomplete_text_field'),
      focusNode: _btFocusNode,
      textEditingController: _btController,
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
            labelText: 'species_label'.tr(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: InkWell(
              child: const Icon(Icons.clear),
              onTap: () {
                _btController.clear();
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_value'.tr();
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
                    _btFocusNode.unfocus();
                  },
                  child: ListTile(
                    title: Text(option),
                    subtitle: Text('species.$option'.tr()),
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
          return kOptions.where((String option) {
            final translated = 'species.$option'.tr().toLowerCase();
            final original = option.toLowerCase();
            final search = textEditingValue.text.toLowerCase();
            return original.contains(search) || translated.contains(search);
          });
        }
      },
    );
  }
}