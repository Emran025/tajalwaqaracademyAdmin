// lib/core/database/app_database.dart
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

/// AppDatabase provides a singleton instance to manage the application's SQLite database.
///
/// It's designed with an "offline-first" and "sync-ready" architecture in mind.
///
/// Key Design Principles:
/// 1.  **Sync-Ready Schema:**
///     - `uuid` (TEXT): A universally unique identifier for rows that need to be synced with a remote server.
///       This is the canonical ID for a record across all devices and the backend.
///     - `lastModified` (INTEGER): A Unix timestamp (milliseconds since epoch in UTC) indicating the last time
///       a record was changed. Used for conflict resolution during synchronization.
///     - `isDeleted` (INTEGER): A boolean flag (0 or 1) for soft deletes. When a user deletes a record,
///       it's marked as deleted locally and synced to the server, instead of being removed immediately.
///
/// 2.  **Maintainability:**
///     - `onUpgrade` path is implemented for future schema migrations.
///     - Table and column names are defined as constants to prevent typos.
///     - Schema creation is broken down into logical, private methods.
///
/// 3.  **Performance:**
///     - Indexes are explicitly created on foreign key columns to speed up JOINs and queries.
///
/// 4.  **Security:**
///     - No sensitive data like password hashes are stored in the local database. Authentication should
///       be handled by a backend service that provides a session token (e.g., JWT).
///
class AppDatabase {
  // --- Singleton Pattern ---
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  // --- Database & Table Constants ---
  static const String _dbName = 'app_main.db';
  static const int _dbVersion = 1;

  // Table Names
  static const String _kRolesTable = 'roles';
  static const String _kUsersTable = 'users';
  static const String _kRegistrationRequestsTable = 'registration_requests';
  static const String _kHalqasTable = 'halqas';
  static const String _kTeacherHalqasTable = 'teacher_halqas';
  static const String _kHalqaStudentsTable = 'halqa_students';
  static const String _kUnitsTable = 'units';
  static const String _kFrequenciesTable = 'frequencies';
  static const String _kTrackingTypesTable = 'tracking_types';
  static const String _kTrackingPlansTable = 'tracking_plans';
  static const String _kAttendanceTypesTable = 'attendance_types';
  static const String _kTrackingSourcesTable = 'tracking_sources';
  static const String _kDailyTrackingTable = 'daily_tracking';
  static const String _kDailyTrackingDetailTable = 'daily_tracking_detail';
  static const String _kPendingOperationsTable = 'pending_operations';
  static const String _kSyncMetadataTable = 'sync_metadata';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Called when the database is configured.
  /// Best place to enable features like foreign keys.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Called when the database is created for the first time.
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await _createLookupTables(txn);
      await _createUserTables(txn);
      await _createHalqaTables(txn);
      await _createTrackingTables(txn);
      await _createSyncInfrastructureTables(txn);
      await _createIndexes(txn);
    });
  }

  /// Creates static lookup tables that define types and categories within the app.
  /// These tables are typically seeded with initial data and rarely change.
  /// They do not require sync columns as they are considered part of the app's core data.
  ///

  // =========================================================================
  //                             SCHEMA CREATION
  // =========================================================================

  /// **(جديد)** Creates the core tables required for the synchronization engine.
  /// These tables track local changes and the sync state for different data entities.
  Future<void> _createSyncInfrastructureTables(Transaction txn) async {
    await txn.execute('''
  CREATE TABLE $_kSyncMetadataTable (
    entity_type TEXT PRIMARY KEY,       -- 'teachers', 'students', etc.
    last_server_sync_timestamp INTEGER NOT NULL DEFAULT 0
  )
''');
    await txn.execute('''
  CREATE TABLE $_kPendingOperationsTable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_uuid TEXT NOT NULL,
    entity_type TEXT NOT NULL,      -- e.g., 'teacher'
    operation_type TEXT NOT NULL,   -- 'create', 'update', 'delete'
    payload TEXT,                   -- JSON string of the data for create/update
    created_at INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' -- 'pending', 'in_progress', 'failed'
  )
''');
  }

  Future<void> _createLookupTables(Transaction txn) async {
    // Roles (e.g., student, teacher)
    await txn.execute('''
      CREATE TABLE $_kRolesTable (
        id     INTEGER PRIMARY KEY,
        code   TEXT    NOT NULL UNIQUE,
        nameAr TEXT    NOT NULL
      )
    ''');
    await txn.insert(_kRolesTable, {
      'id': 1,
      'code': 'power_admin',
      'nameAr': 'مشرف نظام',
    });
    await txn.insert(_kRolesTable, {
      'id': 2,
      'code': 'supervisor',
      'nameAr': 'مشرف',
    });
    await txn.insert(_kRolesTable, {
      'id': 3,
      'code': 'teacher',
      'nameAr': 'معلم',
    });
    await txn.insert(_kRolesTable, {
      'id': 4,
      'code': 'student',
      'nameAr': 'طالب',
    });

    // Units (e.g., page, juz)
    await txn.execute('''
      CREATE TABLE $_kUnitsTable (
        id     INTEGER PRIMARY KEY,
        code   TEXT    NOT NULL UNIQUE,
        nameAr TEXT    NOT NULL
      )
    ''');
    await txn.insert(_kUnitsTable, {'id': 1, 'code': 'juz', 'nameAr': 'جزء'});
    await txn.insert(_kUnitsTable, {'id': 2, 'code': 'hizb', 'nameAr': 'حزب'});
    await txn.insert(_kUnitsTable, {'id': 3, 'code': 'page', 'nameAr': 'صفحة'});

    // Frequencies (e.g., daily, weekly)
    await txn.execute('''
      CREATE TABLE $_kFrequenciesTable (
        id        INTEGER PRIMARY KEY,
        code      TEXT    NOT NULL UNIQUE,
        nameAr    TEXT    NOT NULL,
        daysCount INTEGER NOT NULL
      )
    ''');
    await txn.insert(_kFrequenciesTable, {
      'id': 1,
      'code': 'daily',
      'nameAr': 'يومي',
      'daysCount': 7,
    });
    await txn.insert(_kFrequenciesTable, {
      'id': 2,
      'code': 'weekly',
      'nameAr': 'أسبوعي',
      'daysCount': 1,
    });

    // Tracking Types (e.g., memorize, review)
    await txn.execute('''
      CREATE TABLE $_kTrackingTypesTable (
        id     INTEGER PRIMARY KEY,
        code   TEXT    NOT NULL UNIQUE,
        nameAr TEXT    NOT NULL
      )
    ''');
    await txn.insert(_kTrackingTypesTable, {
      'id': 1,
      'code': 'memorize',
      'nameAr': 'الحفظ',
    });
    await txn.insert(_kTrackingTypesTable, {
      'id': 2,
      'code': 'review',
      'nameAr': 'المراجعة',
    });

    // Attendance Types (e.g., present, absent)
    await txn.execute('''
      CREATE TABLE $_kAttendanceTypesTable (
        id     INTEGER PRIMARY KEY,
        code   TEXT    NOT NULL UNIQUE,
        nameAr TEXT    NOT NULL
      )
    ''');
    await txn.insert(_kAttendanceTypesTable, {
      'id': 1,
      'code': 'present',
      'nameAr': 'حاضر',
    });
    await txn.insert(_kAttendanceTypesTable, {
      'id': 2,
      'code': 'absent',
      'nameAr': 'غياب',
    });

    // Tracking Sources (e.g., auto, manual)
    await txn.execute('''
      CREATE TABLE $_kTrackingSourcesTable (
        id     INTEGER PRIMARY KEY,
        code   TEXT    NOT NULL UNIQUE,
        nameAr TEXT    NOT NULL
      )
    ''');
    await txn.insert(_kTrackingSourcesTable, {
      'id': 1,
      'code': 'auto_generated',
      'nameAr': 'تلقائي',
    });
    await txn.insert(_kTrackingSourcesTable, {
      'id': 2,
      'code': 'manual',
      'nameAr': 'يدوي',
    });
  }

  /// Creates tables related to users and registration.
  Future<void> _createUserTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE $_kUsersTable (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid              TEXT    NOT NULL,
        roleId            INTEGER NOT NULL,
        status            TEXT    NOT NULL,
        name              TEXT    NOT NULL,
        gender            TEXT    NOT NULL,
        birthDate         TEXT,
        email             TEXT    NOT NULL UNIQUE,
        avatar TEXT,
        phoneZone         TEXT,
        bio               TEXT,
        phone             TEXT    NOT NULL,
        whatsappZone      TEXT,
        whatsapp          TEXT,
        qualification     TEXT,
        experienceYears   INTEGER,
        country           TEXT,
        residence         TEXT,
        city              TEXT,
        availableTime     TEXT,
        stopReasons       TEXT,
        memorizationLevel TEXT,
        lastModified      INTEGER NOT NULL,
        isDeleted         INTEGER NOT NULL DEFAULT 0,
        
        UNIQUE(roleId, uuid),
        FOREIGN KEY(roleId) REFERENCES $_kRolesTable(id) ON UPDATE CASCADE ON DELETE RESTRICT
      )
    ''');

    await txn.execute('''
      CREATE TABLE $_kRegistrationRequestsTable (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid              TEXT    NOT NULL,
        type              TEXT    NOT NULL,
        name              TEXT    NOT NULL,
        gender            TEXT    NOT NULL,
        birthDate         TEXT,
        email             TEXT    NOT NULL,
        phoneZone         TEXT,
        phone             TEXT    NOT NULL,
        whatsappZone      TEXT,
        whatsapp          TEXT,
        country           TEXT,
        residence         TEXT,
        city              TEXT,
        qualification     TEXT,
        experienceYears   INTEGER,
        memorizationLevel TEXT,
        availableTime     TEXT,
        status            TEXT    NOT NULL DEFAULT 'new',
        note              TEXT,
        lastModified      INTEGER NOT NULL,

        UNIQUE(email),
        UNIQUE(uuid, type),
        UNIQUE(phoneZone, phone)
      )
    ''');
  }

  /// Creates tables related to Halqas (study circles) and their members.
  Future<void> _createHalqaTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE $_kHalqasTable (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid         TEXT    NOT NULL UNIQUE,
        name         TEXT    NOT NULL,
        isActive     INTEGER NOT NULL DEFAULT 1,
        archivedAt   TEXT,
        gender       TEXT    NOT NULL,
        residence    TEXT,
        lastModified INTEGER NOT NULL,
        isDeleted    INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await txn.execute('''
      CREATE TABLE $_kTeacherHalqasTable (
        uuid         TEXT    NOT NULL UNIQUE,
        teacherId    INTEGER NOT NULL,
        halqaId      INTEGER NOT NULL,
        lastModified INTEGER NOT NULL,
        isDeleted    INTEGER NOT NULL DEFAULT 0,
        
        PRIMARY KEY (teacherId, halqaId),
        FOREIGN KEY(teacherId) REFERENCES $_kUsersTable(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(halqaId)   REFERENCES $_kHalqasTable(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await txn.execute('''
      CREATE TABLE $_kHalqaStudentsTable (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid         TEXT    NOT NULL UNIQUE,
        halqaId      INTEGER NOT NULL,
        studentId    INTEGER NOT NULL,
        assignedAt   TEXT    NOT NULL,
        leftAt       TEXT,
        lastModified INTEGER NOT NULL,
        isDeleted    INTEGER NOT NULL DEFAULT 0,

        UNIQUE(halqaId, studentId),
        FOREIGN KEY(halqaId)   REFERENCES $_kHalqasTable(id)   ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(studentId) REFERENCES $_kUsersTable(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  /// Creates tables related to student progress tracking.
  Future<void> _createTrackingTables(Transaction txn) async {
    await txn.execute('''
      CREATE TABLE $_kTrackingPlansTable (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid             TEXT    NOT NULL UNIQUE,
        halqaStudentId   INTEGER NOT NULL,
        typeId           INTEGER NOT NULL,
        frequencyId      INTEGER NOT NULL,
        unitId           INTEGER NOT NULL,
        amount           INTEGER NOT NULL,
        startDate        TEXT    NOT NULL,
        endDate          TEXT,
        lastModified     INTEGER NOT NULL,
        isDeleted        INTEGER NOT NULL DEFAULT 0,

        FOREIGN KEY(halqaStudentId) REFERENCES $_kHalqaStudentsTable(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(typeId)         REFERENCES $_kTrackingTypesTable(id)  ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(frequencyId)    REFERENCES $_kFrequenciesTable(id)    ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(unitId)         REFERENCES $_kUnitsTable(id)          ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await txn.execute('''
      CREATE TABLE $_kDailyTrackingTable (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid             TEXT    NOT NULL UNIQUE,
        halqaStudentId   INTEGER NOT NULL,
        trackDate        TEXT    NOT NULL,
        attendanceTypeId INTEGER NOT NULL,
        lastModified     INTEGER NOT NULL,

        UNIQUE(halqaStudentId, trackDate),
        FOREIGN KEY(halqaStudentId) REFERENCES $_kHalqaStudentsTable(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(attendanceTypeId) REFERENCES $_kAttendanceTypesTable(id) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await txn.execute('''
      CREATE TABLE $_kDailyTrackingDetailTable (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid         TEXT    NOT NULL UNIQUE,
        trackingId   INTEGER NOT NULL,
        typeId       INTEGER NOT NULL,
        planId       INTEGER,
        completed    INTEGER,
        sourceId     INTEGER,
        note         TEXT,
        lastModified INTEGER NOT NULL,
        
        UNIQUE(trackingId, typeId),
        FOREIGN KEY(trackingId) REFERENCES $_kDailyTrackingTable(id)   ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(typeId)     REFERENCES $_kTrackingTypesTable(id)   ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(planId)     REFERENCES $_kTrackingPlansTable(id)   ON DELETE SET NULL ON UPDATE CASCADE,
        FOREIGN KEY(sourceId)   REFERENCES $_kTrackingSourcesTable(id) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    // Trigger to auto-populate detail rows when a daily tracking entry is created.
    await txn.execute('''
      CREATE TRIGGER after_insert_daily_tracking
      AFTER INSERT ON $_kDailyTrackingTable
      BEGIN
        INSERT INTO $_kDailyTrackingDetailTable(uuid, trackingId, typeId, lastModified)
        SELECT lower(hex(randomblob(16))), NEW.id, tt.id, NEW.lastModified
        FROM $_kTrackingTypesTable tt;
      END;
    ''');
  }

  /// Creates indexes on foreign key columns to improve query performance.
  Future<void> _createIndexes(Transaction txn) async {
    await txn.execute('CREATE INDEX idx_users_roleId ON $_kUsersTable(roleId)');
    await txn.execute(
      'CREATE INDEX idx_teacher_halqas_halqaId ON $_kTeacherHalqasTable(halqaId)',
    );
    await txn.execute(
      'CREATE INDEX idx_halqa_students_studentId ON $_kHalqaStudentsTable(studentId)',
    );
    await txn.execute(
      'CREATE INDEX idx_tracking_plans_halqaStudentId ON $_kTrackingPlansTable(halqaStudentId)',
    );
    await txn.execute(
      'CREATE INDEX idx_daily_tracking_halqaStudentId ON $_kDailyTrackingTable(halqaStudentId)',
    );
    await txn.execute(
      'CREATE INDEX idx_daily_tracking_detail_trackingId ON $_kDailyTrackingDetailTable(trackingId)',
    );
  }

  /// Called when the database needs to be upgraded.
  /// Use this to alter tables and add new features in future app versions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Example for a future migration:
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE $_kUsersTable ADD COLUMN someNewField TEXT;");
    // }
    // if (oldVersion < 3) {
    //   await db.execute("CREATE TABLE new_awesome_table (...)");
    // }
  }
}
