import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/auth/cubit/register_state.dart';
import 'package:konsul_dosen/features/auth/model/user_login.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  Future<void> register(
      String email, String password, String nama, String nisn) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'name': nama,
          'nisn': nisn,
          'type': 'dosen',
        });
      }

      emit(state.copyWith(
        status: LoadStatus.success,
        user: UserLogin(email: email, name: nama, nisn: nisn),
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
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}
