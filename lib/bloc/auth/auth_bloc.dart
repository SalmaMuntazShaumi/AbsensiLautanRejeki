import 'package:bloc/bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/repositories/auth_repository.dart';

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

      // Extract token if available, otherwise use a default or handle accordingly
      final token = userData['token'];
      emit(AuthSuccess(
        message: 'Login successful',
        userData: userData,
        token: token,
      ));
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
    // Check if user is already logged in
    // This can be extended to check saved tokens, user session, etc.
    emit(const AuthUnauthenticated());
  }
}
