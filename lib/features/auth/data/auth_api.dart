import 'package:dio/dio.dart';

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final token = response.data?['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('토큰을 가져오지 못했습니다.');
    }
    return token;
  }
}
