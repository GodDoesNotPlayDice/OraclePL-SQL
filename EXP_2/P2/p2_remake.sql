VAR b_limite NUMBER;
EXEC :b_limite:=500000;
DECLARE
CURSOR cur_res_recauda IS
    SELECT EXTRACT(YEAR FROM SYSDATE)-1 || '06' as mes_anno, nombre_nivel as lvl_emp FROM NIVEL_EMPLEADO;
CURSOR cur_det_recauda(mes_anno VARCHAR2, lvl_emp VARCHAR2) IS
    SELECT e.run_empleado as r, e.nombre as n, e.paterno as pa, e.materno as ma,
    SUM(b.monto_total_venta) as mtv, e.nivel_empleado as clvl
    FROM EMPLEADO e JOIN BOLETA b on(e.run_empleado = b.run_empleado)
    WHERE EXTRACT(YEAR FROM b.fecha) = SUBSTR(mes_anno,1,4) AND
    EXTRACT(MONTH FROM b.fecha) = SUBSTR(mes_anno,5,2)
    GROUP BY e.run_empleado, e.nombre, e.paterno, e.materno,e.nivel_empleado;
    
    v_nombre VARCHAR2(120);
    v_lvl VARCHAR(120);
    v_msg VARCHAR2(120);
    v_ora VARCHAR2(120);
     
    v_com_lvl NUMBER(10);
    v_com_ext NUMBER(10);
    v_com_rein NUMBER(10);
    v_t_v NUMBER(10);
    v_t_r NUMBER(10);
    
    v_limite EXCEPTION;
   
   TYPE arr_porc IS VARRAY(3) OF NUMBER(3,3);
   varr_porc arr_porc := arr_porc(0.05, 0.08, 0.12);
   
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUMEN_RECAUDACION';
    FOR reg_res IN cur_res_recauda LOOP
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_RECAUDACION';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ERROR_CALC';
        EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ERROR';
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ERROR';
        v_t_v := 0;
        v_t_r := 0;
        FOR reg_det IN cur_det_recauda(reg_res.mes_anno, reg_res.lvl_emp) LOOP
            v_nombre := reg_det.n || ' ' || reg_det.pa || ' ' || reg_det.ma;
            
            BEGIN 
            SELECT reg_det.mtv * pct/100, nombre_nivel INTO v_com_lvl, v_lvl FROM NIVEL_EMPLEADO
            WHERE reg_det.clvl = id_nivel;
            IF v_com_lvl > :b_limite THEN
                RAISE v_limite;
            END IF;
            
            EXCEPTION WHEN v_limite THEN
                v_com_lvl := :b_limite;    
                v_ora := 'Se supero el limite de comision para el empleado ' || reg_det.r;
                v_msg := 'Se asigna el limite de comision de ' || :b_limite;
                INSERT INTO ERROR_CALC VALUES (seq_error.nextval, v_ora, v_msg);
            END;
            
            BEGIN
                SELECT reg_det.mtv * (pct/100) INTO v_com_ext FROM PORC_COM_VENTAS_EXTRA
                WHERE reg_det.mtv BETWEEN monto_vta_inf AND mto_vta_sup;
            EXCEPTION WHEN OTHERS THEN
                v_com_ext := 0;
                v_msg :='No se encontro % de comision extra para el monto ' || reg_det.mtv;
                v_ora := SQLERRM;
                INSERT INTO ERROR_CALC VALUES(seq_error.nextval, v_ora, v_msg);
            END;
            
            IF reg_det.mtv BETWEEN 50000 AND 150000 THEN
                v_com_rein := reg_det.mtv * varr_porc(1);
            ELSIF reg_det.mtv BETWEEN 150001 AND 500000 THEN
                v_com_rein := reg_det.mtv * varr_porc(2);
            ELSIF reg_det.mtv > 500000 THEN
                v_com_rein := reg_det.mtv * varr_porc(3);
            END IF;
            
            IF reg_res.lvl_emp = v_lvl THEN
                v_t_v := reg_det.mtv + v_t_v;
                v_t_r := v_t_r + (reg_det.mtv - v_com_rein);
            END IF;
            
               INSERT INTO detalle_recaudacion 
               VALUES (reg_res.mes_anno, reg_det.r, reg_det.n, v_lvl, reg_det.mtv, v_com_lvl, v_com_ext, v_com_rein);
        END LOOP;
        INSERT INTO resumen_recaudacion VALUES (reg_res.mes_anno, reg_res.lvl_emp, v_t_v, v_t_r);
    END LOOP;
END;