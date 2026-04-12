import 'dart:io';

import 'package:bird_tracker/service/data_service.dart';
import 'package:bird_tracker/service/isar_service.dart';
import 'package:bird_tracker/utils/kml_utils.dart';
import 'package:context_holder/context_holder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String? title,
  String? yesText,
  String? noText,
}) {
  showAlertDialog(
    Text(title ?? 'are_you_sure'.tr()),
    [
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          yesFunction();
        },
        child: Text(yesText ?? 'yes'.tr()),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
          noFunction();
        },
        child: Text(noText ?? 'no'.tr()),
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
        child: Text('confirm'.tr()),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(ContextHolder.currentContext).pop();
        },
        child: Text('cancel'.tr()),
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
          title: Text(title ?? 'add_species'.tr()),
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
        title: Text('location_permission_title'.tr()),
        backgroundColor: Theme.of(context).cardColor,
        content: Text('location_permission_content'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = false;
            },
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = true;
            },
            child: Text('continue'.tr()),
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
        text: 'backup_text'.tr(),
      ),
    );
  } catch (e) {
    showSnackBar('backup_error'.tr(args: [e.toString()]));
  }
}

Future<void> restoreData() async {
  FilePickerResult? result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['isar'], // isar doesn't always have extension, but we can default to any
  );
  if (result != null) {
    try {
      showSnackBar('restoring_backup'.tr(), duration: 2);
      await IsarService().restoreBackup(result.files.single.path ?? '');
      showSnackBar('restore_success'.tr());
      DataService().setTransect(null); 
    } catch (e) {
      showSnackBar('restore_error'.tr(args: [e.toString()]));
    }
  }
}
