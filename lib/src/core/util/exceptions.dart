import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Custom exception class for handling exceptions in the api_client
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  static ApiException getException(DioException err) {
    debugPrint('DioError: ${err.message}');
    debugPrint('DioError: ${err.response?.data}');

    switch (err.type) {
      case DioExceptionType.cancel:
        return OtherExceptions('Request was cancelled');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return InternetConnectException('Timeout error. Try again');
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return InternetConnectException('Bad certificate. Try again');
      case DioExceptionType.unknown:
        if (err.error is FormatException) {
          return FormatException();
        }
        if (err.error is SocketException) {
          return InternetConnectException("No internet connection. Try again");
        }
        break;
      case DioExceptionType.badResponse:
        return _handleBadResponse(err);
    }
    return OtherExceptions('An error occurred. Try again');
  }

  static ApiException _handleBadResponse(DioException err) {
    try {
      if (err.response?.data != null) {
        final data = err.response!.data as Map;
        if (data['message'] is Map) {
          return OtherExceptions(data['message']['message']);
        }
        return OtherExceptions(data['message']);
      } else {
        return _handleStatusCode(err.response?.statusCode);
      }
    } catch (e) {
      log(e.toString());
      return OtherExceptions('An error occurred. Try again');
    }
  }

  static ApiException _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 500:
        return InternalServerException();
      case 404:
      case 502:
        return OtherExceptions('Server error. Try again');
      case 400:
        return OtherExceptions('Bad request. Try again');
      case 403:
      case 401:
        return UnAuthorizedException();
      default:
        return OtherExceptions('An error occurred. Try again');
    }
  }
}

class OtherExceptions implements ApiException {
  OtherExceptions(this.newMessage);

  final String newMessage;

  @override
  String toString() => message;

  @override
  String get message => newMessage;
}

class FormatException implements ApiException {
  @override
  String toString() => message;

  @override
  String get message => 'An error occurred. Try again';
}

class InternetConnectException implements ApiException {
  InternetConnectException(this.newMessage);

  final String newMessage;

  @override
  String toString() => message;

  @override
  String get message => newMessage;
}

class InternalServerException implements ApiException {
  @override
  String toString() => message;

  @override
  String get message => 'Internal server error. Try again';
}

class UnAuthorizedException implements ApiException {
  @override
  String toString() => message;

  @override
  String get message => 'Unauthorized. Try again';
}

class CacheException implements Exception {
  CacheException(this.message);

  final String message;

  @override
  String toString() => message;
}
