import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'pomodoro_state.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  PomodoroCubit() : super(PomodoroInitial());
}
