CREATE OR REPLACE PACKAGE pkg_trabajador AS 
v_ptj_zona NUMBER(10);
v_ptj_ranking NUMBER(10);
FUNCTION fn_extrema(p_zona NUMBER) RETURN NUMBER;
FUNCTION fn_ranking(p_inst NUMBER) RETURN NUMBER;
END;


CREATE OR REPLACE PACKAGE BODY pkg_trabajador AS
        FUNCTION fn_extrema(p_zona NUMBER) RETURN NUMBER AS
            v_ptj NUMBER(10);
            BEGIN
            IF p_zona IS NULL THEN
                RETURN 0;
            END IF;
                SELECT MAX(ptje_zona) INTO v_ptj FROM PTJE_ZONA_EXTREMA;
                RETURN v_ptj;
            END fn_extrema;
            
        FUNCTION fn_ranking(p_inst NUMBER) RETURN NUMBER AS
            v_ptj NUMBER(10);
            BEGIN
                IF p_inst IS NULL THEN
                    RETURN 0;
                END IF;
                SELECT ptje_ranking INTO v_ptj FROM PTJE_RANKING_INST WHERE
                p_inst BETWEEN rango_ranking_ini AND rango_ranking_ter;
                RETURN v_ptj;
            END fn_ranking;
    END pkg_trabajador;
    
    
   CREATE OR REPLACE FUNCTION fn_obt_pjte_horas_trab(p_hrs NUMBER, p_numrun NUMBER) RETURN NUMBER AS
    v_ptj NUMBER(10);
    msg_ora VARCHAR2(100);
    BEGIN
        SELECT ptje_horas_trab INTO v_ptj FROM PTJE_HORAS_TRABAJO WHERE 
        p_hrs BETWEEN rango_horas_ini AND rango_horas_ter;
        RETURN v_ptj;
        EXCEPTION WHEN OTHERS THEN
            msg_ora := SQLERRM;
            INSERT INTO ERROR_PROCESO VALUES(p_numrun,
            'Error en fn_obt_pjte_horas_trab al obtener puntaje con horas 
            de trabajo semanal: ' || p_hrs, msg_ora);
            RETURN 0;
    END;
    
CREATE OR REPLACE FUNCTION fn_obt_pjte_annos_experiencia(p_tiempo NUMBER, p_numrun NUMBER) RETURN NUMBER AS
    v_ptj NUMBER(10);
    msg_ora VARCHAR2(100);
    BEGIN
        SELECT ptje_experiencia INTO v_ptj FROM PTJE_ANNOS_EXPERIENCIA WHERE 
        p_tiempo BETWEEN rango_annos_ini AND rango_annos_ter;
        RETURN v_ptj;
        EXCEPTION WHEN OTHERS THEN
            msg_ora := SQLERRM;
            INSERT INTO ERROR_PROCESO VALUES(p_numrun,
            'Error en fn_obt_pjte_horas_trab al obtener puntaje con años 
            de experiencia: ' || p_tiempo, msg_ora);
            RETURN 0;
    END;
    
    
CREATE OR REPLACE PROCEDURE sp_trabajador(p_fecha DATE, v_porc_ext_uno NUMBER, v_porc_ext_dos NUMBER) AS
    CURSOR cur_trabajadores IS 
        SELECT numrun as run, dvrun as dv,
        pnombre || ' ' || snombre || ' ' || apaterno || ' ' || amaterno as nombre,
        cod_esp, fecha_nacimiento
        FROM ANTECEDENTES_PERSONALES;
        
        
    v_nombre VARCHAR2(100);
    v_run VARCHAR2(100);
    v_horas NUMBER(10);
    v_annos NUMBER(10);
    v_ptj_horas NUMBER(10);
    v_ptj_annos NUMBER(10);
    
    v_zona_cod NUMBER(10);
    v_cod_inst NUMBER(10);
    v_rank_inst NUMBER(10);
    v_postulante NUMBER(10);
    v_annos_postulante NUMBER(10);
    
    v_ext_uno NUMBER(10);
    v_ext_dos NUMBER(10);
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_PUNTAJE_POSTULACION';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE RESULTADO_POSTULACION';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ERROR_PROCESO';
        FOR reg_trab IN cur_trabajadores LOOP
            pkg_trabajador.v_ptj_zona := 0;
            pkg_trabajador.v_ptj_ranking := 0;
            SELECT SUM(horas_semanales), 
            ROUND(MONTHS_BETWEEN(p_fecha, MIN(fecha_contrato))/12) 
            INTO v_horas, v_annos FROM ANTECEDENTES_LABORALES
            WHERE numrun = reg_trab.run;
            
            SELECT MAX(zona_extrema) INTO v_zona_cod
            FROM ANTECEDENTES_LABORALES al JOIN SERVICIO_SALUD ss 
            on(al.cod_serv_salud = ss.cod_serv_salud) 
            WHERE numrun = reg_trab.run 
            AND al.cod_serv_salud = ss.cod_serv_salud AND zona_extrema IS NOT NULL;
            
            SELECT MAX(cod_inst), ppe.numrun INTO v_cod_inst, v_postulante
            FROM POSTULACION_PROGRAMA_ESPEC ppe 
            JOIN PROGRAMA_ESPECIALIZACION pe
            on(ppe.cod_programa = pe.cod_programa)
            WHERE numrun = reg_trab.run AND ppe.cod_programa = pe.cod_programa
            GROUP BY ppe.numrun;
            SELECT max(ranking) INTO v_rank_inst FROM INSTITUCION WHERE cod_inst = v_cod_inst;
            
            -- SELECT numrun INTO v_postulante FROM POSTULACION_PROGRAMA_ESPEC where numrun = reg_trab.run;
            
            pkg_trabajador.v_ptj_zona := pkg_trabajador.fn_extrema(v_zona_cod); -- VER
            pkg_trabajador.v_ptj_ranking :=  pkg_trabajador.fn_ranking(v_rank_inst);
            
            v_nombre := UPPER(reg_trab.nombre);
            v_run := TO_CHAR(reg_trab.run, '99g999g999') || '-' || reg_trab.dv;
            v_ptj_horas := fn_obt_pjte_horas_trab(v_horas, reg_trab.run);
            v_ptj_annos := fn_obt_pjte_annos_experiencia(v_annos, reg_trab.run);
            
           
            v_ext_uno := 0;
            v_ext_dos := 0;
            IF v_postulante = reg_trab.run THEN
                v_annos_postulante := TRUNC(MONTHS_BETWEEN(p_fecha, reg_trab.fecha_nacimiento)/12);
                IF v_annos_postulante < 45 AND v_horas > 30 THEN
                    v_ext_uno := (v_ptj_annos * (v_porc_ext_uno/100)) + (pkg_trabajador.v_ptj_ranking * (v_porc_ext_uno/100));
                END IF;
                IF v_annos < 25 THEN
                    v_ext_dos := (v_ptj_annos * (v_porc_ext_dos/100)) + (pkg_trabajador.v_ptj_ranking * (v_porc_ext_dos/100));
                END IF;
            END IF;
            
            INSERT INTO DETALLE_PUNTAJE_POSTULACION 
            VALUES (v_run, v_nombre, v_ptj_annos,v_ptj_horas , pkg_trabajador.v_ptj_zona, pkg_trabajador.v_ptj_ranking, v_ext_uno, v_ext_dos);
            
            
        END LOOP;
    END;
    
exec sp_trabajador(TO_DATE('30/06/2023', 'DD/MM/YYYY'), 30,15);
    
CREATE OR REPLACE TRIGGER tr_trab AFTER INSERT ON DETALLE_PUNTAJE_POSTULACION
FOR EACH ROW
DECLARE
v_suma_ptj NUMBER(10);
v_msg VARCHAR2(100);
BEGIN
    v_suma_ptj := :NEW.ptje_annos_exp + :NEW.ptje_horas_trab + 
    :NEW.ptje_zona_extrema + :NEW.ptje_ranking_inst + 
    :NEW.ptje_extra_1 + :NEW.ptje_extra_2;
    v_msg := 'NO SELECCIONADO';
    IF v_suma_ptj > 4500 THEN
        v_msg := 'SELECCIONADO';
    END IF;
    INSERT INTO RESULTADO_POSTULACION VALUES (:NEW.run_postulante, v_suma_ptj, v_msg);
END;
