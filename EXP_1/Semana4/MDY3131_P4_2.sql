DECLARE
v_min NUMBER(10);
v_max NUMBER(10);
v_nombre VARCHAR2(60);
v_run NUMBER(10);
v_dv VARCHAR2(1);
v_comuna VARCHAR2(30);
v_sueldo NUMBER(10);
v_est_civil VARCHAR2(30);
v_user VARCHAR(20);
v_pnombre VARCHAR(30);
v_fecha DATE;
v_anos NUMBER(10);
v_clave VARCHAR2(30);
v_nac_fecha DATE;
v_id_civil NUMBER(10);
v_apaterno VARCHAR(30);
BEGIN 
    SELECT MIN(id_emp), MAX(id_emp) INTO v_min, v_max FROM EMPLEADO;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE USUARIO_CLAVE';
    WHILE v_min <= v_max LOOP
    SELECT e.pnombre_emp ||' '|| NVL(e.snombre_emp,'') ||' '|| e.appaterno_emp || ' ' || e.apmaterno_emp 
        ,e.numrun_emp, e.dvrun_emp, c.nombre_comuna, e.sueldo_base, ec.nombre_estado_civil, e.pnombre_emp,
        e.fecha_contrato, e.fecha_nac,e.id_estado_civil,e.appaterno_emp 
        INTO v_nombre, v_run, v_dv, v_comuna, v_sueldo, v_est_civil,v_pnombre,v_fecha, v_nac_fecha,v_id_civil,v_apaterno
        FROM EMPLEADO e JOIN COMUNA c ON(c.id_comuna = e.id_comuna)
        JOIN ESTADO_CIVIL ec ON(ec.id_estado_civil = e.id_estado_civil)
        WHERE e.id_emp = v_min;
        
    v_anos := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha)/12);
    v_user := LOWER(SUBSTR(v_est_civil,1,1)) || SUBSTR(v_nombre, 1,3) ||
        LENGTH(v_pnombre)||'*'||SUBSTR(v_sueldo,-1,1)||v_dv||TO_CHAR(v_anos);
        
        
    IF v_anos < 10 THEN 
        v_user := v_user || 'X';
    END IF;
    
    v_clave := SUBSTR(v_run,3,1)||(EXTRACT(YEAR FROM v_nac_fecha) + 2)|| SUBSTR(v_sueldo,-2,3)-1;
    
    IF v_id_civil = 10 OR v_id_civil = 60 THEN 
        v_clave := v_clave || LOWER(SUBSTR(v_apaterno,1,2));
    ELSIF v_id_civil= 20 OR v_id_civil = 30 THEN
         v_clave := v_clave || LOWER(SUBSTR(v_apaterno,1,1)) || LOWER(SUBSTR(v_apaterno,-1,1));
    ELSIF v_id_civil = 40 THEN
        v_clave := v_clave || LOWER(SUBSTR(v_apaterno,-3,1)) || LOWER(SUBSTR(v_apaterno,-2,1));
    ELSE
        v_clave := v_clave || LOWER(SUBSTR(v_apaterno,-2,1)) || LOWER(SUBSTR(v_apaterno,-1,1));
    END IF;
    v_clave := v_clave || v_min || EXTRACT(MONTH FROM SYSDATE) || EXTRACT(YEAR FROM SYSDATE);
    
    INSERT INTO USUARIO_CLAVE VALUES (v_min,v_run,v_dv,v_nombre,v_user,v_clave);
    v_min:= v_min + 10;
    END LOOP;
END;