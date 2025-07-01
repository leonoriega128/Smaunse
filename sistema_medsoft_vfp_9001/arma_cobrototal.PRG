SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
USE c:\med_new_smaunse\vtaspfmn IN 0
USE c:\med_new_smaunse\vtaspftd IN 0
USE c:\med_new_smaunse\vtasrgmn IN 0
USE c:\med_new_smaunse\vtasrgtd IN 0
USE c:\med_new_smaunse\vtasopmn IN 0
USE c:\med_new_smaunse\vtasoptd IN 0

USE c:\med_new_smaunse\vtas1117 IN 0

SELECT vtas1117
SET ORDER TO clave

LOCAL dFecha
STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDto,nTarjeta,nDebito

SELECT vtaspfmn
SCAN
	dFecha=VTASPFMN.fecha
	nEfectivo=VTASPFMN.efectivo
	nDto=VTASPFMN.documento
	nTarjeta=VTASPFMN.tarjeta
	nDebito=VTASPFMN.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totpfmn WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totpfmn WITH totpfmn+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT vtaspfmn
ENDSCAN

SELECT VTASPFTD
SCAN
	dFecha=VTASPFTD.fecha
	nEfectivo=VTASPFTD.efectivo
	nDto=VTASPFTD.documento
	nTarjeta=VTASPFTD.tarjeta
	nDebito=VTASPFTD.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totpftd WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totpftd WITH totpftd+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT VTASPFTD
ENDSCAN

SELECT VTASRGMN
SCAN
	dFecha=VTASRGMN.fecha
	nEfectivo=VTASRGMN.efectivo
	nDto=VTASRGMN.documento
	nTarjeta=VTASRGMN.tarjeta
	nDebito=VTASRGMN.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totregmn WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totregmn WITH totregmn+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT VTASRGMN
ENDSCAN

SELECT VTASRGTD
SCAN
	dFecha=VTASRGTD.fecha
	nEfectivo=VTASRGTD.efectivo
	nDto=VTASRGTD.documento
	nTarjeta=VTASRGTD.tarjeta
	nDebito=VTASRGTD.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totregtd WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totregtd WITH totregtd+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT VTASRGTD
ENDSCAN

SELECT VTASOPMN
SCAN
	dFecha=VTASOPMN.fecha
	nEfectivo=VTASOPMN.efectivo
	nDto=VTASOPMN.documento
	nTarjeta=VTASOPMN.tarjeta
	nDebito=VTASOPMN.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totoptmn WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totoptmn WITH totoptmn+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT VTASOPMN
ENDSCAN

SELECT VTASOPTD
SCAN
	dFecha=VTASOPTD.fecha
	nEfectivo=VTASOPTD.efectivo
	nDto=VTASOPTD.documento
	nTarjeta=VTASOPTD.tarjeta
	nDebito=VTASOPTD.debito

	SELECT vtas1117
	IF !SEEK(DTOS(dFecha))
		APPEND BLANK
		Replace fecha WITH dFecha
		Replace totopttd WITH nEfectivo+nDto+nTarjeta+nDebito
	ELSE
		Replace totopttd WITH totopttd+nEfectivo+nDto+nTarjeta+nDebito
	ENDIF

	SELECT VTASOPTD
ENDSCAN

