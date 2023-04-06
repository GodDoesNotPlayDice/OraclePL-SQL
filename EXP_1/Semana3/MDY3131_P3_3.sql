--	Número del cliente.
--  El crédito (número solicitud del crédito) sobre el cual el cliente desea postergar cuotas.
--	La cantidad de cuotas que el cliente desea a postergar.



SELECT MAX(CCC.NRO_CUOTA), MAX(CCC.FECHA_VENC_CUOTA), CCC.VALOR_CUOTA
FROM CUOTA_CREDITO_CLIENTE CCC JOIN CREDITO_CLIENTE CC on(CCC.nro_solic_credito = CC.nro_solic_credito )
WHERE CCC.nro_solic_credito = 2001 AND CC.nro_cliente = 5
GROUP BY VALOR_CUOTA;