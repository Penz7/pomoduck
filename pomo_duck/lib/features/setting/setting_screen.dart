import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/global_bloc/language/language_cubit.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

import 'setting_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('settings_title'.tr()),
        ),
        body: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            if (state is SettingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final loaded = state as SettingLoaded;
            final prefs = loaded.preferences;
            final sound = loaded.notificationSound;
            final tags = loaded.pomodoroTags;

            Future<void> changeLanguage(String v) async {
              await context.read<SettingCubit>().changeLanguage(v);
              final locale = v == 'en' ? const Locale('en', 'US') : const Locale('vi', 'VN');
              await context.setLocale(locale);
              if (!mounted) return;
              context.read<LanguageCubit>().setNewLanguage(locale);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Language
                ListTile(
                  title: Text('settings_language'.tr()),
                  subtitle: Text(prefs.language == 'en' ? LocaleKeys.english.tr() : LocaleKeys.vietnamese.tr()),
                  trailing: DropdownButton<String>(
                    value: prefs.language,
                    items: [
                      DropdownMenuItem(value: 'vi', child: Text(LocaleKeys.vietnamese.tr())),
                      DropdownMenuItem(value: 'en', child: Text(LocaleKeys.english.tr())),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await changeLanguage(v);
                    },
                  ),
                ),
                const Divider(),

                // Theme (dark / light)
                SwitchListTile(
                  title: Text('settings_dark_mode'.tr()),
                  value: prefs.appTheme == 'dark',
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setAppTheme(v ? 'dark' : 'light');
                  },
                ),
                const Divider(),

                // Date format
                ListTile(
                  title: Text('settings_date_format'.tr()),
                  subtitle: Text(prefs.dateFormat),
                  trailing: DropdownButton<String>(
                    value: prefs.dateFormat,
                    items: [
                      DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('date_format_dd_mm_yyyy'.tr())),
                      DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('date_format_mm_dd_yyyy'.tr())),
                      DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('date_format_yyyy_mm_dd'.tr())),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await context.read<SettingCubit>().setDateFormat(v);
                    },
                  ),
                ),

                // Time format
                ListTile(
                  title: Text('settings_time_format'.tr()),
                  subtitle: Text(prefs.timeFormat),
                  trailing: DropdownButton<String>(
                    value: prefs.timeFormat,
                    items: [
                      DropdownMenuItem(value: '24h', child: Text('time_format_24h'.tr())),
                      DropdownMenuItem(value: '12h', child: Text('time_format_12h'.tr())),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await context.read<SettingCubit>().setTimeFormat(v);
                    },
                  ),
                ),
                const Divider(),

                // Notifications
                SwitchListTile(
                  title: Text('settings_notifications'.tr()),
                  value: prefs.showNotifications,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setNotifications(v);
                  },
                ),

                // Notification sound picker
                ListTile(
                  title: Text('settings_notification_sound'.tr()),
                  subtitle: Text(sound.capitalizeFirstLetter()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      builder: (context) {
                        final items = <String>['default', 'soft', 'bell', 'ding'];
                        return SafeArea(
                          child: ListView(
                            children: [
                              for (final s in items)
                                RadioListTile<String>(
                                  title: Text('notification_sound_$s'.tr()),
                                  value: s,
                                  groupValue: sound,
                                  onChanged: (val) => Navigator.of(context).pop(val),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                    if (selected != null) {
                      await context.read<SettingCubit>().setNotificationSound(selected);
                    }
                  },
                ),
                const Divider(),

                // Haptic
                SwitchListTile(
                  title: Text('settings_haptic'.tr()),
                  value: prefs.enableHapticFeedback,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setHaptic(v);
                  },
                ),

                // Show task progress
                SwitchListTile(
                  title: Text('settings_show_task_progress'.tr()),
                  value: prefs.showTaskProgress,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowTaskProgress(v);
                  },
                ),

                // Show daily stats
                SwitchListTile(
                  title: Text('settings_show_daily_stats'.tr()),
                  value: prefs.showDailyStats,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowDailyStats(v);
                  },
                ),

                // Show pomodoro counter
                SwitchListTile(
                  title: Text('settings_show_pomodoro_counter'.tr()),
                  value: prefs.showPomodoroCounter,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowPomodoroCounter(v);
                  },
                ),

                // Show session progress
                SwitchListTile(
                  title: Text('settings_show_session_progress'.tr()),
                  value: prefs.showSessionProgress,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowSessionProgress(v);
                  },
                ),
                const Divider(),

                // Default category
                ListTile(
                  title: Text('settings_default_category'.tr()),
                  subtitle: Text(
                    (prefs.defaultTaskCategory.isEmpty ? 'focus' : prefs.defaultTaskCategory)
                        .capitalizeFirstLetter(),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: ListView(
                            children: [
                              for (final t in tags)
                                RadioListTile<String>(
                                  title: Text(t.capitalizeFirstLetter()),
                                  value: t,
                                  groupValue: prefs.defaultTaskCategory,
                                  onChanged: (val) => Navigator.of(context).pop(val),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                    if (selected != null) {
                      await context.read<SettingCubit>().setDefaultCategory(selected);
                    }
                  },
                ),
                context.bottomPadding.height,
              ],
            );
          },
        ),
      ),
    );
  }
}

extension _Cap on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
