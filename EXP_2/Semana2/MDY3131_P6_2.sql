DECLARE
CURSOR cur_medico IS 
    SELECT u.nombre AS UNIDAD, m.med_run || ' - ' ||m.dv_run AS RUN_MEDICO,
    m.pnombre || ' ' || m.snombre || ' ' || m.apaterno || ' ' || m.amaterno AS PAC_NOMBRE,
    COUNT(a.med_run) AS TOTAL_ATEN_MEDICAS, SUBSTR(u.nombre,1,2)||SUBSTR(m.apaterno,-3,2)||'@medicocktk.cl'
    AS CORREO_INSTITUCIONAL
    FROM MEDICO m JOIN UNIDAD u ON(m.uni_id = u.uni_id) JOIN ATENCION a ON(m.med_run= a.med_run)
    WHERE EXTRACT(YEAR FROM a.fecha_atencion) = EXTRACT(YEAR FROM SYSDATE) - 1
    GROUP BY u.nombre, m.med_run || ' - ' ||m.dv_run,
    m.pnombre || ' ' || m.snombre || ' ' || m.apaterno || ' ' || m.amaterno,
    SUBSTR(u.nombre,1,2)||SUBSTR(m.apaterno,-3,2)||'@medicocktk.cl';
    
    TYPE arr_dest IS VARRAY(10) OF VARCHAR2(50) NOT NULL;
    t_dest arr_dest := arr_dest('Servicio de Atención Primaria de Urgencia (SAPU)');
BEGIN
    
    FOR reg_med IN cur_med
    
    
END;