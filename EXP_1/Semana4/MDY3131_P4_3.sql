DECLARE
v_min NUMBER(10);
v_max NUMBER(10);
v_patente VARCHAR2(30);
v_arriendo NUMBER(10);
v_garantia NUMBER(10);
v_total_veces NUMBER(10);
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE HIST_ARRIENDO_ANUAL_CAMION';
    SELECT MIN(id_camion), MAX(id_camion) INTO v_min, v_max FROM CAMION;
    FOR i IN v_min..v_max LOOP
        
        SELECT COUNT(*) INTO v_total_veces FROM ARRIENDO_CAMION
        WHERE id_camion = i AND EXTRACT(YEAR FROM fecha_devolucion)  =  EXTRACT(YEAR FROM SYSDATE) - 1;
        
        IF v_total_veces < 4 THEN
            UPDATE CAMION SET
                valor_arriendo_dia = valor_arriendo_dia-(valor_arriendo_dia*(22.5/100)),
                valor_garantia_dia = valor_garantia_dia-(valor_garantia_dia*(22.5/100))
            WHERE id_camion = i;
        END IF;
        
        SELECT c.nro_patente, c.valor_arriendo_dia, c.valor_garantia_dia INTO v_patente, v_arriendo, v_garantia FROM CAMION c
        WHERE c.id_camion = i;
        
        INSERT INTO HIST_ARRIENDO_ANUAL_CAMION VALUES 
        (EXTRACT(YEAR FROM SYSDATE),i,v_patente,v_arriendo,v_garantia,v_total_veces);
    END LOOP;
END;