// lib/features/privacy_policy/domain/entities/privacy_policy_entity.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Represents a pure, immutable privacy policy entity.
///
/// This class is a core business object within the Domain layer. It is completely
/// decoupled from data-layer implementation details (like JSON or database
/// formats) and presentation logic. Its immutability ensures that the state is
/// predictable and safe to share across different parts of the application.
@immutable
class PrivacyPolicyEntity {
  /// The unique version identifier for the policy document, e.g., "2025.08.09".
  /// This acts as the canonical ID for the policy.
  final String version;

  /// The exact date and time of the last update to this policy version.
  final DateTime lastUpdated;

  /// A concise list of key summary points, suitable for quick review by the user.
  final List<String> summary;

  /// A detailed list of the full policy sections.
  final List<SectionEntity> sections;

  /// An optional string describing the specific changes made in this version.
  final String? changelog;

  /// Determines whether this policy version requires explicit, new consent from the user.
  final bool requiredConsent;

  /// Creates a constant, immutable instance of a [PrivacyPolicyEntity].
  ///
  /// All primary fields are required to ensure the entity is always in a valid
  /// and complete state upon creation.
  const PrivacyPolicyEntity({
    required this.version,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
    this.changelog,
    required this.requiredConsent,
  });

  /// Creates a new [PrivacyPolicyEntity] instance with updated fields.
  ///
  /// This method is the conventional way to "modify" an immutable object. It produces
  /// a new copy of the entity, replacing only the fields that are provided.
  ///
  /// Example:
  /// `final updatedPolicy = originalPolicy.copyWith(requiredConsent: true);`
  PrivacyPolicyEntity copyWith({
    String? version,
    DateTime? lastUpdated,
    List<String>? summary,
    List<SectionEntity>? sections,
    String? changelog,
    bool? requiredConsent,
  }) {
    return PrivacyPolicyEntity(
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      summary: summary ?? this.summary,
      sections: sections ?? this.sections,
      changelog: changelog ?? this.changelog,
      requiredConsent: requiredConsent ?? this.requiredConsent,
    );
  }

  /// Provides a human-readable string representation of the object, useful for debugging.
  @override
  String toString() {
    return 'PrivacyPolicyEntity(version: $version, lastUpdated: $lastUpdated, summary: $summary, sections: $sections, changelog: $changelog, requiredConsent: $requiredConsent)';
  }

  /// Overrides the default equality operator to enable value-based comparison.
  ///
  /// Two [PrivacyPolicyEntity] instances are considered equal if all their
  /// corresponding properties, including the contents of their lists, are equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // The ListEquality comparator from `package:collection` is essential for
    // deep-checking the contents of the lists, rather than just their references.
    const listEquals = ListEquality();

    return other is PrivacyPolicyEntity &&
        other.version == version &&
        other.lastUpdated == lastUpdated &&
        listEquals.equals(other.summary, summary) &&
        listEquals.equals(other.sections, sections) &&
        other.changelog == changelog &&
        other.requiredConsent == requiredConsent;
  }

  /// Provides a hash code that is consistent with the value-based equality check.
  ///
  /// This is crucial for the correct functioning of hash-based collections like
  /// [Set] and [Map].
  @override
  int get hashCode {
    const listEquals = ListEquality();
    
    return version.hashCode ^
        lastUpdated.hashCode ^
        listEquals.hash(summary) ^
        listEquals.hash(sections) ^
        changelog.hashCode ^
        requiredConsent.hashCode;
  }
}

// =========================================================================

/// Represents a pure, immutable section within a [PrivacyPolicyEntity].
///
/// As a core domain object, it is decoupled from any data or presentation
/// layer concerns.
@immutable
class SectionEntity {
  /// The title of the policy section (e.g., "How We Use Your Data").
  final String title;

  /// The full, detailed content of this specific section.
  final String content;

  /// Creates a constant, immutable instance of a [SectionEntity].
  const SectionEntity({
    required this.title,
    required this.content,
  });

  /// Creates a new [SectionEntity] instance with updated fields.
  SectionEntity copyWith({
    String? title,
    String? content,
  }) {
    return SectionEntity(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  String toString() => 'SectionEntity(title: $title, content: $content)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SectionEntity &&
      other.title == title &&
      other.content == content;
  }

  @override
  int get hashCode => title.hashCode ^ content.hashCode;
}