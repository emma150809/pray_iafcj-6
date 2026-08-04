import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_navigation.dart';
import '../../core/app_snackbar.dart';
import '../../core/app_text_styles.dart';
import '../../screens/welcome/welcome_screen.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../widgets/brand_circle.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/biography_card.dart';
import 'widgets/info_card.dart';
import 'widgets/notifications_card.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  String? _uid;
  String _displayName = 'Perfil';
  String _username = '@usuario';
  String _biography = '';
  String _birthday = '';
  String _age = '';
  String? _photoUrl;
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _uid = AuthService().currentUser?.uid;
    if (_uid != null) {
      _listenToUser();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _listenToUser() {
    if (_uid == null) return;

    _userSubscription = _userService.streamUser(_uid!).listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data() ?? {};
      final nombre = (data['nombre'] ?? '').toString().trim();
      final apellido = (data['apellido'] ?? '').toString().trim();
      final username = (data['username'] ?? '').toString().trim();
      final birthday = (data['cumpleanos'] ?? '').toString();
      final biography = (data['biografia'] ?? '').toString();
      final photo = (data['foto'] ?? '').toString();
      final notificationEnabled = data['notificacion'] ?? true;
      final recordHora = (data['recordHora'] ?? '21:00').toString();
      final hour = data['notificationHour'] ?? 21;
      final minute = data['notificationMinute'] ?? 0;

      setState(() {
        final fullName = [
          nombre,
          apellido,
        ].where((value) => value.isNotEmpty).join(' ').trim();
        _displayName = fullName.isNotEmpty
            ? fullName
            : (username.isNotEmpty ? username : 'Perfil');
        _username = username.isNotEmpty
            ? (username.startsWith('@') ? username : '@$username')
            : '@usuario';
        _biography = biography;
        _birthday = birthday;
        _age = _calculateAge(birthday);
        _photoUrl = photo.isNotEmpty ? photo : null;
        _notificationsEnabled = notificationEnabled;
        _notificationTime = _parseTimeOfDay(recordHora, hour, minute);
      });

      _syncReminder();
    });
  }

  /// Programa o cancela el recordatorio según la configuración actual.
  void _syncReminder() {
    try {
      if (_notificationsEnabled) {
        NotificationService.scheduleDailyReminder(
          hour: _notificationTime.hour,
          minute: _notificationTime.minute,
        );
      } else {
        (NotificationService as dynamic).cancelReminder();
      }
    } catch (e) {
      print('Error al sincronizar recordatorio: $e');
    }
  }

  String _calculateAge(String birthday) {
    if (birthday.isEmpty) return '';

    final parts = birthday.split('/');
    if (parts.length != 3) return '';

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return '';

    final birthDate = DateTime(year, month, day);
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  TimeOfDay _parseTimeOfDay(String recordHora, dynamic hour, dynamic minute) {
    final parts = recordHora.split(':');
    if (parts.length >= 2) {
      final parsedHour = int.tryParse(parts[0]);
      final parsedMinute = int.tryParse(parts[1]);
      if (parsedHour != null && parsedMinute != null) {
        return TimeOfDay(hour: parsedHour, minute: parsedMinute);
      }
    }

    return TimeOfDay(
      hour: hour is int ? hour : 21,
      minute: minute is int ? minute : 0,
    );
  }

  Future<void> _saveNotificationPreference(bool value) async {
    if (_uid == null) return;

    setState(() => _notificationsEnabled = value);

    await _userService.updateUser(_uid!, {'notificacion': value});

    _syncReminder();
  }

  Future<void> _saveNotificationTime(TimeOfDay time) async {
    if (_uid == null) return;

    setState(() => _notificationTime = time);

    await _userService.updateUser(_uid!, {
      'notificationHour': time.hour,
      'notificationMinute': time.minute,
      'recordHora':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    });

    _syncReminder();
  }

  Future<void> _editBiography() async {
    if (_uid == null) return;

    final controller = TextEditingController(text: _biography);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Editar biografía',
            style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Cuéntanos sobre ti...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(
                'Guardar',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await _userService.updateUser(_uid!, {'biografia': result});

    if (!mounted) return;
    AppSnackBar.show(context, 'Biograf\u00eda actualizada.');
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Inicia sesión para ver tu perfil')),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final barHeight = 84.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BrandCircle(size: 44, fontSize: 26),
                  Text('Perfil', style: AppTextStyles.appTitle),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22, 0, 22, barHeight),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  ProfileAvatar(imageUrl: _photoUrl, userName: _displayName),
                  const SizedBox(height: 10),
                  Text(
                    _displayName,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _username,
                    style: AppTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  BiographyCard(
                    biography: _biography.isNotEmpty
                        ? _biography
                        : 'Agrega una biografía para compartir más sobre ti.',
                    onTap: _editBiography,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          icon: Icons.cake_rounded,
                          title: _birthday.isEmpty ? 'Sin fecha' : _birthday,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InfoCard(
                          icon: Icons.auto_awesome_rounded,
                          title: _age.isEmpty ? 'Sin edad' : '$_age años',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NotificationsCard(
                    enabled: _notificationsEnabled,
                    time: _notificationTime,
                    onChanged: _saveNotificationPreference,
                    onTimeChanged: _saveNotificationTime,
                  ),
                  const SizedBox(height: 16),
                  LogoutButton(
                    onPressed: () async {
                      await AuthService().logout();
                      if (!context.mounted) return;
                      pushFadeAndRemoveUntil(context, const WelcomeScreen());
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
