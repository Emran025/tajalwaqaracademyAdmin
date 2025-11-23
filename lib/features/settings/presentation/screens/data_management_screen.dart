import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/widgets/enum_to_string.dart';

import '../../domain/entities/import_export.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة البيانات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'تصدير', icon: Icon(Icons.file_download_outlined)),
              Tab(text: 'استيراد', icon: Icon(Icons.file_upload_outlined)),
            ],
          ),
        ),
        body: const TabBarView(children: [ExportDataView(), ImportDataView()]),
      ),
    );
  }
}

class ExportDataView extends StatefulWidget {
  const ExportDataView({super.key});

  @override
  State<ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends State<ExportDataView> {
  final Set<EntityType> _selectedData = {};
  DataExportFormat _selectedFormat = DataExportFormat.csv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          if (state.exportStatus == DataExportStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تصدير البيانات بنجاح إلى: ${state.exportFilePath}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          } else if (state.exportStatus == DataExportStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ أثناء تصدير البيانات: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          }
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is SettingsLoadSuccess &&
            state.exportStatus == DataExportStatus.loading;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('البيانات المراد تصديرها', style: theme.textTheme.titleLarge),
            ...EntityType.values.map(
              (data) => CheckboxListTile(
                title: Text(toDisplayString(data)),
                value: _selectedData.contains(data),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedData.add(data);
                    } else {
                      _selectedData.remove(data);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('تنسيق الملف', style: theme.textTheme.titleLarge),
            ...DataExportFormat.values.map(
              (format) => RadioListTile<DataExportFormat>(
                title: Text(toDisplayString(format)),
                value: format,
                groupValue: _selectedFormat,
                onChanged: (DataExportFormat? value) {
                  if (value != null) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: Text(isLoading ? 'جاري التصدير...' : 'تصدير البيانات'),
              onPressed: (_selectedData.isEmpty || isLoading)
                  ? null
                  : () {
                      final config = ExportConfig(
                        entityTypes: _selectedData.toList(),
                        fileFormat: _selectedFormat,
                      );
                      context.read<SettingsBloc>().add(
                        SettingsExportDataRequested(config),
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}

class ImportDataView extends StatefulWidget {
  const ImportDataView({super.key});

  @override
  State<ImportDataView> createState() => _ImportDataViewState();
}

class _ImportDataViewState extends State<ImportDataView> {
  String? _filePath;
  ConflictResolution _conflictStrategy = ConflictResolution.skip;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
    );
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          if (state.importStatus == DataImportStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم استيراد البيانات بنجاح: ${state.importSummary}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          } else if (state.importStatus == DataImportStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ أثناء استيراد البيانات: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          }
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is SettingsLoadSuccess &&
            state.importStatus == DataImportStatus.importing;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('ملف البيانات'),
              subtitle: Text(_filePath ?? 'لم يتم اختيار أي ملف'),
              trailing: ElevatedButton(
                onPressed: _pickFile,
                child: const Text('اختيار ملف'),
              ),
            ),
            const SizedBox(height: 20),
            Text('عند وجود تضارب', style: theme.textTheme.titleLarge),
            ...ConflictResolution.values.map(
              (strategy) => RadioListTile<ConflictResolution>(
                title: Text(toDisplayString(strategy)),
                value: strategy,
                groupValue: _conflictStrategy,
                onChanged: (ConflictResolution? value) {
                  if (value != null) {
                    setState(() {
                      _conflictStrategy = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: Text(isLoading ? 'جاري الاستيراد...' : 'استيراد البيانات'),
              onPressed: (_filePath == null || isLoading)
                  ? null
                  : () {
                      final config = ImportConfig(
                        entityType: EntityType.student,
                        conflictResolution: _conflictStrategy,
                      );
                      context.read<SettingsBloc>().add(
                        SettingsImportDataRequested(_filePath!, config),
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}
