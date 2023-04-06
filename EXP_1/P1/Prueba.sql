VAR b_anno_p NUMBER
VAR b_mes_p NUMBER
VAR b_limite_m NUMBER
VAR b_concep_ext NUMBER

EXEC :b_anno_p := EXTRACT(YEAR FROM SYSDATE);
EXEC :b_mes_p := EXTRACT(MONTH FROM SYSDATE);
EXEC :b_limite_m := 250000;


DECLARE
v_min NUMBER(10);
v_max NUMBER(10);
v_nombre VARCHAR2(30);
v_nro_aceso NUMBER(10);
v_sueldo NUMBER(10);
v_id_contrato NUMBER(1);
v_comuna NUMBER(2);
v_mov_extra NUMBER(10);
v_honorario NUMBER(10);
v_incentivo NUMBER(10);
v_porc_contrato NUMBER(10);
v_porc_asigancion  FLOAT(10);
v_asig_prof NUMBER(10);
v_total NUMBER(10);
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_ASIGNACION_MES';
    SELECT MAX(id_profesional), MIN(id_profesional) INTO v_max, v_min FROM PROFESIONAL;
    WHILE v_min <= v_max LOOP
    SELECT p.nombre || ' ' || p.appaterno  || ' ' || p.apmaterno, p.sueldo, tp.porc_incentivo, p.cod_comuna
    INTO v_nombre, v_sueldo,v_porc_contrato,v_comuna FROM PROFESIONAL p JOIN TIPO_CONTRATO tp ON(tp.cod_tpcontrato = p.cod_tpcontrato)
    JOIN COMUNA co ON(co.cod_comuna = p.cod_comuna)
    WHERE p.id_profesional = v_min;
    
    SELECT COUNT(inicio_asesoria) INTO v_nro_aceso FROM ASESORIA 
    WHERE id_profesional = v_min AND :b_anno_p-1 = EXTRACT(YEAR FROM fin_asesoria) AND :b_mes_p= EXTRACT(MONTH FROM fin_asesoria);
    
    SELECT NVL(SUM(honorario),0) INTO v_honorario FROM ASESORIA 
    WHERE id_profesional = v_min AND :b_anno_p-1 = EXTRACT(YEAR FROM fin_asesoria) AND :b_mes_p= EXTRACT(MONTH FROM fin_asesoria);
    
    SELECT pr.cod_profesion into v_id_contrato FROM PROFESION pe JOIN PROFESIONAL pr ON(pe.cod_profesion = pr.cod_profesion) WHERE pr.id_profesional = v_min;
    SELECT porc_asignacion into v_porc_asigancion FROM PORCENTAJE_PROFESION WHERE cod_profesion = v_id_contrato;
    
         -- Falta la variables bind para los cargos honorarios 400000,800000,680000
        IF v_comuna = 83 THEN
            v_mov_extra := v_honorario*0.04;
        ELSIF v_comuna = 85 AND v_honorario < 400000 THEN
            v_mov_extra := v_honorario*0.05;
        ELSIF v_comuna = 86 AND v_honorario < 800000 THEN
            v_mov_extra := v_honorario*0.07;
        ELSIF v_comuna = 89 AND v_honorario < 680000 THEN
            v_mov_extra := v_honorario*0.09;
        ELSE 
            v_mov_extra := 0;
        END IF;
        
        v_incentivo := (v_honorario*(v_porc_contrato/100));
        v_asig_prof := ((v_porc_asigancion/100)*v_sueldo);
        v_total := (v_honorario + v_mov_extra + v_incentivo + v_asig_prof); -- Era sin el /12
        IF v_total > :b_limite_m THEN
            v_total := 250000;
        END IF;
    INSERT INTO DETALLE_ASIGNACION_MES VALUES(:b_mes_p,:b_anno_p,v_min,v_nombre,v_nro_aceso,v_honorario,v_mov_extra,v_incentivo,v_asig_prof,v_total);
    v_min := v_min + 5;
    
    END LOOP;
END;