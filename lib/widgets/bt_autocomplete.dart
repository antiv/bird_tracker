import 'package:flutter/material.dart';

class BtAutocomplete extends StatelessWidget {
  const BtAutocomplete({
    super.key,
    required this.spicesFocusNode,
    required this.spicesController,
    required this.kOptions,
  }) : _btFocusNode = spicesFocusNode, _btController = spicesController;

  final FocusNode _btFocusNode;
  final TextEditingController _btController;
  final TextEditingController spicesController;
  final FocusNode spicesFocusNode;
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
            labelText: 'Species',
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
              return 'Please enter a value';
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
          return kOptions.where((String option) {
            return option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        }
      },
    );
  }
}