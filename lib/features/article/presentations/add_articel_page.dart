import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_state.dart';
import 'package:konsul_dosen/widgets/my_button.dart';
import 'package:konsul_dosen/widgets/my_text_field.dart';
import 'package:path/path.dart' as path;

class AddArticelPage extends StatefulWidget {
  const AddArticelPage({super.key});

  @override
  State<AddArticelPage> createState() => _AddArticelPageState();
}

class _AddArticelPageState extends State<AddArticelPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortUrlController = TextEditingController();
  final _tempController = TextEditingController();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
    });

    String fileName = path.basename(_image!.path);
    print('Image picked: $fileName');
  }

  Future<void> _uploadArticle(String? id) async {
    if (_image == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _shortUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all fields and select an image.')));
      return;
    }

    if (id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    try {
      // Append current date and time to the filename
      DateTime now = DateTime.now();
      String formattedDate =
          '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}';
      String fileName = 'article_$formattedDate.jpg';

      // Upload image to Firebase Storage with the new filename
      Reference storageRef =
          FirebaseStorage.instance.ref().child('articles/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(_image!.path));
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Save article data to Firestore
      await FirebaseFirestore.instance.collection('articles').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'shortUrl': _shortUrlController.text,
        'imageUrl': imageUrl,
        'userId': id,
        'createdAt': Timestamp.now(),
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article uploaded successfully.')));
      });
      _clearForm();
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload article: $error')));
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _shortUrlController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Artikel')),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                child: MyTextField(
                  controller: _titleController,
                  labelText: 'Judul',
                  type: TextFieldType.normal,
                  filled: false,
                  textColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                child: MyTextField(
                  controller: _descriptionController,
                  labelText: 'Deskripsi',
                  type: TextFieldType.normal,
                  filled: false,
                  textColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                child: MyTextField(
                  controller: _shortUrlController,
                  labelText: 'URL',
                  type: TextFieldType.normal,
                  filled: false,
                  textColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                child: MyTextField(
                  controller: _tempController,
                  prefixIcon: Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  labelText: 'Pilih gambar',
                  type: TextFieldType.none,
                  textColor: Theme.of(context).colorScheme.onSurface,
                  onTap: () => _pickImage(),
                ),
              ),
              const SizedBox(height: 20),
              _image == null
                  ? const Text('Tidak ada gambar yang dipilih.')
                  : Image.file(File(_image!.path), height: 200),
              const SizedBox(height: 26),
              BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                return Row(
                  children: [
                    Expanded(
                      child: MyButton(
                        onPressed: () {},
                        text: 'Batal',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: MyButton(
                            onPressed: () => _uploadArticle(state.userId),
                            text: 'Unggah')),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
