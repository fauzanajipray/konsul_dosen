import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/auth/model/all_user.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // search from collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      AllUser userLogin = AllUser.fromJson(userData);
      if (userLogin.type == "dosen") {
        emit(state.copyWith(
            status: LoadStatus.success,
            user: userCredential.user,
            userId: userCredential.user!.uid,
            data: userLogin));
      } else {
        throw FirebaseAuthException(
            code: 'invalid-credential', message: 'Invalid Credential');
      }
    } on FirebaseAuthException catch (e) {
      String? errorMsg = '';
      if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid Credential';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'The account already exists for that email.';
      } else {
        errorMsg = e.message;
      }
      emit(state.copyWith(status: LoadStatus.failure, error: errorMsg));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoadStatus.initial,
    this.user,
    this.userId,
    this.data,
    this.error,
  });

  final LoadStatus status;
  final User? user;
  final String? userId;
  final AllUser? data;
  final String? error;

  LoginState copyWith({
    LoadStatus? status,
    User? user,
    String? userId,
    AllUser? data,
    String? error,
  }) {
    return LoginState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, userId, user, data, error];
}
