import 'package:flutter/material.dart';

import 'package:pray_iafcj/core/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.imageUrl, this.userName});

  final String? imageUrl;
  final String? userName;

  String _getInitial() {
    if (userName == null || userName!.trim().isEmpty) return '';
    return userName!.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imageUrl != null && imageUrl!.isNotEmpty;
    final initial = hasPhoto ? '' : _getInitial();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 4),
          ),
        ),
        CircleAvatar(
          radius: 52,
          backgroundColor: hasPhoto ? Colors.grey.shade300 : AppColors.primary,
          backgroundImage: hasPhoto ? NetworkImage(imageUrl!) : null,
          child: hasPhoto
              ? null
              : initial.isNotEmpty
              ? Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 8, 8, 8),
                  ),
                )
              : Icon(Icons.person, size: 70, color: Colors.grey.shade300),
        ),
      ],
    );
  }
}
