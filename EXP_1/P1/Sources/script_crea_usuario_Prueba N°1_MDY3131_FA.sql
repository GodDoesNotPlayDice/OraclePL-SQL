﻿/* Creación de usuario si está trabajando con BD Oracle XE */
CREATE USER MDY3131_PRUEBA1_FA IDENTIFIED BY "MDY3131.prueba_1A"
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY3131_PRUEBA1_FA QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO MDY3131_PRUEBA1_FA;
GRANT "RESOURCE" TO MDY3131_PRUEBA1_FA;
ALTER USER MDY3131_PRUEBA1_FA DEFAULT ROLE "RESOURCE";

/* Creación de usuario si está trabajando con BD Oracle Cloud */
CREATE USER MDY3131_PRUEBA1_FA IDENTIFIED BY "MDY3131.prueba_1A"
DEFAULT TABLESPACE "DATA"
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY3131_PRUEBA1_FA QUOTA UNLIMITED ON DATA;
GRANT CREATE SESSION TO MDY3131_PRUEBA1_FA;
GRANT "RESOURCE" TO MDY3131_PRUEBA1_FA;
ALTER USER MDY3131_PRUEBA1_FA DEFAULT ROLE "RESOURCE";