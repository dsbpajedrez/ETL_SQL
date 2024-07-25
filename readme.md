<h1>DataWarehouse con SQL server</h1>
<p> En este repo se ilustra el desarrollado un almacen de datos a partir de la base de datos
AdventureWorks de microsoft, la cual consta de una tienda ficticia de venta de bicicletas a nivel
internacional. 

Para esto es importante conocer las herramientas necesarias:
## Herramientas y Tecnologías
- SQL Server
- AdventureWorks Database
- SQL
</p>
<h2>Pasos a seguir:</h2>

<ol>
    <li>Crear las consultas SQL</li>
    <li>Crear las correspondientes vistas</li>
    <li>Crear las tablas en nuestro DataWarehouse</li>
    <li>Migrar los datos de las vistas al DataWarehouse</li>
    <li>Se tendra una tabla de hechos y siete tablas de dimensiones</li>
</ol>
<p>A continuación se muestra el modelo estrella como resultado de la transformación</p>
<img src="./img/Modelo_Estrella.png" alt=""><br>
Como se puede observar , nuestra tabla de hechos es nuestra tabla de ventas. En ella se han combinado las tablas
Sales <b>Sales.SalesOrderHeader</b> y <b>Sales.SalesOrderDetail</b>, que son las que contienen la información 
de las facturas a los clientes. En esta se agregan los campos de interés y se realizan las transformaciones 
pertinentes para una interpretación más eficiente y rápida.