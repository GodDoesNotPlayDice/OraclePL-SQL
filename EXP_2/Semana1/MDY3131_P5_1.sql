DECLARE
v_min NUMBER(5);
v_max NUMBER(5);
v_run VARCHAR2(30);
v_tipo VARCHAR2(30);
v_nombre VARCHAR2(50);
v_monto_cred NUMBER(10);
v_monto_suma NUMBER(10);
v_extra NUMBER(10);



TYPE REG_TODO_SUMA IS RECORD(MONTO_MIN NUMBER(8), MONTO_MAX NUMBER(8), MONTO_EXTRA NUMBER(8));

TYPE TAB_TODO_SUMA IS TABLE OF REG_TODO_SUMA INDEX BY BINARY_INTEGER;

V_REG_TODO_SUMA TAB_TODO_SUMA; -- REGISTRO

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE CLIENTE_TODOSUMA';
    
    SELECT MAX(nro_cliente), MIN(nro_cliente) INTO v_max, v_min FROM CLIENTE;
    V_REG_TODO_SUMA(1).MONTO_MIN := 1000001;
    V_REG_TODO_SUMA(1).MONTO_MAX := 3000000;
    V_REG_TODO_SUMA(1).MONTO_EXTRA := 300;
        
    V_REG_TODO_SUMA(2).MONTO_MIN := 3000001;
    V_REG_TODO_SUMA(2).MONTO_MAX := 6000000;
    V_REG_TODO_SUMA(2).MONTO_EXTRA := 550;
        
    V_REG_TODO_SUMA(3).MONTO_MIN := 6000001;
    V_REG_TODO_SUMA(3).MONTO_MAX := 9999999;
    V_REG_TODO_SUMA(3).MONTO_EXTRA := 700;
    
    FOR i in v_min..v_max LOOP
        BEGIN 
            
        SELECT TO_CHAR(c.numrun, '99g999g999')||'-'||c.dvrun,
        c.pnombre || ' ' ||c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno,
        tc.nombre_tipo_cliente, cc.monto_solicitado
        INTO v_run,v_nombre,v_tipo,v_monto_cred
        FROM CLIENTE c JOIN TIPO_CLIENTE tc ON(c.cod_tipo_cliente = tc.cod_tipo_cliente)
        JOIN CREDITO_CLIENTE cc ON(c.nro_cliente = cc.nro_cliente)
        WHERE c.nro_cliente = i;
        
        case 
            when v_monto_cred between v_reg_todo_suma(1).monto_min and
                v_reg_todo_suma(1).monto_max then
                    v_extra:=((v_monto_cred/100000)*1200);
                    
            when v_monto_cred between v_reg_todo_suma(2).monto_min and
                v_reg_todo_suma(2).monto_max then
                    v_extra:=((v_monto_cred/100000)*1200);
               
            when v_monto_cred between v_reg_todo_suma(3).monto_min and
                v_reg_todo_suma(3).monto_max then
                    v_extra:=((v_monto_cred/100000)*1200);
            else
                v_extra:=((v_monto_cred/100000)*1200);
               
            end case;
    
        INSERT INTO CLIENTE_TODOSUMA VALUES(i,v_run,v_nombre,v_tipo,v_monto_cred,v_extra);
        
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        end;
    END LOOP;
END;