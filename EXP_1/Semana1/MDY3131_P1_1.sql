SET SERVEROUTPUT ON
VARIABLE B_RUN VARCHAR2(10)
EXEC :B_RUN:=11846972
--- CASO 1
DECLARE
    V_NOMBRE VARCHAR2(50);
    V_RUN VARCHAR2(10);
    V_SUELDO NUMBER(8);
BEGIN
    SELECT E.NOMBRE_EMP || ' ' || E.APPATERNO_EMP || ' ' || E.APMATERNO_EMP AS NOMBRE,
    E.NUMRUT_EMP || '-' ||E.dvrut_emp AS RUT,
    E.SUELDO_EMP AS SUELDO
    INTO V_NOMBRE, V_RUN, V_SUELDO
    FROM EMPLEADO E 
    WHERE E.NUMRUT_EMP=:B_RUN AND E.SUELDO_EMP < 500000 AND E.ID_CATEGORIA_EMP<>3;    
    
    DBMS_OUTPUT.put_line('DATOS CALCULO BONIFICACION EXTRA DEL 40%');
    DBMS_OUTPUT.put_line('Nombre Empleado: ' || V_NOMBRE);
    DBMS_OUTPUT.put_line('RUN: ' || V_RUN);
    DBMS_OUTPUT.put_line('SUELDO: ' || V_SUELDO);
    DBMS_OUTPUT.put_line('Bonificacion Extra: ' || V_SUELDO*0.4);
END;
    
    

