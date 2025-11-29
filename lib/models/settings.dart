import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String? apiKey;

  @HiveField(1)
  final String themeMode; // 'light', 'dark', 'amoled'

  AppSettings({this.apiKey, this.themeMode = 'dark'});

  AppSettings copyWith({String? apiKey, String? themeMode}) {
    return AppSettings(
      apiKey: apiKey ?? this.apiKey,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
