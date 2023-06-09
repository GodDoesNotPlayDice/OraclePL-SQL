VAR B_PATENTE VARCHAR2(50);
VAR B_IPC NUMBER;
EXEC :B_PATENTE:= 'VR1003';
EXEC :B_IPC:=25000;

DECLARE
V_PATENTE VARCHAR2(10);
V_ARRIENDO_INI DATE;
V_DIAS NUMBER(10);
V_ARRIENDO_DEV DATE;
V_ATRASO NUMBER(5);
V_MULTA NUMBER(10);
V_C_MULTA MULTA_ARRIENDO%ROWTYPE;
V_ANNO_PROCESO VARCHAR2(10);
BEGIN
    SELECT FECHA_INI_ARRIENDO, DIAS_SOLICITADOS, FECHA_DEVOLUCION,
    (EXTRACT(DAY FROM FECHA_DEVOLUCION) - EXTRACT(DAY FROM FECHA_INI_ARRIENDO)) - DIAS_SOLICITADOS
    INTO V_ARRIENDO_INI,V_DIAS,V_ARRIENDO_DEV,V_ATRASO
    FROM ARRIENDO_CAMION
    WHERE NRO_PATENTE = :B_PATENTE AND EXTRACT(MONTH FROM FECHA_INI_ARRIENDO) = EXTRACT(MONTH FROM SYSDATE) - 1
    AND (EXTRACT(DAY FROM FECHA_DEVOLUCION) - EXTRACT(DAY FROM FECHA_INI_ARRIENDO)) - DIAS_SOLICITADOS <> 0;

    V_MULTA:= V_ATRASO * :B_IPC;
    V_ANNO_PROCESO := EXTRACT(YEAR FROM SYSDATE) || EXTRACT(MONTH FROM SYSDATE);
    
    V_C_MULTA.ANNO_MES_PROCESO:= V_ANNO_PROCESO;
    V_C_MULTA.NRO_PATENTE:= :B_PATENTE;
    V_C_MULTA.FECHA_INI_ARRIENDO:= V_ARRIENDO_INI;
    V_C_MULTA.DIAS_SOLICITADO:= V_DIAS;
    V_C_MULTA.FECHA_DEVOLUCION:= V_ARRIENDO_DEV;
    V_C_MULTA.DIAS_ATRASO:= V_ATRASO;
    V_C_MULTA.VALOR_MULTA:= V_MULTA;
    INSERT INTO MULTA_ARRIENDO VALUES V_C_MULTA; 
END;

