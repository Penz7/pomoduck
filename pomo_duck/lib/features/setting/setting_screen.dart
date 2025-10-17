import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/global_bloc/language/language_cubit.dart';

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
          title: Text('settings.title'.tr()),
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
                  title: Text('settings.language'.tr()),
                  subtitle: Text(prefs.language == 'en' ? 'English' : 'Tiếng Việt'),
                  trailing: DropdownButton<String>(
                    value: prefs.language,
                    items: const [
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
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
                  title: Text('settings.dark_mode'.tr()),
                  value: prefs.appTheme == 'dark',
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setAppTheme(v ? 'dark' : 'light');
                  },
                ),
                const Divider(),

                // Date format
                ListTile(
                  title: Text('settings.date_format'.tr()),
                  subtitle: Text(prefs.dateFormat),
                  trailing: DropdownButton<String>(
                    value: prefs.dateFormat,
                    items: const [
                      DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
                      DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
                      DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await context.read<SettingCubit>().setDateFormat(v);
                    },
                  ),
                ),

                // Time format
                ListTile(
                  title: Text('settings.time_format'.tr()),
                  subtitle: Text(prefs.timeFormat),
                  trailing: DropdownButton<String>(
                    value: prefs.timeFormat,
                    items: const [
                      DropdownMenuItem(value: '24h', child: Text('24h')),
                      DropdownMenuItem(value: '12h', child: Text('12h')),
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
                  title: Text('settings.notifications'.tr()),
                  value: prefs.showNotifications,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setNotifications(v);
                  },
                ),

                // Notification sound picker
                ListTile(
                  title: Text('settings.notification_sound'.tr()),
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
                                  title: Text(s.capitalizeFirstLetter()),
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
                  title: Text('settings.haptic'.tr()),
                  value: prefs.enableHapticFeedback,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setHaptic(v);
                  },
                ),

                // Show task progress
                SwitchListTile(
                  title: Text('settings.show_task_progress'.tr()),
                  value: prefs.showTaskProgress,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowTaskProgress(v);
                  },
                ),

                // Show daily stats
                SwitchListTile(
                  title: Text('settings.show_daily_stats'.tr()),
                  value: prefs.showDailyStats,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowDailyStats(v);
                  },
                ),

                // Show pomodoro counter
                SwitchListTile(
                  title: Text('settings.show_pomodoro_counter'.tr()),
                  value: prefs.showPomodoroCounter,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowPomodoroCounter(v);
                  },
                ),

                // Show session progress
                SwitchListTile(
                  title: Text('settings.show_session_progress'.tr()),
                  value: prefs.showSessionProgress,
                  onChanged: (v) async {
                    await context.read<SettingCubit>().setShowSessionProgress(v);
                  },
                ),
                const Divider(),

                // Default category
                ListTile(
                  title: Text('settings.default_category'.tr()),
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
