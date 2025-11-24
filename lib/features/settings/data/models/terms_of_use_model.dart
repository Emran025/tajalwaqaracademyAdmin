import 'dart:convert';

import '../../domain/entities/terms_of_use_entity.dart';
import 'privacy_policy_model.dart';


class TermsOfUseModel {
  final String version;
  final String lastUpdated;
  final List<String> summary;
  final List<SectionModel> sections;
  final String? changelog;
  final bool isActive;

  TermsOfUseModel({
    required this.version,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
    this.changelog,
    required this.isActive,
  });

  factory TermsOfUseModel.fromJson(Map<String, dynamic> json) {
    dynamic _parseJsonField(dynamic field) {
      if (field is String) {
        try {
          return jsonDecode(field);
        } catch (e) {
          return field;
        }
      }
      return field;
    }

    final summaryRaw = json['summary'] ?? [];
    final parsedSummary = _parseJsonField(summaryRaw);
    final summaryList = parsedSummary is List
        ? List<String>.from(parsedSummary)
        : <String>[];

    final sectionsRaw = json['sections'] ?? [];
    final parsedSections = _parseJsonField(sectionsRaw);
    final sectionsList = parsedSections is List
        ? parsedSections
            .map((sectionJson) => SectionModel.fromMap(sectionJson))
            .toList()
        : <SectionModel>[];

    return TermsOfUseModel(
      version: json['version'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
      summary: summaryList,
      sections: sectionsList,
      changelog: json['changelog'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  TermsOfUseEntity toEntity() {
    return TermsOfUseEntity(
      version: version,
      lastUpdated: DateTime.parse(lastUpdated),
      summary: summary,
      sections: sections.map((model) => model.toEntity()).toList(),
      changelog: changelog,
      isActive: isActive,
    );
  }
}
