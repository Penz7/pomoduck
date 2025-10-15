import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../timer_cubit.dart';
import '../timer_state.dart';

/// Timer Controls Widget - Các nút điều khiển timer
class TimerControlsWidget extends StatelessWidget {
  final TimerState state;
  final bool showSecondaryControls;
  final bool showResetButton;
  final bool showCompleteButton;

  const TimerControlsWidget({
    super.key,
    required this.state,
    this.showSecondaryControls = true,
    this.showResetButton = true,
    this.showCompleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        return Column(
          children: [
            // Primary Controls
            _buildPrimaryControls(context),
            
            if (showSecondaryControls) ...[
              const SizedBox(height: 16),
              _buildSecondaryControls(context),
            ],
          ],
        );
      },
    );
  }

  /// Build primary controls (Start/Pause/Stop)
  Widget _buildPrimaryControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Start/Resume Button
        _buildControlButton(
          context,
          icon: state.isRunning ? Icons.pause : Icons.play_arrow,
          label: state.isRunning ? 'Pause' : (state.canResume ? 'Resume' : 'Start'),
          color: state.isRunning ? Colors.orange : Colors.green,
          onPressed: state.isRunning 
              ? () => context.read<TimerCubit>().pauseTimer()
              : (state.canResume 
                  ? () => context.read<TimerCubit>().resumeTimer()
                  : () => context.read<TimerCubit>().startTimer()),
          enabled: state.canStart || state.canPause || state.canResume,
        ),
        
        // Stop Button
        _buildControlButton(
          context,
          icon: Icons.stop,
          label: 'Stop',
          color: Colors.red,
          onPressed: state.canStop 
              ? () => context.read<TimerCubit>().stopTimer()
              : null,
          enabled: state.canStop,
        ),
      ],
    );
  }

  /// Build secondary controls (Reset/Complete)
  Widget _buildSecondaryControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset Button
        if (showResetButton)
          _buildControlButton(
            context,
            icon: Icons.refresh,
            label: 'Reset',
            color: Colors.grey,
            onPressed: state.canReset 
                ? () => context.read<TimerCubit>().resetTimer()
                : null,
            enabled: state.canReset,
            isSecondary: true,
          ),
        
        // Complete Session Button
        if (showCompleteButton && state.canCompleteSession)
          _buildControlButton(
            context,
            icon: Icons.check_circle,
            label: 'Complete',
            color: Colors.green,
            onPressed: () => context.read<TimerCubit>().completeSession(),
            enabled: state.canCompleteSession,
            isSecondary: true,
          ),
      ],
    );
  }

  /// Build control button
  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool enabled,
    bool isSecondary = false,
  }) {
    final buttonSize = isSecondary ? 48.0 : 64.0;
    final iconSize = isSecondary ? 20.0 : 24.0;
    
    return Column(
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: enabled ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
            boxShadow: enabled ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(buttonSize / 2),
              onTap: enabled ? onPressed : null,
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.grey.shade500,
                size: iconSize,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: enabled ? color : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Timer Action Button - Nút hành động đơn lẻ
class TimerActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  const TimerActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 48,
      decoration: BoxDecoration(
        color: enabled ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(24),
        boxShadow: enabled ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        enabled ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: enabled ? Colors.white : Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: enabled ? Colors.white : Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Timer Status Widget - Hiển thị trạng thái timer
class TimerStatusWidget extends StatelessWidget {
  final TimerState state;

  const TimerStatusWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            state.sessionProgressText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (state.isRunning) {
      return Color(state.sessionTypeColor);
    } else if (state.isPaused) {
      return Colors.orange;
    } else if (state.isSessionCompleted) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (state.isRunning) {
      return Icons.play_circle_filled;
    } else if (state.isPaused) {
      return Icons.pause_circle_filled;
    } else if (state.isSessionCompleted) {
      return Icons.check_circle;
    } else {
      return Icons.radio_button_unchecked;
    }
  }
}
