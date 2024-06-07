import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_state.dart';
import 'package:konsul_dosen/features/profile/bloc/profile_cubit.dart';
import 'package:konsul_dosen/features/profile/model/profile.dart';
import 'package:konsul_dosen/helpers/helpers.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';
import 'package:konsul_dosen/widgets/my_button.dart';
import 'package:konsul_dosen/widgets/my_text_field.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _noController = TextEditingController();
  DateTime? birthDate = DateTime.now();

  Future<void> _update(String? uid) async {
    if (_nameController.text.isEmpty ||
        _noController.text.isEmpty ||
        _birthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      // Update collection users
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text,
        'birthday': _birthController.text,
        'number': _noController.text,
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update successfully.')));
        context.pop(true);
      });
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $error')));
      });
    }
  }

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    context
        .read<ProfileCubit>()
        .getProfile(BlocProvider.of<AuthCubit>(context).state.userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocConsumer<ProfileCubit, DataState<Profile>>(
        listener: (BuildContext context, DataState<Profile> state) {
          if (state.status == LoadStatus.success) {
            setState(() {
              _nameController.text = state.item?.name ?? '';
              _birthController.text = state.item?.birthday != null
                  ? formatDateTimeCustom(state.item?.birthday,
                      format: 'dd-MM-yyyy')
                  : '';
              _noController.text = state.item?.number ?? '';
              birthDate = state.item?.birthday;
            });
          }
        },
        builder: (context, state) {
          String? imageUrl = state.item?.imageUrl;
          imageUrl = (imageUrl == '') ? null : imageUrl;
          return SafeArea(
            child: SingleChildScrollView(
                child: Column(
              children: [
                const SizedBox(height: 8),
                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (ctx) {
                                  return SafeArea(
                                    child: CupertinoActionSheet(
                                      actions: [
                                        CupertinoActionSheetAction(
                                          onPressed: () async {
                                            Navigator.of(ctx).pop();
                                            _pickImage(state.userId);
                                          },
                                          child: const Text('Pilih Gambar'),
                                        ),
                                        CupertinoActionSheetAction(
                                          onPressed: () async {
                                            Navigator.of(ctx).pop();
                                            //
                                          },
                                          child: Text('Delete',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error)),
                                        ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error)),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage: imageUrl != null
                                      ? NetworkImage(imageUrl)
                                          as ImageProvider<Object>
                                      : const AssetImage(
                                              'assets/images/user_image.png')
                                          as ImageProvider<Object>,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.outline,
                                ),
                                // Edit Icon
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.edit,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _formInput(
                          MyTextField(
                            controller: _nameController,
                            labelText: 'Nama',
                            type: TextFieldType.normal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _formInput(
                          MyTextField(
                            controller: _noController,
                            labelText: 'Nomor',
                            type: TextFieldType.number,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _formInput(
                          MyTextField(
                            controller: _birthController,
                            labelText: 'Tanggal Lahir',
                            type: TextFieldType.none,
                            textColor: Theme.of(context).colorScheme.onSurface,
                            onTap: () async => {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _birthController.text =
                                        DateFormat('dd-MM-yyyy').format(value);
                                    birthDate = value;
                                  });
                                }
                              })
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: MyButton(
                        color: Theme.of(context).colorScheme.error,
                        textColor: Theme.of(context).colorScheme.onError,
                        verticalPadding: 0,
                        text: 'Cancel',
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                      return Container(
                        width: 120,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: MyButton(
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.onSecondary,
                          verticalPadding: 0,
                          text: 'Save',
                          onPressed: () {
                            _update(state.userId);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            )),
          );
        },
      ),
    );
  }

  Widget _formInput(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      ),
      child: child,
    );
  }

  Future<void> _pickImage(String? uid) async {
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
        DateTime now = DateTime.now();
        String formattedDate =
            '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
        String fileName = 'article_$formattedDate.jpg';
        String? imageUrl;
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profile/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(_image!.path));
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'imageUrl': imageUrl,
        });
        initAsync();
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error : $e')));
      });
    }
  }
}
