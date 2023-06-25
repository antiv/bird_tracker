import 'package:flutter/material.dart';

class EnumRadio extends StatelessWidget {
  const EnumRadio({Key? key, this.enumValues, this.value, this.onChanged})
      : super(key: key);

  final List<dynamic>? enumValues;
  final dynamic value;
  final Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runSpacing: 20,
              children: enumValues
                      ?.map((e) => InkWell(
                            onTap: () {
                              if (onChanged != null) {
                                onChanged!(e);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio(
                                  value: e,
                                  groupValue: value,
                                  onChanged: (value) {
                                    if (onChanged != null) {
                                      onChanged!(value);
                                    }
                                  },
                                ),
                                Text(e.toString().split('.').last),
                              ],
                            ),
                          ))
                      .toList() ??
                  [],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 3,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Text(enumValues!.first.toString().split('.').first,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    )),
          ),
        ),
        Positioned(
          right: 2,
          top: 3,
          child: Container(
            // padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: SizedBox(
              height: 20,
              width: 20,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey.shade300,
                  ),
                ),
                onPressed: () {
                  if (onChanged != null) {
                    onChanged!(null);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
