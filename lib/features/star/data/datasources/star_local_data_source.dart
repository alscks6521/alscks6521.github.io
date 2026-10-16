import 'package:shared_preferences/shared_preferences.dart';

/// 이 기기에서 이미 별을 눌렀는지 기억한다.
class StarLocalDataSource {
  static const _prefKey = 'star_voted';

  const StarLocalDataSource();

  Future<bool> hasVoted() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_prefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markVoted() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_prefKey, true);
    } catch (_) {}
  }
}
