import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/model/all_user.dart';
import 'package:konsul_dosen/features/student/bloc/appointment_cubit.dart';
import 'package:konsul_dosen/features/student/bloc/student_cubit.dart';
import 'package:konsul_dosen/features/student/model/promise.dart';
import 'package:konsul_dosen/helpers/dialog.dart';
import 'package:konsul_dosen/helpers/helpers.dart';
import 'package:konsul_dosen/services/app_router.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';
import 'package:konsul_dosen/widgets/loading_progress.dart';
import 'package:konsul_dosen/widgets/my_text_field.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage(this.uid, {super.key});

  final String uid;
  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    inittAsync();
  }

  inittAsync() async {
    context.read<StudentCubit>().get(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppointmentCubit>(
      create: (context) => AppointmentCubit(),
      child: BlocBuilder<StudentCubit, DataState<AllUser>>(
          builder: (context, state) {
        String? imageUrl = state.item?.imageUrl;
        imageUrl = (imageUrl == '') ? null : imageUrl;
        return BlocConsumer<AppointmentCubit, DataState>(
          listener: (context, stateUpdate) {
            if (stateUpdate.status == LoadStatus.success) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _reasonController.text = '';
                });
              });
            } else if (stateUpdate.status == LoadStatus.failure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialogMsg(
                    context, stateUpdate.error ?? 'Ada sesuatu yang salah');
              });
            }
          },
          builder: (context, stateUpdate) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(title: const Text('Detail')),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    // child: ClipOval(
                                    //   child: Image.asset(
                                    //     'assets/images/user.png',
                                    //     fit: BoxFit.cover,
                                    //   ),
                                    // ),
                                    child: CircleAvatar(
                                      radius: 80,
                                      backgroundImage: imageUrl != null
                                          ? NetworkImage(imageUrl)
                                              as ImageProvider<Object>
                                          : const AssetImage(
                                              'assets/images/user.png'),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalize(state.item?.name ?? ""),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            state.status == LoadStatus.success
                                                ? "Email : ${state.item?.email}\nNISN : ${state.item?.nisn}\nTelp : ${state.item?.phoneNumber ?? '-'}"
                                                : '',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).colorScheme.primary,
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            'History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('promises')
                              .where('dosenId',
                                  isEqualTo: BlocProvider.of<AuthCubit>(context)
                                      .state
                                      .userId)
                              .where('siswaId', isEqualTo: state.item?.id)
                              .orderBy('updatedAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                color: Theme.of(context).colorScheme.primary,
                                child: Center(
                                  child: Text(
                                    'Tidak ada siswa bimbingan',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                ),
                              );
                            }

                            List<DocumentSnapshot> usersDocs =
                                snapshot.data!.docs;
                            return Container(
                              color: Theme.of(context).colorScheme.primary,
                              width: double.infinity,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot promiseDoc =
                                      usersDocs[index];
                                  String uid = promiseDoc.id;
                                  Promise promise = Promise.fromJson(promiseDoc
                                          .data() as Map<String, dynamic>)
                                      .copyWith(id: uid);
                                  return Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4.0,
                                          spreadRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      minVerticalPadding: 6,
                                      title: Text(
                                        capitalize(promise.status ?? '-'),
                                        style: TextStyle(
                                            color:
                                                getColorStatus(promise.status)),
                                      ),
                                      subtitle: Text(formatDateTimeCustom(
                                          promise.date,
                                          format: 'EEEE, d MMM yyyy HH:mm')),
                                      trailing: const Icon(
                                          Icons.keyboard_arrow_right),
                                      onTap: () {
                                        if (promise.status == 'pending') {
                                          showDialogConfirmation(
                                            context,
                                            () {
                                              context
                                                  .read<AppointmentCubit>()
                                                  .accept(uid);
                                            },
                                            message:
                                                'Apakah anda yakin ingin menerima siswa ini?',
                                            minusText: 'Tolak',
                                            positiveText: 'Terima',
                                            buttonStyle1: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .error),
                                            buttonStyle2: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                            onMinus: () {
                                              showAdaptiveDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  final formKey =
                                                      GlobalKey<FormState>();
                                                  return Form(
                                                    key: formKey,
                                                    child: AlertDialog(
                                                      title: const Text(
                                                          'Alesan menolak'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            MyTextField(
                                                              controller:
                                                                  _reasonController,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Field tidak boleh kosong';
                                                                }
                                                                return null;
                                                              },
                                                              labelText:
                                                                  'Alasan',
                                                              filled: false,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .outline,
                                                          ),
                                                          child: const Text(
                                                              "Batal"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            if (formKey
                                                                .currentState!
                                                                .validate()) {
                                                              context
                                                                  .read<
                                                                      AppointmentCubit>()
                                                                  .reject(
                                                                      uid,
                                                                      _reasonController
                                                                          .text);
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            }
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Theme.of(ctx)
                                                                    .colorScheme
                                                                    .primary,
                                                          ),
                                                          child: const Text(
                                                              "Save"),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        } else if (promise.status ==
                                                'accepted' ||
                                            promise.status == 'completed') {
                                          context.push(
                                              Destination.chatPath.replaceAll(
                                                  ':id',
                                                  promise.roomId ?? ':id'),
                                              extra: promise.roomId);
                                        } else if (promise.status ==
                                            'rejected') {
                                          showDialogInfo(
                                            context,
                                            () {},
                                            message: promise.reason ?? '-',
                                            title: 'Alasan',
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == LoadStatus.loading ||
                    stateUpdate.status == LoadStatus.loading)
                  const LoadingProgress(),
              ],
            );
          },
        );
      }),
    );
  }
}
