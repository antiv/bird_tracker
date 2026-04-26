import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../model/transect.dart';
import 'sembast_service.dart';

/// Isar service — kept only for v1.0.4 migration purposes.
/// 
/// On [init], checks if an old `.isar` database file exists.
/// If it does, all data is migrated to [SembastService] automatically,
/// and the `.isar` file is deleted.
///
/// In v1.0.5, this class and all `isar*` dependencies will be removed.
class IsarService with ChangeNotifier {
  static final IsarService _isarService = IsarService._internal();

  factory IsarService() {
    return _isarService;
  }

  IsarService._internal();

  Isar? _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isarFile = File('${dir.path}/bird_tracker.isar');

    // Auto-migrate if old .isar database still exists on device
    if (isarFile.existsSync()) {
      await _migrateToSembast(dir.path, isarFile);
    }
  }

  /// Opens the Isar db, reads all transects, writes them to sembast,
  /// then deletes the .isar file so migration never runs again.
  Future<void> _migrateToSembast(String dirPath, File isarFile) async {
    try {
      _isar = await Isar.open(
        [TransectSchema],
        directory: dirPath,
        name: 'bird_tracker',
      );

      final transects = await _isar!.transects.where().findAll();

      await SembastService().init();
      final sembastHasData = await SembastService().hasData();

      // Only import if sembast is empty (avoid duplicate migration)
      if (!sembastHasData && transects.isNotEmpty) {
        await SembastService().importTransects(transects);
      }

      await _isar!.close();
      _isar = null;

      // Rename instead of delete for safety — remove on next launch
      await isarFile.rename('${isarFile.path}.migrated');
    } catch (e) {
      // Migration failure is non-fatal — user still has their data in Isar
      debugPrint('Isar migration error: $e');
    }
  }

  /// Restore from an old .isar backup file.
  /// Opens the provided file as an Isar DB, reads all transects,
  /// imports them into sembast, then closes.
  Future<void> restoreFromIsarBackup(String backupFilePath) async {
    final tempDir = await getTemporaryDirectory();

    // Copy backup to a temp location Isar can open
    final tempFile = File('${tempDir.path}/restore_temp.isar');
    await File(backupFilePath).copy(tempFile.path);

    final isar = await Isar.open(
      [TransectSchema],
      directory: tempDir.path,
      name: 'restore_temp',
    );

    try {
      final transects = await isar.transects.where().findAll();
      await SembastService().importTransects(transects);
    } finally {
      await isar.close();
      if (tempFile.existsSync()) await tempFile.delete();
    }
  }
}
