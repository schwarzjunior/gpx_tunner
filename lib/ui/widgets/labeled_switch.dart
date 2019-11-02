import 'package:flutter/material.dart';

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    Key key,
    @required this.label,
    @required this.value,
    @required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.groupValue,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool groupValue;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null
          ? null
          : () {
              return onChanged(!value);
            },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: Theme.of(context).textTheme.subhead)),
            Switch(
              value: value,
              onChanged: onChanged == null
                  ? null
                  : (bool newValue) {
                      return onChanged(newValue);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
