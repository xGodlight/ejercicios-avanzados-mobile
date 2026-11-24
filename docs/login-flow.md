# Flujo de inicio de sesión

1. Validar las credenciales antes de enviar la solicitud.
2. Guardar el JWT recibido con `JwtTokenStore`.
3. Leer el token desde el almacenamiento seguro al reanudar la sesión.
4. Eliminar el token del almacenamiento seguro al cerrar sesión.

No registrar el token ni incluirlo en mensajes de error.
