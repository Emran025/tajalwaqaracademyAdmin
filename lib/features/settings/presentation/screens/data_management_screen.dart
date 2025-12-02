import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/widgets/enum_to_string.dart';

import '../../domain/entities/import_export.dart';

// --- ويدجت مساعدة للتصميم الموحد ---
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SettingsCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // استخدام لون السطح من الثيم
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة البيانات'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: const Size.fromHeight(60).height,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 1.5,
                  color: theme.colorScheme.primary.withOpacity(0.25),
                ),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                  0.7,
                ),

                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'تصدير', icon: Icon(Icons.file_download_outlined)),
                  Tab(text: 'استيراد', icon: Icon(Icons.file_upload_outlined)),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [ExportDataView(), ImportDataView()],
        ),
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
    final colorScheme = theme.colorScheme;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          if (state.exportStatus == DataExportStatus.success) {
            _showSnackBar(context, 'تم تصدير البيانات بنجاح', Colors.green);
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          } else if (state.exportStatus == DataExportStatus.failure) {
            _showSnackBar(
              context,
              'حدث خطأ: ${state.error}',
              colorScheme.error,
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          }
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is SettingsLoadSuccess &&
            state.exportStatus == DataExportStatus.loading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم اختيار البيانات
              const _SectionHeader(
                title: 'البيانات المراد تصديرها',
                icon: Icons.checklist_rtl,
              ),
              _SettingsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: EntityType.values
                      .map((data) {
                    final isSelected = _selectedData.contains(data);
                    return CheckboxListTile(
                      activeColor: colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        toDisplayString(data),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      value: isSelected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedData.add(data);
                          } else {
                            _selectedData.remove(data);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // قسم تنسيق الملف
              const _SectionHeader(
                title: 'تنسيق الملف',
                icon: Icons.format_shapes,
              ),
              Row(
                children: DataExportFormat.values.map((format) {
                  final isSelected = _selectedFormat == format;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFormat = format),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withOpacity(0.1)
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              format == DataExportFormat.csv
                                  ? Icons.table_chart_outlined
                                  : Icons.data_object,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              toDisplayString(format),
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // زر الإجراء
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
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
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('جاري التصدير...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_download_outlined),
                            SizedBox(width: 8),
                            Text(
                              'تصدير البيانات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
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
  String? _fileName;
  EntityType _selectedEntityType = EntityType.student;
  ConflictResolution _conflictStrategy = ConflictResolution.skip;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
    );
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoadSuccess) {
          if (state.importStatus == DataImportStatus.success) {
            _showSnackBar(
              context,
              'تم الاستيراد: ${state.importSummary}',
              Colors.green,
            );
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          } else if (state.importStatus == DataImportStatus.failure) {
            _showSnackBar(context, 'خطأ: ${state.error}', colorScheme.error);
            context.read<SettingsBloc>().add(SettingsImportExportResetStatus());
          }
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is SettingsLoadSuccess &&
            state.importStatus == DataImportStatus.importing;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // منطقة اختيار الملف
              const _SectionHeader(
                title: 'ملف البيانات',
                icon: Icons.attach_file,
              ),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _filePath != null
                        ? colorScheme.primary.withOpacity(0.05)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _filePath != null
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.4),
                      width: 2,
                      style: _filePath != null
                          ? BorderStyle.solid
                          : BorderStyle.solid,
                      // ملاحظة: لو كنت تستخدم مكتبة dotted_border يمكن جعلها منقطة هنا
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _filePath != null
                            ? Icons.check_circle_outline
                            : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _filePath != null
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fileName ?? 'اضغط لاختيار ملف (CSV, JSON)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _filePath != null
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_filePath != null)
                        Text(
                          'تم تحديد الملف جاهز للاستيراد',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // قسم اختيار نوع البيانات
              const _SectionHeader(
                title: 'نوع البيانات المراد استيرادها',
                icon: Icons.category,
              ),
              _SettingsCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<EntityType>(
                  value: _selectedEntityType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: EntityType.values.map((EntityType type) {
                    return DropdownMenuItem<EntityType>(
                      value: type,
                      child: Text(toDisplayString(type)),
                    );
                  }).toList(),
                  onChanged: (EntityType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedEntityType = newValue;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // استراتيجية التضارب
              const _SectionHeader(
                title: 'عند وجود تضارب (تشابه بيانات)',
                icon: Icons.merge_type,
              ),
              _SettingsCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: ConflictResolution.values.map((strategy) {
                    final isSelected = _conflictStrategy == strategy;
                    return RadioListTile<ConflictResolution>(
                      activeColor: colorScheme.primary,
                      title: Text(
                        toDisplayString(strategy),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      value: strategy,
                      groupValue: _conflictStrategy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (ConflictResolution? value) {
                        if (value != null) {
                          setState(() => _conflictStrategy = value);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: (_filePath == null || isLoading)
                      ? null
                      : () {
                          final config = ImportConfig(
                            entityType: _selectedEntityType,
                            conflictResolution: _conflictStrategy,
                          );
                          context.read<SettingsBloc>().add(
                            SettingsImportDataRequested(_filePath!, config),
                          );
                        },
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('جاري الاستيراد...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_upload_outlined),
                            SizedBox(width: 8),
                            Text(
                              'بدء الاستيراد',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
