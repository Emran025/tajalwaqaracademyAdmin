enum EntityType { student, teacher , halaqa }

enum ConflictResolution { skip, overwrite }

enum DataExportFormat { 
  csv("csv"),
  json("json"); 

  final String label;
  const DataExportFormat(this.label);
  static DataExportFormat fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'json':
        return DataExportFormat.json;
      default:
        return DataExportFormat.csv;
    }
  }

}
