  import 'package:equatable/equatable.dart';

  /// Base class for all authentication events
  abstract class AuthEvent extends Equatable {
    const AuthEvent();

    @override
    List<Object> get props => [];
  }

  /// Event for register request
  class RegisterRequested extends AuthEvent {
    final String name;
    final String role;
    final String phone;
    final String birthDate;

    const RegisterRequested({
      required this.name,
      required this.role,
      required this.phone,
      required this.birthDate,
    });

    @override
    List<Object> get props => [name, role, phone, birthDate];

  }

  /// Event untuk request OTP via nomor telepon
  class RequestOtpRequested extends AuthEvent {
    final String phoneNumber;

    const RequestOtpRequested({required this.phoneNumber});

    @override
    List<Object> get props => [phoneNumber];
  }

  /// Event untuk verifikasi OTP
  class VerifyOtpRequested extends AuthEvent {
    final String phoneNumber;
    final String otp;

    const VerifyOtpRequested({
      required this.phoneNumber,
      required this.otp,
    });

    @override
    List<Object> get props => [phoneNumber, otp];
  }

  /// Event for logout request
  class LogoutRequested extends AuthEvent {
    const LogoutRequested();
  }

  /// Event to check authentication status on app start
  class AuthStatusChanged extends AuthEvent {
    const AuthStatusChanged();
  }
