# Configuración segura de Stripe Test

## Flujo implementado

El portal crea una **Checkout Session** por cada donación desde `StripeCheckoutService`. Esto conserva el monto elegido, el correo del donante y una referencia de Salesforce (`MD-...`) en `client_reference_id` y `metadata[salesforce_reference]`.

La sesión se crea mediante el endpoint `callout:Stripe_Test/v1/checkout/sessions`; por ello la clave secreta nunca se almacena en Apex, LWC, Git ni documentación.

## Configuración manual en Salesforce

Una persona administradora de la org debe crear la credencial con el nombre exacto `Stripe_Test`:

1. En **Setup**, abre **Named Credentials** y crea una credencial para `https://api.stripe.com`.
2. Usa una credencial externa de tipo **Named Principal** o la opción equivalente de autenticación de la org.
3. Agrega el secreto de Stripe Test (`sk_test_...`) como secreto de la credencial. No lo pegues en el repositorio, capturas, chat o código fuente.
4. Configura la autenticación que genere el encabezado `Authorization` requerido por Stripe para la clave secreta. Usa la documentación vigente de Stripe y la interfaz disponible en la org.
5. Asigna el principal de la credencial al contexto que ejecuta el controlador público, sin conceder permisos de lectura/escritura directos sobre `Donation__c` al Guest User.
6. Guarda y prueba primero desde un usuario interno; después realiza la prueba desde incógnito.

## URL compartida

El enlace recibido es:

`https://donate.stripe.com/test_fZu00k5QQ9c0ePldUV6Na00`

Es un **Stripe Payment Link** de prueba. Puede usarse para verificar que la cuenta Stripe Test funciona, pero no es el flujo principal del portal: un Payment Link reutilizable no recibe por sí solo el monto dinámico ni la referencia única de cada donación Salesforce. El flujo implementado usa Checkout Sessions para mantener esa trazabilidad.

## Prueba esperada

1. Un visitante selecciona campaña, monto y preferencias de reconocimiento.
2. Salesforce registra una donación en estado `Pending`.
3. Salesforce crea una Checkout Session de Stripe Test y redirige a su URL.
4. Stripe muestra el correo precargado y recibe la referencia `MD-...`.
5. Stripe vuelve a la página de agradecimiento sin declarar el pago confirmado; E1 requiere confirmación manual.

## Wall of Fame

Si el donante autoriza reconocimiento, puede elegir **Mi nombre** o **Empresa u organización**, indicar el texto público y, opcionalmente, una URL HTTPS pública para logo/foto. Por privacidad y mínimo privilegio, esta entrega no permite que visitantes anónimos suban archivos directamente a Salesforce.

El muro recibe sólo los campos públicos mínimos: nombre de reconocimiento, tipo, URL de imagen opcional y monto de donaciones `Paid` con consentimiento. No expone correos, RFC, datos fiscales ni identificadores de donación.
