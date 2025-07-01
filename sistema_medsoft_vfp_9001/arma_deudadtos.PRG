SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE ON
SET DELETED ON
USE c:\med_new_smaunse\ctb\dtoencuo IN 0
USE c:\med_new_smaunse\d\dh_deuda IN 0
*USE c:\med_new_smaunse\opt\t_ctacte IN 0

SELECT dtoencuo
SET ORDER TO AFI   && O_SOCIAL+A_NUMERO
*SET ORDER TO LIQUIDA   && IDLIQUIDA+O_SOCIAL+A_NUMERO

LOCAL cOSocial,cLiquida,cClave,nDtos
*STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDtos
cLiquida="00000258"

SELECT dtoencuo
GO top
*SEEK (cLiquida)
cClave=a_numero
cOSocial=o_social
*SCAN REST WHILE EMPTY(LEFT(cClave,1))
*	cClave=a_numero
*ENDSCAN

*SCAN REST WHILE idliquida=cLiquida FOR VAL(iddescuen)=0 OR VAL(iddescuen)=50 OR VAL(iddescuen)=99 OR VAL(iddescuen)=119
*SCAN REST FOR !EMPTY(LEFT(cClave,1)) AND saldo>0 AND VAL(iddescuen)=119
SCAN REST FOR saldo>0 AND VAL(iddescuen)=119 AND VAL(STR(ano,4)+RIGHT("00"+ALLTRIM(STR(mes)),2))<201906
	
	IF cClave<>a_numero
		SELECT dh_deuda
		APPEND BLANK
		replace o_social WITH cOSocial
		replace a_numero WITH cClave
*		replace idliquida WITH cLiquida
		replace saldo WITH nDtos
		SELECT dtoencuo
		cClave=a_numero
		cOSocial=o_social
		nDtos=0
	ENDIF
	
	nDtos=nDtos+saldo

ENDSCAN
SELECT dh_deuda
APPEND BLANK
replace o_social WITH cOSocial
replace a_numero WITH cClave
*replace idliquida WITH cLiquida
replace saldo WITH nDtos
