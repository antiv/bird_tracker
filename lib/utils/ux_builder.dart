import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';

/// EG.
// showBottomModal(context, Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ListTile(
//           leading: const Icon(Icons.edit),
//           title: const Text('Edit'),
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         ListTile(
//           leading: const Icon(Icons.delete),
//           title: const Text('Delete'),
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ],
//     ));
showBottomModal(Widget widget) {
  showModalBottomSheet(
    context: ContextHolder.currentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
    ),
    builder: (BuildContext context) {
      return widget;
    },
  );
}

showDialogBox(Widget widget) {
  showDialog(
    context: ContextHolder.currentContext,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

showAlertDialog(Widget content, List<Widget> actions) {
  showDialogBox( AlertDialog(content: content, actions: actions));
}

showYesNoDialog(Function yesFunction, Function noFunction, {
  String title = 'Are you sure?',
  String yesText = 'Yes',
  String noText = 'No',
}) {
  showAlertDialog(
    Text(title),
    [
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          yesFunction();
        },
        child: Text(yesText),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          noFunction();
        },
        child: Text(noText),
      ),
    ],
  );
}

showTextInputDialog(String title, String hint, String? defaultValue, Function(String) onConfirm) {
  final TextEditingController controller = TextEditingController(text: defaultValue);
  showDialogBox(AlertDialog(
    title: Text(title),
    content: TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          onConfirm(controller.text);
        },
        child: const Text('Confirm'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
        },
        child: const Text('Cancel'),
      ),
    ],
  ));
}


showSnackBar(String message, {int duration = 1}) {
  ScaffoldMessenger.of(ContextHolder.currentContext).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}

showFullScreenDialog(Widget widget) {
  showGeneralDialog(
    context: ContextHolder.currentContext,
    // barrierColor: Colors.white, // Background color
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(ContextHolder.currentContext).secondaryHeaderColor,
          elevation: 0,
          title: const Text('Add Specie'),
          actions: [IconButton(
            onPressed: () => Navigator.of(ContextHolder.currentContext).pop(),
            icon: const Icon(Icons.close, color: Colors.black,),
          )],
        ),
        body: widget,
      );
    },
  );
}
