import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PomodoroEvent {}

class StartTimer extends PomodoroEvent {}
class PauseTimer extends PomodoroEvent {}
class ResetTimer extends PomodoroEvent {}
class _Tick extends PomodoroEvent {
  final int duration;
  _Tick(this.duration);
}

class PomodoroState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isBreak;

  PomodoroState({
    required this.remainingSeconds,
    required this.isRunning,
    required this.isBreak,
  });

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  static const int _workDuration = 25 * 60; // 25 minutes
  static const int _breakDuration = 5 * 60; // 5 minutes

  StreamSubscription<int>? _tickerSubscription;

  PomodoroBloc() : super(PomodoroState(
          remainingSeconds: _workDuration,
          isRunning: false,
          isBreak: false,
        )) {
    on<StartTimer>(_onStart);
    on<PauseTimer>(_onPause);
    on<ResetTimer>(_onReset);
    on<_Tick>(_onTick);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStart(StartTimer event, Emitter<PomodoroState> emit) {
    if (state.isRunning) return;

    _tickerSubscription?.cancel();
    emit(PomodoroState(
      remainingSeconds: state.remainingSeconds,
      isRunning: true,
      isBreak: state.isBreak,
    ));

    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => state.remainingSeconds - 1)
        .take(state.remainingSeconds)
        .listen((seconds) {
      add(_Tick(seconds));
    });
  }

  void _onPause(PauseTimer event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    emit(PomodoroState(
      remainingSeconds: state.remainingSeconds,
      isRunning: false,
      isBreak: state.isBreak,
    ));
  }

  void _onReset(ResetTimer event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    emit(PomodoroState(
      remainingSeconds: state.isBreak ? _breakDuration : _workDuration,
      isRunning: false,
      isBreak: state.isBreak,
    ));
  }

  void _onTick(_Tick event, Emitter<PomodoroState> emit) {
    if (event.duration > 0) {
      emit(PomodoroState(
        remainingSeconds: event.duration,
        isRunning: true,
        isBreak: state.isBreak,
      ));
    } else {
      final nextBreak = !state.isBreak;
      final nextDuration = nextBreak ? _breakDuration : _workDuration;
      _tickerSubscription?.cancel();
      emit(PomodoroState(
        remainingSeconds: nextDuration,
        isRunning: false,
        isBreak: nextBreak,
      ));
    }
  }
}
