import 'package:flutter/material.dart';

class BtAutocomplete extends StatelessWidget {
  const BtAutocomplete({
    super.key,
    required this.kOptions,
    this.label = '',
    required this.btFocusNode,
    required this.btController,
  });

  final FocusNode btFocusNode;
  final TextEditingController btController;
  final List<String> kOptions;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      key: const ValueKey('autocomplete_text_field'),
      focusNode: btFocusNode,
      textEditingController: btController,
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
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            labelText: label,
            // prefixIcon: const Icon(Icons.search),
            suffixIcon: InkWell(
              child: const Icon(Icons.clear),
              onTap: () {
                btController.clear();
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Polje je obavezno';
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
                    focusColor: Colors.grey[300],
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