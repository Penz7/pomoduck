import 'package:bloc/bloc.dart';
import 'package:pomo_duck/data/models/index.dart';
import 'package:pomo_duck/data/database/database_helper.dart';

import '../../core/base_state.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState()) {}
}
