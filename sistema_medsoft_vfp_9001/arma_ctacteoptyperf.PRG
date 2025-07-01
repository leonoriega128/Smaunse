SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
USE \\srvhp-os-2k8\medsoft\med_new_smaunse\ctb\dtoencuo IN 0
USE \\srvhp-os-2k8\medsoft\med_new_smaunse\pyr\o_ctacte IN 0
USE \\srvhp-os-2k8\medsoft\med_new_smaunse\opt\t_ctacte IN 0

*USE c:\med_new_smaunse\vtas1117 IN 0

SELECT dtoencuo
SET ORDER TO clave

LOCAL dFecha
STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDto,nTarjeta,nDebito

SELECT o_ctacte
SCAN FOR tipo_comp="TB" AND saldo>0
	nSaldo=0
	nOk=0
	cClave=tipo_comp+sucursal+numero
	
*!*		dFecha=VTASPFMN.fecha
*!*		nEfectivo=VTASPFMN.efectivo
*!*		nDto=VTASPFMN.documento
*!*		nTarjeta=VTASPFMN.tarjeta
*!*		nDebito=VTASPFMN.debito

	SELECT dtoencuo
	IF SEEK(cClave)
		nOk=1
		SCAN REST WHILE cClave=dtoencuo.originado
			nSaldo=nSaldo+dtoencuo.saldo
		ENDSCAN
	ENDIF

	SELECT o_ctacte
	IF nOk=1
		Replace saldo WITH nSaldo
	ENDIF
ENDSCAN


SELECT t_ctacte
SCAN FOR tipo_comp="TB" AND saldo>0
	nSaldo=0
	nOk=0
	cClave=tipo_comp+sucursal+numero
	
*!*		dFecha=VTASPFMN.fecha
*!*		nEfectivo=VTASPFMN.efectivo
*!*		nDto=VTASPFMN.documento
*!*		nTarjeta=VTASPFMN.tarjeta
*!*		nDebito=VTASPFMN.debito

	SELECT dtoencuo
	IF SEEK(cClave)
		nOk=1
		SCAN REST WHILE cClave=dtoencuo.originado
			nSaldo=nSaldo+dtoencuo.saldo
		ENDSCAN
	ENDIF

	SELECT t_ctacte
	IF nOk=1
		Replace saldo WITH nSaldo
	ENDIF
ENDSCAN
