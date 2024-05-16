import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:konsul_dosen/features/auth/model/user_login.dart';

enum AuthStatus {
  initial,
  loading,
  reloading,
  authenticated,
  unauthenticated,
  failure
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.data,
    this.error,
  });

  final AuthStatus status;
  final UserLogin? data;
  final DioException? error;

  AuthState copyWith({
    AuthStatus? status,
    dynamic? data,
    DioException? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      data: _setData(data),
      error: error ?? this.error,
    );
  }

  UserLogin? _setData(dynamic selectedData) {
    if (selectedData is bool) {
      return null;
    } else {
      if (selectedData is UserLogin) {
        return selectedData;
      } else {
        return data;
      }
    }
  }

  @override
  List<Object?> get props => [
        status,
        data,
        error,
      ];
}
