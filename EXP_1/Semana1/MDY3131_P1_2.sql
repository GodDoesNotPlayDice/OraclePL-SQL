-- CASO 2
SET SERVEROUTPUT ON
VARIABLE B_RUN_CLI VARCHAR2(10)
EXEC :B_RUN_CLI:=13074837


DECLARE
V_NOMBRE_CLI VARCHAR2(50);
V_RUT_CLI VARCHAR2(10);
V_ECIVIL VARCHAR2(50);
V_RENTA NUMBER(8);
    
BEGIN
    SELECT C.NOMBRE_CLI ||' '|| C.APPATERNO_CLI || ' ' || C.APMATERNO_CLI AS Nombre,
    C.NUMRUT_CLI||'-'||C.DVRUT_CLI AS RUN,
    ec.desc_estcivil AS Estado,
    C.RENTA_CLI AS Renta
    INTO V_NOMBRE_CLI, V_RUT_CLI, V_ECIVIL, V_RENTA
    FROM CLIENTE C JOIN ESTADO_CIVIL EC ON(C.ID_ESTCIVIL = EC.ID_ESTCIVIL)
    WHERE C.ID_ESTCIVIL IN (1,3,4) AND C.NUMRUT_CLI=:B_RUN_CLI AND C.RENTA_CLI>=&RENTA;
    
    DBMS_OUTPUT.put_line('DATOS DEL CLIENTE');
    DBMS_OUTPUT.put_line('-----------------------');
    DBMS_OUTPUT.put_line('Nombre Cliente: ' || V_NOMBRE_CLI);
    DBMS_OUTPUT.put_line('RUN: ' || V_RUT_CLI);
    DBMS_OUTPUT.put_line('ESTADO CIVIL: ' || V_ECIVIL);
    DBMS_OUTPUT.put_line('RENTA: ' || V_RENTA);
    
END;