import 'package:bloc/bloc.dart';

import '../../core/base_state.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState()) {}
}
