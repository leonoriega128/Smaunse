SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
USE c:\med_new_smaunse\d\dtoencuo IN 0
USE c:\med_new_smaunse\d\dh_dto IN 0
*USE c:\med_new_smaunse\opt\t_ctacte IN 0

SELECT dtoencuo
SET ORDER TO LIQUIDA   && IDLIQUIDA+O_SOCIAL+A_NUMERO

LOCAL cOSocial,cLiquida,cClave,nDtos
*STORE '' TO cCaja,cUnidad
STORE 0 TO nEfectivo,nDtos
cLiquida="00000244"

SELECT dtoencuo
SEEK (cLiquida)
cClave=a_numero
cOSocial=o_social
SCAN REST WHILE idliquida=cLiquida FOR VAL(iddescuen)=0 OR VAL(iddescuen)=50 OR VAL(iddescuen)=99 OR VAL(iddescuen)=119
	
	IF cClave<>a_numero
		SELECT dh_dto
		APPEND BLANK
		replace o_social WITH cOSocial
		replace a_numero WITH cClave
		replace idliquida WITH cLiquida
		replace descuento WITH nDtos
		SELECT dtoencuo
		cClave=a_numero
		cOSocial=o_social
		nDtos=0
	ENDIF
	
	nDtos=nDtos+descuento

ENDSCAN
SELECT dh_dto
APPEND BLANK
replace o_social WITH cOSocial
replace a_numero WITH cClave
replace idliquida WITH cLiquida
replace descuento WITH nDtos
