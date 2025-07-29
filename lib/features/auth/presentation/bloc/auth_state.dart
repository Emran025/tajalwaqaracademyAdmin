import 'package:tajalwaqaracademy/features/auth/domain/entities/user_entity.dart';

import '../../../../core/entities/success_entity.dart';
import '../../data/models/states_modle.dart';
class AuthState {}

final class AuthInitial extends AuthState {}

final class UploadProfilePic extends AuthState {}

/* 
+---------------------------------------------------------------------------+
|                           States of Sign In                               |
+---------------------------------------------------------------------------+
 */

final class LoginLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final UserEntity userEntity;

  LoginSuccess({required this.userEntity});
}

final class LoginFailure extends AuthState {
  final String message;

  LoginFailure({required this.message});
}



/* 
+---------------------------------------------------------------------------+
|                           States of Sign Up                               |
+---------------------------------------------------------------------------+
*/

final class SignUpLoading extends AuthState {}

final class SignUpSuccess extends AuthState {
  final UserEntity userEntity;

  SignUpSuccess({required this.userEntity});
}

final class SignUpFailure extends AuthState {
  final String message;

  SignUpFailure({required this.message});
}





/* 
+---------------------------------------------------------------------------+
|                           States of Ubdate PassWord                       |
+---------------------------------------------------------------------------+
*/

final class ForgetPasswordLoading extends AuthState {}

final class ForgetPasswordSuccess extends AuthState {
  final SuccessEntity successEntity;

  ForgetPasswordSuccess({required this.successEntity});
}

final class ForgetPasswordFailure extends AuthState {
  final String message;

  ForgetPasswordFailure({required this.message});
}
/* 
+---------------------------------------------------------------------------+
|                           States of counteris                             |
+---------------------------------------------------------------------------+
*/

/* 
+---------------------------------------------------------------------------+
|                           States of States                                |
+---------------------------------------------------------------------------+
*/

final class StatesLoading extends AuthState {}

final class StatesSuccess extends AuthState {
  final StatesModel statesModel;

  StatesSuccess({required this.statesModel});
}

final class StatesFailure extends AuthState {
  final String message;

  StatesFailure({required this.message});
}

/* 
+---------------------------------------------------------------------------+
|                           States of Get Auth Date                         |
+---------------------------------------------------------------------------+
*/

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final bool auth;

  AuthSuccess({required this.auth});
}

final class AuthFailure extends AuthState {
}

/* 
+---------------------------------------------------------------------------+
|                           States of Get Auth Date                         |
+---------------------------------------------------------------------------+
*/

final class GetUserLoading extends AuthState {}

final class GetUserSuccess extends AuthState {
  final UserEntity usreEntity;

  GetUserSuccess({required this.usreEntity});
}

final class GetUserFailure extends AuthState {
  final String message;

  GetUserFailure({required this.message});
}


