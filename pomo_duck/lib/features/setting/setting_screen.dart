import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomo_duck/common/extensions/context_extension.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/common/global_bloc/language/language_cubit.dart';
import 'package:pomo_duck/common/utils/font_size.dart';
import 'package:pomo_duck/common/widgets/text.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';

import 'setting_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  bool _isChangingLanguage = false;
  String? _lastLanguageChange;
  DateTime? _lastChangeTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: LCText.medium(
            LocaleKeys.settings_title,
            fontSize: FontSizes.big,
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            if (state is SettingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final loaded = state as SettingLoaded;
            final prefs = loaded.preferences;

            Future<void> changeLanguage(String v) async {
              final now = DateTime.now();
              if (_lastLanguageChange == v &&
                  _lastChangeTime != null &&
                  now.difference(_lastChangeTime!).inMilliseconds < 1000) {
                return;
              }

              setState(() {
                _isChangingLanguage = true;
                _lastLanguageChange = v;
                _lastChangeTime = now;
              });

              try {
                final locale = v == 'en'
                    ? const Locale('en', 'US')
                    : const Locale('vi', 'VN');

                _animationController.reverse();
                await Future.wait([
                  context.read<SettingCubit>().changeLanguage(v),
                  context.setLocale(locale),
                ]);

                if (!mounted) return;
                if (context.mounted) {
                  context.read<LanguageCubit>().setNewLanguage(locale);
                }
                _animationController.forward();
              } finally {
                if (mounted) {
                  setState(() {
                    _isChangingLanguage = false;
                  });
                }
              }
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Language
                  ListTile(
                    title: LCText.medium(
                      LocaleKeys.settings_language,
                      fontSize: FontSizes.medium,
                    ),
                    subtitle: LCText.base(
                      prefs.language == 'en'
                          ? LocaleKeys.english.tr()
                          : LocaleKeys.vietnamese.tr(),
                    ),
                    trailing: _isChangingLanguage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : DropdownButton<String>(
                            value: prefs.language,
                            items: [
                              DropdownMenuItem(
                                  value: 'vi',
                                  child: LCText.base(LocaleKeys.vietnamese)),
                              DropdownMenuItem(
                                  value: 'en',
                                  child: LCText.base(LocaleKeys.english)),
                            ],
                            onChanged: _isChangingLanguage
                                ? null
                                : (v) async {
                                    if (v == null) return;
                                    await changeLanguage(v);
                                  },
                          ),
                  ),
                  const Divider(),

                  // Theme (dark / light) - Ẩn theo yêu cầu
                  // SwitchListTile(
                  //   title: Text('settings_dark_mode'.tr()),
                  //   value: prefs.appTheme == 'dark',
                  //   onChanged: (v) async {
                  //     await context.read<SettingCubit>().setAppTheme(v ? 'dark' : 'light');
                  //   },
                  // ),
                  // const Divider(),

                  // Date format
                  ListTile(
                    title: LCText.medium(LocaleKeys.settings_date_format),
                    subtitle: LCText.base(prefs.dateFormat),
                    trailing: DropdownButton<String>(
                      value: prefs.dateFormat,
                      items: [
                        DropdownMenuItem(
                            value: 'dd/MM/yyyy',
                            child: LCText.base(LocaleKeys.date_format_dd_mm_yyyy)),
                        DropdownMenuItem(
                            value: 'MM/dd/yyyy',
                            child: LCText.base(LocaleKeys.date_format_mm_dd_yyyy)),
                        DropdownMenuItem(
                            value: 'yyyy-MM-dd',
                            child: LCText.base(LocaleKeys.date_format_yyyy_mm_dd)),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await context.read<SettingCubit>().setDateFormat(v);
                      },
                    ),
                  ),

                  // Time format
                  ListTile(
                    title: LCText.medium(LocaleKeys.settings_time_format),
                    subtitle: LCText.base(prefs.timeFormat),
                    trailing: DropdownButton<String>(
                      value: prefs.timeFormat,
                      items: [
                        DropdownMenuItem(
                            value: '24h', child: LCText.base(LocaleKeys.time_format_24h)),
                        DropdownMenuItem(
                            value: '12h', child: LCText.base(LocaleKeys.time_format_12h)),
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
                    title: LCText.medium(LocaleKeys.settings_notifications),
                    value: prefs.showNotifications,
                    onChanged: (v) async {
                      await context.read<SettingCubit>().setNotifications(v);
                    },
                  ),

                  // Enable notification sound
                  SwitchListTile(
                    title: LCText.medium(LocaleKeys.settings_enable_notification_sound),
                    value: prefs.enableNotificationSound,
                    onChanged: (v) async {
                      await context.read<SettingCubit>().setEnableNotificationSound(v);
                    },
                  ),
                  const Divider(),

                  // Haptic - Ẩn theo yêu cầu
                  // SwitchListTile(
                  //   title: Text('settings_haptic'.tr()),
                  //   value: prefs.enableHapticFeedback,
                  //   onChanged: (v) async {
                  //     await context.read<SettingCubit>().setHaptic(v);
                  //   },
                  // ),
                  SwitchListTile(
                    title: LCText.medium(LocaleKeys.settings_show_task_progress),
                    value: prefs.showTaskProgress,
                    onChanged: (v) async {
                      await context.read<SettingCubit>().setShowTaskProgress(v);
                    },
                  ),
                  SwitchListTile(
                    title: LCText.medium(LocaleKeys.settings_show_daily_stats),
                    value: prefs.showDailyStats,
                    onChanged: (v) async {
                      await context.read<SettingCubit>().setShowDailyStats(v);
                    },
                  ),
                  SwitchListTile(
                    title: LCText.medium(LocaleKeys.settings_show_pomodoro_counter),
                    value: prefs.showPomodoroCounter,
                    onChanged: (v) async {
                      await context
                          .read<SettingCubit>()
                          .setShowPomodoroCounter(v);
                    },
                  ),
                  SwitchListTile(
                    title: LCText.medium(LocaleKeys.settings_show_session_progress),
                    value: prefs.showSessionProgress,
                    onChanged: (v) async {
                      await context
                          .read<SettingCubit>()
                          .setShowSessionProgress(v);
                    },
                  ),
                  const Divider(),
                  context.bottomPadding.height,
                ],
              ),
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
