import 'package:flutter/material.dart';
import '../timer_state.dart';

/// Session Indicator Widget - Hiển thị thông tin session hiện tại
class SessionIndicatorWidget extends StatelessWidget {
  final TimerState state;
  final bool showProgress;
  final bool showNextSession;
  final bool showCycleInfo;

  const SessionIndicatorWidget({
    super.key,
    required this.state,
    this.showProgress = true,
    this.showNextSession = true,
    this.showCycleInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(state.sessionTypeColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(state.sessionTypeColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Session Info
          _buildCurrentSessionInfo(context),
          
          if (showProgress) ...[
            const SizedBox(height: 12),
            _buildProgressInfo(context),
          ],
          
          if (showNextSession) ...[
            const SizedBox(height: 12),
            _buildNextSessionInfo(context),
          ],
          
          if (showCycleInfo && state.sessionType == 'work') ...[
            const SizedBox(height: 12),
            _buildCycleInfo(context),
          ],
        ],
      ),
    );
  }

  /// Build current session info
  Widget _buildCurrentSessionInfo(BuildContext context) {
    return Row(
      children: [
        // Session type icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(state.sessionTypeColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSessionIcon(state.sessionType),
            color: Colors.white,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Session info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.sessionTypeDisplayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Color(state.sessionTypeColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.sessionTypeDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Session status
        _buildSessionStatus(context),
      ],
    );
  }

  /// Build progress info
  Widget _buildProgressInfo(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: state.progressPercentage,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(state.sessionTypeColor),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Progress details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(state.progressPercentage * 100).toInt()}% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Color(state.sessionTypeColor),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${state.formattedElapsedTime} / ${state.formattedPlannedDuration}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build next session info
  Widget _buildNextSessionInfo(BuildContext context) {
    final nextSessionType = state.nextSessionType;
    final nextSessionDuration = _getNextSessionDuration(nextSessionType);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _getSessionIcon(nextSessionType),
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Next: ${_getSessionDisplayName(nextSessionType)} (${_formatDuration(nextSessionDuration)})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build cycle info
  Widget _buildCycleInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          // Cycle progress
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Colors.blue.shade700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Pomodoro Cycle',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Cycle progress bar
          LinearProgressIndicator(
            value: state.cycleProgressPercentage,
            backgroundColor: Colors.blue.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
          
          const SizedBox(height: 8),
          
          // Cycle status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.pomodoroProgressText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                state.cycleStatus,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build session status
  Widget _buildSessionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get session icon
  IconData _getSessionIcon(String sessionType) {
    switch (sessionType) {
      case 'work':
        return Icons.work;
      case 'shortBreak':
        return Icons.coffee;
      case 'longBreak':
        return Icons.restaurant;
      default:
        return Icons.work;
    }
  }

  /// Get session display name
  String _getSessionDisplayName(String sessionType) {
    switch (sessionType) {
      case 'work':
        return 'Focus Time';
      case 'shortBreak':
        return 'Short Break';
      case 'longBreak':
        return 'Long Break';
      default:
        return 'Focus Time';
    }
  }

  /// Get next session duration
  int _getNextSessionDuration(String sessionType) {
    final settings = state.settings;
    if (settings == null) return 0;
    
    switch (sessionType) {
      case 'work':
        return settings.workDuration;
      case 'shortBreak':
        return settings.shortBreakDuration;
      case 'longBreak':
        return settings.longBreakDuration;
      default:
        return settings.workDuration;
    }
  }

  /// Format duration
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }

  /// Get status color
  Color _getStatusColor() {
    if (state.isRunning) {
      return Colors.green;
    } else if (state.isPaused) {
      return Colors.orange;
    } else if (state.isSessionCompleted) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  /// Get status text
  String _getStatusText() {
    if (state.isRunning) {
      return 'Running';
    } else if (state.isPaused) {
      return 'Paused';
    } else if (state.isSessionCompleted) {
      return 'Completed';
    } else {
      return 'Ready';
    }
  }
}

/// Session Type Chip - Chip hiển thị loại session
class SessionTypeChip extends StatelessWidget {
  final String sessionType;
  final bool isActive;
  final VoidCallback? onTap;

  const SessionTypeChip({
    super.key,
    required this.sessionType,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getSessionColor(sessionType);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSessionIcon(sessionType),
              color: isActive ? Colors.white : color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _getSessionDisplayName(sessionType),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSessionColor(String sessionType) {
    switch (sessionType) {
      case 'work':
        return const Color(0xFF4CAF50);
      case 'shortBreak':
        return const Color(0xFF2196F3);
      case 'longBreak':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getSessionIcon(String sessionType) {
    switch (sessionType) {
      case 'work':
        return Icons.work;
      case 'shortBreak':
        return Icons.coffee;
      case 'longBreak':
        return Icons.restaurant;
      default:
        return Icons.work;
    }
  }

  String _getSessionDisplayName(String sessionType) {
    switch (sessionType) {
      case 'work':
        return 'Focus';
      case 'shortBreak':
        return 'Break';
      case 'longBreak':
        return 'Long Break';
      default:
        return 'Focus';
    }
  }
}
