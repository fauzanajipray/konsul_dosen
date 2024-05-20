import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:konsul_dosen/features/auth/model/user_login.dart';
import 'package:konsul_dosen/utils/enum_values.dart';

enum AuthStatus {
  initial,
  loading,
  reloading,
  authenticated,
  unauthenticated,
  failure
}

final authStatusValues = EnumValues({
  "authenticated": AuthStatus.authenticated,
  "unauthenticated": AuthStatus.unauthenticated,
});

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.userId = '',
    this.name = '',
    this.error,
  });

  final AuthStatus status;
  final String? userId;
  final String? name;
  final DioException? error;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? name,
    DioException? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, name, userId, error];
}
