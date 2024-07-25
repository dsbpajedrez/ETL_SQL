<h1>DataWarehouse con SQL server</h1>
<p> En este repo se ilustra el desarrollado un almacen de datos a partir de la base de datos
AdventureWorks de microsoft, la cual consta de una tienda ficticia de venta de bicicletas a nivel
internacional. 

Para esto es importante conocer las herramientas necesarias:
## Herramientas y Tecnologías 
- SQL Server
- AdventureWorks Database
- SQL

## Estructura del Proyecto
  - `ETL_AdventureWorks.sql`: Contenido de los scripts para el ETL.

## Tabla de Hechos de Ventas:

Descripción: Esta tabla contiene los datos de las transacciones de ventas realizadas. Cada registro en la tabla representa una venta individual.
Contenido: Incluye métricas clave como la cantidad vendida, el precio unitario, el total de ventas, estado de los pedidos y otros indicadores financieros relevantes.
## Dimensiones:

## Clientes (Individuos y Tiendas):
- Descripción: Esta dimensión categoriza los clientes en dos tipos: individuos y tiendas. Proporciona detalles específicos sobre cada tipo de cliente.
- Contenido: Incluye información como el nombre del cliente, genéro, ubicación, y otros datos demográficos y de contacto relevantes.
## Territorio:
- Descripción: Esta dimensión identifica el territorio geográfico donde se realizó la venta.
- Contenido: Incluye información sobre el país, región, ciudad, etc.
## Método de Envío:
- Descripción: Esta dimensión describe los diferentes métodos de envío utilizados para entregar los productos a los clientes.
- Contenido: Incluye detalles sobre el método de envío, y costos asociados.
## Fecha:
- Descripción: Esta dimensión proporciona una estructura temporal para analizar las ventas a lo largo del tiempo.
- Contenido: Incluye datos como la fecha de la venta, día de la semana, mes, trimestre, año, y otros marcadores temporales.
## Cambio de Moneda:
- Descripción: Esta dimensión permite la conversión y análisis de las ventas en diferentes monedas, según el país en el que se realizó la venta.
- Contenido: Incluye la moneda utilizada, la tasa de cambio en el momento de la venta.
## Producto:
- Descripción: Esta dimensión proporciona detalles sobre los productos vendidos.
- Contenido: Incluye información como el nombre del producto, categoría, subcategoría, fabricante, y otras características del producto.

