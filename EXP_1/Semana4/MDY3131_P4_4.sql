VAR b_utilidad NUMBER;
VAR b_porc_util NUMBER;
EXEC :b_utilidad := 200000000;
EXEC :b_porc_util := 30;

DECLARE
    v_min NUMBER(10);
    v_max NUMBER(10);
    v_sueldo NUMBER(10);
    v_bonif_utilidad NUMBER(10);
    v_cantidad NUMBER(10);
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE BONIF_POR_UTILIDAD';
    SELECT MIN(id_emp), MAX(id_emp) INTO v_min, v_max FROM EMPLEADO;
    
    WHILE v_min <= v_max LOOP
    SELECT e.sueldo_base INTO v_sueldo FROM EMPLEADO e
    WHERE e.id_emp = v_min;
    
    IF v_sueldo BETWEEN 320000 AND 600000 THEN
        SELECT COUNT(*) INTO v_cantidad FROM EMPLEADO WHERE sueldo_base BETWEEN 320000 AND 600000;
        v_bonif_utilidad := ROUND(((:b_utilidad*(:b_porc_util/100))*0.35)/v_cantidad);
    ELSIF v_sueldo BETWEEN 600001 AND 1300000 THEN
        SELECT COUNT(*) INTO v_cantidad FROM EMPLEADO WHERE sueldo_base BETWEEN 600001 AND 1300000;
        v_bonif_utilidad := ROUND(((:b_utilidad*(:b_porc_util/100))*0.25)/v_cantidad);
    ELSIF v_sueldo BETWEEN 1300001 AND 1800000 THEN
        SELECT COUNT(*) INTO v_cantidad FROM EMPLEADO WHERE sueldo_base BETWEEN 1300001 AND 1800000 ;
        v_bonif_utilidad := ROUND(((:b_utilidad*(:b_porc_util/100))*0.2)/v_cantidad);
    ELSIF v_sueldo BETWEEN 1800000 AND 2200000 THEN
        SELECT COUNT(*) INTO v_cantidad FROM EMPLEADO WHERE sueldo_base BETWEEN 1800000 AND 2200000 ;
        v_bonif_utilidad := ROUND(((:b_utilidad*(:b_porc_util/100))*0.15)/v_cantidad);
    ELSIF v_sueldo > 2200000 THEN
        SELECT COUNT(*) INTO v_cantidad FROM EMPLEADO WHERE sueldo_base > 2200000;
        v_bonif_utilidad := ROUND(((:b_utilidad*(:b_porc_util/100))*0.05)/v_cantidad);
    END IF;
    INSERT INTO BONIF_POR_UTILIDAD VALUES (EXTRACT(YEAR FROM SYSDATE), v_min, v_sueldo,v_bonif_utilidad);
    v_min := v_min + 10;
    END LOOP;
END;
