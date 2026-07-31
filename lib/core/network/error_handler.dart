import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static String friendly(
    dynamic error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    try {
      if (error is DioException && error.response?.statusCode == 403 &&
          (error.response?.data?.toString() ?? '').contains('<html')) {
        return "You're connected to a Wi-Fi that requires a sign-in page. Please switch networks and try again.";
      }

      if (_isNetworkError(error)) {
        return 'No internet connection. Please check network.';
      }

      if (error is DioException) {
        final data = error.response?.data;
        if (data is Map) {
          final msg = data['message'] ?? data['error'];
          if (msg is String && msg.isNotEmpty && !_isTechnicalJunk(msg)) {
            return msg;
          }
        }
      }
      
      if (error is String && error.isNotEmpty && !_isTechnicalJunk(error)) {
        return error;
      }
    } catch (_) {}
    return fallback;
  }

  static bool _isNetworkError(dynamic e) {
    if (e is SocketException) return true;
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.response == null) {
        return true;
      }
    }
    
    final lower = e.toString().toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('connection error') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection timeout') ||
        lower.contains('offline') ||
        lower.contains('handshake') ||
        lower.contains('software caused connection abort') ||
        lower.contains('no internet') ||
        lower.contains('connection closed') ||
        lower.contains('httpexception');
  }

  static bool _isTechnicalJunk(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('exception') ||
        lower.contains('stack trace') ||
        lower.contains('goroutine') ||
        lower.contains('panic') ||
        lower.contains('sql') ||
        lower.contains('pq:') ||
        lower.contains('null pointer') ||
        lower.contains('index out of') ||
        lower.contains('undefined') ||
        lower.contains('http') ||
        RegExp(r'\b[45]\d{2}\b').hasMatch(msg);
  }

  static void show(
    BuildContext context,
    dynamic error, {
    String fallback = 'Something went wrong. Please check internet connection.',
  }) {
    if (!context.mounted) return;
    final message = friendly(error, fallback: fallback);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Inter', )),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Inter', )),
          backgroundColor: const Color(0xFF133026),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
