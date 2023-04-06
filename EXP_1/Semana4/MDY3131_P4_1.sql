VAR b_anno NUMBER;

VAR b_mariapinto VARCHAR2;
VAR b_curacavi VARCHAR2;
VAR b_talagante VARCHAR2;
VAR b_elmonte VARCHAR2;
VAR b_buin VARCHAR2;

VAR b_mov_mariapinto NUMBER;
VAR b_mov_curacavi NUMBER;
VAR b_mov_talagante NUMBER;
VAR b_mov_elmonte NUMBER;
VAR b_mov_buin NUMBER;

EXEC :b_mariapinto := 'María Pinto';
EXEC :b_curacavi := 'Curacaví';
EXEC :b_talagante := 'Talagante';
EXEC :b_elmonte := 'El Monte';
EXEC :b_buin := 'Buin';

EXEC :b_mov_mariapinto := 20000;
EXEC :b_mov_curacavi := 25000;
EXEC :b_mov_talagante := 30000;
EXEC :b_mov_elmonte := 35000;
EXEC :b_mov_buin := 40000;

EXEC :b_anno := EXTRACT(YEAR FROM SYSDATE);
DECLARE
v_min NUMBER(10);
v_max NUMBER(10);
v_run NUMBER(10);
v_dv VARCHAR2(1);
v_nombre VARCHAR2(50);
v_comuna VARCHAR2(50);
v_sueldo NUMBER(10);
v_porc_movil_normal NUMBER(10);
v_valor_normal NUMBER(10);
v_valor_extra NUMBER(10);
v_total NUMBER(10);
BEGIN
    SELECT MIN(id_emp), MAX(id_emp) INTO v_min, v_max FROM EMPLEADO;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PROY_MOVILIZACION';
    
    WHILE v_min < v_max LOOP
        SELECT e.pnombre_emp ||' '|| e.snombre_emp ||' '|| e.appaterno_emp || ' ' || e.apmaterno_emp 
        ,e.numrun_emp, e.dvrun_emp, c.nombre_comuna, e.sueldo_base
        INTO v_nombre, v_run, v_dv, v_comuna, v_sueldo FROM EMPLEADO e JOIN COMUNA c ON(c.id_comuna = e.id_comuna)
        WHERE e.id_emp = v_min;
        
        v_porc_movil_normal := TRUNC(v_sueldo/100000);
        v_valor_normal := TRUNC(v_sueldo*(v_porc_movil_normal)/100);
        
        IF v_comuna = :b_mariapinto THEN 
            v_valor_extra := :b_mov_mariapinto;
        ELSIF v_comuna = :b_curacavi THEN
            v_valor_extra := :b_mov_curacavi;
        ELSIF v_comuna = :b_talagante THEN
            v_valor_extra := :b_mov_talagante;
        ELSIF v_comuna = :b_elmonte THEN
            v_valor_extra := :b_mov_elmonte;
        ELSIF v_comuna = :b_buin THEN
            v_valor_extra := :b_mov_buin;
        ELSE
            v_valor_extra := 0;
        END IF;
        
        v_total := v_valor_normal  + v_valor_extra;
        
        INSERT INTO PROY_MOVILIZACION VALUES (:b_anno,v_min,v_run,v_dv,v_nombre,v_comuna,v_sueldo,v_porc_movil_normal,v_valor_normal,v_valor_extra,v_total);  
        v_min := v_min + 10;
    END LOOP;        
END;

