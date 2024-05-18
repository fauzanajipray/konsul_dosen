import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_state.dart';
import 'package:konsul_dosen/services/app_router.dart';
import 'package:konsul_dosen/widgets/my_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var layoutBuilder = LayoutBuilder(builder: (context, constraint) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  //   return Container(
                  //     margin: const EdgeInsets.all(16),
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: Theme.of(context).colorScheme.primary,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           width: 60.0,
                  //           height: 60.0,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             border: Border.all(color: Colors.white, width: 2.0),
                  //             color: Theme.of(context).colorScheme.tertiary,
                  //           ),
                  //           child: ClipOval(
                  //             child: Image.asset(
                  //               'assets/images/user.png',
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         Column(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             RichText(
                  //               text: TextSpan(children: [
                  //                 const TextSpan(
                  //                   text: "Hai, ",
                  //                   style: TextStyle(fontWeight: FontWeight.normal),
                  //                 ),
                  //                 TextSpan(
                  //                   text: "${state.data?.name}",
                  //                   style:
                  //                       const TextStyle(fontWeight: FontWeight.w500),
                  //                 ),
                  //               ]),
                  //             ),
                  //             Text(
                  //               "Bagaimana perasaan mu hari ini? ",
                  //               style: TextStyle(
                  //                 color: Theme.of(context).colorScheme.onPrimary,
                  //                 // fontSize: 14,
                  //                 fontWeight: FontWeight.normal,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // }),
                  // Container(
                  //   color: Colors.blue,
                  //   child: StreamBuilder<QuerySnapshot>(
                  //       stream: FirebaseFirestore.instance
                  //           .collection('articles')
                  //           .limit(4) // Ambil hanya 4 data
                  //           .snapshots(),
                  //       builder: (context, snapshot) {
                  //         if (snapshot.hasError) {
                  //           return Center(child: Text('Error: ${snapshot.error}'));
                  //         }

                  //         if (snapshot.connectionState == ConnectionState.waiting) {
                  //           return const Center(child: CircularProgressIndicator());
                  //         }
                  //         return ListView.builder(
                  //           shrinkWrap: true,
                  //           physics: const NeverScrollableScrollPhysics(),
                  //           itemCount: snapshot.data?.docs.length,
                  //           itemBuilder: (context, index) {
                  //             DocumentSnapshot? article = snapshot.data?.docs[index];
                  //             return Container(
                  //               margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  //               child: Column(
                  //                 children: [
                  //                   Container(
                  //                     margin: EdgeInsets.only(
                  //                         top: (index == 0) ? 8 : 4, bottom: 4),
                  //                     padding: const EdgeInsets.symmetric(
                  //                         horizontal: 10, vertical: 8),
                  //                     decoration: BoxDecoration(
                  //                       color: Theme.of(context).cardColor,
                  //                       borderRadius: BorderRadius.circular(8.0),
                  //                       boxShadow: const [
                  //                         BoxShadow(
                  //                           color: Colors.black12,
                  //                           blurRadius: 4.0,
                  //                           spreadRadius: 2.0,
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     child: Row(
                  //                       crossAxisAlignment: CrossAxisAlignment.start,
                  //                       children: [
                  //                         ClipRRect(
                  //                           borderRadius: BorderRadius.circular(8.0),
                  //                           child: Container(
                  //                             color: Theme.of(context)
                  //                                 .colorScheme
                  //                                 .outlineVariant,
                  //                             width: 100.0,
                  //                             height: 100.0,
                  //                             child: Image.network(
                  //                               article?['imageUrl'] ?? '-',
                  //                               fit: BoxFit.cover,
                  //                               loadingBuilder: (context, child,
                  //                                   loadingProgress) {
                  //                                 if (loadingProgress == null) {
                  //                                   return child;
                  //                                 }
                  //                                 return Center(
                  //                                   child: CircularProgressIndicator(
                  //                                     value: loadingProgress
                  //                                                 .expectedTotalBytes !=
                  //                                             null
                  //                                         ? loadingProgress
                  //                                                 .cumulativeBytesLoaded /
                  //                                             loadingProgress
                  //                                                 .expectedTotalBytes!
                  //                                         : null,
                  //                                   ),
                  //                                 );
                  //                               },
                  //                               errorBuilder:
                  //                                   (context, error, stackTrace) {
                  //                                 return Center(
                  //                                     child: Text(
                  //                                   'Error',
                  //                                   style: TextStyle(
                  //                                       fontSize: 16,
                  //                                       color: Theme.of(context)
                  //                                           .colorScheme
                  //                                           .outline),
                  //                                 ));
                  //                               },
                  //                             ),
                  //                           ),
                  //                         ),
                  //                         const SizedBox(width: 12),
                  //                         Expanded(
                  //                           child: Column(
                  //                             crossAxisAlignment:
                  //                                 CrossAxisAlignment.start,
                  //                             children: [
                  //                               Text(article?['title'] ?? '-',
                  //                                   maxLines: 2,
                  //                                   style: const TextStyle(
                  //                                       fontSize: 14,
                  //                                       overflow:
                  //                                           TextOverflow.ellipsis,
                  //                                       fontWeight: FontWeight.bold)),
                  //                               const SizedBox(height: 4),
                  //                               Text(article?['description'] ?? '-',
                  //                                   maxLines: 4,
                  //                                   style: TextStyle(
                  //                                       fontSize: 12,
                  //                                       overflow:
                  //                                           TextOverflow.ellipsis,
                  //                                       color: Theme.of(context)
                  //                                           .colorScheme
                  //                                           .outlineVariant)),
                  //                             ],
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       }),
                  // ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('articles')
                          .limit(4) // Ambil hanya 4 data
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
                        return Container(
                          color: Colors.blue,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot? article =
                                  snapshot.data?.docs[index];
                              return ListTile(
                                title: Text('Item ${article?['title'] ?? '-'}'),
                              );
                            },
                          ),
                        );
                      }),
                  Container(
                    height: constraint.maxHeight * .6,
                    color: Theme.of(context).colorScheme.surface,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Jumlah kolom
                        crossAxisSpacing: 10, // Spasi antar kolom
                        mainAxisSpacing: 10, // Spasi antar baris
                        childAspectRatio: 1,
                      ),
                      itemCount: 6, // Ganti dengan jumlah item yang sesuai
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: Text('Item ${index + 1}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().setUnauthenticated();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                return Container(
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
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/user.png',
                            fit: BoxFit.cover,
                          ),
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
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: "${state.data?.name}",
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
                );
              }),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('articles')
                      .limit(4) // Ambil hanya 4 data
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var height = 0.6;
                    if (snapshot.data!.docs.isEmpty) {
                      height = 0.0;
                    } else if (snapshot.data!.docs.length <= 2) {
                      height = 0.3;
                    } else if (snapshot.data!.docs.length <= 4) {
                      height = 0.6;
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Container(
                        height: 80,
                        color: Theme.of(context).colorScheme.primary,
                        child: const Center(
                          child: Text(
                            'No articles found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: constraint.maxHeight * height,
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      color: Theme.of(context).colorScheme.primary,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot? article =
                              snapshot.data?.docs[index];
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    '${article?['title'] ?? '-'}',
                                    // maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      // overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    width: 180,
                    height: 40,
                    child: MyButton(
                      onPressed: () => context.go(Destination.articlePath),
                      text: 'Lihat lebih banyak',
                      verticalPadding: 0,
                      horizontalPadding: 4,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.surface,
                      textColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                width: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6, // Replace with the appropriate number of items
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Item ${index + 1}'),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    width: 240,
                    height: 40,
                    child: MyButton(
                      onPressed: () => context.go(Destination.articlePath),
                      text: 'Lihat Seluruh Siswa Bimbingan',
                      verticalPadding: 0,
                      horizontalPadding: 4,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
