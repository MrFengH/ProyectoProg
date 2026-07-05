# ESSENCE — Perfumería online

Proyecto JSP + Oracle para el curso. Frontend en JSP/HTML/CSS, backend en
procedimientos almacenados de Oracle llamados desde los JSP vía JDBC.

## Requisitos

- JDK 21
- Apache Maven
- Apache Tomcat 8.5+ (o 9.x)
- Oracle Database (XE) corriendo en `localhost:1521`, con un usuario
  `essence` / `1234` (o los que definas — son los que usan los JSP en
  su cadena de conexión `jdbc:oracle:thin:@localhost:1521:xe`)

## 1. Preparar la base de datos

Conéctate como el usuario `essence` (o el que uses) y ejecuta los
scripts en orden, por ejemplo con SQL*Plus:

```
cd sql
sqlplus essence/1234@localhost:1521/xe @00_ejecutar_todo.sql
```

Esto corre en orden:

1. `01_tablas.sql` — tablas (Cliente, Categoria, Marca, Producto, Ordenes, Orden_Item)
2. `02_secuencias.sql` — secuencias
3. `03_datos_iniciales.sql` — categorías, marcas y productos de ejemplo
4. `04_procedimientos.sql` — todos los procedures que usan los JSP

Si prefieres correrlos manualmente, respeta ese mismo orden (las tablas
y secuencias tienen que existir antes de los datos e procedimientos).

> Nota: los scripts asumen un esquema vacío (`CREATE TABLE` falla si las
> tablas ya existen). Si ya tienes datos, avísame y armamos un script de
> migración en vez de uno desde cero.

## 2. Compilar el proyecto

Desde la raíz del proyecto:

```
mvn clean install
```

Esto genera el WAR en `target/proyectoprog-1.0.war` (y también lo deja
"explotado" en `target/proyectoprog-1.0/`).

## 3. Desplegar en Tomcat

Copia el WAR generado a la carpeta `webapps` de tu instalación de
Tomcat:

```
copy target\proyectoprog-1.0.war <RUTA_TOMCAT>\webapps\
```

Inicia Tomcat (`<RUTA_TOMCAT>\bin\startup.bat`). Tomcat va a
desempaquetar el WAR automáticamente en
`<RUTA_TOMCAT>\webapps\proyectoprog-1.0\`.

## 4. Probar

Con Tomcat corriendo (puerto por defecto 8080, ajusta si el tuyo usa
otro como 8082):

```
http://localhost:8080/proyectoprog-1.0/index.jsp
```

Páginas principales:

- `index.jsp` — inicio
- `productos.jsp` — colección (lee productos desde Oracle)
- `carrito.jsp` — carrito de compras (requiere sesión iniciada para pagar)
- `admin.jsp` — historial de órdenes (solo lectura)
- `login.html` / `registro.html` — iniciar sesión / crear cuenta

## Notas

- Las credenciales de conexión a Oracle están hardcodeadas en cada JSP
  (`jdbc:oracle:thin:@localhost:1521:xe`, usuario `essence`, password
  `1234`). Si cambias usuario/password/puerto de tu Oracle, hay que
  actualizarlas en cada archivo que abre conexión.
- Si modificas los procedures de Oracle, vuelve a correr
  `sql/04_procedimientos.sql` (son todos `CREATE OR REPLACE`, seguros
  de re-ejecutar).
