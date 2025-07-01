PROCEDURE LlamarClase
lparameters codi

*if vartype(portero.FuncionesMenus)<>'O'
*set step on
*portero.funcionesmenus=createobject("funcionesdemenus-dll.funcionesdemenus",portero)
*endif

PORTERO.COMANDOSMENUS(codi)
ENDPROC


*-------------------------------------------------------------------------------
*  Procedimiento   :  RESPALDO BASE DE DATOS
*  Procedure       :  RESPALDO 
*  Desarrolado por :  GERMAN
*  Fecha           :  03/11/2005
*===============================================================================

*-------------------------------------------------------------------------------

PROCEDURE RESPALDO

local nam,archivo,archivoruta,ctest,cerror,archivoruta2
**Si el directorio no existe lo creo
if !directory("C:\Respaldo")
	MKDIR "C:\Respaldo"
endif
cerror="-ilogc:\Respaldo\error.log"
messagebox("Asegúrese que todas las Terminales esten fuera del Sistema antes de realizar"+chr(13)+"esta operacion. Caso contrario podría no terminar correctamente.",64,"Mensaje de MedSoft...")

**Cierro la base de datos para la operación
close databases All

archivoruta2="C:\Respaldo\"+alltrim(dtos(date()))+"-"+"RESPALDO"+sys(2015)+".rar"
**Armo el comando de respaldo en WINRAR
nam="C:\Respaldo\"
archivo=alltrim(dtos(date()))+"-"+"RESPALDO"+".rar"
nam=nam+archivo
archivoruta=nam
ctest="winrar t "+archivoruta
nam="winrar a -r -rr -m5 -x*.jpg -x*.bak -x*.chm "+cerror+" "+nam+" "+alltrim(portero.camino)

**Si ya existe un Respaldo lo conservo con otro nombre
if file(archivoruta)
	RENAME &archivoruta to &archivoruta2
else
	archivoruta2=""
endif

LOCAL loWshShell
loWshShell = CreateObject("WScript.Shell")

**Respaldo
loWshShell.Run(nam, 1,.t.)

if file(alltrim(archivoruta))
	
	if file("c:\Respaldo\error.log")
	
		DELETE FILE "c:\Respaldo\error.log"
		DELETE FILE alltrim(archivoruta)
		if !empty(archivoruta2)
			RENAME &archivoruta2 to &archivoruta
		endif
		messagebox("Ocurrió un error al generar el archivo de respaldo ["+archivo+"]"+chr(13)+"Asegúrese que todas las Terminales esten fuera del Sistema.",64,"Mensaje de MedSoft...")
		
	else
		messagebox("El archivo de respaldo "+archivo+chr(13)+"se ha creado correctamente.",64,"Mensaje de MedSoft...")
		loWshShell.Run("C:\Respaldo\", 1)
	endif
else
	if !empty(archivoruta2)
		RENAME &archivoruta2 to &archivoruta
	endif
	messagebox("El archivo de respaldo ["+alltrim(archivo)+"] no se creó correctamente. Deberá repetir la operación.",64,"Mensaje de MedSoft...")

endif

release loWshShell

ENDPROC


*-------------------------------------------------------------------------------
*  Procedimiento   :  Detección de errores
*  Procedure       :  ErrLog 
*  Desarrolado por :  Mercado Marcelo (Trucho)
*  Fecha           :  05/04/2001
*===============================================================================

*-------------------------------------------------------------------------------
                             Procedure Err_log

*-------------------------------------------------------------------------------
lParameters lnNumeroError,lvMensaje,lcLineaError,lcModulo,lnNumeroLineaError
Local lcError, lnMetodoSalir
lnMetodoSalir=0
*wait window 'Error: '+str(lnNumeroError) timeout 1
*set step on

* Evitar un bucle recursivo si errlog contiene un error
lcerror = on('ERROE')
ON ERROR
Do case
*** revisa errores triviales
  * revisa si esta mas alla del fin de archivo y se coloca en el ultimo registro
    case lnNumeroError = 4
         go bottom
  * revisa si esta antes del inicio del archivo y se coloca en el primer regisro
    case lnNumeroError = 38
         go top
    case lnNumeroError = 1115

    case lnNumeroError = 1236

*** revisa errores recuperables
  * no hay tablas en uso o no encontr¢ tabla
    case lnNumeroError = 1 or lnNumeroError = 52
         local lcArchivoNuevo
         SELECT 0
         lcArchivoNuevo = getfile('DBF', 'seleccione un DBF:','Seleciona')
         if empty(lcArchivoNuevo)
            lnMetodoSalir = 2
         ELse
            USE (lcArchivoNuevo) SHARED
         Endif

  * Registro fuera de rango
    case lnNumeroError = 5 or lnNumeroError = 20
         local lcDBF, lnMetodoSalir, lcNumRotulo, lcExpRotulo, lcFiltro,;
               lcIndice, lcSeguridad, llActivarExclusivo, lcUnico
         * recolecta informacion acerca del dbf  e indice actuales
           lcDBF = DBF()
           lnMetodoSalir = TAG()
           lcNumRotulo = SYS(21)
           lcUnico = iif(UNIQUE(), 'UNIQUE','')
           if val(lcNumRotulo) = 0
              wait window "No se ha especificado etiqueta. No se sabe qu‚ hacer"
              lnMetodoSalir = 2
           else
              lcExpRotulo = KEY()
              lcFiltro = SYS(2021,val(lcNumRotulo))
              lcIndice = ORDER(1,1)
              If left(lcIndice,3) = 'IDX'
              *  Abre tabla sin indice
                 USE (lcCDBF)
              *  Desactiva la seguridad para permitir reindexado
                 lcSeguridad = SET('SAFETY')
                 SET SAFETY OFF
                 If empty(lcFiltro)
                    index on &lcExpRotulo to (lcIndice) &lcUnico ADDITIVE
                 else
                    index on &lcExpRotulo for &lcFiltro to (lcIndice) &lcUnico  ADDITIVE
                 Endif
                 SET SAFETY &lcSeguridad
              *  vuelve a abrir la tabla con nuevo indice
                 USE (lcDBF) index (lcindice)
              Else
              * abre la tabla en forma exclusiva para eliminar y volver a crear la etiqueta
                 llActivarExclusivo = ISEXCLUSIVE()
                 if !llActivarExclusivo
                    use (lcDBF) exclusive
                 endif
                 delete tag (lnMetodoSalir)
                 if empty(lcfiltro)
                    index on &lcExpRotulo for &lcUnico tag (lnMetodoSalir)
                 else
                    index on &lcExpRotulo for &lcfiltro &lcUnico tag (lnMetodoSalir)
                 endif
                 if !llActivarExclusivo
                    use (lcDBF) shared
                    set order to tag (lnMetdoSalir)
                 endif
              Endif
              lnMetodoSalir = 0
           Endif
*** Errores no recuperados
  * redirecciona la salida a un archivo
    otherwise
       lnMetodoSalir = 21
       local lcChkDBC, lcCurDBC, lcArchivoError, lcSufijo, lnRespuesta, lnCnt, lnqueActivacion
     * obtiene un nombre de archivo basado en la fecha y hora
       lcArchivoError = substr(dtoc(date()),1,2) + ;
                        substr(dtoc(date()),4,2) + ;
                        substr(time(),1,2) + ;
                        substr(time(),4,2) + '.EVF'
     * se asegura que el nombre de archivo sea £nico cambiando la extensi¢n
       lcSufijo = '0'
       Do while file(lcArchivoError)
          lcArchivoError = stuff(lcArchivoError, ;
                                 len(lcArchivoError) - len(lcSufijo) + 1, ;
                                 len(lcSufijo), lcSufijo)
          lcSufijo = alltrim(str(val(lcSufijo)+1,3))
       EndDo
       set console off
       set alternate to (lcArchivoError)
       set alternate on

     * identifica que es un error
       ? 'Fecha            : '+ttoc(datetime())
       ? 'Version          : '+version()
       ? 'Nombre Archivo   : '+lcArchivoError
       ?

     * luego identifica al error
       ? 'Error:'
       = aerror(laMatrizError)
       ? '       N£mero            : '+Str(laMatrizError[1],5)
       ? '       Mensaje           : '+laMatrizError[2]

       if !isnull(laMatrizError[5])
          ? '       Parametros        : '+laMatrizError[3]
       Endif

       if !isnull(laMatrizError[5])
          ? '       Area de trabajo   : '+laMatrizError[4]
       Endif

       if !isnull(laMatrizError[5])
          lnQueActivacion = laMatrizError[5]
          Do Case
             Case lnQueActivacion = 1
                  ? '       Fall¢ Activaci¢n (trigger) para insertar '
             Case lnQueActivacion = 2
                  ? '       Fall¢ Activaci¢n (trigger) para actualizar '
             Case lnQueActivacion = 3
                  ? '       Fall¢ Activaci¢n (trigger) para borrar '
          EndCase
       Endif

       If laMatrizError[1] = lnNumeroError
          ? '       M¢dulo            : '+lcModulo
          ? '       L¡nea             : '+lcLineaError
          ? '       N£mero L¡nea      : '+str(lnNumeroLineaError)
       Endif
       Release laMatrizError, lnQueActivacion
       ?

     * Identifica al entorno operativo b sico
*       ? 'Sistema Operativo        : '+os()
*       ? 'Procesador               : '+sys(17)
*       ? 'Tarjeta de Video         : '+Left(sys(2006), at('/',sys(2006)) - 1)
*       ? 'Monitor                  : '+substr(sys(2006),at('/',sys(2006)) + 1)
*       ? 'Archivo de Recursos      : '+sys(2005)
*       ? 'Directorio de Arranque   : '+sys(2004)
*       ? 'Archivo de Conf. VFP     : '+sys(2019)
       ? 'Memoria                  : '+alltrim(str(memory())), 'KB OR '+ sys(12) + ' Bytes'
*       ? '    Convencional         : '+sys(12)
*       ? 'Total Memoria            : '
*       ? '    Limite EMS           : '+sys(24)
       ? '    Memoria Obje. Def.   : '+sys(1016)
*       ? '    Set Console          : '+sys(100)
*       ? '    Set Device           : '+sys(101)
       ? '    Impresora Actual     : '+sys(102)
       ? '    Directorio Actual    : '+sys(2003)
*       ? '    Ultima Tecla Oprim.  : '+str(lastkey(),5)
       ?

     * Luego identifica la unidad de disco predeterminada y sus propiedades
       ? 'Unidad Predeterminada    : '+sys(5)
       ? '     Tama¤o de la unidad : '+transform(val(sys(2020)), '9,999,999,999')
       ? '           Espacio Libre : '+transform(diskspace(), '9,999,999,999')
       ? '  Carpeta predeterminado : '+curdir()
       ? '  Carpeta de Arch. Temp. : '+sys(2023)
       ?

     * Impresoras disponibles
 *      ? 'Impresoras :'
 *      if aprinters(laPrt) > 0
 *         for lnCnt = 1 to alen(laPrt,1)
 *            ? Padr(laPrt[lncnt,1],50) + ' on ' + padr(laPrt[lncnt,2], 25)
 *         Endfor
 *      Else
 *        ? 'No hay impresoras actualmente definidas.'
 *      Endif
 *      ?

     * define areas de trabajo
*       ? 'Areas de Trabajo :'
*       if aused(laAreasTrabajo) > 0
*          =asort(laAreasTrabajo,2)
*          list memory like laAreasTrabajo
*          release laAreasTrabajo
*          ? 'Base de datos en Uso : '+alias()
*       Else
*          ? 'No hay tablas abiertas en alguna  rea de trabajo.'
*       Endif
*       ?

     * comienza el vaciado de la informaci¢n
     * despliega variables de memoria
*       ? replicate('-',78)
*       ? 'Variables Activas de memoria'
*       List memory
*       ?

     * despliega el estado
       ? replicate('-',78)
       ? 'Valores actuales de las variables de entorno'
       List status
       ?
     * despliega informaci¢n relacionada con las bases de datos
       *if adatabase(laDblist) > 0
       *   lcCurDBC = juststem(DBC())
       *   for lnCnt = 1 to alen(laDbList,1)
       *       lcChkDBC = laDbList[lncnt,1]
       *       Set database to (lcChkDBC)
       *       List CONNECTIONS
       *       ?
       *       List DATABASE
       *       ?
       *       List PROCEDURES
      *        ?
             * List TABLES
            *  ?
           *   List VIEWS
          *    ?
         * Endfor
        *  Set database to (lcCurDBC)
       *Endif

     * Cierra el archivo de errores y vuelve a activar la pantalla
       Set alternate to
       set alternate off
       set console on
        on key label backspace
        on key label enter
        on key label escape
        on key label pgdn
        on key label pgup
        on key label spacebar
*        set sysmenu to default
        =MESSAGEBOX('Revisar archivo : '+chr(13)+chr(13)+;
                    sys(2003)+'\'+lcArchivoError + '.- '+chr(13)+chr(13)+;
                    'para información del error',16,'El Sistema se Cancelará')
             
*        Wait window 'Revisar archivo : '+sys(2003)+'\'+lcArchivoError + ;
*             chr(13) + ' para informaci¢n del error'
*        lnRespuesta = MESSAGEBOX('Ver informaci¢n del error ahora ?',292)
*        lnRespuesta = MESSAGEBOX('Ver informaci¢n del error ahora ?',32)
*        if lnRespuesta=6
*           modify file (lcArchivoError)
*        Endif
EndCase

* tipo de salida
*Do Case
*   Case lnMetodoSalir = 0
*        retry
*   Case lnMetodoSalir = 1
*        return
*   Case lnMetodoSalir = 2
*        on error &lcError
*        cancel
*EndCase
On error &lcError
pop menu _msysmenu
clear events
set century on
set scoreboard on
set safety on
set notify on
set status bar on
set date to british
set exclusive on
set talk on
set delete off
cancel
Return

