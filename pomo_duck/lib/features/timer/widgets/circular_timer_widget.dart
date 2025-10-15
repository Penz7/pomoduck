import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../timer_state.dart';

/// Circular Timer Widget - Hiển thị timer với circular progress
class CircularTimerWidget extends StatelessWidget {
  final TimerState state;
  final double size;
  final double strokeWidth;
  final bool showProgressText;
  final bool showTimeText;
  final bool showSessionInfo;

  const CircularTimerWidget({
    super.key,
    required this.state,
    this.size = 200.0,
    this.strokeWidth = 8.0,
    this.showProgressText = true,
    this.showTimeText = true,
    this.showSessionInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular Progress Indicator
        CircularPercentIndicator(
          radius: size / 2,
          lineWidth: strokeWidth,
          percent: state.progressPercentage,
          center: _buildCenterContent(context),
          progressColor: Color(state.sessionTypeColor),
          backgroundColor: Colors.grey.shade300,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 1000,
        ),
        
        const SizedBox(height: 24),
        
        // Session Info
        if (showSessionInfo) _buildSessionInfo(context),
        
        const SizedBox(height: 16),
        
        // Progress Text
        if (showProgressText) _buildProgressText(context),
      ],
    );
  }

  /// Build center content của circular indicator
  Widget _buildCenterContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Time Display
        if (showTimeText) _buildTimeDisplay(context),
        
        const SizedBox(height: 8),
        
        // Session Type
        _buildSessionType(context),
      ],
    );
  }

  /// Build time display
  Widget _buildTimeDisplay(BuildContext context) {
    return Text(
      state.formattedTimeRemaining,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Color(state.sessionTypeColor),
        fontSize: 32,
      ),
    );
  }

  /// Build session type indicator
  Widget _buildSessionType(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(state.sessionTypeColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(state.sessionTypeColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        state.sessionTypeDisplayName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Color(state.sessionTypeColor),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build session info
  Widget _buildSessionInfo(BuildContext context) {
    return Column(
      children: [
        // Session description
        Text(
          state.sessionTypeDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Session progress
        Text(
          state.sessionProgressText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: state.isRunning 
                ? Color(state.sessionTypeColor)
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build progress text
  Widget _buildProgressText(BuildContext context) {
    return Column(
      children: [
        // Elapsed time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeInfo(
              context,
              'Elapsed',
              state.formattedElapsedTime,
              Colors.grey.shade600,
            ),
            _buildTimeInfo(
              context,
              'Total',
              state.formattedPlannedDuration,
              Colors.grey.shade600,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Pomodoro progress
        if (state.sessionType == 'work') _buildPomodoroProgress(context),
      ],
    );
  }

  /// Build time info
  Widget _buildTimeInfo(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build pomodoro progress
  Widget _buildPomodoroProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: state.cycleProgressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(state.sessionTypeColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${state.completedPomodoros}/4',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(state.sessionTypeColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress text
          Text(
            state.pomodoroProgressText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
