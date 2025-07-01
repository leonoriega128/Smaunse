SET CENTURY on
SET DATE FRENCH
SET EXCLUSIVE OFF
USE c:\med_new_smaunse\delegaci\move_afi IN 0
USE c:\med_new_smaunse\delegaci\alba_afi IN 0

SELECT alba_afi
SET ORDER TO CLAVE   && O_SOCIAL+A_NUMERO+FAMILIAR+DTOS(FECHA_M)
SELECT move_afi
SET ORDER TO CLAVEAFI   && O_SOCIAL+A_NUMERO+FAMILIAR+DTOS(FECHA_M)

STORE '' TO cAfi,cObra,cFam
SCAN
	IF cObra<>move_afi.o_social OR cAfi<>move_Afi.a_numero OR cFam<>move_Afi.familiar
		SCATTER memvar
		cObra=m.o_social
		cAfi=m.a_numero
		cFam=m.familiar
		nEstado=m.estado
		SELECT ALBA_AFI
		IF SEEK(cObra+cAfi+cFam)
			Replace estado WITH m.estado
			Replace e_fecha WITH m.e_fecha
			Replace fecha WITH m.fecha
			Replace hora WITH m.hora
			Replace operador WITH m.operador
			Replace fecha_m WITH m.fecha_m
		ELSE
			APPEND BLANK
			GATHER memvar
		ENDIF
	ELSE
		IF move_afi.estado<>nEstado
			nEstado=move_afi.estado
			SCATTER memvar
			SELECT ALBA_AFI
			APPEND BLANK
			GATHER memvar
		ENDIF
	ENDIF
	SELECT move_afi
ENDSCAN
