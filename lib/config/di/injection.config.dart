// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;
import 'package:tajalwaqaracademy/config/di/injection.dart' as _i913;
import 'package:tajalwaqaracademy/config/di/register_module.dart' as _i409;
import 'package:tajalwaqaracademy/core/api/api_consumer.dart' as _i478;
import 'package:tajalwaqaracademy/core/background/background_job_service.dart'
    as _i44;
import 'package:tajalwaqaracademy/core/background/workmanager_job_service_impl.dart'
    as _i870;
import 'package:tajalwaqaracademy/core/database/app_database.dart' as _i788;
import 'package:tajalwaqaracademy/core/network/network_info.dart' as _i1;
import 'package:tajalwaqaracademy/core/network/network_info_impl.dart' as _i81;
import 'package:tajalwaqaracademy/core/services/device_info_service.dart'
    as _i1060;
import 'package:tajalwaqaracademy/core/services/dummy_push_notification_service_impl.dart'
    as _i669;
import 'package:tajalwaqaracademy/core/services/push_notification_service.dart'
    as _i76;
import 'package:tajalwaqaracademy/features/app/cubit/app_setup_cubit.dart'
    as _i120;
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_local_data_source.dart'
    as _i1057;
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_local_data_source_impl.dart'
    as _i796;
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i52;
import 'package:tajalwaqaracademy/features/auth/data/datasources/auth_remote_data_source_impl.dart'
    as _i512;
import 'package:tajalwaqaracademy/features/auth/data/repositories_impl/auth_repository_impl.dart'
    as _i410;
import 'package:tajalwaqaracademy/features/auth/domain/repositories/auth_repository.dart'
    as _i879;
import 'package:tajalwaqaracademy/features/auth/domain/usecases/change_password_usecase.dart'
    as _i566;
import 'package:tajalwaqaracademy/features/auth/domain/usecases/check_login_usecase.dart'
    as _i306;
import 'package:tajalwaqaracademy/features/auth/domain/usecases/forget_password_usecase.dart'
    as _i912;
import 'package:tajalwaqaracademy/features/auth/domain/usecases/login_usecase.dart'
    as _i432;
import 'package:tajalwaqaracademy/features/auth/domain/usecases/logout_usecase.dart'
    as _i4;
import 'package:tajalwaqaracademy/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1019;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/quran_local_data_source.dart'
    as _i1040;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/quran_local_data_source_impl.dart'
    as _i200;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/tracking_local_data_source.dart'
    as _i94;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/tracking_local_data_source_impl.dart'
    as _i390;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/tracking_remote_data_source.dart'
    as _i237;
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/tracking_remote_data_source_impl.dart'
    as _i777;
import 'package:tajalwaqaracademy/features/daily_tracking/data/repositories/quran_repository_impl.dart'
    as _i288;
import 'package:tajalwaqaracademy/features/daily_tracking/data/repositories/tracking_repository_impl.dart'
    as _i81;
import 'package:tajalwaqaracademy/features/daily_tracking/data/services/halaqa_sync_service_impl.dart'
    as _i701;
import 'package:tajalwaqaracademy/features/daily_tracking/data/services/tracking_sync_service.dart'
    as _i1026;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/quran_repository.dart'
    as _i479;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/tracking_repository.dart'
    as _i125;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/finalize_session.dart'
    as _i875;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_all_mistakes.dart'
    as _i664;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_mistakes_ayahs.dart'
    as _i610;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_or_create_today_tracking.dart'
    as _i829;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_page_data.dart'
    as _i768;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/get_surahs_list.dart'
    as _i592;
import 'package:tajalwaqaracademy/features/daily_tracking/domain/usecases/save_task_progress.dart'
    as _i348;
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart'
    as _i1010;
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/tracking_session_bloc.dart'
    as _i8;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/datasources/halaqa_local_data_source.dart'
    as _i825;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/datasources/halaqa_local_data_source_impl.dart'
    as _i721;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/datasources/halaqa_remote_data_source.dart'
    as _i789;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/datasources/halaqa_remote_data_source_impl.dart'
    as _i470;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/repositories_impl/halaqa_repository_impl.dart'
    as _i764;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/services/halaqa_sync_service.dart'
    as _i221;
import 'package:tajalwaqaracademy/features/HalaqasManagement/data/services/halaqa_sync_service_impl.dart'
    as _i23;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/repositories/halaqa_repository.dart'
    as _i253;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/fetch_more_halaqas_usecase.dart'
    as _i586;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/get_filtered_students.dart'
    as _i505;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/get_halaqa_by_id.dart'
    as _i442;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/get_halaqas.dart'
    as _i661;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/halaqa_halaqa_usecase.dart'
    as _i160;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/set_halaqa_status_params.dart'
    as _i717;
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/usecases/upsert_halaqa_usecase.dart'
    as _i1020;
import 'package:tajalwaqaracademy/features/HalaqasManagement/presentation/bloc/halaqa_bloc.dart'
    as _i398;
import 'package:tajalwaqaracademy/features/settings/data/datasources/core_data_local_data_source.dart'
    as _i830;
import 'package:tajalwaqaracademy/features/settings/data/datasources/core_data_local_data_source_impl.dart'
    as _i1010;
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_local_data_source.dart'
    as _i281;
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_local_data_source_impl.dart'
    as _i242;
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_remote_data_source.dart'
    as _i801;
import 'package:tajalwaqaracademy/features/settings/data/datasources/settings_remote_data_source_impl.dart'
    as _i1060;
import 'package:tajalwaqaracademy/features/settings/data/repositories_impl/settings_repository_impl.dart'
    as _i190;
import 'package:tajalwaqaracademy/features/settings/domain/repositories/settings_repository.dart'
    as _i17;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/export_data_usecase.dart'
    as _i632;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_faqs_usecase.dart'
    as _i860;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_latest_policy_usecase.dart'
    as _i311;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_settings.dart'
    as _i959;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_terms_of_use_usecase.dart'
    as _i962;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/get_user_profile.dart'
    as _i604;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/import_data_usecase.dart'
    as _i16;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/save_theme.dart'
    as _i589;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/set_analytics_preference.dart'
    as _i562;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/set_notifications_preference.dart'
    as _i762;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/submit_support_ticket_usecase.dart'
    as _i5;
import 'package:tajalwaqaracademy/features/settings/domain/usecases/update_user_profile.dart'
    as _i577;
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart'
    as _i441;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/datasources/student_local_data_source.dart'
    as _i395;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/datasources/student_local_data_source_impl.dart'
    as _i937;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/datasources/student_remote_data_source.dart'
    as _i133;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/datasources/student_remote_data_source_impl.dart'
    as _i217;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/repositories_impl/student_repository_impl.dart'
    as _i624;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/services/student_sync_service.dart'
    as _i668;
import 'package:tajalwaqaracademy/features/StudentsManagement/data/services/student_sync_service_impl.dart'
    as _i411;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart'
    as _i847;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/delete_student_usecase.dart'
    as _i219;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/fetch_more_student_usecase.dart'
    as _i754;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/generate_follow_up_report_use_case.dart'
    as _i286;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/get_filtered_students.dart'
    as _i45;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/get_student_by_id.dart'
    as _i358;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/get_students.dart'
    as _i167;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/set_student_status_params.dart'
    as _i358;
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/upsert_student_usecase.dart'
    as _i223;
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/bloc/student_bloc.dart'
    as _i294;
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/factories/follow_up_report_factory.dart'
    as _i926;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/datasources/supervisor_local_data_source.dart'
    as _i325;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/datasources/supervisor_local_data_source_impl.dart'
    as _i414;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/datasources/supervisor_remote_data_source.dart'
    as _i277;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/datasources/supervisor_remote_data_source_impl.dart'
    as _i60;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/repositories_impl/repository_impl.dart'
    as _i454;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/service/timeline_builder_impl.dart'
    as _i750;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/repositories/repository.dart'
    as _i795;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/applicants_use_case.dart'
    as _i365;

import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/approve_applicant_usecase.dart'
    as _i674;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/get_applicant_profile_usecase.dart'
    as _i45;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/get_date_range_use_case.dart'
    as _i751;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/get_entities_counts_use_case.dart'
    as _i538;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/usecases/get_timeline_use_case.dart'
    as _i278;
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/bloc/supervisor_bloc.dart'
    as _i692;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/datasources/teacher_local_data_source.dart'
    as _i946;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/datasources/teacher_local_data_source_impl.dart'
    as _i216;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/datasources/teacher_remote_data_source.dart'
    as _i665;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/datasources/teacher_remote_data_source_impl.dart'
    as _i275;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/repositories_impl/teacher_repository_impl.dart'
    as _i109;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/services/teacher_sync_service.dart'
    as _i335;
import 'package:tajalwaqaracademy/features/TeachersManagement/data/services/teacher_sync_service_impl.dart'
    as _i651;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/repositories/teacher_repository.dart'
    as _i567;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/delete_teacher_usecase.dart'
    as _i280;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/fetch_more_teachers_usecase.dart'
    as _i50;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/get_teacher_by_id.dart'
    as _i94;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/get_teachers.dart'
    as _i357;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/set_teacher_status_params.dart'
    as _i825;
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/upsert_teacher_usecase.dart'
    as _i382;
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/bloc/teacher_bloc.dart'
    as _i710;
import 'package:workmanager/workmanager.dart' as _i500;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final blocModule = _$BlocModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i120.AppSetupCubit>(() => blocModule.appSetupCubit());
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i926.FollowUpReportFactory>(
      () => _i926.FollowUpReportFactory(),
    );
    gh.lazySingleton<_i788.AppDatabase>(() => registerModule.appDatabase);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => registerModule.connectionChecker,
    );
    gh.lazySingleton<_i833.DeviceInfoPlugin>(
      () => registerModule.deviceInfoPlugin,
    );
    gh.lazySingleton<_i500.Workmanager>(() => registerModule.workmanager);
    gh.lazySingleton<_i76.PushNotificationService>(
      () => _i669.DummyPushNotificationServiceImpl(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dioForTokenRefreshInstance(),
      instanceName: 'DioForTokenRefresh',
    );
    gh.lazySingleton<_i1060.DeviceInfoService>(
      () => _i1060.DeviceInfoServiceImpl(
        deviceInfoPlugin: gh<_i833.DeviceInfoPlugin>(),
        pushNotificationService: gh<_i76.PushNotificationService>(),
      ),
    );
    gh.lazySingleton<_i1040.QuranLocalDataSource>(
      () => _i200.QuranLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i44.BackgroundJobService>(
      () => _i870.WorkmanagerJobServiceImpl(),
    );
    gh.lazySingleton<_i1057.AuthLocalDataSource>(
      () => _i796.AuthLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i661.WatchHalaqasParams>(
      () => _i661.WatchHalaqasParams(forceRefresh: gh<bool>()),
    );
    gh.factory<_i357.WatchTeachersParams>(
      () => _i357.WatchTeachersParams(forceRefresh: gh<bool>()),
    );
    gh.lazySingleton<_i94.TrackingLocalDataSource>(
      () => _i390.TrackingLocalDataSourceImpl(gh<_i788.AppDatabase>()),
    );
    gh.lazySingleton<_i281.SettingsLocalDataSource>(
      () => _i242.SettingsLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        appDatabase: gh<_i788.AppDatabase>(),
      ),
    );
    await gh.factoryAsync<_i779.Database>(
      () => registerModule.database(gh<_i788.AppDatabase>()),
      preResolve: true,
    );
    gh.lazySingleton<_i395.StudentLocalDataSource>(
      () => _i937.StudentLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i325.SupervisorLocalDataSource>(
      () => _i414.SupervisorLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i830.CoreDataLocalDataSource>(
      () => _i1010.CoreDataLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i1.NetworkInfo>(
      () => _i81.NetworkInfoImpl(
        connectionChecker: gh<_i161.InternetConnection>(),
      ),
    );
    gh.lazySingleton<_i125.TrackingRepository>(
      () => _i81.TrackingRepositoryImpl(
        localDataSource: gh<_i94.TrackingLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i946.TeacherLocalDataSource>(
      () => _i216.TeacherLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i361.Dio>(instanceName: 'DioForTokenRefresh'),
      ),
    );
    gh.lazySingleton<_i875.FinalizeSession>(
      () => _i875.FinalizeSession(gh<_i125.TrackingRepository>()),
    );
    gh.lazySingleton<_i664.GetAllMistakes>(
      () => _i664.GetAllMistakes(gh<_i125.TrackingRepository>()),
    );
    gh.lazySingleton<_i829.GetOrCreateTodayTrackingDetails>(
      () =>
          _i829.GetOrCreateTodayTrackingDetails(gh<_i125.TrackingRepository>()),
    );
    gh.lazySingleton<_i348.SaveTaskProgress>(
      () => _i348.SaveTaskProgress(gh<_i125.TrackingRepository>()),
    );
    gh.lazySingleton<_i479.QuranRepository>(
      () => _i288.QuranRepositoryImpl(
        localDataSource: gh<_i1040.QuranLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i478.ApiConsumer>(
      () => registerModule.apiConsumer(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i789.HalaqaRemoteDataSource>(
      () => _i470.HalaqaRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i133.StudentRemoteDataSource>(
      () => _i217.StudentRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i237.TrackingRemoteDataSource>(
      () => _i777.TrackingRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i801.SettingsRemoteDataSource>(
      () => _i1060.SettingsRemoteDataSourceImpl(api: gh<_i478.ApiConsumer>()),
    );
    gh.factory<_i750.TimelineBuilderImpl>(
      () => _i750.TimelineBuilderImpl(
        localDataSource: gh<_i325.SupervisorLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i825.HalaqaLocalDataSource>(
      () => _i721.HalaqaLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i610.GetMistakesAyahs>(
      () => _i610.GetMistakesAyahs(repository: gh<_i479.QuranRepository>()),
    );
    gh.lazySingleton<_i768.GetPageData>(
      () => _i768.GetPageData(repository: gh<_i479.QuranRepository>()),
    );
    gh.lazySingleton<_i592.GetSurahsList>(
      () => _i592.GetSurahsList(repository: gh<_i479.QuranRepository>()),
    );
    gh.factory<_i1010.QuranReaderBloc>(
      () => blocModule.quranReaderBloc(
        gh<_i592.GetSurahsList>(),
        gh<_i610.GetMistakesAyahs>(),
        gh<_i768.GetPageData>(),
      ),
    );
    gh.lazySingleton<_i668.StudentSyncService>(
      () => _i411.StudentSyncServiceImpl(
        remoteDataSource: gh<_i133.StudentRemoteDataSource>(),
        localDataSource: gh<_i395.StudentLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.factory<_i8.TrackingSessionBloc>(
      () => blocModule.trackingSession(
        gh<_i829.GetOrCreateTodayTrackingDetails>(),
        gh<_i348.SaveTaskProgress>(),
        gh<_i875.FinalizeSession>(),
        gh<_i664.GetAllMistakes>(),
      ),
    );
    gh.lazySingleton<_i221.HalaqaSyncService>(
      () => _i23.HalaqaSyncServiceImpl(
        remoteDataSource: gh<_i789.HalaqaRemoteDataSource>(),
        localDataSource: gh<_i825.HalaqaLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i277.SupervisorRemoteDataSource>(
      () => _i60.SupervisorRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i665.TeacherRemoteDataSource>(
      () => _i275.TeacherRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i253.HalaqaRepository>(
      () => _i764.HalaqaRepositoryImpl(
        localDataSource: gh<_i825.HalaqaLocalDataSource>(),
        syncService: gh<_i221.HalaqaSyncService>(),
      ),
    );
    gh.lazySingleton<_i52.AuthRemoteDataSource>(
      () => _i512.AuthRemoteDataSourceImpl(gh<_i478.ApiConsumer>()),
    );
    gh.lazySingleton<_i1026.TrackingSyncService>(
      () => _i701.TrackingSyncServiceImpl(
        remoteDataSource: gh<_i237.TrackingRemoteDataSource>(),
        localDataSource: gh<_i94.TrackingLocalDataSource>(),
        studentLocalDataSource: gh<_i395.StudentLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i586.FetchMoreHalaqasUseCase>(
      () => _i586.FetchMoreHalaqasUseCase(gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i505.FetchFilteredHalaqasUseCase>(
      () => _i505.FetchFilteredHalaqasUseCase(gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i442.GetHalaqaById>(
      () => _i442.GetHalaqaById(gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i160.DeleteHalaqaUseCase>(
      () => _i160.DeleteHalaqaUseCase(gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i1020.UpsertHalaqa>(
      () => _i1020.UpsertHalaqa(gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i17.SettingsRepository>(
      () => _i190.SettingsRepositoryImpl(
        localDataSource: gh<_i281.SettingsLocalDataSource>(),
        remoteDataSource: gh<_i801.SettingsRemoteDataSource>(),
        coreDataSource: gh<_i830.CoreDataLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i879.AuthRepository>(
      () => _i410.AuthRepositoryImpl(
        remoteDataSource: gh<_i52.AuthRemoteDataSource>(),
        localDataSource: gh<_i1057.AuthLocalDataSource>(),
        deviceInfoService: gh<_i1060.DeviceInfoService>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i661.WatchHalaqasUseCase>(
      () => _i661.WatchHalaqasUseCase(repository: gh<_i253.HalaqaRepository>()),
    );
    gh.lazySingleton<_i335.TeacherSyncService>(
      () => _i651.TeacherSyncServiceImpl(
        remoteDataSource: gh<_i665.TeacherRemoteDataSource>(),
        localDataSource: gh<_i946.TeacherLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i311.GetLatestPolicyUseCase>(
      () => _i311.GetLatestPolicyUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i959.GetSettings>(
      () => _i959.GetSettings(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i604.GetUserProfile>(
      () => _i604.GetUserProfile(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i589.SaveTheme>(
      () => _i589.SaveTheme(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i562.SetAnalyticsPreference>(
      () => _i562.SetAnalyticsPreference(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i762.SetNotificationsPreference>(
      () => _i762.SetNotificationsPreference(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i577.UpdateUserProfile>(
      () => _i577.UpdateUserProfile(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i567.TeacherRepository>(
      () => _i109.TeacherRepositoryImpl(
        localDataSource: gh<_i946.TeacherLocalDataSource>(),
        syncService: gh<_i335.TeacherSyncService>(),
      ),
    );
    gh.lazySingleton<_i847.StudentRepository>(
      () => _i624.StudentRepositoryImpl(
        localDataSource: gh<_i395.StudentLocalDataSource>(),
        remoteDataSource: gh<_i133.StudentRemoteDataSource>(),
        syncService: gh<_i668.StudentSyncService>(),
      ),
    );
    gh.lazySingleton<_i280.DeleteTeacherUseCase>(
      () => _i280.DeleteTeacherUseCase(gh<_i567.TeacherRepository>()),
    );
    gh.lazySingleton<_i50.FetchMoreTeachersUseCase>(
      () => _i50.FetchMoreTeachersUseCase(gh<_i567.TeacherRepository>()),
    );
    gh.lazySingleton<_i94.GetTeacherById>(
      () => _i94.GetTeacherById(gh<_i567.TeacherRepository>()),
    );
    gh.lazySingleton<_i382.UpsertTeacher>(
      () => _i382.UpsertTeacher(gh<_i567.TeacherRepository>()),
    );
    gh.lazySingleton<_i795.SupervisorRepository>(
      () => _i454.SupervisorRepositoryImpl(
        localDataSource: gh<_i325.SupervisorLocalDataSource>(),
        remoteDataSource: gh<_i277.SupervisorRemoteDataSource>(),
        timelineBuilder: gh<_i750.TimelineBuilderImpl>(),
      ),
    );
    gh.lazySingleton<_i632.ExportDataUseCase>(
      () => _i632.ExportDataUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i16.ImportDataUseCase>(
      () => _i16.ImportDataUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i860.GetFaqsUseCase>(
      () => _i860.GetFaqsUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i962.GetTermsOfUseUseCase>(
      () => _i962.GetTermsOfUseUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i5.SubmitSupportTicketUseCase>(
      () => _i5.SubmitSupportTicketUseCase(gh<_i17.SettingsRepository>()),
    );
    gh.lazySingleton<_i717.SetHalaqaStatusUseCase>(
      () => _i717.SetHalaqaStatusUseCase(gh<_i253.HalaqaRepository>()),
    );
    gh.factory<_i674.ApproveApplicantUseCase>(
      () => _i674.ApproveApplicantUseCase(gh<_i795.SupervisorRepository>()),
    );
    gh.factory<_i45.GetApplicantProfileUseCase>(
      () => _i45.GetApplicantProfileUseCase(gh<_i795.SupervisorRepository>()),
    );
    gh.lazySingleton<_i751.GetDateRangeUseCase>(
      () => _i751.GetDateRangeUseCase(
        repository: gh<_i795.SupervisorRepository>(),
      ),
    );
    gh.lazySingleton<_i538.GetEntitiesCountsUseCase>(
      () => _i538.GetEntitiesCountsUseCase(
        repository: gh<_i795.SupervisorRepository>(),
      ),
    );
    gh.lazySingleton<_i278.GetTimelineUseCase>(
      () => _i278.GetTimelineUseCase(
        repository: gh<_i795.SupervisorRepository>(),
      ),
    );
    gh.lazySingleton<_i566.ChangePasswordUseCase>(
      () => _i566.ChangePasswordUseCase(gh<_i879.AuthRepository>()),
    );
    gh.lazySingleton<_i306.CheckLogInUseCase>(
      () => _i306.CheckLogInUseCase(gh<_i879.AuthRepository>()),
    );
    gh.factory<_i912.ForgetPasswordUseCase>(
      () => _i912.ForgetPasswordUseCase(gh<_i879.AuthRepository>()),
    );
    gh.factory<_i432.LogInUseCase>(
      () => _i432.LogInUseCase(gh<_i879.AuthRepository>()),
    );
    gh.factory<_i4.LogOutUseCase>(
      () => _i4.LogOutUseCase(gh<_i879.AuthRepository>()),
    );
    gh.lazySingleton<_i358.SetStudentStatusUseCase>(
      () => _i358.SetStudentStatusUseCase(gh<_i847.StudentRepository>()),
    );
    gh.factory<_i398.HalaqaBloc>(
      () => blocModule.halaqaBloc(
        gh<_i661.WatchHalaqasUseCase>(),
        gh<_i586.FetchMoreHalaqasUseCase>(),
        gh<_i505.FetchFilteredHalaqasUseCase>(),
        gh<_i1020.UpsertHalaqa>(),
        gh<_i160.DeleteHalaqaUseCase>(),
        gh<_i442.GetHalaqaById>(),
        gh<_i717.SetHalaqaStatusUseCase>(),
      ),
    );
    gh.factory<_i365.GetApplicantsUseCase>(
      () => _i365.GetApplicantsUseCase(gh<_i795.SupervisorRepository>()),
    );
    gh.lazySingleton<_i219.DeleteStudentUseCase>(
      () => _i219.DeleteStudentUseCase(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i754.FetchMoreStudentsUseCase>(
      () => _i754.FetchMoreStudentsUseCase(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i45.FetchFilteredStudentsUseCase>(
      () => _i45.FetchFilteredStudentsUseCase(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i358.GetStudentById>(
      () => _i358.GetStudentById(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i223.UpsertStudent>(
      () => _i223.UpsertStudent(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i357.WatchTeachersUseCase>(
      () =>
          _i357.WatchTeachersUseCase(repository: gh<_i567.TeacherRepository>()),
    );
    gh.lazySingleton<_i286.GenerateFollowUpReportUseCase>(
      () => _i286.GenerateFollowUpReportUseCase(
        gh<_i847.StudentRepository>(),
        gh<_i926.FollowUpReportFactory>(),
      ),
    );
    gh.lazySingleton<_i167.WatchStudentsUseCase>(
      () =>
          _i167.WatchStudentsUseCase(repository: gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i825.SetTeacherStatusUseCase>(
      () => _i825.SetTeacherStatusUseCase(gh<_i567.TeacherRepository>()),
    );
    gh.factory<_i710.TeacherBloc>(
      () => blocModule.teacherBloc(
        gh<_i357.WatchTeachersUseCase>(),
        gh<_i50.FetchMoreTeachersUseCase>(),
        gh<_i382.UpsertTeacher>(),
        gh<_i280.DeleteTeacherUseCase>(),
        gh<_i94.GetTeacherById>(),
        gh<_i825.SetTeacherStatusUseCase>(),
      ),
    );
    gh.factory<_i441.SettingsBloc>(
      () => blocModule.settingsBloc(
        gh<_i959.GetSettings>(),
        gh<_i589.SaveTheme>(),
        gh<_i762.SetNotificationsPreference>(),
        gh<_i562.SetAnalyticsPreference>(),
        gh<_i604.GetUserProfile>(),
        gh<_i577.UpdateUserProfile>(),
        gh<_i311.GetLatestPolicyUseCase>(),
        gh<_i16.ImportDataUseCase>(),
        gh<_i632.ExportDataUseCase>(),
        gh<_i860.GetFaqsUseCase>(),
        gh<_i5.SubmitSupportTicketUseCase>(),
        gh<_i962.GetTermsOfUseUseCase>(),
      ),
    );
    gh.factory<_i692.SupervisorBloc>(
      () => blocModule.supervisorBloc(
        gh<_i278.GetTimelineUseCase>(),
        gh<_i751.GetDateRangeUseCase>(),
        gh<_i538.GetEntitiesCountsUseCase>(),
        gh<_i365.GetApplicantsUseCase>(),
      ),
    );
    gh.factory<_i1019.AuthBloc>(
      () => blocModule.authBloc(
        gh<_i432.LogInUseCase>(),
        gh<_i306.CheckLogInUseCase>(),
        gh<_i4.LogOutUseCase>(),
        gh<_i912.ForgetPasswordUseCase>(),
        gh<_i566.ChangePasswordUseCase>(),
      ),
    );
    gh.factory<_i692.SupervisorBloc>(
      () => blocModule.supervisorBloc(
        gh<_i278.GetTimelineUseCase>(),
        gh<_i751.GetDateRangeUseCase>(),
        gh<_i538.GetEntitiesCountsUseCase>(),
        gh<_i365.GetApplicantsUseCase>(),
        gh<_i45.GetApplicantProfileUseCase>(),
        gh<_i674.ApproveApplicantUseCase>(),
      ),
    );
    gh.factory<_i294.StudentBloc>(
      () => blocModule.studentBloc(
        gh<_i167.WatchStudentsUseCase>(),
        gh<_i754.FetchMoreStudentsUseCase>(),
        gh<_i45.FetchFilteredStudentsUseCase>(),
        gh<_i223.UpsertStudent>(),
        gh<_i219.DeleteStudentUseCase>(),
        gh<_i358.GetStudentById>(),
        gh<_i358.SetStudentStatusUseCase>(),
        gh<_i286.GenerateFollowUpReportUseCase>(),
      ),
    );
    return this;
  }
}

class _$BlocModule extends _i913.BlocModule {}

class _$RegisterModule extends _i409.RegisterModule {}
