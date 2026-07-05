# Informe del Proyecto — ESSENCE

## Modificaciones de estilo

No se cambió la tipografía base del sitio (se mantuvo `Lora` para
títulos y la fuente de sistema para el texto), ni la paleta de colores
original (dorado `#d6ad60`, fondos oscuros `#0f0f0e`/`#181816`, bordes
`#3d3322`, texto gris `#c9c4bb`). El criterio en todas las secciones
nuevas fue **reutilizar** esa identidad visual ya definida en vez de
introducir estilos distintos, para que el sitio se vea como un solo
sistema y no como partes pegadas en momentos distintos:

- **Carrito de compras**: se agregaron clases nuevas (`.cart-body`,
  `.cart-item`, `.cart-item-qty`, `.cart-resumen`, `.resumen-linea`,
  `.resumen-total`, `.btn-pagar`, etc.), pero todas heredan los mismos
  colores y bordes que ya usaban las tarjetas de productos. Se usó un
  grid de dos columnas (`2fr 1fr`) para que la lista de productos sea
  más ancha que el resumen de pago, con `align-items: start` para que
  el resumen no se estire de más si la lista de productos es larga.
- **Ajuste de espaciado**: la sección del carrito tenía un espacio en
  blanco excesivo antes del pie de página, causado por un
  `padding: 80px 8%` (arriba y abajo por igual). Se corrigió reduciendo
  solo el padding inferior (`80px 8% 40px`) en vez de forzar una altura
  fija con `vh`, que hubiera roto el diseño con carritos de distinto
  tamaño.
- **Sección "Sobre Nosotros" (equipo)**: en vez de crear tarjetas
  nuevas, se reutilizaron literalmente las mismas clases de las
  tarjetas de perfumes (`.card-perfume`, `.card-info`,
  `.cards-coleccion`) para las 5 tarjetas del equipo, cambiando solo el
  contenido (foto, ID, carrera, resumen de experiencia).
- **Panel de Admin (órdenes)**: se agregaron clases nuevas
  (`.orden-card`, `.orden-header`, `.orden-total`, `.orden-items`,
  etc.) con el mismo lenguaje visual que el carrito (tarjeta oscura,
  borde sutil, acentos dorados en montos importantes) para que un
  administrador reconozca visualmente que está en la misma aplicación.
- **Limpieza**: se quitaron los atributos `aria-label` de íconos y
  botones (decisión explícita para simplificar el markup) y los `id`
  de sección (`#coleccion`, `#equipo`) que quedaron sin ningún enlace
  ni regla CSS apuntándoles, es decir, sin ninguna función real.

## Retos y Dificultades

| RETO | Descripción de la solución |
|---|---|
| 1. El procedure original `crear_orden` solo soportaba **un producto por orden** (una fila de `Ordenes` por cada producto comprado), pero el carrito necesita pagar varios productos distintos con un solo total. | Se diseñaron dos procedures nuevos: `iniciar_orden` (crea la cabecera de la orden) y `agregar_item_orden` (agrega cada línea de producto y acumula el total). Así una compra con N productos genera una sola orden con N ítems, en vez de N órdenes separadas. |
| 2. `mostrar_productos` no devolvía `producto_id`, así que el carrito no tenía forma de identificar qué producto agregar o quitar. Esto provocaba una `SQLException` a mitad de la página, que cortaba el resto del listado sin avisar por qué. | Se agregó `producto_id` al cursor del procedure, y se documentó el patrón del error (un `try/catch` que envuelve todo un `while`, corta el ciclo completo ante cualquier excepción) para reconocer más rápido este tipo de falla en el futuro. |
| 3. `validar_login` solo confirmaba si el usuario y contraseña eran correctos, pero no devolvía el `cliente_id`, y sin eso no había forma de asociar una orden a un cliente autenticado al momento de pagar. | Se agregó un parámetro de salida `p_cliente_id` al procedure, y se guardó en la sesión HTTP (`session.setAttribute`) justo después de un login exitoso, para reutilizarlo en el checkout. |
| 4. Varias veces el código JSP llamaba a un procedure con una cantidad o tipo de parámetros distinta a la que existía realmente en la base de datos del equipo (por scripts corridos parcialmente o en momentos distintos), generando errores `ORA-06550 / PLS-00306` difíciles de leer. | Se centralizaron todos los procedures en scripts SQL numerados y versionados (`01_tablas.sql` a `04_procedimientos.sql`) como única fuente de verdad, y se adoptó el hábito de comparar la firma que arma el `CallableStatement` en Java contra la firma real del procedure en Oracle antes de asumir que el bug estaba en el JSP. |
| 5. El sitio acumuló enlaces rotos e IDs sin uso de iteraciones anteriores: referencias a un `index.html` ya eliminado, anclas `#coleccion` que no tenían ni CSS ni ningún link real apuntándolas, y un botón de "Logout" que en varias páginas en realidad apuntaba a `login.html` en vez de cerrar sesión. | Se auditaron todos los archivos `.jsp`/`.html` del proyecto buscando esos patrones, se unificaron los enlaces de navegación y pie de página, y se eliminaron los `id` que ya no cumplían ninguna función. |
| 6. Cambios que parecían "no aplicarse" en el navegador, cuando en realidad eran caché del navegador mostrando una versión vieja de un archivo, o archivos sueltos en la raíz del proyecto que Maven nunca empaqueta (por estar fuera de `src/main/webapp`). | Se comparó el contenido desplegado en `target/` contra el código fuente para descartar despliegues desactualizados, y se identificaron y eliminaron los archivos huérfanos que no formaban parte del build real. |

## Conclusión

El punto más difícil de resolver como equipo fue mantener sincronizado
el código de la aplicación (JSP) con los procedures de Oracle. A
diferencia de un error de compilación en Java, un procedure con la
firma equivocada solo falla en tiempo de ejecución, con un mensaje de
Oracle (`ORA-06550`) que no dice directamente "tu JSP y tu base de
datos no coinciden" — hubo que aprender a leer ese error como una señal
de desincronización entre ambos lados, y no como un bug del código
Java en sí. Ordenar todos los procedures en scripts numerados y
tratarlos como una única fuente de verdad fue lo que finalmente evitó
seguir arrastrando ese problema en cada nueva funcionalidad.
