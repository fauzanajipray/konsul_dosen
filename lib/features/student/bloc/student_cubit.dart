import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/auth/model/all_user.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class StudentCubit extends Cubit<DataState<AllUser>> {
  StudentCubit() : super(const DataState());

  Future<void> get(String uid) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      AllUser alluser = AllUser.fromJson(userData);

      emit(state.copyWith(
          status: LoadStatus.success,
          data: userData,
          item: alluser.copyWith(id: uid)));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}
