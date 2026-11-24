import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtTokenStore {
  JwtTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
            );

  static const _tokenKey = 'jwt';
  final FlutterSecureStorage _storage;

  Future<void> save(String token) async {
    if (token.trim().isEmpty) {
      throw ArgumentError.value(token, 'token', 'El JWT no puede estar vacío.');
    }
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> delete() => _storage.delete(key: _tokenKey);
}
