SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
*USE \\srvhp-os-2k8\medsoft\med_new_smaunse\ctb\dtoencuo IN 0
*USE \\srvhp-os-2k8\medsoft\med_new_smaunse\pyr\o_ctacte IN 0
*USE \\srvhp-os-2k8\medsoft\med_new_smaunse\opt\t_ctacte IN 0

*USE c:\med_new_smaunse\vtas1117 IN 0

*SELECT dtoencuo
*SET ORDER TO clave

LOCAL dFecha
STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDto,nTarjeta,nDebito

SELECT a_ctacte
SCAN NEXT 5 FOR tipo_comp="TB" AND cobranza.fondo>0
	nSaldo=0
	nOk=0
	cClave=tipo_comp+sucursal+numero
	
	IF importe<>cobranza.efectivo+cobranza.banco+cobranza.tarjeta+cobranza.debito+cobranza.documento
		REPLACE importe WITH importe+cobranza.fondo
		REPLACE saldo WITH saldo+cobranza.fondo
		REPLACE iva_comp WITH ROUND(cobranza.fondo-(cobranza.fondo/1.21),2)
		REPLACE alic_comp WITH 21
	ELSE
		REPLACE iva_comp WITH ROUND(cobranza.fondo-(cobranza.fondo/1.21),2)
		REPLACE alic_comp WITH 21
	ENDIF
	
	SELECT a_ctacte
ENDSCAN

