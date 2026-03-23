-- Seleccionar Base de Datos
USE proyecto_analisis_clientes;

-- Overview del dataset 
SELECT *
FROM clientes
LIMIT 20;

-- Q1 ¿Cual es el Ingreso Total (Revenue) generado por hombres y mujeres?
SELECT genero, sum(cantidad_de_compra) AS revenue
FROM clientes
GROUP BY genero;

-- Q2. ¿Que clientes usaron descuento pero aun asi gastaron 
-- mas del promedio de la cantidad de la compra?
SELECT cliente_id, cantidad_de_compra
FROM clientes 
WHERE descuento_aplicado = 'Si' AND cantidad_de_compra >= (
	-- Crear un subquery
	SELECT avg(cantidad_de_compra)
	FROM clientes
);


-- Q3. ¿Cual es el top 5 de productos con el promedio mas alto de reviews?
SELECT item_comprado, ROUND(avg(calificacion_de_reviews), 2) AS promedio_reviews
FROM clientes 
GROUP BY item_comprado
ORDER BY avg(calificacion_de_reviews) DESC
LIMIT 5;

-- Q4. Compara el promedio de la Cantidad de Compras entre Envio Standard y Express
SELECT tipo_de_envio, ROUND(avg(cantidad_de_compra), 2) AS promedio_compras
FROM clientes 
WHERE tipo_de_envio IN ('Standard', 'Express') -- Seleccionar solo esos 2 de la columna 'tipo_de_envio'
GROUP BY tipo_de_envio
;

-- Q5.¿Los clientes suscritos gastan más? Compara el gasto promedio y los ingresos totales (revenue)
-- entre suscriptores y no suscriptores.
SELECT status_de_suscripcion, 
count(cliente_id) AS total_clientes, 
ROUND(avg(cantidad_de_compra), 2) AS promedio_pagado, -- Redondear a 2 puntos decimales
ROUND(sum(cantidad_de_compra), 2) AS revenue_total -- Ingresos totales
FROM clientes 
GROUP BY status_de_suscripcion 
ORDER BY promedio_pagado, revenue_total DESC;

-- Q6. ¿Que 5 productos tienen el mayor porcentaje de compras con descuento aplicado?
SELECT item_comprado, 
ROUND(100 * sum(CASE WHEN descuento_aplicado = 'Si' THEN 1 ELSE 0 END)/COUNT(*),2) AS tasa_descuento
FROM clientes
GROUP BY item_comprado 
ORDER BY tasa_descuento DESC 
LIMIT 5;


-- Q7. Clasifica a los clientes en Nuevos, Recurrentes y Leales según el total
-- de compras realizadas previamente, y muestra el conteo de cada segmento.

-- Crear un CTE para facilitar la logica de las clasificacion de cada cliente
WITH tipo_cliente AS (
	SELECT cliente_id, compras_anteriores,
	CASE
	    WHEN compras_anteriores = 1 THEN 'Nuevo'
	    WHEN compras_anteriores BETWEEN 2 AND 10 THEN 'Recurrente'
	    ELSE 'Leal'
	    END AS clasificacion_cliente
FROM clientes)
-- Agrupar la clasificacion de clientes con el total de clientes
SELECT clasificacion_cliente, count(*) AS "Total de clientes"
FROM tipo_cliente -- Usar el CTE
GROUP BY clasificacion_cliente;


-- Q8. ¿Cuáles son los 3 productos más comprados dentro de cada categoría?
WITH conteo_item AS ( -- Crear CTE
	SELECT categoria, item_comprado,
		count(cliente_id) AS ordenes_totales,
		-- Crear un Window Function para el ranking de cada item de acuerdo a su categoria
		ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY count(cliente_id) DESC) AS item_rank
	FROM clientes
	GROUP BY categoria, item_comprado
)
SELECT item_rank, categoria, item_comprado, ordenes_totales
FROM conteo_item
WHERE item_rank <= 3;



-- Q9. ¿Los clientes que compran seguido (Mas de 5 compras previas) son probables a 
-- suscribirse?
SELECT status_de_suscripcion, 
count(cliente_id) AS compradores_seguidos 
FROM clientes
WHERE compras_anteriores > 5
GROUP BY status_de_suscripcion -- Agrupar a todos los clientes con mayor de 5 compras de acuerdo a su suscripcion 
;


-- Q10. Cual es la contribucion de ingresos totales (revenue) de acuerdo a cada grupo de edad?
SELECT edad_grupo, 
sum(cantidad_de_compra) AS revenue
FROM clientes
GROUP BY edad_grupo DESC; -- Agrupar por la clase de edad de mayor a menor 




