import 'package:bloc/bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/repositories/auth_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';

/// AuthBloc handles all authentication-related events and emits appropriate states
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  /// Handle login request event
  Future<dynamic> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final userData = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      final token = userData['token'];

      // SAVE SESSION
      await SessionService.saveSession(
        token: token,
        userData: userData,
      );

      emit(
        AuthSuccess(
          message: 'Login successful',
          userData: userData,
          token: token,
        ),
      );
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final success = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
        birthDate: event.birthDate,
      );

      if (success) {
        // GANTI DI SINI
        emit(const AuthRegisterSuccess(
          message: 'Registration successful. Please login.',
        ));
      } else {
        emit(const AuthFailure(error: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle logout request event
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _authRepository.logout();

      // CLEAR SESSION
      await SessionService.clearSession();

      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle auth status check event
  Future<void> _onAuthStatusChanged(
      AuthStatusChanged event,
      Emitter<AuthState> emit,
      ) async {

    try {
      final isLoggedIn = await SessionService.isLoggedIn();

      if (isLoggedIn) {
        final userData = await SessionService.getUserData();
        final token = await SessionService.getToken();

        emit(
          AuthSuccess(
            message: 'Session restored',
            userData: userData ?? {},
            token: token ?? '',
          ),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
