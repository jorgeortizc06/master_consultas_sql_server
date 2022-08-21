/* 
Funciones de Agregacion: realiza operaciones que devuelve un valor

	- AVG([ALL|DISTINCT] expresison)
	- SUM([ALL|DISTINCT] expresison)
	- MIN([ALL|DISTINCT] expresison)
	- MAX([ALL|DISTINCT] expresison)
	- COUNT([ALL|DISTINCT] expresison)
	- COUNT(*)
*/

/* 
- Agrupar por Sucursal, 
- Calcular cual es la venta mayor y menor por sucursal
- Calcular cual es la primera venta y la ultima venta por sucursal
- Contar numero de ventas por sucursal
- Calcular promedio de vntas por sucursal.
- Utilizar tablas tblventas y tblVentas_Detalle
*/

SELECT v.COD_SUC,
	MAX(vd.CANTIDAD * vd.valor)	AS	venta_mayor, 
	MIN(vd.CANTIDAD * vd.valor)	AS	venta_menor, 
	MIN(v.fecha)				AS	primera_venta, 
	MAX(v.fecha)				AS	ultima_venta, 
	COUNT(valor)				AS	numero_ventas, 
	AVG(vd.CANTIDAD * vd.valor)	AS	promedio_ventas
FROM tblVentas v
INNER JOIN tblVentas_Detalle vd	ON v.ID = vd.ID
GROUP BY v.COD_SUC
ORDER BY v.COD_SUC;

/*
- Calcular total costo, total venta, total utilidad, porcentaje de utilidad
- Agruparlo por nombre de la linea.
- Filtrar por el porcentaje de utilidad que sea menor de 10
- rango de fecha comprendido 01/01/2014 && 31/12/2015
- Tablas a utilizas: tblVentas, tblVentas_Detalle, tblProductos, tblLineas
*/
SET DATEFORMAT DMY;
select l.NOM_LIN
		,SUM(vd.cantidad*vd.costo) AS total_costo
		,SUM(vd.cantidad*vd.valor) AS TOTAL_VENTA
		,SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo) AS total_utilidad
		--utilidad menor que diez, esta es un funcion de agregacion, no puedes meterno en un where
		--se utiliza un having
		,ROUND(SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo)/SUM(vd.cantidad*vd.valor)*100,0) AS PUtilidad
FROM tblLineas l
	INNER JOIN tblProductos p		ON	l.COD_LIN = p.COD_LIN
	INNER JOIN tblVentas_Detalle vd	ON	p.COD_PROD = vd.COD_PROD
	INNER JOIN tblVentas	v		ON	v.ID = vd.ID
WHERE v.FECHA BETWEEN '01/01/2014' AND '31/12/2015'
GROUP BY l.NOM_LIN
HAVING ROUND(SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo)/SUM(vd.cantidad*vd.valor)*100,0) < 10
ORDER BY l.NOM_LIN;



/*
- Calcular total costo, total venta, total utilidad, porcentaje de utilidad
- Agruparlo por nombre de la linea.
- Filtrar por el porcentaje de utilidad que sea menor de 10
- rango de fecha comprendido 01/01/2014 && 31/12/2015
- Se requiere un resume final utilizando cube, rollup, ademas enumerar cada fila utilizando over
- Tablas a utilizas: tblVentas, tblVentas_Detalle, tblProductos, tblLineas
*/
SET DATEFORMAT DMY;
select COUNT(*) OVER(ORDER BY l.NOM_LIN DESC) as N --enumera por cada linea
		,l.NOM_LIN
		,SUM(vd.cantidad*vd.costo) AS total_costo
		,SUM(vd.cantidad*vd.valor) AS TOTAL_VENTA
		,SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo) AS total_utilidad
		--utilidad menor que diez, esta es un funcion de agregacion, no puedes meterno en un where
		--se utiliza un having
		,ROUND(SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo)/SUM(vd.cantidad*vd.valor)*100,0) AS PUtilidad
FROM tblLineas l
	INNER JOIN tblProductos p		ON	l.COD_LIN = p.COD_LIN
	INNER JOIN tblVentas_Detalle vd	ON	p.COD_PROD = vd.COD_PROD
	INNER JOIN tblVentas	v		ON	v.ID = vd.ID
WHERE v.FECHA BETWEEN '01/01/2014' AND '31/12/2015'
--GROUP BY ROLLUP(l.NOM_LIN)
GROUP BY l.NOM_LIN WITH ROLLUP -- te hace una suma de cada fila
--HAVING ROUND(SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo)/SUM(vd.cantidad*vd.valor)*100,0) < 10 -- no puede ir having si usas rollup

/*
Realizar un acumulado de total_ventas por linea utilizando over
*/

SET DATEFORMAT DMY;

WITH CTE_VENTAS AS
(
	select COUNT(*) OVER(ORDER BY l.NOM_LIN DESC) as N
			,l.NOM_LIN
			,SUM(vd.cantidad*vd.costo) AS total_costo
			,SUM(vd.cantidad*vd.valor) AS TOTAL_VENTA
			,SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo) AS total_utilidad
			,ROUND(SUM(vd.cantidad*vd.valor-vd.cantidad*vd.costo)/SUM(vd.cantidad*vd.valor)*100,0) AS PUtilidad
	FROM tblLineas l
		INNER JOIN tblProductos p		ON	l.COD_LIN = p.COD_LIN
		INNER JOIN tblVentas_Detalle vd	ON	p.COD_PROD = vd.COD_PROD
		INNER JOIN tblVentas	v		ON	v.ID = vd.ID
	WHERE v.FECHA BETWEEN '01/01/2014' AND '31/12/2015'
	GROUP BY l.NOM_LIN
	
)
SELECT cv.NOM_LIN
		,cv.TOTAL_VENTA
		--se suma el primer valor con el segundo y el tercero, etc, se va acumulando
		,SUM(SUM(cv.total_venta)) OVER (ORDER BY cv.NOM_LIN ASC) AS ACUMULADO
FROM CTE_VENTAS cv
GROUP BY cv.NOM_LIN, CV.TOTAL_VENTA


/*
Una consulta resumen contar por cada grupo, utilizando grouping sets
Utilizar la tabla tblproductos hacer dos grupos por cod_lin y marca
*/

SELECT p.COD_LIN, p.MARCA, COUNT(*) AS nproductos
FROM tblProductos p
WHERE p.COD_LIN IN ('003','004')
GROUP BY GROUPING SETS(p.COD_LIN, p.MARCA) --crea dos grupos. Debes revisar el resultado y veras que son dos grupos
ORDER BY p.COD_LIN desc, p.MARCA desc;