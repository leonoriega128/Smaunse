&&  Actualizado : 19/10/95
&&  Programador : HUGO
&&  Descripcion : Modulo  de  Calculo de coseguros en el prestador

#include "inkey.ch"
#Include "Achoice.Ch"
#include "Dbedit.ch"
#include "SET.ch"

******************* CALCULOS DE ARANCELES PARA COSEGUROS *******************
function COSEGUROAmbulatorios(XOBRA,XPLAN,XEMPRESA,zprestacion,zimporte,zfecha,ztipo)
local aVigencia:={},nLugar,nUnidadGaleno:=0,COSEGURO:=0,xrubro:=space(8),nUnidadGasto:=0
local xArea,xAreas,nAreaActiva,Error,dfecha:=ctod("01/01/01"),importer:=0,importep:=0
LOCAL SEN:=0,RECNO1,RECNO2,RECNO3,RECNO4,RECNO5,SAN:=0,EMPREPR,EMPRERU
Field O_Social,plan,empresa,rubro
nAreaActiva = select()
xArea:=Select("COSERUB")
xAreaS:=Select("COSEPRE")
If (xAreaS=0)
   Abra("dbf\COSEPRE",{{"dbf\COSEPRER","O_Social+Plan+EMPRESA+Rubro",{||O_Social+Plan+EMPRESA+Rubro}}},@error)
End
If (xArea=0)
   Abra("dbf\COSERUB",{{"dbf\COSERUBR","O_Social+Plan+EMPRESA+Rubro",{||O_Social+Plan+EMPRESA+Rubro}}},@error)
End

RECNO1 = NOMENCLA->(RECNO())
RECNO2 = F_LISTA->(RECNO())
RECNO3 = LISTA->(RECNO())
RECNO4 = S_UNIDAD->(RECNO())
RECNO5 = S_UNIDAD->(RECNO())

xrubro:=substr(zprestacion,1,3)
zimporte:=0

NOMENCLA->(DBSEEK("NN"+ZPRESTACION))

emprepr:=xempresa
empreru:=xempresa

 IF COSEPRE->(dBSeek(xObra+XPLAN+XEMPRESA+ZPRESTACION))
    emprepr:=xempresa
 else
    emprepr:=space(5)
 endif
  If COSERUB->(dBSeek(xObra+XPLAN+XEMPRESA+"000"))
    empreru:=xempresa
 else
    empreru:=space(5)
 endif

IF NOMENCLA->P_TIPO = "L"

 IF COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+ZPRESTACION))

     IF ((COSEPRE->PORCENTAJE>0.OR.COSEPRE->VALOR_FIJ1>0.OR.COSEPRE->VALOR_FIJ2>0).AND.;
        (COSEPRE->RUBRO=ZPRESTACION.and.COSEPRE->O_SOCIAL=XOBRA.AND.COSEPRE->PLAN=XPLAN))
        SAN:=1
     ELSE
        SAN:=0
     ENDIF
 ELSE
    SAN:=0
 ENDIF

 if ztipo=1.AND.SAN=0

  ZIMPORTE:=0
    * coseguros por RUBROS Y porcentajes en honorarios *

  If COSERUB->(dBSeek(xObra+XPLAN+EMPRERU+"000"))

      If (COSERUB->TIPO=.F..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO="000")

          if !NOMENCLA->(dbseek(coserub->nomencla+zPrestacion))
              return(nil)
          endif
            if (coserub->arancel=.T..AND.COSERUB->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())

                      if S_UNIDAD->codigo=coserub->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif

                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                      s_unidad->(DBGOTO(RECNO5))
                      nUnidadGaleno = S_UNIDAD->l_galeno
                      zimporte  = nUnidadGaleno*NOMENCLA->honorario
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_1
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_2
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_3
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_4
                      zimporte += nUnidadGaleno*NOMENCLA->instrumen
                      zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
            else
                  IF (COSERUB->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=coserub->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                            if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                               dfecha:=f_lista->v_fecha
*                            endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                    nUnidadGaleno = S_UNIDAD->l_galeno
                   if LISTA->(dbseek(coserub->lista+dtos(dfecha)+zprestacion))
                      zimporte  = LISTA->honorario
                      zimporte += LISTA->ayuda_1
                      zimporte += LISTA->ayuda_2
                      zimporte += LISTA->ayuda_3
                      zimporte += LISTA->ayuda_4
                      zimporte += LISTA->instrumen
                      zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
                    else
                      zimporte:=0
                    endif
                  ENDIF
            endif

      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en honorarios *

      If (COSERUB->TIPO=.T..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO="000")

                   if (dtos(coserub->fecha_v)<=dtos(zfecha))
                       zimporte:= COSERUB->VALOR_FIJ2
                   else
                       ZIMPORTE:=0
                   ENDIF
      ENDIF
  endif
endif

if ztipo=2.AND.SAN=0

 * coseguros por RUBROS Y porcentajes en gastos *
    ZIMPORTE:=0

  If COSERUB->(dBSeek(xObra+XPLAN+EMPRERU+"000"))

      If (COSERUB->TIPO=.F..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO="000")

          if !NOMENCLA->(dbseek(coserub->nomencla+zPrestacion))
              return(nil)
          endif

            if (coserub->arancel=.T..AND.COSERUB->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())
                      if S_UNIDAD->codigo=coserub->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_FECHA
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif
                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(DBGOTO(RECNO5))
                   nUnidadGasto = S_UNIDAD->l_gasto
                   zimporte  = nUnidadGasto*NOMENCLA->gastos
                   zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
            else
                 IF (COSERUB->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=coserub->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                            if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                               dfecha:=f_lista->v_fecha
*                            endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   if LISTA->(dbseek(coserub->lista+dtos(dfecha)+zprestacion))
                        if (dtos(coserub->fecha_v)<=dtos(zfecha))
                           zimporte:= LISTA->gastos
                           zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
                         else
                           ZIMPORTE:=0
                        ENDIF
                    else
                      zimporte:=0
                    endif
                 ENDIF
            endif

      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en GASTOS *
     If COSERUB->(dBSeek(xObra+XPLAN+EMPRERU+"000"))

       If (COSERUB->TIPO=.T..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
          .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO="000")

              if (dtos(coserub->fecha_v)<=dtos(zfecha))
                  zimporte:=COSERUB->VALOR_FIJ1
              else
                  ZIMPORTE:=0
              ENDIF
 
       endif
     else
              ZIMPORTE:=0
     endif
  endif

endif

* fin de rubro
* calculo de % por prestacion de laboratorio

 if ztipo=1.AND.SAN=1

  ZIMPORTE:=0
    * coseguros por prestacion Y porcentajes en honorarios *

  If COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+zprestacion))

      If (COSEPRE->TIPO=.F..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=zprestacion)

          if !NOMENCLA->(dbseek(COSEPRE->nomencla+zPrestacion))
              return(nil)
          endif
            if (COSEPRE->arancel=.T..AND.COSEPRE->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())

                      if S_UNIDAD->codigo=COSEPRE->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif

                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                      s_unidad->(DBGOTO(RECNO5))
                      nUnidadGaleno = S_UNIDAD->l_galeno
                      zimporte  = nUnidadGaleno*NOMENCLA->honorario
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_1
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_2
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_3
                      zimporte += nUnidadGaleno*NOMENCLA->ayuda_4
                      zimporte += nUnidadGaleno*NOMENCLA->instrumen
                      zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
            else
                  IF (COSEPRE->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=COSEPRE->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                            if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                               dfecha:=f_lista->v_fecha
*                            endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                    nUnidadGaleno = S_UNIDAD->l_galeno
                   if LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion))
                      zimporte  = LISTA->honorario
                      zimporte += LISTA->ayuda_1
                      zimporte += LISTA->ayuda_2
                      zimporte += LISTA->ayuda_3
                      zimporte += LISTA->ayuda_4
                      zimporte += LISTA->instrumen
                      zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                    else
                      zimporte:=0
                    endif
                  ENDIF
            endif

      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en honorarios *

      If (COSEPRE->TIPO=.T..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=zprestacion)

                   if (dtos(COSEPRE->fecha_v)<=dtos(zfecha))
                       zimporte:= COSEPRE->VALOR_FIJ2
                   else
                       ZIMPORTE:=0
                   ENDIF
      ENDIF
  endif
endif

if ztipo=2.AND.SAN=1

 * coseguros por RUBROS Y porcentajes en gastos *
    ZIMPORTE:=0

  If COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+zprestacion))

      If (COSEPRE->TIPO=.F..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=zprestacion)

          if !NOMENCLA->(dbseek(COSEPRE->nomencla+zPrestacion))
              return(nil)
          endif

            if (COSEPRE->arancel=.T..AND.COSEPRE->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())
                      if S_UNIDAD->codigo=COSEPRE->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_FECHA
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif
                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(DBGOTO(RECNO5))
                   nUnidadGasto = S_UNIDAD->l_gasto
                   zimporte  = nUnidadGasto*NOMENCLA->gastos
                   zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
            else
                 IF (COSEPRE->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=COSEPRE->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                            if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                               dfecha:=f_lista->v_fecha
*                            endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   if LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion))
                        if (dtos(COSEPRE->fecha_v)<=dtos(zfecha))
                           zimporte:= LISTA->gastos
                           zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                         else
                           ZIMPORTE:=0
                        ENDIF
                    else
                      zimporte:=0
                    endif
                 ENDIF
            endif

      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en GASTOS *
     If COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+zprestacion))

       If (COSEPRE->TIPO=.T..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
          .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=zprestacion)

              if (dtos(COSEPRE->fecha_v)<=dtos(zfecha))
                  zimporte:=COSEPRE->VALOR_FIJ1
              else
                  ZIMPORTE:=0
              ENDIF
 
       endif
     else
              ZIMPORTE:=0
     endif
  endif

endif

* fin de laboratorio y paso al resto
ELSE
* FIN DEL ANALISIS POR LABORATORIO

IF COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+ZPRESTACION))

     IF ((COSEPRE->PORCENTAJE>0.OR.COSEPRE->VALOR_FIJ1>0.OR.COSEPRE->VALOR_FIJ2>0).AND.;
        (COSEPRE->RUBRO=ZPRESTACION.and.COSEPRE->O_SOCIAL=XOBRA.AND.COSEPRE->PLAN=XPLAN))
        SEN:=1
     ELSE
        SEN:=0
     ENDIF
ELSE
    SEN:=0
ENDIF

if ztipo=1.AND.SEN=1

    * coseguros por prestacion Y porcentajes en honorarios *

  If COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+ZPRESTACION))

      If (COSEPRE->TIPO=.F..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=ZPRESTACION)

          if !NOMENCLA->(dbseek(COSEPRE->nomencla+zPrestacion))
              return(nil)
          endif

            if (COSEPRE->arancel=.T..AND.COSEPRE->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())

                      if S_UNIDAD->codigo=COSEPRE->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif

                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(DBGOTO(RECNO5))
                   do case
                      case (NOMENCLA->p_tipo="P")
                           nUnidadGaleno = S_UNIDAD->p_galeno
                      case (NOMENCLA->p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD->q_galeno
                      case (NOMENCLA->p_tipo="C")
                           nUnidadGaleno = S_UNIDAD->c_galeno
                      case (NOMENCLA->p_tipo="R")
                           nUnidadGaleno = S_UNIDAD->r_galeno
                      case (NOMENCLA->p_tipo="L")
                           nUnidadGaleno = S_UNIDAD->l_galeno
                   endcase
                   zimporte  = nUnidadGaleno*NOMENCLA->honorario
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_1
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_2
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_3
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_4
                   zimporte += nUnidadGaleno*NOMENCLA->instrumen
                   zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                   IMPORTEP:=ZIMPORTE
            else
                 IF (COSEPRE->LISTA#SPACE(2).and.LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion)))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=COSEPRE->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                            if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                               dfecha:=f_lista->v_fecha
*                            endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   do case
                      case (NOMENCLA->p_tipo="P")
                           nUnidadGaleno = S_UNIDAD->p_galeno
                      case (NOMENCLA->p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD->q_galeno
                      case (NOMENCLA->p_tipo="C")
                           nUnidadGaleno = S_UNIDAD->c_galeno
                      case (NOMENCLA->p_tipo="R")
                           nUnidadGaleno = S_UNIDAD->r_galeno
                      case (NOMENCLA->p_tipo="L")
                           nUnidadGaleno = S_UNIDAD->l_galeno
                   endcase
                   if LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion))
                        zimporte  = LISTA->honorario
                        zimporte += LISTA->ayuda_1
                        zimporte += LISTA->ayuda_2
                        zimporte += LISTA->ayuda_3
                        zimporte += LISTA->ayuda_4
                        zimporte += LISTA->instrumen
                        zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                      IMPORTEP:=ZIMPORTE
                    else
                      zimporte:=0
                      IMPORTEP:=ZIMPORTE
                    endif
                 ENDIF
            endif

      ENDIF

    * coseguros por prestacion Y MONTOS FIJOS en honorarios *

      If (COSEPRE->TIPO=.T..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=ZPRESTACION)

           if (dtos(cosepre->fecha_v)<=dtos(zfecha))
               zimporte:=COSEPRE->VALOR_FIJ1
               IMPORTEP:=ZIMPORTE
           else
               IMPORTEP:=0
           ENDIF
      ENDIF

  endif
         
endif

if ztipo=2.and.sen=1

 * coseguros por prestacion Y porcentajes en gastos *

  If COSEPRE->(dBSeek(xObra+XPLAN+EMPREPR+ZPRESTACION))

      If (COSEPRE->TIPO=.F..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=ZPRESTACION)

         if !NOMENCLA->(dbseek(COSEPRE->nomencla+zPrestacion))
              return(nil)
          endif

            if (COSEPRE->arancel=.T..AND.COSEPRE->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())
                      if S_UNIDAD->codigo=COSEPRE->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif
                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(dbGOTO(RECNO5))
                   do case
                      case (NOMENCLA->g_tipo=1)
                           nUnidadGasto = S_UNIDAD->o_gasto
                      case (NOMENCLA->g_tipo=2)
                           nUnidadGasto = S_UNIDAD->p_gasto
                      case (NOMENCLA->g_tipo=3)
                           nUnidadGasto = S_UNIDAD->r_gasto
                      case (NOMENCLA->g_tipo=4)
                           nUnidadGasto = S_UNIDAD->l_gasto
                      case (NOMENCLA->g_tipo=5)
                           nUnidadGasto = S_UNIDAD->otro_gasto
                   endcase
                   zimporte  = nUnidadGasto*NOMENCLA->gastos
                   zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                   IMPORTEP:=ZIMPORTE
            else
                  IF (COSEPRE->LISTA#SPACE(2))
*                  .and.LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion)))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=COSEPRE->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                           if dtos(f_lista->v_fecha)>=dtos(dfecha)
                              dfecha:=f_lista->v_fecha
                           endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   if LISTA->(dbseek(COSEPRE->lista+dtos(dfecha)+zprestacion))
                      zimporte:= LISTA->gastos
                      zimporte:=(zimporte*COSEPRE->PORCENTAJE)/100
                      IMPORTEP:=ZIMPORTE
                    else
                      zimporte:=0
                      IMPORTEP:=ZIMPORTE
                    endif
                  ENDIF
            endif
            if dtos(zfecha)<dtos(cosepre->fecha_v)
               zimporte:=0
            endif
 
      ENDIF

    * coseguros por prestacion Y MONTOS FIJOS en GASTOS *

      If (COSEPRE->TIPO=.T..AND.COSEPRE->O_SOCIAL=xOBRA.AND.COSEPRE->PLAN=XPLAN;
         .AND.COSEPRE->EMPRESA=EMPREPR.AND.COSEPRE->RUBRO=ZPRESTACION)

           if (dtos(cosepre->fecha_v)<=dtos(zfecha))
               zimporte:=COSEPRE->VALOR_FIJ2
               IMPORTEP:=ZIMPORTE
           ELSE
               IMPORTEP:=0
           ENDIF
      ENDIF

  endif

endif


* comienza con rubros

if ztipo=1.AND.SEN=0

  ZIMPORTE:=0
    * coseguros por RUBROS Y porcentajes en honorarios *

  If COSERUB->(dBSeek(xObra+XPLAN+EMPRERU+XRUBRO))

      If (COSERUB->TIPO=.F..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO=XRUBRO)

          if !NOMENCLA->(dbseek(coserub->nomencla+zPrestacion))
              return(nil)
          endif

            if (coserub->arancel=.T..AND.COSERUB->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())

                      if S_UNIDAD->codigo=coserub->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif

                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(dbGOTO(RECNO5))
                   do case
                      case (NOMENCLA->p_tipo="P")
                           nUnidadGaleno = S_UNIDAD->p_galeno
                      case (NOMENCLA->p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD->q_galeno
                      case (NOMENCLA->p_tipo="C")
                           nUnidadGaleno = S_UNIDAD->c_galeno
                      case (NOMENCLA->p_tipo="R")
                           nUnidadGaleno = S_UNIDAD->r_galeno
                      case (NOMENCLA->p_tipo="L")
                           nUnidadGaleno = S_UNIDAD->l_galeno
                   endcase
                   zimporte  = nUnidadGaleno*NOMENCLA->honorario
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_1
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_2
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_3
                   zimporte += nUnidadGaleno*NOMENCLA->ayuda_4
                   zimporte += nUnidadGaleno*NOMENCLA->instrumen
                   zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
            else
                 IF (COSERUB->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=coserub->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                               dfecha:=f_lista->v_fecha
*                           if dtos(f_lista->v_fecha)>=dtos(dfecha)
*                              dfecha:=f_lista->v_fecha
*                           endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   do case
                      case (NOMENCLA->p_tipo="P")
                           nUnidadGaleno = S_UNIDAD->p_galeno
                      case (NOMENCLA->p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD->q_galeno
                      case (NOMENCLA->p_tipo="C")
                           nUnidadGaleno = S_UNIDAD->c_galeno
                      case (NOMENCLA->p_tipo="R")
                           nUnidadGaleno = S_UNIDAD->r_galeno
                      case (NOMENCLA->p_tipo="L")
                           nUnidadGaleno = S_UNIDAD->l_galeno
                   endcase
                   if LISTA->(dbseek(coserub->lista+dtos(dfecha)+zprestacion))
                      zimporte  = LISTA->honorario
                      zimporte += LISTA->ayuda_1
                      zimporte += LISTA->ayuda_2
                      zimporte += LISTA->ayuda_3
                      zimporte += LISTA->ayuda_4
                      zimporte += LISTA->instrumen
                      zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
                    else
                      zimporte:=0
                    endif
                 ENDIF
            endif

      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en honorarios *

      If (COSERUB->TIPO=.T..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO=xrubro)

            if (dtos(COSERUB->fecha_v)<=dtos(zfecha))
                 zimporte:=COSERUB->VALOR_FIJ1
            ELSE
                 ZIMPORTE:=0
            ENDIF
      ENDIF
  endif
endif

if ztipo=2.AND.SEN=0

 * coseguros por RUBROS Y porcentajes en gastos *
    ZIMPORTE:=0

  If COSERUB->(dBSeek(xObra+XPLAN+EMPRERU+XRUBRO))

      If (COSERUB->TIPO=.F..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO=XRUBRO)

          if !NOMENCLA->(dbseek(coserub->nomencla+zPrestacion))
              return(nil)
          endif

            if (coserub->arancel=.T..AND.COSERUB->SET#SPACE(2))

                    S_UNIDAD->(dbgotop())
                    do while !S_UNIDAD->(eof())
                      if S_UNIDAD->codigo=coserub->SET

                          if dtos(S_UNIDAD->v_fecha)<=dtos(zfecha)
                            if dtos(S_UNIDAD->v_fecha)>=dtos(dfecha)
                               dfecha:=S_UNIDAD->v_fecha
                               RECNO5 = S_UNIDAD->(RECNO())
                            endif
                           endif
                       endif
                       S_UNIDAD->(dbskip())
                    enddo
                   s_unidad->(dbGOTO(RECNO5))
                   do case
                      case (NOMENCLA->g_tipo=1)
                           nUnidadGasto = S_UNIDAD->o_gasto
                      case (NOMENCLA->g_tipo=2)
                           nUnidadGasto = S_UNIDAD->p_gasto
                      case (NOMENCLA->g_tipo=3)
                           nUnidadGasto = S_UNIDAD->r_gasto
                      case (NOMENCLA->g_tipo=4)
                           nUnidadGasto = S_UNIDAD->l_gasto
                      case (NOMENCLA->g_tipo=5)
                           nUnidadGasto = S_UNIDAD->otro_gasto
                   endcase
                   zimporte  = nUnidadGasto*NOMENCLA->gastos
                   zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
*                endif
                           
            else
                 IF (COSERUB->LISTA#SPACE(2))
                    f_lista->(dbgotop())
                    do while !f_lista->(eof())
                      if f_lista->codigo=coserub->lista

                          if dtos(f_lista->v_fecha)<=dtos(zfecha)
                           if dtos(f_lista->v_fecha)>=dtos(dfecha)
                              dfecha:=f_lista->v_fecha
                           endif
                           endif
                       endif
                       f_lista->(dbskip())
                    enddo
                   if LISTA->(dbseek(coserub->lista+dtos(dfecha)+zprestacion))
                      zimporte:= LISTA->gastos
                      zimporte:=(zimporte*COSERUB->PORCENTAJE)/100
                    else
                      zimporte:=0
                    endif
                 ENDIF
            endif
            if dtos(zfecha)<dtos(coserub->fecha_v).and.(NOMENCLA->p_tipo="M")

               zimporte:=0
            endif
      ENDIF

    * coseguros por RUBROS Y MONTOS FIJOS en GASTOS *

      If (COSERUB->TIPO=.T..AND.COSERUB->O_SOCIAL=xOBRA.AND.COSERUB->PLAN=XPLAN;
         .AND.COSERUB->EMPRESA=EMPRERU.AND.COSERUB->RUBRO=xrubro)

            if (dtos(COSERUB->fecha_v)<=dtos(zfecha))
                 zimporte+=COSERUB->VALOR_FIJ2
            ELSE
                 ZIMPORTE:=0
            ENDIF
      ENDIF
  endif
endif
ENDIF

If (xAreaS=0)
   COSEPRE->(DBCLOSEAREA())
End
If (xArea=0)
   COSERUB->(DBCLOSEAREA())
End

NOMENCLA->(DBGOTO(RECNO1))
F_LISTA->(DBGOTO(RECNO2))
LISTA->(DBGOTO(RECNO3))
S_UNIDAD->(DBGOTO(RECNO4))

aVigencia:=nLugar:=nUnidadGaleno:=SEN:=IMPORTEP:=IMPORTER:=nil
Return(nil)
