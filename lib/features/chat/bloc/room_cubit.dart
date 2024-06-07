import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/chat/model/room.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class RoomCubit extends Cubit<DataState<Room>> {
  RoomCubit() : super(const DataState());

  Future<void> get(String uid) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('rooms').doc(uid).get();

      Map<String, dynamic> userData = userDoc.data() ?? {};
      Room room = Room.fromJson(userData);

      emit(DataState(
          status: LoadStatus.success,
          data: userData,
          item: room.copyWith(id: uid)));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}
