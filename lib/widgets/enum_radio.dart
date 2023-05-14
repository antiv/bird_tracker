import 'package:flutter/material.dart';

class EnumRadio extends StatefulWidget {
  const EnumRadio({Key? key, this.enumValues, this.value, this.onChanged }) : super(key: key);

  final List<dynamic>? enumValues;
  final dynamic value;
  final Function(dynamic)? onChanged;

  @override
  State<EnumRadio> createState() => _EnumRadioState();
}

class _EnumRadioState extends State<EnumRadio> {
  dynamic enumValue;

  @override
  void initState() {
    enumValue = widget.value ?? widget.enumValues?.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Wrap(
            children: widget.enumValues
                ?.map((e) => InkWell(
                  onTap: () {
                    setState(() {
                      enumValue = e;
                      if (widget.onChanged != null) {
                        widget.onChanged!(e);
                      }
                    });
                  },
                  child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Radio(
                    value: e,
                    groupValue: enumValue,
                    onChanged: (value) {
                      setState(() {
                        enumValue = value;
                        if (widget.onChanged != null) {
                          widget.onChanged!(value);
                        }
                      });
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
        Positioned(
          left: 10,
          top: 5,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Text(
              widget.value.runtimeType.toString().split('.').last,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              )
            ),
          ),
        ),
      ],
    );
  }
}
