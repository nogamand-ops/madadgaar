/// Pakistani mobile format: +92 3XX XXXXXXX
final RegExp pkPhoneRegExp = RegExp(r'^\+92 ?3\d{2} ?\d{7}$');

/// Normalises common local input ("03001234567", "3001234567") to E.164
/// ("+923001234567") so both the UI and the server agree on one format.
String normalizePkPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('92')) return '+$digits';
  if (digits.startsWith('0')) return '+92${digits.substring(1)}';
  if (digits.startsWith('3')) return '+92$digits';
  return '+$digits';
}

String relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return '${time.day}/${time.month}/${time.year}';
}

String formatClock(DateTime time) {
  final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final m = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}
