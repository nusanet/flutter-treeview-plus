import 'dart:async';

import 'package:bloc/bloc.dart';

part 'treeview_event.dart';

part 'treeview_state.dart';

class TreeviewBloc extends Bloc<TreeviewEvent, TreeviewState> {
  TreeviewBloc() : super(InitialTreeviewState()) {
    on<UpdateTreeviewEvent>(_onUpdateTreeviewEvent);
  }

  FutureOr<void> _onUpdateTreeviewEvent(
      UpdateTreeviewEvent event, Emitter<TreeviewState> emit) {
    emit(UpdatedTreeviewState());
  }
}
