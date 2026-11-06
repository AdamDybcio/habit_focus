import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/logout_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_state.dart';

/// App-wide authentication state that drives navigation.
class SessionCubit extends Cubit<SessionState> {
  /// Creates the cubit. [sessionEvents] reports a session that the backend
  /// has rejected.
  new(this._checkSession, this._logoutUseCase, SessionEvents sessionEvents)
    : super(const SessionUnknown()) {
    _expiredSubscription = sessionEvents.expired.listen(
      (_) => _emitIfOpen(const SessionUnauthenticated()),
    );
  }

  final CheckSessionUseCase _checkSession;
  final LogoutUseCase _logoutUseCase;
  late final StreamSubscription<void> _expiredSubscription;

  /// Reads the stored session and publishes the initial state.
  Future<void> start() async {
    final hasSession = await _checkSession();
    if (hasSession) {
      _emitIfOpen(const SessionAuthenticated());
    } else {
      _emitIfOpen(const SessionUnauthenticated());
    }
  }

  /// Marks the user as logged in after a successful login.
  void loggedIn() => _emitIfOpen(const SessionAuthenticated());

  /// Logs the user out on this device.
  Future<void> logout() async {
    await _logoutUseCase();
    _emitIfOpen(const SessionUnauthenticated());
  }

  void _emitIfOpen(SessionState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return await super.close();
  }
}
