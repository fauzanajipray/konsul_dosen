import 'package:equatable/equatable.dart';
import 'package:konsul_dosen/features/auth/model/user_login.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.status = LoadStatus.initial,
    this.user,
    this.error,
  });

  final LoadStatus status;
  final UserLogin? user;
  final String? error;

  RegisterState copyWith(
      {LoadStatus? status,
      Map<String, dynamic>? data,
      String? error,
      UserLogin? user}) {
    return RegisterState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}
