-- CASO 1

DECLARE
V_NRO_CTE NUMBER(10);
V_RUN VARCHAR2(25);
V_NOMBRE VARCHAR2(30);
V_TIPO VARCHAR(50);
V_MONTO NUMBER(20);
V_PESOS NUMBER(20);
V_COD_TIPO NUMBER(3);
V_PESOS_EXTRA NUMBER(10);
V_C_SUMA CLIENTE_TODOSUMA%ROWTYPE;
BEGIN
     
     SELECT C.NRO_CLIENTE "NUMCLIENTE", TO_CHAR(C.NUMRUN,'99G999G999') ||'-'|| C.DVRUN "RUN",
     C.PNOMBRE || ' ' || C.SNOMBRE || ' ' || C.APPATERNO || ' ' || C.APMATERNO "NOMBRE CLIENTE",TC.NOMBRE_TIPO_CLIENTE  "TIPO CLIENTE",
    SUM(CC.MONTO_SOLICITADO) AS "MONTO", TC.COD_TIPO_CLIENTE "CODTIPO"
    INTO V_NRO_CTE,V_RUN,V_NOMBRE,V_TIPO,V_MONTO,V_COD_TIPO
     FROM CLIENTE C JOIN TIPO_CLIENTE TC ON(C.COD_TIPO_CLIENTE = TC.COD_TIPO_CLIENTE) JOIN CREDITO_CLIENTE CC ON(C.NRO_CLIENTE=CC.NRO_CLIENTE) 
     WHERE C.NRO_CLIENTE = 67 AND EXTRACT(YEAR FROM CC.FECHA_OTORGA_CRED) = EXTRACT(YEAR FROM SYSDATE)-1
     GROUP BY C.NRO_CLIENTE,TO_CHAR(C.NUMRUN,'99G999G999'),C.PNOMBRE || ' ' || C.SNOMBRE || ' ' || C.APPATERNO || ' ' || C.APMATERNO,
     TC.NOMBRE_TIPO_CLIENTE, TC.COD_TIPO_CLIENTE,C.DVRUN;
     
     
     
     V_PESOS:=1200*ROUND(V_MONTO/100000);
    
    IF V_COD_TIPO = 2 THEN
        V_PESOS_EXTRA:= CASE 
            WHEN V_MONTO BETWEEN 0 AND 1000000 THEN
                100*ROUND(V_MONTO/100000)
            WHEN V_MONTO BETWEEN 1000001 AND 3000000 THEN
                300*ROUND(V_MONTO/100000)
            ELSE
                550*ROUND(V_MONTO/100000)
            END;
    ELSE
        V_PESOS_EXTRA:=0;
    END IF;
    
    V_PESOS:= V_PESOS + V_PESOS_EXTRA;
    
    V_C_SUMA.NRO_CLIENTE:= V_NRO_CTE;
    V_C_SUMA.RUN_CLIENTE:= V_RUN;
    V_C_SUMA.NOMBRE_CLIENTE:= V_NOMBRE;
    V_C_SUMA.TIPO_CLIENTE:= V_TIPO;
    V_C_SUMA.MONTO_SOLIC_CREDITOS:= V_MONTO;
    V_C_SUMA.MONTO_PESOS_TODOSUMA:= V_PESOS;
    
    INSERT INTO CLIENTE_TODOSUMA VALUES V_C_SUMA;
    
END;