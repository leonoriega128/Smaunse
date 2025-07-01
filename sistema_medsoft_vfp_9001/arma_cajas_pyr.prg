SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
USE c:\med_new_smaunse\c\cobranza IN 0
USE c:\med_new_smaunse\c\totcajas IN 0

SELECT totcajas
SELECT cobranza
SET ORDER TO CAJA   && NRO_CAJA

LOCAL dFecha
STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDto,nTarjeta,nDebito

SCAN FOR tipo="I" AND manual=.F.

	IF cCaja<>cobranza.nro_caja
		IF !EMPTY(cCaja)
			SELECT totcajas
			APPEND BLANK
			Replace nro_caja WITH cCaja
			Replace unidad WITH cUnidad
			Replace dia WITH dFecha
			Replace efectivo WITH nEfectivo
			Replace adescuento WITH nDto
			Replace tcredito WITH nTarjeta
			Replace tdebito WITH nDebito
		ENDIF
		cCaja=COBRANZA.nro_caja
		cUnidad=IIF(COBRANZA.cajero=364,"PERFUMERIA","REGALERIA")
		dFecha=COBRANZA.fecha
		nEfectivo=COBRANZA.efectivo
		nDto=COBRANZA.documento
		nTarjeta=COBRANZA.tarjeta
		nDebito=COBRANZA.debito
	ELSE
		nEfectivo=nEfectivo+COBRANZA.efectivo
		nDto=nDto+cobranza.documento
		nTarjeta=nTarjeta+cobranza.tarjeta
		nDebito=nDebito+cobranza.debito
	ENDIF
	SELECT cobranza
ENDSCAN

	IF !EMPTY(cCaja)
		SELECT totcajas
		APPEND BLANK
		Replace nro_caja WITH cCaja
		Replace unidad WITH cUnidad
		Replace dia WITH dFecha
		Replace efectivo WITH nEfectivo
		Replace adescuento WITH nDto
		Replace tcredito WITH nTarjeta
		Replace tdebito WITH nDebito
	ENDIF
