--------------------------------------------------------------------------
-- Ejecuta todo el esquema de ESSENCE en orden, desde cero.
-- Uso: sqlplus essence/1234@localhost:1521/xe @00_ejecutar_todo.sql
--------------------------------------------------------------------------

@01_tablas.sql
@02_secuencias.sql
@03_datos_iniciales.sql
@04_procedimientos.sql
