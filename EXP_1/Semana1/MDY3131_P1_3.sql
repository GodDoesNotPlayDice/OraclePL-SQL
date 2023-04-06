SET SERVEROUTPUT ON
VAR B_RUN VARCHAR2(20)
EXEC :B_RUN:=&rut
--- CASO 3
DECLARE
    V_NOMBRE VARCHAR2(50);
    V_RUN VARCHAR2(12);
    V_SUELDO NUMBER(20);
    V_SUELDO_REAJUSTADO NUMBER(20);
    V_REAJUSTE FLOAT(10);
    V_REAJUSTE2 FLOAT(10);
BEGIN
    SELECT E.nombre_emp || ' ' || E.appaterno_emp ||' '||E.apmaterno_emp,
    E.numrut_emp || '-' || E.dvrut_emp,
    E.sueldo_emp,
    E.sueldo_emp*(&porcentaje/100),
    E.sueldo_emp*(&porcentaje/100)
    INTO V_NOMBRE, V_RUN, V_SUELDO, V_REAJUSTE, V_REAJUSTE2
    FROM EMPLEADO E
    WHERE E.numrut_emp=:B_RUN AND E.sueldo_emp BETWEEN 200000 AND 400000;
    
    DBMS_OUTPUT.put_line('Nombre Empleado: ' || V_NOMBRE);
    DBMS_OUTPUT.put_line('RUN: ' || V_RUN);
    DBMS_OUTPUT.put_line('Simulacion 1: Aumentar un 8,5% el salario de todos los empleados');
    DBMS_OUTPUT.put_line('SUELDO ACTUAL: ' || V_SUELDO);
    DBMS_OUTPUT.put_line('SUELDO REAJUSTADO: ' ||ROUND(V_REAJUSTE + V_REAJUSTE));
    DBMS_OUTPUT.put_line('REAJUSTE: ' || ROUND(V_REAJUSTE));

    DBMS_OUTPUT.put_line('Simulacion 2: Aumentar un 20% el salario de todos los empleados');
    DBMS_OUTPUT.put_line('SUELDO ACTUAL: ' || V_SUELDO);
    DBMS_OUTPUT.put_line('SUELDO REAJUSTADO: ' ||ROUND(V_REAJUSTE2 + V_REAJUSTE2));
    DBMS_OUTPUT.put_line('REAJUSTE: ' || ROUND(V_REAJUSTE2));
END;



