# Ejercicios avanzados de desarrollo móvil

Proyecto de práctica aislado en Flutter/Dart. Incluye la base local de notas con Drift, consumo de tasas con Dio y almacenamiento de JWT con `flutter_secure_storage`.

## Ejecutar y probar

Requiere Flutter 3.50 o posterior y Dart 3.14 o posterior.

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

La pantalla consulta `https://api.exchangerate-api.com/v4/latest/MXN`, muestra las tasas y permite reintentar tras un error. La llamada clasifica timeout, fallo de conexión, HTTP 404, HTTP 5xx y respuestas mal formadas.

## 3.1 — Flujo Git

El historial se prepara en `main` y `feature/login`: commit inicial, dos commits de la feature y un cambio concurrente en `main` sobre la misma línea. Se resuelve el conflicto mediante merge, se publica `feature/login` y se abre un Pull Request hacia `main`.

## 3.2 — Modelo local con Drift

`Categories` contiene nombre y color; `Notes` contiene título, contenido, fecha y `categoryId` como clave foránea. `NotesDao.getByCategory` devuelve las notas de una categoría en fecha descendente; `watchByCategory` expone la misma consulta como stream.

Drift genera `lib/data/app_database.g.dart`. Tras cambiar tablas o DAO, vuelve a ejecutar `build_runner`.

## 3.3 — API de tasas

`ExchangeRates.fromJson` valida el JSON y convierte los valores numéricos. `ExchangeRatesService` configura timeouts con Dio y transforma errores de red/HTTP en errores de dominio que la vista muestra con opción de reintento.

## 3.4 — JWT y almacenamiento seguro

El ejemplo ejecutable está en `lib/security/jwt_token_store.dart`. Guarda, recupera y elimina un JWT sin escribirlo en logs ni preferencias sin cifrar. En Android, `flutter_secure_storage` usa Android Keystore y cifrado AES-GCM/RSA-OAEP por defecto; en iOS usa Keychain con acceso solo mientras el dispositivo está desbloqueado y ligado al dispositivo.

### Android nativo: EncryptedSharedPreferences (legado)

`EncryptedSharedPreferences` pertenece a Jetpack Security Crypto y está deprecado para nuevas implementaciones. Se muestra por compatibilidad con el ejercicio; para una app nueva usa la configuración actual del plugin (o Android Keystore directamente).

```kotlin
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val securePreferences = EncryptedSharedPreferences.create(
    context,
    "secure_preferences",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

securePreferences.edit().putString("jwt", token).apply()
val savedToken = securePreferences.getString("jwt", null)
```

### iOS nativo: Keychain Services

El equivalente nativo usa un elemento genérico de Keychain. El atributo `WhenUnlockedThisDeviceOnly` evita migrar el token a otro dispositivo.

```swift
import Foundation
import Security

enum TokenKeychain {
    private static let service = Bundle.main.bundleIdentifier ?? "NotesApp"
    private static let account = "jwt"

    static func save(_ token: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: Data(token.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            attributes.forEach { item[$0.key] = $0.value }
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.status(addStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.status(status)
        }
    }

    static func read() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.status(status)
        }
        return String(data: data, encoding: .utf8)
    }
}

enum KeychainError: Error {
    case status(OSStatus)
}
```

## Ejercicio Git en GitHub

El repositorio contiene el historial de commits con el conflicto simulado y el PR abierto desde `feature/login` a `main`.
