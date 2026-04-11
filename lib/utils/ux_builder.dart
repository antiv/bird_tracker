import 'dart:io';

import 'package:bird_tracker/service/data_service.dart';
import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/utils/kml_utils.dart';
import 'package:context_holder/context_holder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../model/transect.dart';

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
void showBottomModal(Widget widget) {
  showModalBottomSheet(
    context: ContextHolder.currentContext,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

void showDialogBox(Widget widget) {
  showDialog(
    context: ContextHolder.currentContext,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

void showAlertDialog(Widget content, List<Widget> actions) {
  showDialogBox(AlertDialog(
    content: content,
    actions: actions,
    backgroundColor: Theme.of(ContextHolder.currentContext).cardColor,
  ));
}

void showYesNoDialog(
  VoidCallback yesFunction,
  VoidCallback noFunction, {
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

void showTextInputDialog(String title, String hint, String? defaultValue,
    Function(String) onConfirm) {
  // final TextEditingController controller = TextEditingController(text: defaultValue);
  String value = defaultValue ?? '';
  showDialogBox(AlertDialog(
    title: Text(title),
    backgroundColor: Theme.of(ContextHolder.currentContext).cardColor,
    content: TextFormField(
      // controller: controller,
      decoration: InputDecoration(hintText: hint),
      autofocus: true,
      initialValue: defaultValue,
      onChanged: (String newValue) {
        value = newValue;
      },
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          onConfirm(value);
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

void showSnackBar(String message, {int duration = 1}) {
  ScaffoldMessenger.of(ContextHolder.currentContext).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}

void showFullScreenDialog(Widget widget, {String? title}) {
  DataService().isOpen.value = false;
  showGeneralDialog(
    context: ContextHolder.currentContext,
    // barrierColor: Colors.white, // Background color
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Scaffold(
        backgroundColor: Theme.of(ContextHolder.currentContext).cardColor,
        appBar: AppBar(
          // toolbarHeight: 30,
          elevation: 0,
          backgroundColor: Theme.of(ContextHolder.currentContext).primaryColor,
          title: Text(title ?? 'Add Species'),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(ContextHolder.currentContext).pop(),
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: widget,
      );
    },
  );
}

Future<void> showImportKMLDialog() async {
  /// Use File picker lib to get KML file path,
  /// then convert data to Transect and save to DB
  /// than, show it on map
  FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['kml'],
  );

  if (result != null) {
    File file = File(result.files.single.path?? '' );
    /// get file data as String XML
    String fileData = await file.readAsString();
    /// convert XML to Transect
    Transect transect = KMLUtils().kmlToTransect(fileData, file.lastModifiedSync());
    /// save transect to DB
    IsarService().addTransect(transect);
    /// show transect on map
    DataService().setTransect(transect);
  } else {
    // User canceled the picker
  }
}

Future<bool> showPermissionInfoDialog() async {
  bool result = false;
  await showDialog(
    context: ContextHolder.currentContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Permission'),
        backgroundColor: Theme.of(context).cardColor,
        content: const Text(
            'Bird Tracker needs your location to track your route and record where you see birds.\n\n'
            'We will first ask for regular location access, and then we will need "Allow all the time" permission to keep tracking even when the app is in the background or your screen is locked. Please allow both to make sure your transects are stored properly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = false;
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = true;
            },
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
  return result;
}

Future<void> backupData() async {
  try {
    String backupPath = await IsarService().createBackupPath();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(backupPath)],
        text: 'Bird Tracker Backup',
      ),
    );
  } catch (e) {
    showSnackBar('Error creating backup: ${e.toString()}');
  }
}

Future<void> restoreData() async {
  FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['isar'], // isar doesn't always have extension, but we can default to any
  );
  if (result != null) {
    try {
      showSnackBar('Restoring backup...', duration: 2);
      await IsarService().restoreBackup(result.files.single.path ?? '');
      showSnackBar('Data restored successfully!');
      DataService().setTransect(null); 
    } catch (e) {
      showSnackBar('Error restoring data: ${e.toString()}');
    }
  }
}
