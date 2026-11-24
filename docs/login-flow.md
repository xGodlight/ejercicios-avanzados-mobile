# Flujo de inicio de sesión

1. Validar las credenciales antes de enviar la solicitud.
2. Guardar el JWT recibido con `JwtTokenStore`.
3. Leer el token desde el almacenamiento seguro al reanudar la sesión.
