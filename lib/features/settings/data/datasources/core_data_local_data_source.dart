// lib/features/settings/data/datasources/core_data_local_data_source.dart

import 'package:tajalwaqaracademy/features/settings/data/models/faq_model.dart';
import 'package:tajalwaqaracademy/features/settings/data/models/privacy_policy_model.dart';
import 'package:tajalwaqaracademy/features/settings/data/models/terms_of_use_model.dart';

abstract class CoreDataLocalDataSource {
  Future<PrivacyPolicyModel?> getLatestPolicy(int userId);
  Future<void> cachePolicy(int userId, PrivacyPolicyModel policy);

  Future<TermsOfUseModel?> getLatestTerms(int userId);
  Future<void> cacheTerms(int userId, TermsOfUseModel terms);

  Future<List<FaqModel>> getFaqs(int userId);
  Future<void> cacheFaqs(int userId, List<FaqModel> faqs);
}
