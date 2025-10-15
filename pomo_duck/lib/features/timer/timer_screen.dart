import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'timer_cubit.dart';
import 'timer_state.dart';
import 'widgets/circular_timer_widget.dart';
import 'widgets/timer_controls_widget.dart';
import 'widgets/session_indicator_widget.dart';

/// Timer Screen - Màn hình timer chính
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerCubit(),
      child: const TimerView(),
    );
  }
}

/// Timer View - Main timer interface
class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
          
          // Statistics button
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatistics(context),
          ),
        ],
      ),
      body: BlocConsumer<TimerCubit, TimerState>(
        listener: (context, state) {
          // Handle session completion
          if (state.isSessionCompleted && state.sessionId != null) {
            _handleSessionCompletion(context, state);
          }
          
          // Handle errors
          if (state.isError && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Session Indicator
                  SessionIndicatorWidget(
                    state: state,
                    showProgress: true,
                    showNextSession: true,
                    showCycleInfo: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Circular Timer
                  CircularTimerWidget(
                    state: state,
                    size: 250,
                    strokeWidth: 12,
                    showProgressText: true,
                    showTimeText: true,
                    showSessionInfo: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Timer Status
                  TimerStatusWidget(state: state),
                  
                  const SizedBox(height: 24),
                  
                  // Timer Controls
                  TimerControlsWidget(
                    state: state,
                    showSecondaryControls: true,
                    showResetButton: true,
                    showCompleteButton: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build quick actions
  Widget _buildQuickActions(BuildContext context, TimerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Task Selection
        _buildQuickActionButton(
          context,
          icon: Icons.task_alt,
          label: 'Select Task',
          onPressed: () => _showTaskSelection(context),
        ),
        
        // Session History
        _buildQuickActionButton(
          context,
          icon: Icons.history,
          label: 'History',
          onPressed: () => _showSessionHistory(context),
        ),
        
        // Cycle Info
        if (state.sessionType == 'work')
          _buildQuickActionButton(
            context,
            icon: Icons.timeline,
            label: 'Cycle',
            onPressed: () => _showCycleInfo(context),
          ),
      ],
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Handle session completion
  void _handleSessionCompletion(BuildContext context, TimerState state) {
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${state.sessionTypeDisplayName} Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Color(state.sessionTypeColor),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.sessionType == 'work'
                  ? 'Great job! Time for a break.'
                  : 'Break time is over. Ready to focus?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Next: ${state.nextSessionType == 'work' ? 'Focus Time' : 'Break Time'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TimerCubit>().completeSession();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Show settings
  void _showSettings(BuildContext context) {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  /// Show statistics
  void _showStatistics(BuildContext context) {
    // TODO: Navigate to statistics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics coming soon!')),
    );
  }

  /// Show task selection
  void _showTaskSelection(BuildContext context) {
    // TODO: Show task selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task selection coming soon!')),
    );
  }

  /// Show session history
  void _showSessionHistory(BuildContext context) {
    // TODO: Show session history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session history coming soon!')),
    );
  }

  /// Show cycle info
  void _showCycleInfo(BuildContext context) {
    // TODO: Show cycle information
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cycle info coming soon!')),
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
