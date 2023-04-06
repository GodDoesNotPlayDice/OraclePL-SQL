-- CASO 4
SET SERVEROUTPUT ON
DECLARE
V_NOMBRE VARCHAR2(50);
V_NUM_PROPIEDAD NUMBER(10);
V_TOTAL NUMBER(20);
V_LETRA CHAR(1);
V_COUNT NUMBER(5);
V_MAX_COUNT NUMBER(5);
BEGIN
    V_COUNT:=1;
    V_MAX_COUNT:=8;

    WHILE V_COUNT <= V_MAX_COUNT LOOP
        IF V_COUNT = 1 THEN
            V_LETRA:='A';
        ELSIF V_COUNT = 2 THEN
            V_LETRA:='B';
        ELSIF V_COUNT = 3 THEN
            V_LETRA:='C';
        ELSIF V_COUNT = 4 THEN
            V_LETRA:='D';
        ELSIF V_COUNT = 5 THEN
            V_LETRA:='E';
        ELSIF V_COUNT = 6 THEN
            V_LETRA:='F';
        ELSIF V_COUNT = 7 THEN
            V_LETRA:='G';
        ELSIF V_COUNT = 8 THEN
            V_LETRA:='H';
        END IF;
        
    SELECT tp.desc_tipo_propiedad, 
    count(ID_TIPO_PROPIEDAD), 
    sum(P.VALOR_ARRIENDO)
    INTO V_NOMBRE,V_NUM_PROPIEDAD, V_TOTAL
    FROM PROPIEDAD P JOIN TIPO_PROPIEDAD TP using(ID_TIPO_PROPIEDAD)
    WHERE ID_TIPO_PROPIEDAD = V_LETRA
    GROUP BY tp.desc_tipo_propiedad;
    
    DBMS_OUTPUT.put_line('RESUMEN DE: ' || V_NOMBRE);
    DBMS_OUTPUT.put_line('Total de Propiedades: ' || V_NUM_PROPIEDAD);
    DBMS_OUTPUT.put_line('Valor Total Arriendo: ' || TO_CHAR(V_TOTAL, 'L999G999G999'));
    
    V_COUNT:= V_COUNT + 1;
    
    END LOOP;
END;