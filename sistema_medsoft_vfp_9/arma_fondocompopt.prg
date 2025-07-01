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

SELECT t_ctacte
SCAN NEXT 5 FOR (tipo_comp="TB" OR tipo_comp="TA") AND importe<>cobranza.efectivo+cobranza.banco+cobranza.tarjeta+cobranza.debito+cobranza.documento
	nSaldo=0
	nOk=0
	cClave=tipo_comp+sucursal+numero
	IF t_ctacte.saldo>0 AND t_ctacte.saldo<>cobranza.documento	
		REPLACE NEXT 1 importe WITH importe+ventas.recargo+ventas.fondo
		REPLACE NEXT 1 saldo WITH saldo+ventas.recargo+ventas.fondo
		REPLACE NEXT 1 iva_comp WITH ROUND(importe-(importe/1.21),2)
	ELSE
		REPLACE NEXT 1 importe WITH importe+ventas.recargo+ventas.fondo
		REPLACE NEXT 1 iva_comp WITH ROUND(importe-(importe/1.21),2)
	ENDIF

	SELECT t_ctacte
ENDSCAN

