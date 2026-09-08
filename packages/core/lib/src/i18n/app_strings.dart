import 'package:flutter_riverpod/flutter_riverpod.dart';

/// English is primary; Urdu ships as a real, working second locale for the
/// highest-traffic labels so the translation architecture is provably real
/// — not every string in the product is translated for this MVP.
enum AppLocale { en, ur }

const Map<String, Map<AppLocale, String>> _dict = {
  'app_tagline': {AppLocale.en: 'Help, when you need it.', AppLocale.ur: 'مدد، جب آپ کو ضرورت ہو۔'},
  'need_help': {AppLocale.en: 'I NEED HELP', AppLocale.ur: 'مجھے مدد چاہیے'},
  'whats_wrong': {AppLocale.en: "What's wrong?", AppLocale.ur: 'کیا مسئلہ ہے؟'},
  'nav_home': {AppLocale.en: 'Home', AppLocale.ur: 'ہوم'},
  'nav_requests': {AppLocale.en: 'Requests', AppLocale.ur: 'درخواستیں'},
  'nav_vehicles': {AppLocale.en: 'Vehicles', AppLocale.ur: 'گاڑیاں'},
  'nav_profile': {AppLocale.en: 'Profile', AppLocale.ur: 'پروفائل'},
  'nav_jobs': {AppLocale.en: 'Jobs', AppLocale.ur: 'کام'},
  'nav_earnings': {AppLocale.en: 'Earnings', AppLocale.ur: 'کمائی'},
  'confirm_location': {AppLocale.en: 'Confirm your location', AppLocale.ur: 'اپنا مقام تصدیق کریں'},
  'request_help': {AppLocale.en: 'Request Help', AppLocale.ur: 'مدد کی درخواست کریں'},
  'finding_madadgaar': {AppLocale.en: 'Finding a Madadgaar nearby…', AppLocale.ur: 'قریبی مددگار تلاش ہو رہا ہے…'},
  'go_online': {AppLocale.en: 'Go Online', AppLocale.ur: 'آن لائن جائیں'},
  'go_offline': {AppLocale.en: 'Go Offline', AppLocale.ur: 'آف لائن جائیں'},
  'accept': {AppLocale.en: 'Accept', AppLocale.ur: 'قبول کریں'},
  'decline': {AppLocale.en: 'Decline', AppLocale.ur: 'مسترد کریں'},
  'total': {AppLocale.en: 'Total', AppLocale.ur: 'کل رقم'},
  'rate_your_madadgaar': {AppLocale.en: 'Rate your Madadgaar', AppLocale.ur: 'اپنے مددگار کو ریٹ کریں'},
  'madadgaar_hai_na': {AppLocale.en: 'Madadgaar hai na.', AppLocale.ur: 'مددگار ہے نا۔'},
};

class AppStrings {
  final AppLocale locale;
  const AppStrings(this.locale);

  String call(String key) => _dict[key]?[locale] ?? _dict[key]?[AppLocale.en] ?? key;
}

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.en);
final stringsProvider = Provider<AppStrings>((ref) => AppStrings(ref.watch(localeProvider)));
