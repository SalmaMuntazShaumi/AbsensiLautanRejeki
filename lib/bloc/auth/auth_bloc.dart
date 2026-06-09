import 'package:bloc/bloc.dart';
import 'package:lautanrejeki/bloc/auth/auth_event.dart';
import 'package:lautanrejeki/bloc/auth/auth_state.dart';
import 'package:lautanrejeki/repositories/auth_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<RequestOtpRequested>(_onRequestOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      final token = response['token'];
      final user = response['user'] as Map<String, dynamic>; // ← ambil nested user

      await SessionService.saveSession(
        token: token,
        userData: user, // ← simpan user object
      );

      emit(AuthSuccess(
        message: 'Login berhasil',
        userData: user, // ← emit user object
        token: token,
      ));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle request OTP event
  Future<void> _onRequestOtpRequested(
      RequestOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.requestOtp(
        phoneNumber: event.phoneNumber,
      );

      emit(
        OtpSent(
          phoneNumber: event.phoneNumber,
          message: response['message'] ?? 'OTP sent to WhatsApp',
        ),
      );
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handle verify OTP event
  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final userData = await _authRepository.verifyOtp(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );

      final token = userData['token'];
      final user = userData['user'] as Map<String, dynamic>;

      // SAVE SESSION
      await SessionService.saveSession(
        token: token,
        userData: user, // ← ganti
      );

      emit(AuthSuccess(
        message: 'Login successful',
        userData: user, // ← ganti
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
        role: event.role,
        phone: event.phone,
        birthDate: event.birthDate,
        email: event.email,
        password: event.password,
      );

      if (success) {
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