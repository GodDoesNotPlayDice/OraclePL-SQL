DECLARE
v_min NUMBER(10);
v_max NUMBER(10);
v_run NUMBER(10);
v_dv VARCHAR2(1);
v_nombre VARCHAR2(50);
v_cargo VARCHAR2(50);
v_count_cargo NUMBER(10);
v_run_completo VARCHAR2(10);
v_meses_t NUMBER(10);
v_fecha_contrato DATE;
v_arriendos NUMBER(10);
v_total_arriendo NUMBER(10);
v_sueldo NUMBER(10);
v_annos_t NUMBER(10);
BEGIN

    SELECT MIN(id_emp), MAX(id_emp) INTO v_min, v_max FROM EMPLEADO;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INFO_SII';
    SELECT e.numrun_emp,e.dvrun_emp,e.fecha_contrato,
    e.pnombre_emp || ' ' || e.snombre_emp || ' ' || e.appaterno_emp || ' ' || e.apmaterno_emp
    ,e.sueldo_base
    INTO v_run,v_dv,v_fecha_contrato,v_nombre,v_sueldo
    FROM EMPLEADO e
    WHERE e.id_emp = v_min;
    
    
    v_run_completo:= v_run ||'-'|| v_dv;
    SELECT NVL(COUNT(*),0) INTO v_count_cargo FROM CAMION WHERE id_emp = v_min;
    IF v_count_cargo > 0 THEN
        v_cargo := 'Encargado de Arriendos';
    ELSE
        v_cargo := 'Labores Administrativas';
    END IF;
    
    
    SELECT ROUND(MONTHS_BETWEEN
    (TO_DATE(EXTRACT(YEAR FROM SYSDATE)-1||'-12-31', 'YYYY-MM-DD'),GREATEST(TO_DATE(EXTRACT(YEAR FROM SYSDATE)-1||'-01-01', 'YYYY-MM-DD'), v_fecha_contrato))) INTO v_meses_t FROM EMPLEADO
    WHERE id_emp = v_min;
    
     v_annos_t :=  TRUNC(MONTHS_BETWEEN(SYSDATE,v_fecha_contrato)/12);
    
    
    SELECT COUNT(*) INTO v_arriendos FROM ARRIENDO_CAMION ac JOIN CAMION c ON 
    (ac.id_camion = c.id_camion)
    WHERE c.id_emp = v_min AND
    EXTRACT(YEAR FROM FECHA_INI_ARRIENDO) = EXTRACT(YEAR FROM SYSDATE)-1;
    
    v_total_arriendo := ((5*v_arriendos)/100)*v_sueldo;
    
    DBMS_OUTPUT.PUT_LINE(v_total_arriendo);
    DBMS_OUTPUT.PUT_LINE(v_annos_t);
    INSERT INTO info_sii VALUES (EXTRACT(YEAR FROM SYSDATE), v_min,v_run,v_nombre,v_cargo,v_meses_t,v_annos_t,0,0,0,0,0,0,0,0,0);
    END;

