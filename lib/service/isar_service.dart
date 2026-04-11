import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../model/transect.dart';

/// Singleton class to initiate and use isar database

class IsarService with ChangeNotifier {
  static final IsarService _isarService = IsarService._internal();

  factory IsarService() {
    return _isarService;
  }

  IsarService._internal();

  late Isar _isar;

  Future<void> init() async {
    _isar = await openIsar();
  }

  Future<Isar> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([TransectSchema],
        directory: dir.path, name: 'bird_tracker.isar');
  }

  Isar get isar {
    return _isar;
  }

 /// commands for collection Transect
  Future<void> addTransect(Transect transect) async {
    await isar.writeTxn<int>(() async => await isar.transects.put(transect));
  }

  Future<void> updateTransect(Transect transect) async {
    await isar.writeTxn<int>(() async => await isar.transects.put(transect));
  }

  Future<bool> deleteTransect(Transect transect) async {
    return await isar.writeTxn<bool>(() async => isar.transects.delete(transect.id));
  }

  Future<List<Transect?>> getAllTransects() {
    return isar.transects.filter().idGreaterThan(-1).sortByStartDateDesc().findAll();
  }

  Future<Transect?> getTransectById(int id) async {
    return await _isar.transects.get(id);
  }

  Future<String> createBackupPath() async {
    final tempDir = await getTemporaryDirectory();
    final backupFile = File('${tempDir.path}/bird_tracker_backup.isar');
    if (backupFile.existsSync()) {
      backupFile.deleteSync();
    }
    await _isar.copyToFile(backupFile.path);
    return backupFile.path;
  }

  Future<void> restoreBackup(String backupFilePath) async {
    final dbPath = _isar.path;
    await _isar.close();
    
    final backupFile = File(backupFilePath);
    await backupFile.copy(dbPath!);
    
    await init();
    notifyListeners();
  }
}
