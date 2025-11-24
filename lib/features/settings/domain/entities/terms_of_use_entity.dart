import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/privacy_policy_entity.dart';

class TermsOfUseEntity extends Equatable {
  final String version;
  final DateTime lastUpdated;
  final List<String> summary;
  final List<SectionEntity> sections;
  final String? changelog;
  final bool isActive;

  const TermsOfUseEntity({
    required this.version,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
    this.changelog,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        version,
        lastUpdated,
        summary,
        sections,
        changelog,
        isActive,
      ];
}
