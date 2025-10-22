import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pomo_duck/common/extensions/size_extension.dart';
import 'package:pomo_duck/features/pomodoro/pomodoro_cubit.dart';
import 'package:pomo_duck/generated/assets/assets.gen.dart';
import 'package:pomo_duck/common/global_bloc/config_pomodoro/config_pomodoro_cubit.dart';
import 'package:pomo_duck/generated/locale_keys.g.dart';
import 'package:pomo_duck/common/widgets/score_display.dart';
import 'package:pomo_duck/common/global_bloc/score/score_bloc.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  List<String> get _pauseQuotes {
    final quotes = <String>[];
    for (int i = 0; i < 5; i++) {
      quotes.add(tr('pause_quotes_$i'));
    }
    return quotes;
  }

  void _showPauseDialog(BuildContext context) {
    // Chọn ngẫu nhiên 1 câu nói khi pause
    final randomQuote = _pauseQuotes[Random().nextInt(_pauseQuotes.length)];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(LocaleKeys.hmmmmm.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiển thị câu nói ngẫu nhiên
              Text(randomQuote),
              10.height,
              Assets.images.duckPause.image(
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PomodoroCubit>().resume();
              },
              child: Text(
                LocaleKeys.resume.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleStopAndReset(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                LocaleKeys.stop.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleStopAndReset(BuildContext context) async {
    await context.read<PomodoroCubit>().pause();
    if (context.mounted) {
      await context.read<PomodoroCubit>().stop();
      // Thông báo reset streak do dừng giữa chừng
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Streak đã được reset do dừng giữa chừng'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      // Cập nhật điểm số hiển thị
      if (context.mounted) {
        context.read<ScoreBloc>().updateScore();
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showTaskCompletionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Text(LocaleKeys.task_completed.tr()),
            ],
          ),
          content: Text(
            LocaleKeys.task_completed_message.tr(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Go back to home screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(LocaleKeys.great.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PomodoroCubit();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  20.height,
                  BlocListener<PomodoroCubit, PomodoroState>(
                    listener: (context, state) {
                      if (state is PomodoroTaskCompleted) {
                        _showTaskCompletionDialog(context);
                      }
                      context.read<ScoreBloc>().updateScore();
                    },
                    child: BlocBuilder<PomodoroCubit, PomodoroState>(
                      builder: (context, state) {
                        final mm = (state.remainingSeconds ~/ 60)
                            .toString()
                            .padLeft(2, '0');
                        final ss = (state.remainingSeconds % 60)
                            .toString()
                            .padLeft(2, '0');

                        final title = switch (state.sessionType) {
                          'work' => LocaleKeys.focus.tr(),
                          'shortBreak' => LocaleKeys.short_break.tr(),
                          'longBreak' => LocaleKeys.long_break.tr(),
                          _ => LocaleKeys.quack.tr(),
                        };
                        return Column(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (state.activeCycle != null)
                              BlocBuilder<ConfigPomodoroCubit,
                                  ConfigPomodoroState>(
                                builder: (context, configState) {
                                  final settings = configState.settings;
                                  final totalPomodoros =
                                      settings.effectivePomodoroCycleCount;
                                  return Text(
                                    '${state.activeCycle!.completedPomodoros}/$totalPomodoros Pomodoro',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  );
                                },
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '$mm:$ss',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  20.height,
                  BlocSelector<PomodoroCubit, PomodoroState, String>(
                    selector: (state) => state.sessionType,
                    builder: (context, sessionType) {
                      if (sessionType == 'work') {
                        return BlocBuilder<ConfigPomodoroCubit,
                            ConfigPomodoroState>(
                          buildWhen: (p, c) => p.selectedTag != c.selectedTag,
                          builder: (context, configState) {
                            final tag =
                                configState.selectedTag.trim().toLowerCase();
                            final dynamicPath = 'assets/images/duck_$tag.png';
                            return Image.asset(
                              dynamicPath,
                              width: 350,
                              height: 350,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Assets.images.duckFocus.image(
                                  width: 350,
                                  height: 350,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          },
                        );
                      }
                      return Assets.images.duckRelax.image(
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  16.height,
                  const MotivationTicker(),
                  40.height,
                  BlocBuilder<PomodoroCubit, PomodoroState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: state.isRunning
                            ? () async {
                                await context
                                    .read<PomodoroCubit>()
                                    .pause()
                                    .then((_) {
                                  if (!context.mounted) return;
                                  _showPauseDialog(context);
                                });
                              }
                            : () => context.read<PomodoroCubit>().resume(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: state.isRunning
                              ? Assets.images.icPause.image(
                                  width: 64,
                                  height: 64,
                                )
                              : Assets.images.icPlay.image(
                                  width: 64,
                                  height: 64,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MotivationMessage {
  final String primary;
  final String? secondary;

  const MotivationMessage({required this.primary, this.secondary});
}

class MotivationTicker extends StatefulWidget {
  const MotivationTicker({super.key});

  @override
  State<MotivationTicker> createState() => _MotivationTickerState();
}

class _MotivationTickerState extends State<MotivationTicker> {
  final Random _random = Random();
  int _currentIndex = 0;
  Timer? _timer;

  List<MotivationMessage> get _tickerMessages {
    final messages = <MotivationMessage>[];
    for (int i = 0; i < 7; i++) {
      messages.add(MotivationMessage(
        primary: tr('motivation_messages_${i}_primary'),
        secondary: tr('motivation_messages_${i}_secondary'),
      ));
    }
    return messages;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(_tickerMessages.length);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        int next;
        do {
          next = _random.nextInt(_tickerMessages.length);
        } while (next == _currentIndex && _tickerMessages.length > 1);
        _currentIndex = next;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = _tickerMessages[_currentIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Column(
        key: ValueKey<int>(_currentIndex),
        children: [
          Text(
            message.primary,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (message.secondary != null) ...[
            const SizedBox(height: 6),
            Text(
              message.secondary!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
