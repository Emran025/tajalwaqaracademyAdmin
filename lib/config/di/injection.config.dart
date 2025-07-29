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
import 'package:tajalwaqaracademy/features/HalqasManagement/data/datasources/auth_local_data_source.dart'
    as _i761;
import 'package:tajalwaqaracademy/features/HalqasManagement/data/datasources/auth_local_data_source_impl.dart'
    as _i292;
import 'package:tajalwaqaracademy/features/HalqasManagement/data/datasources/auth_remote_data_source.dart'
    as _i663;
import 'package:tajalwaqaracademy/features/HalqasManagement/data/datasources/auth_remote_data_source_impl.dart'
    as _i885;
import 'package:tajalwaqaracademy/features/HalqasManagement/data/repositories_impl/auth_repository_impl.dart'
    as _i645;
import 'package:tajalwaqaracademy/features/HalqasManagement/domain/repositories/auth_repository.dart'
    as _i24;
import 'package:tajalwaqaracademy/features/HalqasManagement/domain/usecases/login_usecase.dart'
    as _i1063;
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
    final registerModule = _$RegisterModule();
    final blocModule = _$BlocModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
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
    gh.lazySingleton<_i44.BackgroundJobService>(
      () => _i870.WorkmanagerJobServiceImpl(),
    );
    gh.lazySingleton<_i1057.AuthLocalDataSource>(
      () => _i796.AuthLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    await gh.factoryAsync<_i779.Database>(
      () => registerModule.database(gh<_i788.AppDatabase>()),
      preResolve: true,
    );
    gh.lazySingleton<_i395.StudentLocalDataSource>(
      () => _i937.StudentLocalDataSourceImpl(database: gh<_i779.Database>()),
    );
    gh.lazySingleton<_i1.NetworkInfo>(
      () => _i81.NetworkInfoImpl(
        connectionChecker: gh<_i161.InternetConnection>(),
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
    gh.lazySingleton<_i761.AuthLocalDataSource>(
      () => _i292.AuthLocalDataSourceImpl(gh<_i779.Database>()),
    );
    gh.lazySingleton<_i478.ApiConsumer>(
      () => registerModule.apiConsumer(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i133.StudentRemoteDataSource>(
      () => _i217.StudentRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i663.AuthRemoteDataSource>(
      () => _i885.AuthRemoteDataSourceImpl(gh<_i478.ApiConsumer>()),
    );
    gh.lazySingleton<_i668.StudentSyncService>(
      () => _i411.StudentSyncServiceImpl(
        remoteDataSource: gh<_i133.StudentRemoteDataSource>(),
        localDataSource: gh<_i395.StudentLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i665.TeacherRemoteDataSource>(
      () => _i275.TeacherRemoteDataSourceImpl(
        apiConsumer: gh<_i478.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i52.AuthRemoteDataSource>(
      () => _i512.AuthRemoteDataSourceImpl(gh<_i478.ApiConsumer>()),
    );
    gh.lazySingleton<_i24.AuthRepository>(
      () => _i645.AuthRepositoryImpl(
        gh<_i663.AuthRemoteDataSource>(),
        gh<_i761.AuthLocalDataSource>(),
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
    gh.lazySingleton<_i847.StudentRepository>(
      () => _i624.StudentRepositoryImpl(
        localDataSource: gh<_i395.StudentLocalDataSource>(),
        syncService: gh<_i668.StudentSyncService>(),
      ),
    );
    gh.lazySingleton<_i335.TeacherSyncService>(
      () => _i651.TeacherSyncServiceImpl(
        remoteDataSource: gh<_i665.TeacherRemoteDataSource>(),
        localDataSource: gh<_i946.TeacherLocalDataSource>(),
        networkInfo: gh<_i1.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i167.WatchStudentsUseCase>(
      () =>
          _i167.WatchStudentsUseCase(repository: gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i567.TeacherRepository>(
      () => _i109.TeacherRepositoryImpl(
        localDataSource: gh<_i946.TeacherLocalDataSource>(),
        syncService: gh<_i335.TeacherSyncService>(),
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
    gh.factory<_i1063.LoginUseCase>(
      () => _i1063.LoginUseCase(gh<_i24.AuthRepository>()),
    );
    gh.lazySingleton<_i306.CheckLoginUseCase>(
      () => _i306.CheckLoginUseCase(gh<_i879.AuthRepository>()),
    );
    gh.lazySingleton<_i912.ForgetPasswordUseCase>(
      () => _i912.ForgetPasswordUseCase(gh<_i879.AuthRepository>()),
    );
    gh.lazySingleton<_i4.LogoutUseCase>(
      () => _i4.LogoutUseCase(gh<_i879.AuthRepository>()),
    );
    gh.factory<_i432.LoginUseCase>(
      () => _i432.LoginUseCase(gh<_i879.AuthRepository>()),
    );
    gh.lazySingleton<_i358.SetStudentStatusUseCase>(
      () => _i358.SetStudentStatusUseCase(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i219.DeleteStudentUseCase>(
      () => _i219.DeleteStudentUseCase(gh<_i847.StudentRepository>()),
    );
    gh.lazySingleton<_i754.FetchMoreStudentsUseCase>(
      () => _i754.FetchMoreStudentsUseCase(gh<_i847.StudentRepository>()),
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
    gh.factory<_i294.StudentBloc>(
      () => blocModule.studentBloc(
        gh<_i167.WatchStudentsUseCase>(),
        gh<_i754.FetchMoreStudentsUseCase>(),
        gh<_i223.UpsertStudent>(),
        gh<_i219.DeleteStudentUseCase>(),
        gh<_i358.GetStudentById>(),
        gh<_i358.SetStudentStatusUseCase>(),
      ),
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
    gh.factory<_i1019.AuthBloc>(
      () => blocModule.authBloc(
        gh<_i432.LoginUseCase>(),
        gh<_i306.CheckLoginUseCase>(),
        gh<_i4.LogoutUseCase>(),
        gh<_i912.ForgetPasswordUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i409.RegisterModule {}

class _$BlocModule extends _i913.BlocModule {}
