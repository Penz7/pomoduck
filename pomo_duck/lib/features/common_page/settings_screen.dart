import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/local_storage/hive_data_manager.dart';
import '../../data/models/user_preferences_model.dart';
import '../../common/global_bloc/language/language_cubit.dart';
import '../../generated/locale_keys.g.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserPreferencesModel _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = HiveDataManager.getUserPreferences();
  }

  Future<void> _save(UserPreferencesModel next) async {
    await HiveDataManager.saveUserPreferences(next);
    setState(() {
      _preferences = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('settings.language'.tr()),
            subtitle: Text(_preferences.language == 'en' ? LocaleKeys.english.tr() : LocaleKeys.vietnamese.tr()),
            trailing: DropdownButton<String>(
              value: _preferences.language,
              items: [
                DropdownMenuItem(value: 'vi', child: Text(LocaleKeys.vietnamese.tr())),
                DropdownMenuItem(value: 'en', child: Text(LocaleKeys.english.tr())),
              ],
              onChanged: (v) async {
                if (v == null) return;
                final next = _preferences.copyWith(language: v);
                await _save(next);
                final locale = v == 'en' ? const Locale('en', 'US') : const Locale('vi', 'VN');
                // Đồng bộ EasyLocalization + LanguageCubit
                await context.setLocale(locale);
                context.read<LanguageCubit>().setNewLanguage(locale);
              },
            ),
          ),
          const Divider(),

          // Theme
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            value: _preferences.appTheme == 'dark',
            onChanged: (v) async {
              final next = _preferences.copyWith(appTheme: v ? 'dark' : 'light');
              await _save(next);
            },
          ),
          const Divider(),

          // Notifications
          SwitchListTile(
            title: Text('settings.notifications'.tr()),
            value: _preferences.showNotifications,
            onChanged: (v) async {
              final next = _preferences.copyWith(showNotifications: v);
              await _save(next);
            },
          ),

          // Haptic
          SwitchListTile(
            title: Text('settings.haptic'.tr()),
            value: _preferences.enableHapticFeedback,
            onChanged: (v) async {
              final next = _preferences.copyWith(enableHapticFeedback: v);
              await _save(next);
            },
          ),
        ],
      ),
    );
  }
}


