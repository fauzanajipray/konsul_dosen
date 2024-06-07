import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_state.dart';
import 'package:konsul_dosen/features/profile/bloc/profile_cubit.dart';
import 'package:konsul_dosen/features/profile/model/profile.dart';
import 'package:konsul_dosen/services/app_router.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/widgets/my_button.dart';

class CounselingPage extends StatefulWidget {
  const CounselingPage({super.key});

  @override
  State<CounselingPage> createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Konseling'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
              return BlocBuilder<ProfileCubit, DataState<Profile>>(
                  builder: (context, stateProfile) {
                String? imageUrl = stateProfile.item?.imageUrl;
                imageUrl = (imageUrl == '') ? null : imageUrl;
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                    as ImageProvider<Object>
                                : const AssetImage('assets/images/user.png')
                                    as ImageProvider<Object>,
                            backgroundColor:
                                Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                  text: "Hai, ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: "${state.name}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ]),
                            ),
                            Text(
                              "Bagaimana perasaan mu hari ini? ",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                // fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
            }),
            Container(
              color: Theme.of(context).colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: MyButton(
                text: '+ Tambahkan Jadwal',
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                onPressed: () => context.push(Destination.addSchedulePath),
              ),
            ),
            const SizedBox(child: Divider()),
            Container(
              color: Theme.of(context).colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Mahasiswa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('type', isEqualTo: 'siswa')
                  .where('pembimbing',
                      isEqualTo:
                          BlocProvider.of<AuthCubit>(context).state.userId ??
                              '')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Container(
                    height: 80,
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Text(
                        'Tidak ada siswa bimbingan',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  );
                }

                return Container(
                  color: Theme.of(context).colorScheme.primary,
                  width: double.infinity,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot? doc = snapshot.data?.docs[index];
                      String? uid = doc?.id;

                      String? imageUrl = (doc?.data() as Map<String, dynamic>)
                              .containsKey('imageUrl')
                          ? doc!['imageUrl']
                          : null;
                      String? name = (doc?.data() as Map<String, dynamic>)
                              .containsKey('name')
                          ? doc!['name']
                          : null;

                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
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
                          minVerticalPadding: 5,
                          title: Text(
                            name ?? '-',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            context.push(Destination.studentDetailPath
                                .replaceAll(':id', uid ?? ''));
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 60.0,
                              height: 60.0,
                              child: ExtendedImage.network(
                                imageUrl ?? '',
                                compressionRatio: kIsWeb ? null : 0.2,
                                clearMemoryCacheWhenDispose: true,
                                cache: true,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  if (state.extendedImageLoadState ==
                                      LoadState.completed) {
                                    return state.completedWidget;
                                  } else {
                                    return Center(
                                      child: Text(
                                        name != null
                                            ? name.length == 1
                                                ? name.toUpperCase()
                                                : name
                                                    .substring(0, 2)
                                                    .toUpperCase()
                                            : '',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
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
    );
  }
}
