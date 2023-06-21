DECLARE

-- Se crean los registros de almacenamiento de credito.
    TYPE reg_creditos is record(
        nombre_cred credito.nombre_credito%TYPE,
        descto credito.desc_credito%TYPE,
        tasa_interes credito.tasa_interes_anual%TYPE,
        nro_max_cuotas credito.nro_maximo_cuotas%TYPE);
    TYPE tbl_credito IS TABLE OF reg_creditos INDEX BY BINARY_INTEGER;
    v_reg_creditos tbl_credito;
    
    TYPE interes IS VARRAY(3) OF FLOAT NOT NULL;
    v_interes interes:= interes(0.5,1,2);

v_min NUMBER(10);
v_max NUMBER(10);
v_min_nro_cliente NUMBER(10);
v_max_nro_cliente NUMBER(10);
v_min_nro_solic_credito NUMBER(10);
v_max_nro_solic_credito NUMBER(10);
BEGIN

        SELECT MIN(cod_credito), MAX(cod_credito)
        INTO v_min,v_max
        FROM CREDITO;
        
        FOR i IN v_min..v_max LOOP
            SELECT nombre_credito,desc_credito,tasa_interes_anual,nro_maximo_cuotas
            INTO v_reg_creditos(i).nombre_cred, v_reg_creditos(i).descto, v_reg_creditos(i).tasa_interes, v_reg_creditos(i).nro_max_cuotas
            FROM CREDITO WHERE cod_credito = i;
            END LOOP;
            
        SELECT MIN(nro_cliente), MAX(nro_cliente) INTO v_min_nro_cliente, v_max_nro_cliente FROM CREDITO_CLIENTE;
        FOR v_nro_cliente in v_min_nro_cliente..v_max_nro_cliente LOOP
            SELECT MIN(nro_solic_credito), MAX(nro_solic_credito) INTO v_min_nro_solic_credito, v_max_nro_solic_credito FROM CREDITO_CLIENTE
            WHERE nro_cliente = v_nro_cliente;
        END LOOP;
            
        FOR v_nro_solic_credito IN v_min_nro_solic_credito..v_max_nro_solic_credito LOOP
            SELECT ccc.nro_cuota, ccc.fecha_venc_cuota, ccc.valor_cuota, c.nombre_credito, c.cod_credito
            INTO 
            FROM cuota_credito_cliente ccc JOIN CREDITO_CLIENTE cc ON (ccc.nro_solic_credito = cc.nro_solic_credito) JOIN CREDITO c ON (c.cod_credito = cc.cod_credito)
            WHERE ccc.nro_solic_credito = v_nro_solic_credito AND ccc.nro_cuota = (SELECT MAX(nro_cuota) FROM CUOTA_CREDITO_CLIENTE WHERE nro_solic_credito = v_nro_solic_credito);
        END LOOP;
END;