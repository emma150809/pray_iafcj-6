String displayNameOfUser(Map<String, dynamic> data) {
  final nombre = (data['nombre'] ?? '').toString().trim();
  final apellido = (data['apellido'] ?? '').toString().trim();
  final fullName = [nombre, apellido]
      .where((value) => value.isNotEmpty)
      .join(' ')
      .trim();

  if (fullName.isNotEmpty) return fullName;

  final username = (data['username'] ?? '').toString().trim();
  return username.isNotEmpty ? username : 'Usuario';
}

String usernameOfUser(Map<String, dynamic> data) {
  final username = (data['username'] ?? '').toString().trim();
  return username.isNotEmpty
      ? (username.startsWith('@') ? username : '@$username')
      : '@usuario';
}

String ageFromBirthday(String birthday) {
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
