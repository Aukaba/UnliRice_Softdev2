import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared Supabase client instance for all auth logic files.
final supabaseClient = Supabase.instance.client;

/// Converts raw Supabase / Dart exception messages into friendly text.
String friendlyError(Object e) {
  final raw = e is AuthException
      ? e.message.toLowerCase()
      : e is PostgrestException
          ? e.message.toLowerCase()
          : e.toString().toLowerCase();

  // Auth errors
  if (raw.contains('invalid login credentials') ||
      raw.contains('invalid email or password') ||
      raw.contains('wrong password')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (raw.contains('email not confirmed')) {
    return 'Please verify your email before logging in.';
  }
  if (raw.contains('user already registered') ||
      raw.contains('already been registered')) {
    return 'An account with this email already exists.';
  }
  if (raw.contains('password should be at least')) {
    return 'Password must be at least 6 characters long.';
  }
  if (raw.contains('unable to validate email address') ||
      raw.contains('invalid email')) {
    return 'Please enter a valid email address.';
  }
  if (raw.contains('same_password') ||
      raw.contains('new password should be different')) {
    return 'Your new password must be different from your current one.';
  }

  // Database / RLS errors
  if (raw.contains('row-level security') || raw.contains('42501')) {
    return 'Account created but profile could not be saved. Please contact support.';
  }
  if (raw.contains('duplicate key') || raw.contains('23505')) {
    return 'An account with this information already exists.';
  }

  // Network errors
  if (raw.contains('network') || raw.contains('socket')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (raw.contains('rate limit') || raw.contains('too many requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }

  // OTP errors
  if (raw.contains('otp') ||
      raw.contains('token') ||
      raw.contains('expired')) {
    return 'The code is invalid or has expired. Please request a new one.';
  }

  // Fallback: strip prefixes and capitalise
  final cleaned = e
      .toString()
      .replaceAll('Exception: ', '')
      .replaceAll('AuthException: ', '')
      .replaceAll('AuthApiException: ', '')
      .replaceAll('PostgrestException: ', '');
  if (cleaned.isEmpty) return 'Something went wrong. Please try again.';
  return cleaned[0].toUpperCase() + cleaned.substring(1);
}
