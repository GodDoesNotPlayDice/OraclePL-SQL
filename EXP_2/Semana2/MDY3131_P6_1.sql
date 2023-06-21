DECLARE
type t_valor_multa IS VARRAY(7) OF NUMBER NOT NULL;
varray_multa t_valor_multa;

v_pago_moroso pago_moroso%rowtype;

CURSOR cur_pac IS 
    SELECT p.pac_run,p.dv_run, p.pnombre || ' ' || p.snombre || ' ' || p.apaterno || ' ' || p.amaterno "PAC_NOMBRE",
    a.ate_id, pa.fecha_venc_pago, pa.fecha_pago, e.nombre especialidad,
    ABS(EXTRACT(DAY FROM fecha_pago) - EXTRACT(DAY FROM fecha_venc_pago)) dias,
    TRUNC(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/12) annos
    FROM PACIENTE p JOIN ATENCION a ON(p.pac_run = a.pac_run) JOIN PAGO_ATENCION pa ON(pa.ate_id = a.ate_id)
    JOIN ESPECIALIDAD e ON(e.esp_id = a.esp_id)
    WHERE EXTRACT(YEAR FROM pa.fecha_venc_pago) = EXTRACT(YEAR FROM SYSDATE) - 1 
    AND EXTRACT(YEAR FROM pa.fecha_pago) = EXTRACT(YEAR FROM SYSDATE) - 1
    AND ABS(EXTRACT(DAY FROM fecha_pago) - EXTRACT(DAY FROM fecha_venc_pago)) <> 0;
    
v_dias pago_moroso.dias_morosidad%TYPE;
v_multa pago_moroso.monto_multa%TYPE;
v_porc FLOAT(10);
v_total NUMBER(10);
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PAGO_MOROSO';
    varray_multa := t_valor_multa(1200,1300,1700,1900,1100,2000,2300);
    FOR reg_pac IN cur_pac LOOP
    
            IF reg_pac.especialidad = 'Cirugía General' OR reg_pac.especialidad = 'Dermatología' THEN
                v_multa := varray_multa(1)*reg_pac.dias;
            ELSIF reg_pac.especialidad = 'Ortopedia y Traumatología' THEN
                v_multa := varray_multa(2)*reg_pac.dias;
            ELSIF reg_pac.especialidad = 'Inmunología' OR reg_pac.especialidad = 'Otorrinolaringología' THEN 
                v_multa := varray_multa(3)*reg_pac.dias;
            ELSIF reg_pac.especialidad = 'Fisiatría' OR reg_pac.especialidad = 'Medicina Interna' THEN 
                v_multa := varray_multa(4)*reg_pac.dias;
            ELSIF reg_pac.especialidad = 'Medicina General' THEN 
                v_multa := varray_multa(5)*reg_pac.dias;
            ELSIF reg_pac.especialidad = 'Psiquiatría Adultos' THEN 
                v_multa := varray_multa(6)*reg_pac.dias; 
            ELSIF reg_pac.especialidad = 'Cirugía Digestiva' OR reg_pac.especialidad = 'Reumatología' THEN 
                v_multa := varray_multa(7)*reg_pac.dias;
            END IF;
        
        IF reg_pac.annos >= 65 THEN
            SELECT porcentaje_descto/100 INTO v_porc FROM PORC_DESCTO_3RA_EDAD
            WHERE reg_pac.annos BETWEEN anno_ini AND anno_ter;
            v_total := v_multa - (v_multa*v_porc);
        ELSE 
            v_total := v_multa;
        END IF;
        
        
        
        v_pago_moroso.pac_run := reg_pac.pac_run;
        v_pago_moroso.pac_dv_run := reg_pac.dv_run;
        v_pago_moroso.pac_nombre := reg_pac.pac_nombre;
        v_pago_moroso.ate_id := reg_pac.ate_id;
        v_pago_moroso.fecha_venc_pago := reg_pac.fecha_venc_pago;
        v_pago_moroso.fecha_pago := reg_pac.fecha_pago;
        v_pago_moroso.dias_morosidad := reg_pac.dias;
        v_pago_moroso.especialidad_atencion := reg_pac.especialidad;
        v_pago_moroso.monto_multa := v_total;
        
        INSERT INTO PAGO_MOROSO VALUES v_pago_moroso;
        
    END LOOP;
END;