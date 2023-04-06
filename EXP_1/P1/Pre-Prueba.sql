VAR B_ASIG NUMBER
EXEC :B_ASIG := 10;

DECLARE
v_min NUMBER(4);
v_max NUMBER(4);
v_sueldo NUMBER(10);
v_carga_familiar NUMBER(10);
v_suma_sueldo NUMBER(10);
v_boni_jef NUMBER(10);
v_id_t VARCHAR2(30);
v_boni_trab FLOAT(10);
v_bonif_trab_total NUMBER(10);
v_super_suma NUMBER(10);
v_region NUMBER(10);
v_asig_euro NUMBER(10);
v_salud NUMBER(10);
v_afp NUMBER(10);
v_afp_total NUMBER(10);
v_salud_total NUMBER(10);
v_total NUMBER(10);
BEGIN

    EXECUTE IMMEDIATE 'TRUNCATE TABLE DETALLE_REMUNERACION_MENSUAL';
    
    SELECT MIN(id_empleado), MAX(id_empleado) INTO v_min,v_max FROM EMPLEADO;
    
    FOR i IN v_min..v_max LOOP
    
    SELECT e.sueldo_base INTO v_sueldo FROM EMPLEADO e
    WHERE e.id_empleado = i;
    
    SELECT COUNT(id_empleado) INTO v_carga_familiar FROM CARGA_FAMILIAR
    WHERE id_empleado = i;
    
    SELECT NVL(SUM(e.sueldo_base),0) INTO v_suma_sueldo FROM EMPLEADO e JOIN EMPLEADO j on(e.id_jefe = j.id_empleado)
    WHERE j.id_empleado = i;
    
    
    v_carga_familiar := v_carga_familiar * :B_ASIG;
    
    CASE 
        WHEN v_suma_sueldo BETWEEN 5000 AND 10000 THEN 
        v_boni_jef := v_suma_sueldo*.05;
        WHEN v_suma_sueldo BETWEEN 10001 AND 20000 THEN 
        v_boni_jef := v_suma_sueldo*.14;
        WHEN v_suma_sueldo BETWEEN 20001 AND 40000 THEN 
        v_boni_jef := v_suma_sueldo*.16;
        WHEN v_suma_sueldo BETWEEN 40001 AND 50000 THEN 
        v_boni_jef := v_suma_sueldo*.18;
        WHEN v_suma_sueldo BETWEEN 50001 AND 100000 THEN 
        v_boni_jef := v_suma_sueldo*.25;
        WHEN v_suma_sueldo BETWEEN 100001 AND 300000 THEN 
        v_boni_jef := v_suma_sueldo*.3;
        ELSE
            v_boni_jef := 0;
        END CASE;
        
        IF v_boni_jef > v_sueldo THEN
            v_boni_jef := v_sueldo;
        END IF;
        
        SELECT NVL(t.porc_bonif_trab,0) INTO v_boni_trab 
        FROM EMPLEADO e LEFT JOIN BONIF_POR_TRABAJO t on(e.id_trabajo = t.id_trabajo)
        WHERE e.id_empleado = i;
        
        v_super_suma := v_sueldo + v_carga_familiar + v_boni_jef;
        v_bonif_trab_total := TRUNC(v_boni_trab * v_super_suma);

        
        SELECT r.id_region INTO v_region FROM EMPLEADO e LEFT OUTER JOIN
        DEPARTAMENTO d ON(e.id_departamento = d.id_departamento) LEFT JOIN UBICACION u ON(d.id_ubicacion = u.id_ubicacion)
        LEFT JOIN PAIS p ON(u.id_pais = p.id_pais) LEFT JOIN REGION r ON(r.id_region = p.id_region)
        WHERE e.id_empleado = i;
        
        IF v_region = 1 THEN
            v_asig_euro := 1000;
            IF v_sueldo < 7000 THEN
                v_asig_euro := v_asig_euro + 500;
            ELSIF v_sueldo BETWEEN 7000 AND 11000 THEN
                v_asig_euro := v_asig_euro + 300;
            ELSIF v_sueldo > 7000 THEN
                v_asig_euro := v_asig_euro + 200;
            END IF;
        ELSE
            v_asig_euro := 0;
        END IF;
        
        SELECT s.porc_descto_salud, a.porc_descto_afp
        INTO v_afp, v_salud 
        FROM EMPLEADO e JOIN SALUD s ON(e.cod_salud = s.cod_salud)
        JOIN AFP a ON(e.cod_afp = a.cod_afp)
        WHERE id_empleado = i;
        
        
        v_afp_total := (v_afp/100) * (v_sueldo + v_boni_jef + v_bonif_trab_total);
        v_salud_total := (v_salud/100) * (v_sueldo + v_boni_jef + v_bonif_trab_total);
        
        
        
        v_total := v_sueldo + v_bonif_trab_total +
        v_boni_jef + v_asig_euro - v_salud_total - v_afp_total;
        
        
    INSERT INTO DETALLE_REMUNERACION_MENSUAL VALUES (i,
    EXTRACT(MONTH FROM SYSDATE) || EXTRACT(YEAR FROM SYSDATE),v_sueldo, v_carga_familiar,
    v_boni_jef,v_bonif_trab_total,v_asig_euro,v_salud_total,v_afp_total,v_total);
    
    
    
    END LOOP;
END;