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
    enumValue = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: const EdgeInsets.only(right: 15),
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
          left: 20,
          top: 3,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Text(
              widget.enumValues!.first.toString().split('.').first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              )
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 0,
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
                  setState(() {
                    enumValue = null;
                    if (widget.onChanged != null) {
                      widget.onChanged!(null);
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
