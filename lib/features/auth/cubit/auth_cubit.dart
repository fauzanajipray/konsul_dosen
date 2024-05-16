import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:konsul_dosen/features/auth/model/user_login.dart';
import 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState());

  void setUnauthenticated() {
    emit(state.copyWith(status: AuthStatus.unauthenticated, data: false));
  }

  void setAuthenticated(UserLogin? data) {
    emit(state.copyWith(status: AuthStatus.authenticated, data: data));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState(
        data: UserLogin.fromJson(json),
      );

  @override
  Map<String, dynamic>? toJson(AuthState state) => {
        'data': state.data?.toRawJson(),
      };
}
