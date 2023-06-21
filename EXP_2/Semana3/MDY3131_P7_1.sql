DECLARE
    CURSOR cur_mes_anno IS 
        SELECT DISTINCT TO_CHAR(fecha_transaccion, 'MMYYYY') AS mes_anno
        FROM transaccion_tarjeta_cliente
        WHERE EXTRACT (YEAR FROM  fecha_transaccion) = EXTRACT(YEAR FROM SYSDATE)-1;

    CURSOR cur_trab (p_mes_anno VARCHAR2) IS 
        SELECT c.numrun as run, c.dvrun as dv,
        tc.nro_tarjeta as t_nro, ttc.fecha_transaccion as fecha_t,
        ttc.nro_transaccion as nro_tran,
        ttt.nombre_tptran_tarjeta as nombre_t_tarjeta, ttc.monto_transaccion as monto_t,
        c.cod_tipo_cliente tp_cliente
        FROM CLIENTE c JOIN TARJETA_CLIENTE tc on(c.numrun = tc.numrun) 
        JOIN TRANSACCION_TARJETA_CLIENTE ttc on(ttc.nro_tarjeta = tc.nro_tarjeta)
        JOIN TIPO_TRANSACCION_TARJETA ttt on(ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta)
        WHERE EXTRACT(YEAR FROM ttc.fecha_transaccion) = SUBSTR(p_mes_anno,3,4);
        
    TYPE tp_varray_puntos IS VARRAY(4) OF NUMBER;
    v_puntos tp_varray_puntos;
    
    v_pts NUMBER(10);
    v_detalles_pts DETALLE_PUNTOS_TARJETA_CATB%rowtype;
    v_resumen_pts RESUMEN_PUNTOS_TARJETA_CATB%rowtype;
    
    
    v_monto_total NUMBER(10);
    v_total_pts_compra NUMBER(10);
    v_total_avances NUMBER(10);
    v_total_savances NUMBER(10);
    v_total_pts_avances NUMBER(10);
    v_total_pts_savances NUMBER(10);
        
BEGIN
   
   EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUMEN_PUNTOS_TARJETA_CATB';
    v_puntos:=tp_varray_puntos(250,300,550,700);
    
    FOR reg_mes_anno IN cur_mes_anno LOOP
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_PUNTOS_TARJETA_CATB';
        v_monto_total := 0;
        v_total_pts_compra := 0;
        v_total_avances := 0;
        v_total_savances := 0;
        v_total_pts_avances := 0;
        v_total_pts_savances := 0;
        FOR reg_tarjeta IN cur_trab(reg_mes_anno.mes_anno) LOOP
            IF reg_tarjeta.monto_t BETWEEN 500000 AND 700000 AND reg_tarjeta.tp_cliente = 30 OR reg_tarjeta.tp_cliente = 40 THEN
                v_pts:=TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(1)+
                TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(2);
                
            ELSIF reg_tarjeta.monto_t BETWEEN 700001 AND 900000 AND reg_tarjeta.tp_cliente = 30 OR reg_tarjeta.tp_cliente = 40 THEN
                v_pts:=TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(1)+
                TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(3);
                
            ELSIF reg_tarjeta.monto_t > 900000 AND reg_tarjeta.tp_cliente = 30 OR reg_tarjeta.tp_cliente = 40 THEN
                v_pts:=TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(1)+
                TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(4);
            ELSE
                 v_pts:=TRUNC(reg_tarjeta.monto_t/100000)*v_puntos(1);
            END IF;
             DBMS_OUTPUT.put_line('XD');
            v_detalles_pts.numrun:= reg_tarjeta.run;
            v_detalles_pts.dvrun:= reg_tarjeta.dv;
            v_detalles_pts.nro_tarjeta:= reg_tarjeta.t_nro;
            v_detalles_pts.nro_transaccion := reg_tarjeta.nro_tran;
            v_detalles_pts.fecha_transaccion:= reg_tarjeta.fecha_t;
            v_detalles_pts.tipo_transaccion:= reg_tarjeta.nombre_t_tarjeta;
            v_detalles_pts.monto_transaccion:= reg_tarjeta.monto_t;
            v_detalles_pts.puntos_allthebest:= v_pts;
            
            INSERT INTO DETALLE_PUNTOS_TARJETA_CATB VALUES v_detalles_pts;
            
            IF SUBSTR(reg_mes_anno.mes_anno,1,2) = EXTRACT(MONTH FROM reg_tarjeta.fecha_t) THEN
                IF reg_tarjeta.nombre_t_tarjeta = 'Compras Tiendas Retail o Asociadas' THEN
                     v_monto_total := reg_tarjeta.monto_t + v_monto_total;
                     v_total_pts_compra := v_pts + v_total_pts_compra;
                END IF;
                IF reg_tarjeta.nombre_t_tarjeta = 'Avance en Efectivo' THEN
                     v_total_avances := v_total_avances + reg_tarjeta.monto_t;
                     v_total_pts_avances := v_pts + v_total_pts_avances;
                END IF;
                IF reg_tarjeta.nombre_t_tarjeta = 'Súper Avance en Efectivo' THEN
                    v_total_savances := v_total_savances + reg_tarjeta.monto_t;
                    v_total_pts_savances := v_total_pts_savances + v_pts;
                END IF;
            END IF;
        END LOOP;
        v_resumen_pts.mes_anno := reg_mes_anno.mes_anno;
        v_resumen_pts.monto_total_compras := v_monto_total;
        v_resumen_pts.total_puntos_compras := v_total_pts_compra;
        v_resumen_pts.monto_total_avances := v_total_avances;
        v_resumen_pts.total_puntos_avances := v_total_pts_avances;
        v_resumen_pts.monto_total_savances := v_total_savances;
        v_resumen_pts.total_puntos_savances := v_total_pts_savances;
        INSERT INTO RESUMEN_PUNTOS_TARJETA_CATB VALUES v_resumen_pts;
    END LOOP;
    
END;