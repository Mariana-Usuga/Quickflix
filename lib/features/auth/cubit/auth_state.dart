// lib/features/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final Profile? profile;
  AuthSuccess(this.user, {this.profile});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class Unauthenticated extends AuthState {}
