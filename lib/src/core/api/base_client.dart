import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:map_test/src/core/util/exceptions.dart';

class BaseClient {
  BaseClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 6000),
      receiveTimeout: const Duration(milliseconds: 6000),
      contentType: 'application/json',
      validateStatus: (status) => status == 200 || status == 201,
    ));

    _setHeaders();
    _addInterceptors();
  }

  late final Dio _dio;
  static String baseUrl = '';

  void _setHeaders() {
    final token = getToken();
    log('token is $token');

    _dio.options.headers = {
      Headers.acceptHeader: '*/*',
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  void _addInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          error: false,
        ),
      );
    }
  }

  void _setAuthCookie() {
    final token = getToken();
    if (token != null) {
      _dio.options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
  }

  Future<Response> _request(
    Future<Response> Function() request,
  ) async {
    try {
      _setAuthCookie();
      return await request();
    } catch (e) {
      throw ApiException.getException(e as DioException);
    }
  }

  Future<Response> get(String uri, {Map<String, dynamic>? queryParameters}) {
    return _request(() => _dio.get(uri, queryParameters: queryParameters));
  }

  Future<Response> post(
    String uri, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extraHeaders,
  }) {
    return _request(() {
      if (extraHeaders != null) {
        _dio.options.headers.addAll(extraHeaders);
      }
      return _dio.post(uri,
          data: data ?? formData, queryParameters: queryParameters);
    });
  }

  Future<Response> put(String uri,
      {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) {
    return _request(
        () => _dio.put(uri, data: data, queryParameters: queryParameters));
  }

  Future<Response> patch(String uri,
      {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) {
    return _request(
        () => _dio.patch(uri, data: data, queryParameters: queryParameters));
  }

  Future<Response> delete(String uri,
      {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) {
    return _request(
        () => _dio.delete(uri, data: data, queryParameters: queryParameters));
  }

  String? getToken() {
    return '';
  }
}
