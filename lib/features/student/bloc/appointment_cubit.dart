import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';

class AppointmentCubit extends Cubit<DataState> {
  AppointmentCubit() : super(const DataState());

  Future<void> accept(String uid) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      await FirebaseFirestore.instance.collection('promises').doc(uid).update({
        'status': 'accepted',
      });

      final docSnapshot = await FirebaseFirestore.instance
          .collection('promises')
          .doc(uid)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        // Create new data on collection rooms, rooms mena room for chat
        final roomsData =
            await FirebaseFirestore.instance.collection('rooms').add({
          'promiseId': uid,
          'siswaId': data?['siswaId'] ?? '',
          'dosenId': data?['dosenId'] ?? '',
          'status': 'open',
        });
        // Update promises to accepted
        await FirebaseFirestore.instance.collection('promises').doc(uid).update(
          {
            'status': 'accepted',
            'roomId': roomsData.id,
          },
        );
      } else {
        await FirebaseFirestore.instance
            .collection('promises')
            .doc(uid)
            .update({
          'status': 'pending',
        });
        throw Exception('Document does not exist on the database');
      }

      // Create new data on collection rooms
      emit(const DataState(status: LoadStatus.success));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }

  Future<void> reject(String uid, String reason) async {
    emit(state.copyWith(status: LoadStatus.loading));
    try {
      await FirebaseFirestore.instance.collection('promises').doc(uid).update({
        'status': 'rejected',
        'reason': reason,
      });
      emit(const DataState(status: LoadStatus.success));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: LoadStatus.failure, error: e.toString()));
    }
  }
}
