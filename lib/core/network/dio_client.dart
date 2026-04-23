import 'package:dio/dio.dart';

final Dio dioClient = Dio(
  BaseOptions(
    baseUrl: 'https://reqres.in/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: const {'x-api-key': 'reqres-free-v1'},
  ),
);
