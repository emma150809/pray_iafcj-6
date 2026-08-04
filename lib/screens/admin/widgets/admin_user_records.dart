import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_responsive.dart';
import '../../../core/app_text_styles.dart';

class AdminUserRecords extends StatelessWidget {
  final String uid;
  final String subcollection;
  final String emptyMessage;
  final Widget Function(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) itemBuilder;

  const AdminUserRecords({
    super.key,
    required this.uid,
    required this.subcollection,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    final future = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection(subcollection)
        .orderBy('fechaRegistro', descending: true)
        .get();

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * s),
            child: Center(
              child: SizedBox(
                width: 22 * s,
                height: 22 * s,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * s),
            child: Center(
              child: Text(
                'No se pudieron cargar los registros.',
                style: AppTextStyles.body.copyWith(fontSize: 14 * s),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * s),
            child: Center(
              child: Text(
                emptyMessage,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14 * s,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final doc in docs) itemBuilder(context, doc),
          ],
        );
      },
    );
  }
}
