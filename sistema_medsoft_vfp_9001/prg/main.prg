*** SETEOS GENERALES
set sysmenu off
*SET SYSFORMATS ON
*set help to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\ayuda.chm"

set help to "MegaSistema.chm"
_screen.Tag='1.2.0'

*!*	SMAUNSE 
_screen.AddProperty('Cliente','S.M.A.U.N.S.E.')

*_screen.AddProperty('Cliente','ZURICH HEALTH')

*_screen.AddProperty('Cliente','MEDICAL WORKERS')

*set defa to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\prg"

EXTERNAL PROCEDURE ReportOutput.prg
_ReportOutput = "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\reportes\ReportOutput\ReportOutput.prg"

EXTERNAL PROCEDURE frxpreview.prg
_REPORTPREVIEW = "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\reportes\ReportPreview\frxpreview.prg"

_screen.caption="MedSoft"
_Screen.Windowstate=2
_screen.closable=.f.
_screen.Icon='medsoft2.ico'
_screen.MaxButton= .T.
_screen.MinButton= .T.

SET STATUS BAR OFF
SET STATUS OFF 
SET UDFPARMS TO REFERENCE 

*SET SYSMENU TO 
set century on
set scoreboard off
set safety off
set notify off
set ESCAPE OFF
set date to BRITISH
set exclusive off
set message TO
set talk off
set deleted on
set decimal to 3
set cpdialog off
SET EXACT OFF
**SET SEPARATOR TO ","
*
ON ERROR DO ERR_LOG WITH ERROR(), MESSAGE(), MESSAGE(1), SYS(16), LINENO(1)

Public Portero
*** Cambiar las rutas al mover el sistema de lugar si queres que te diga..
*!*	
*** Carga los Contenedores de Clases digo

set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\clases control\configuracion"
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES padres\clase padre" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES padres\controles" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES eNTIDAD\ENTIDADES" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\ingreso_de_comprobantes_prestadores" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\Clases Formulario\Formularios" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\Clases Formulario\Parametros" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\nomencladores" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\set_de_unidades" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\menus&usuarios" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\mantenimiento_de_tablas" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\lista_de_precios" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\planes&coberturas" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Afiliados" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Convenios" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Convenios_med" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Convenios_part" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Carga_prestaciones" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\autorizaciones" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\facturacion_cuotas" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\pagos" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\migraciones2" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\prestadores" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\proveedores" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\medicamentos" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\iva" ADDITIVE
set classlib to "c:\archivos de programa\microsoft visual foxpro 9\ffc\_reportlistener" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\mbanco" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\mcontable" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\mtarjetas" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\mexpediente" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\cLASES formulario\Carga_presta_delega" ADDITIVE

*set classlib to "c:\archivos de programa\microsoft visual foxpro 9\ffc\_app" ADDITIVE

*** Para compilar no tener en cuenta los contenedores German y Marcelo
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\tareas_procesando\german" ADDITIVE
set classlib to "c:\sistemas\megasistema\smaunse\sistema_medsoft_vfp_9\tareas_procesando\marcelo" ADDITIVE

**INSTANCIO EL OBJETO PORTERO QUE MANEJARÁ AL USUARIO ACTUAL Y LE PERMITIRÁ
**ACCEDER A LOS MENUS DE LA APLICACIÓN
Portero= createobject('Portero')

IF !Portero.valida_fecha()
	clear events
	RELEASE PORTERO
	cancel
endif

READ EVENTS