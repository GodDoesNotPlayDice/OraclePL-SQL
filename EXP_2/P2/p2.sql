VAR b_limite NUMBER
EXEC :b_limite:=500000
DECLARE
   
    CURSOR cur_resumen IS
        SELECT TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1||'06') mesanno,
               nombre_nivel lvl
               FROM nivel_empleado;
               
    CURSOR cur_detalle (p_mesanno VARCHAR2,p_lvl VARCHAR2) IS
        SELECT e.run_empleado as run,
               e.nombre|| ' ' || e.paterno|| ' ' ||e.materno as nombre,
               n.nombre_nivel as lvl,
               SUM(b.monto_total_venta) as monto
        FROM empleado e
            JOIN nivel_empleado n ON e.nivel_empleado=n.id_nivel
            JOIN boleta b ON e.run_empleado=b.run_empleado
        WHERE EXTRACT(YEAR FROM b.fecha)=SUBSTR(p_mesanno, 1, 4)  AND 
              EXTRACT(MONTH FROM b.fecha)=SUBSTR(p_mesanno, 5, 2)
        GROUP BY e.run_empleado,
               e.nombre|| ' ' || e.paterno|| ' ' ||e.materno,
               n.nombre_nivel;
        
        
v_m_lvl NUMBER(10);
v_m_extra NUMBER(10);
v_m_sum NUMBER(10);
v_msg_error VARCHAR2(100);

v_except EXCEPTION;
v_rein NUMBER(10);

TYPE varr_porc IS VARRAY(3) OF NUMBER(3,3);
arr_porc varr_porc;

v_t_ventas NUMBER(10);
v_t_reca NUMBER(10);
BEGIN
arr_porc := varr_porc(0.05,0.08,0.12);
    EXECUTE IMMEDIATE 'TRUNCATE TABLE RESUMEN_RECAUDACION';
    FOR reg_resumen IN cur_resumen LOOP
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_RECAUDACION';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ERROR_CALC';
        EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ERROR';
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_ERROR';
        v_t_ventas := 0;
        v_t_reca := 0;
        FOR reg_detalle IN cur_detalle(reg_resumen.mesanno,reg_resumen.lvl) LOOP
        
        
            SELECT reg_detalle.monto * (pct/100) INTO v_m_lvl FROM NIVEL_EMPLEADO
            WHERE nombre_nivel = reg_detalle.lvl;
            
            BEGIN 
                IF v_m_lvl > :b_limite THEN
                    RAISE v_except;
                END IF;
            EXCEPTION WHEN v_except THEN
                v_m_lvl:=:b_limite;
                v_msg_error:= 'Se supero el limite de comision para el empleado: ' || reg_detalle.run;
                INSERT INTO error_calc
                VALUES(seq_error.NEXTVAL,v_msg_error,'Se asigna el limite de comision de '|| :b_limite);
            END;
            
            
            BEGIN
                SELECT reg_detalle.monto * (pct/100) INTO v_m_extra FROM PORC_COM_VENTAS_EXTRA
                WHERE reg_detalle.monto BETWEEN monto_vta_inf AND mto_vta_sup;
            EXCEPTION WHEN OTHERS THEN
                v_msg_error:=SQLERRM;
                INSERT INTO error_calc 
                VALUES(seq_error.NEXTVAL,v_msg_error,'no se encontro % de comision extra para el monto: '||
                    reg_detalle.monto);
                v_m_extra := 0;
            END;
            
            IF reg_detalle.monto BETWEEN 50000 AND 150000 THEN
                v_rein := ROUND(reg_detalle.monto*arr_porc(1));
            ELSIF reg_detalle.monto BETWEEN 150001 AND 500000 THEN
                v_rein := ROUND(reg_detalle.monto*arr_porc(2));
            ELSIF reg_detalle.monto > 500000 THEN
                v_rein := ROUND(reg_detalle.monto*arr_porc(3));
            END IF;
            
            IF reg_detalle.lvl = reg_resumen.lvl THEN
                v_t_ventas := v_t_ventas + reg_detalle.monto;
                v_t_reca := v_t_reca + (reg_detalle.monto - v_rein);
            END IF;
            
            INSERT INTO DETALLE_RECAUDACION VALUES
            (reg_resumen.mesanno, reg_detalle.run, reg_detalle.nombre, 
            reg_detalle.lvl, reg_detalle.monto, v_m_lvl, v_m_extra, v_rein);
            
            
        END LOOP;
        INSERT INTO RESUMEN_RECAUDACION VALUES
            (reg_resumen.mesanno, reg_resumen.lvl , v_t_ventas, v_t_reca);
            
    END LOOP;
END;