import 'dart:convert';

import '../../domain/entities/privacy_policy_entity.dart';

/// Represents the entire privacy policy document within the data layer.
///
/// This model is designed to interface directly with data sources, particularly
/// a local SQLite database. It expertly handles the complexity of serializing
/// complex data types (like lists of objects) into formats suitable for storage
/// (e.g., JSON strings) and deserializing them back into structured Dart objects.
class PrivacyPolicyModel {
  /// The unique version identifier for the policy document.
  final String version;

  /// The date of the last update, stored as a string.
  final String lastUpdated;

  /// A structured list of summary points.
  final List<String> summary;

  /// A structured list of detailed policy sections.
  final List<SectionModel> sections;

  /// An optional string describing the changes in this version.
  final String? changelog;

  /// A boolean indicating if this policy version requires new user consent.
  final bool requiredConsent;

  /// Creates a [PrivacyPolicyModel] instance.
  PrivacyPolicyModel({
    required this.version,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
    this.changelog,
    required this.requiredConsent,
  });

  /// Creates a [PrivacyPolicyModel] from a JSON map (from a remote API).
  ///
  /// This factory is designed to parse the structured JSON response typically
  /// received from a web server. It handles cases where nested JSON structures
  /// may be returned as JSON strings rather than direct objects, which can occur
  /// with certain database configurations or API implementations.
  ///
  /// The method automatically detects and parses JSON strings for 'summary'
  /// and 'sections' fields, and maps field names from API snake_case to
  /// Dart camelCase conventions.
  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse JSON strings if needed
    dynamic _parseJsonField(dynamic field) {
      if (field is String) {
        try {
          return jsonDecode(field);
        } catch (e) {
          // If decoding fails, return the original string
          return field;
        }
      }
      return field;
    }

    // Parse summary field - could be List or JSON string
    final summaryRaw = json['summary'] ?? [];
    final parsedSummary = _parseJsonField(summaryRaw);
    final summaryList = parsedSummary is List
        ? List<String>.from(parsedSummary)
        : <String>[];

    // Parse sections field - could be List or JSON string
    final sectionsRaw = json['sections'] ?? [];
    final parsedSections = _parseJsonField(sectionsRaw);
    final sectionsList = parsedSections is List
        ? parsedSections
              .map((sectionJson) => SectionModel.fromMap(sectionJson))
              .toList()
        : <SectionModel>[];

    return PrivacyPolicyModel(
      version: json['version'] as String? ?? '',
      // Handle both camelCase and snake_case field names
      lastUpdated:
          json['lastUpdated'] as String? ??
          json['last_updated'] as String? ??
          '',
      summary: summaryList,
      sections: sectionsList,
      changelog: json['changelog'] as String?,
      // Handle both field naming conventions for consent
      requiredConsent:
          json['requiredConsent'] as bool? ??
          json['is_active'] as bool? ??
          true,
    );
  }

  /// Creates a [PrivacyPolicyModel] from a database map record.
  ///
  /// This factory is crucial for hydrating the model from a local SQLite database,
  /// where nested lists are stored as JSON-encoded strings. It deserializes
  /// `summaryJson` and `sectionsJson` text fields into structured Dart lists.
  factory PrivacyPolicyModel.fromMap(Map<String, dynamic> map) {
    return PrivacyPolicyModel(
      version: map['version'],
      lastUpdated: map['lastUpdated'],
      summary: (jsonDecode(map['summaryJson']) as List)
          .map((item) => item.toString())
          .toList(),
      sections: (jsonDecode(map['sectionsJson']) as List)
          .map((item) => SectionModel.fromMap(item))
          .toList(),
      changelog: map['changelog'],
      requiredConsent: map['requiredConsent'] == 1,
    );
  }

  /// Converts the [PrivacyPolicyModel] instance into a map for database storage.
  ///
  /// This method serializes the `summary` and `sections` lists into JSON strings
  /// (`summaryJson` and `sectionsJson` respectively) to be stored in single `TEXT`
  /// columns in the SQLite database.
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'lastUpdated': lastUpdated,
      'summaryJson': jsonEncode(summary),
      'sectionsJson': jsonEncode(sections.map((s) => s.toMap()).toList()),
      'changelog': changelog,
      'requiredConsent': requiredConsent ? 1 : 0,
    };
  }

  /// Maps the data-layer [PrivacyPolicyModel] to a domain-layer [PrivacyPolicyEntity].
  ///
  /// This conversion transforms the data-centric model into the application's
  /// core business object. It also handles data type conversions, such as
  /// parsing the `lastUpdated` string into a `DateTime` object and mapping
  /// the nested `SectionModel` list to a `SectionEntity` list.
  PrivacyPolicyEntity toEntity() {
    return PrivacyPolicyEntity(
      version: version,
      lastUpdated: DateTime.parse(lastUpdated),
      summary: summary,
      sections: sections.map((model) => model.toEntity()).toList(),
      changelog: changelog,
      requiredConsent: requiredConsent,
    );
  }
}

/// Represents a single section of the privacy policy within the data layer.
///
/// This class acts as a data transfer object (DTO) that can be easily
/// serialized to and deserialized from a map structure (like JSON). It serves
/// as an intermediary between the raw data source and the pure domain [SectionEntity].
class SectionModel {
  /// The title of the policy section (e.g., "Data We Collect").
  final String title;

  /// The detailed content of the policy section.
  final String content;

  /// Creates a [SectionModel] instance.
  SectionModel({required this.title, required this.content});

  /// Creates a [SectionModel] instance from a map.
  ///
  /// This factory is typically used after decoding a JSON object that represents
  /// a single section.
  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(title: map['title'], content: map['content']);
  }

  /// Converts the [SectionModel] instance into a map.
  ///
  /// This is useful for encoding the object into a JSON-compatible format before
  /// storing or transmitting the data.
  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content};
  }

  /// Maps the data-layer [SectionModel] to a domain-layer [SectionEntity].
  ///
  /// This method provides a clean way to convert the data representation
  /// into the pure, immutable business object used by the rest of the application.
  SectionEntity toEntity() {
    return SectionEntity(title: title, content: content);
  }
}
