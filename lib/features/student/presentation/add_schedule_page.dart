import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/helpers/helpers.dart';
import 'package:konsul_dosen/widgets/loading_progress.dart';
import 'package:konsul_dosen/widgets/my_button.dart';
import 'package:konsul_dosen/widgets/my_text_field.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _timeController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    final selectedDateTime = DateTime(
      2000,
      1,
      1,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    _selectedTime = selectedDateTime;
    final formattedTime =
        '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}';
    _timeController.text = formattedTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Jadwal'),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                            'Di sini anda dapat menambahkan jadwal anda',
                            style: TextStyle(fontSize: 16)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16, bottom: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.1)),
                        child: MyTextField(
                          controller: _timeController,
                          prefixIcon: Icon(Icons.access_time,
                              color: Theme.of(context).colorScheme.outline),
                          type: TextFieldType.none,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: _selectedTime.hour,
                                  minute: _selectedTime.minute),
                            ).then((selectedTime) {
                              if (selectedTime != null) {
                                final selectedDateTime = DateTime(2000, 1, 1,
                                    selectedTime.hour, selectedTime.minute);
                                final formattedTime =
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                                _timeController.text = formattedTime;
                                setState(() {
                                  _selectedTime = selectedDateTime;
                                });
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 12),
                        child: MyButton(
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.onSecondary,
                          verticalPadding: 0,
                          text: 'Tambah',
                          onPressed: () {
                            _addTime(BlocProvider.of<AuthCubit>(context)
                                .state
                                .userId);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Jadwal',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('schedules')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Center(
                          child: Text(
                            'Tidak ada jadwal',
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

                          Timestamp? timestamp =
                              (doc?.data() as Map<String, dynamic>)
                                      .containsKey('time')
                                  ? doc!['time']
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
                                timestamp != null
                                    ? formatTimestampToTime(timestamp)
                                    : 'No Time',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              trailing: const Icon(Icons.delete),
                              onTap: () {
                                _deleteTime(uid);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50)
              ],
            ),
          ),
        ),
        if (isLoading) const LoadingProgress()
      ],
    );
  }

  Future<void> _addTime(String? userId) async {
    try {
      if (userId != null) {
        setState(() {
          isLoading = true;
        });

        final timestamp = Timestamp.fromDate(_selectedTime);

        // Query untuk memeriksa apakah timestamp sudah ada
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('schedules')
            .where('time', isEqualTo: timestamp)
            .where('userId', isEqualTo: userId)
            .get();

        // Jika ada dokumen dengan timestamp yang sama, lempar error
        if (querySnapshot.docs.isNotEmpty) {
          throw Exception('Schedule already exists for this time.');
        }

        // Jika tidak ada dokumen dengan timestamp yang sama, tambahkan data baru
        await FirebaseFirestore.instance.collection('schedules').add({
          'time': timestamp,
          'userId': userId,
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule uploaded successfully.')),
          );
        });
      } else {
        throw Exception("You need to relogin");
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTime(String? uid) async {
    try {
      if (uid != null) {
        setState(() {
          isLoading = true;
        });

        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(uid)
            .delete();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule deleted successfully.')),
          );
        });
      } else {
        throw Exception("You need to relogin");
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
