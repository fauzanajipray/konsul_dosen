// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/utils/load_status.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  Future<void> login(
      String email, String password, String nama, String nisn) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      ///
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      // Create user document in Firestore collection "users"
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userCredential.user!.uid)
      //     .set({
      //   'nama': nama,
      //   'nisn': nisn,
      //   // Add more fields as needed
      // });

      emit(state.copyWith(
        status: LoadStatus.success,
        userCredential: userCredential,
        error: null,
      ));
    } on FirebaseAuthException catch (e) {
      String? errorMsg = '';
      if (e.code == 'weak-password') {
        errorMsg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'The account already exists for that email.';
      } else {
        errorMsg = e.message;
      }
      emit(state.copyWith(status: LoadStatus.failure, error: errorMsg));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}

class RegisterState extends Equatable {
  const RegisterState({
    this.status = LoadStatus.initial,
    this.userCredential,
    this.error,
  });

  final LoadStatus status;
  final UserCredential? userCredential;
  final String? error;

  RegisterState copyWith(
      {LoadStatus? status,
      Map<String, dynamic>? data,
      String? error,
      UserCredential? userCredential}) {
    return RegisterState(
      status: status ?? this.status,
      userCredential: userCredential ?? this.userCredential,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, userCredential, error];
}
