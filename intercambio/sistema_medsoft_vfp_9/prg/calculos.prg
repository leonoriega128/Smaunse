#define SET_UNIDAD   1
#define LISTA_PRECIO 2
#define CON_CLINICA  1
#define CON_MEDICO   2
#define CLINICA      1
#define MEDICO       2
#define GRABA        1
#define CANCELA      2
#define MODIFICA     3
#define DEL_CONVENIO 1
#define DEL_PLAN     2
#define DE_LA_LISTA  .T.
#define DEL__PLAN    .f.
#define FARMACEUTICO 2
#define PROPIO       3
#define MEDICAMENTO  1
#define DESCARTABLE  2

*********************************************************************************************
*                               I N T E R N A C I O N 
*********************************************************************************************

*--------------------------------------------------------------------------------------------                      
Function ArancelInternado(nArancel,nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion,;
                          nTipoConvenio,nRecnoArancel,lTipoClinica,nLote)
*--------------------------------------------------------------------------------------------                      
local aVigencia,nLugar,nUnidadGaleno,dPrimeraCobertura,dSegundaCobertura
Dimension aVigencia(1)
nUnidadGaleno=0

iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoArancel));
                            ,CONV_MED.(dbgoto(nRecnoArancel)))
NOMENCLA.(dbgoto(nRecnoPrestacion))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_abona,CONV_MED.h_abona))
   nArancel = 0
   do case
      case (NOMENCLA.columna=1)
           nArancel = nArancel + nGastos
           nGastos  = 0
      case (NOMENCLA.columna=2)
           nGastos  = nGastos + nArancel
           nArancel = 0
   endcase
   Release aVigencia,nLugar,nUnidadGaleno
   Return(nil)
endif
do case
   case (cCausa="P")
        do case
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel + LISTA.ayuda_1
                   nArancel = nArancel + LISTA.ayuda_2
                   nArancel = nArancel + LISTA.ayuda_3
                   nArancel = nArancel + LISTA.ayuda_4
                   nArancel = nArancel + LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel +  LISTA.anestesia
                   endif
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel + LISTA.ayuda_1
                   nArancel = nArancel + LISTA.ayuda_2
                   nArancel = nArancel + LISTA.ayuda_3
                   nArancel = nArancel + LISTA.ayuda_4
                   nArancel = nArancel + LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel + nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel + LISTA.ayuda_1
                   nArancel = nArancel + LISTA.ayuda_2
                   nArancel = nArancel + LISTA.ayuda_3
                   nArancel = nArancel + LISTA.ayuda_4
                   nArancel = nArancel + LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel + LISTA.ayuda_1
                   nArancel = nArancel + LISTA.ayuda_2
                   nArancel = nArancel + LISTA.ayuda_3
                   nArancel = nArancel + LISTA.ayuda_4
                   nArancel = nArancel + LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel + LISTA.ayuda_1
           nArancel = nArancel + LISTA.ayuda_2
           nArancel = nArancel + LISTA.ayuda_3
           nArancel = nArancel + LISTA.ayuda_4
           nArancel = nArancel + LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel + LISTA.anestesia
           endif
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel + LISTA.ayuda_1
           nArancel = nArancel + LISTA.ayuda_2
           nArancel = nArancel + LISTA.ayuda_3
           nArancel = nArancel + LISTA.ayuda_4
           nArancel = nArancel + LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel + LISTA.anestesia
           endif
        endif
endcase
if D_INTERN.(dbseek(str(nLote,6)))
   dPrimeraCobertura = D_INTERN.i_fecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_1,CONV_MED.h_dias_1)
   dSegundaCobertura = D_INTERN.i_fecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_2,CONV_MED.h_dias_2)
   do case
      case (dtos(dFecha)<=dtos(dPrimeraCobertura))
           nArancel = nArancel * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_1,CONV_MED.honor_1)/100)
           nGastos  = nGastos  * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_1,CONV_MED.gastos_1)/100)
      case (dtos(dFecha)<=dtos(dSegundaCobertura))
           nArancel = nArancel * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_2,CONV_MED.honor_2)/100)
           nGastos  = nGastos  * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_2,CONV_MED.gastos_2)/100)
      otherwise
           nArancel = 0
           nGastos  = 0
   endcase
endif
do case
   case (NOMENCLA.columna=1)
        nArancel = nArancel + nGastos
        nGastos  = 0
   case (NOMENCLA.columna=2)
        nGastos  = nGastos + nArancel
        nArancel = 0
endcase
Release aVigencia,nLugar,nUnidadGaleno
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function GastosInternados(nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion;
                      ,nTipoConvenio,nRecnoGasto,cDefNomenclador,lTipoClinica)
*--------------------------------------------------------------------------------------------                      
local aVigencia,nLugar,nUnidadGasto,cNomenclador
Dimension aVigencia(1)
nUnidadGasto=0
cNomenclador=space(3)

iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoGasto));
                            ,CONV_MED.(dbgoto(nRecnoGasto)))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.g_abona,CONV_MED.g_abona))
   nGastos   = 0
   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
   Return(nil)
endif
do case
   case (cCausa="P")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_nomencla,CONV_MED.p_nomencla)
   case (cCausa="C")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_nomencla,CONV_MED.c_nomencla)
   case (cCausa="M")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_nomen,CONV_MED.mod_nomen)
   case cCausa="A"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_nomencl,CONV_MED.an_nomencl)
   case cCausa="O"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_nomen,CONV_MED.o_nomen)
endcase
if (cNomenclador#cDefNomenclador)
   if !NOMENCLA.(dbseek(cNomenclador+cPrestacion))
      nGastos   = 0
      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
      Return(nil)
   endif
else
   NOMENCLA.(dbgoto(nRecnoPrestacion))
endif
do case
   case (cCausa="P")
        do case
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                Return(nil)
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
endcase
Release aVigencia,nLugar,nUnidadGasto,cNomenclador
Return(nil)


*--------------------------------------------------------------------------------------------                      
Function GastosRemedios(nGastos,cPrestacion,nRecnoPrestacion,dFecha,;
                        nTipoConvenio,nRecnoGasto,nLote,lInternacion,cCobertura,fijo,GCOSEGU,GTOTAL)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,cLista,dPrimeraCobertura,dSegundaCobertura,zgastos
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoGasto));
                            ,CONV_MED.(dbgoto(nRecnoGasto)))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.g_abona,CONV_MED.g_abona))
   nGastos   = 0
   Release aVigencia,nLugar
   Return(nil)
endif
REMEDIOS.(dbgoto(nRecnoPrestacion))
nLugar = ascan(CoberturaRemedio(),{|x|x[1]=cCobertura})
if (nLugar=0)
   nGastos   = 0
   Release aVigencia,nLugar
   Return(nil)
endif
PLAN_MED.(dbgoto(CoberturaRemedio()[nLugar,3]))
if (PLAN_MED.dequelista=DEL_CONVENIO)
   cLista = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.m_lista,CONV_MED.m_lista)
else
   cLista = PLAN_MED.lista
endif
if !R_LISTA.(dbseek(cLista+cPrestacion))
   nGastos   = 0
   Release aVigencia,nLugar
   Return(nil)
endif
R_LISTA.(dbeval({||aadd(aVigencia,{dtos(R_LISTA.v_fecha),R_LISTA.(recno())})};
               ,,{||R_LISTA.codigo=cPrestacion and R_LISTA.lista=cLista}))
asort(aVigencia,,,{|x,y|x[1]>y[1]})
nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
nLugar = iif(nLugar=0,len(aVigencia),nLugar)
R_LISTA.(dbgoto(aVigencia[nLugar,2]))
nGastos   = R_LISTA.precio
if fijo>0
     zgastos=ngastos
     zGastos = zGastos  * (fijo/100)
     GCOSEGU = R_LISTA.PRECIO-zGASTOS
     GTOTAL  = R_LISTA.PRECIO
     NGASTOS = NGASTOS-GCOSEGU
else
 do case
   case PLAN_MED.cualcobert=DE_LA_LISTA
        do case
           case lInternacion
                nGastos  =nGastos  * (R_LISTA.i_cobertur/100)
           case !lInternacion
                nGastos  =nGastos  * (R_LISTA.a_cobertur/100)
        endcase
   case PLAN_MED.cualcobert=DEL__PLAN
        do case
           case lInternacion
                if D_INTERN.(dbseek(str(nLote,6)))
                   dPrimeraCobertura = D_INTERN.i_fecha+PLAN_MED.h_dias_1
                   dSegundaCobertura = D_INTERN.i_fecha+PLAN_MED.h_dias_2
                endif
                do case
                   case REMEDIOS.psicofarma
                        do case
                           case (dFecha<=dPrimeraCobertura)
                                nGastos  =nGastos  * (PLAN_MED.psicofar_1/100)
                           case (dFecha<=dSegundaCobertura)
                                nGastos  =nGastos  * (PLAN_MED.psicofar_2/100)
                           otherwise
                                nGastos  = 0
                        endcase
                   case REMEDIOS.ventalibre
                        do case
                           case (dFecha<=dPrimeraCobertura)
                                nGastos  =nGastos  * (PLAN_MED.ventalib_1/100)
                           case (dFecha<=dSegundaCobertura)
                                nGastos  =nGastos  * (PLAN_MED.ventalib_2/100)
                           otherwise
                                nGastos  = 0
                        endcase
                   case REMEDIOS.tipo=MEDICAMENTO
                        do case
                           case (dFecha<=dPrimeraCobertura)
                                nGastos  =nGastos  * (PLAN_MED.i_medica_1/100)
                           case (dFecha<=dSegundaCobertura)
                                nGastos  =nGastos  * (PLAN_MED.i_medica_2/100)
                           otherwise
                                nGastos  = 0
                        endcase
                   case REMEDIOS.tipo=DESCARTABLE
                        do case
                           case (dFecha<=dPrimeraCobertura)
                                nGastos  =nGastos  * (PLAN_MED.i_descar_1/100)
                           case (dFecha<=dSegundaCobertura)
                                nGastos  =nGastos  * (PLAN_MED.i_descar_2/100)
                           otherwise
                                nGastos  = 0
                        endcase
                endcase
           case !lInternacion
                do case
                   case REMEDIOS.psicofarma
                        nGastos  =nGastos  * (PLAN_MED.psicofar_1/100)
                   case REMEDIOS.ventalibre
                        nGastos  =nGastos  * (PLAN_MED.ventalib_1/100)
                   case REMEDIOS.tipo=MEDICAMENTO
                        nGastos  =nGastos  * (PLAN_MED.a_medica_1/100)
                   case REMEDIOS.tipo=DESCARTABLE
                        nGastos  =nGastos  * (PLAN_MED.a_descar_1/100)
                endcase
        endcase
 endcase
endif
Release aVigencia,nLugar
Return(nil)


*********************************************************************************************
*                               A M B U L A T O R I O S
*********************************************************************************************


*--------------------------------------------------------------------------------------------                      
Function ArancelAmbulatorios(nArancel,nGastos,cCausa,cPrestacion,dFecha;
                            ,nRecnoPrestacion,nTipoConvenio,nRecnoArancel,XOBRA,XPLAN,XEMPRESA,HTOTAL,HCOSEGU)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGaleno=0,COSEGURO=0
Dimension aVigencia
nUnidadGaleno=0
COSEGURO=0

iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoArancel));
                            ,CONV_MED.(dbgoto(nRecnoArancel)))
NOMENCLA.(dbgoto(nRecnoPrestacion))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_abona,CONV_MED.h_abona))
   nArancel = 0
   do case
      case (NOMENCLA.columna=1)
           nArancel = nArancel + nGastos
           nGastos  = 0
      case (NOMENCLA.columna=2)
           nGastos  = nGastos  + nArancel
           nArancel = 0
   endcase
   Release aVigencia,nLugar,nUnidadGaleno
   Return(nil)
endif
do case
   case (cCausa="P")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel +nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel +nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel +nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel +nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel +nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel =nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel + LISTA.ayuda_1
                   nArancel = nArancel +LISTA.ayuda_2
                   nArancel = nArancel +LISTA.ayuda_3
                   nArancel = nArancel +LISTA.ayuda_4
                   nArancel = nArancel +LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel +LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel + nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel +LISTA.ayuda_1
                   nArancel = nArancel +LISTA.ayuda_2
                   nArancel = nArancel +LISTA.ayuda_3
                   nArancel = nArancel +LISTA.ayuda_4
                   nArancel = nArancel +LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel +LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel +nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel +LISTA.ayuda_1
                   nArancel = nArancel +LISTA.ayuda_2
                   nArancel = nArancel +LISTA.ayuda_3
                   nArancel = nArancel +LISTA.ayuda_4
                   nArancel = nArancel +LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel +LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel +LISTA.ayuda_1
           nArancel = nArancel +LISTA.ayuda_2
           nArancel = nArancel +LISTA.ayuda_3
           nArancel = nArancel +LISTA.ayuda_4
           nArancel = nArancel +LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel + LISTA.anestesia
           endif
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel +LISTA.ayuda_1
           nArancel = nArancel +LISTA.ayuda_2
           nArancel = nArancel +LISTA.ayuda_3
           nArancel = nArancel +LISTA.ayuda_4
           nArancel = nArancel +LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel +LISTA.anestesia
           endif
        endif
endcase
nArancel = nArancel * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_1,CONV_MED.honor_1)/100)
nGastos  = nGastos  * (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_1,CONV_MED.gastos_1)/100)
do case
   case (NOMENCLA.columna=1)
        nArancel = nArancel +nGastos
        nGastos   = 0
   case (NOMENCLA.columna=2)
        nGastos  = nGastos  + nArancel
        nArancel  = 0
endcase
      HTOTAL=NARANCEL
      hcosegu=0;coseguro=0
      COSEGuroambulatorio(XOBRA,XPLAN,XEMPRESA,CPRESTACION,@COSEGURO,dfecha,1,NRECNOPRESTACION)
      NARANCEL=round((NARANCEL-COSEGURO),2)
      HCOSEGU =round(COSEGURO,2)

Release aVigencia,nLugar,nUnidadGaleno
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function GastosAmbulatorios(nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion;
                           ,nTipoConvenio,nRecnoGasto,cDefNomenclador,XOBRA,XPLAN,XEMPRESA,GTOTAL,GCOSEGU)
*--------------------------------------------------------------------------------------------                      
local aVigencia,nLugar,nUnidadGasto,cNomenclador,COSEGURO
Dimension aVigencia(1)
nUnidadGasto=0
cNomenclador=space(3)
COSEGURO=0
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoGasto));
                            ,CONV_MED.(dbgoto(nRecnoGasto)))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.g_abona,CONV_MED.g_abona))
   nGastos   = 0
   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
   Return(nil)
endif
do case
   case (cCausa="P")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_nomencla,CONV_MED.p_nomencla)
   case (cCausa="C")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_nomencla,CONV_MED.c_nomencla)
   case (cCausa="M")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_nomen,CONV_MED.mod_nomen)
   case cCausa="A"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_nomencl,CONV_MED.an_nomencl)
   case cCausa="O"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_nomen,CONV_MED.o_nomen)
endcase
if (cNomenclador#cDefNomenclador)
   if !NOMENCLA.(dbseek(cNomenclador+cPrestacion))
      nGastos   = 0
      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
      Return(nil)
   endif
else
   NOMENCLA.(dbgoto(nRecnoPrestacion))
endif
do case
   case (cCausa="P")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                if (len(aVigencia)=0)
                   Return aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar;nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                Release aVigencia,nLugar,nUnidadGasto
                Return(nil)
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
endcase

      GTOTAL=NGASTOS
      Store 0 to gcosegu,coseguro
      COSEGuroambulatorio(XOBRA,XPLAN,XEMPRESA,CPRESTACION,@COSEGURO,dfecha,2,NRECNOPRESTACION)
      NGASTOS=round((NGASTOS-COSEGURO),2)
      GCOSEGU=round(COSEGURO,2)

Release aVigencia,nLugar,nUnidadGasto,cNomenclador
Return(nil)

*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*

*

*--------------------------------------------------------------------------------------------                      
Function Calculo(lHonorario,lGasto)
*--------------------------------------------------------------------------------------------                      
local nTipoGasto,nRecnoGasto,nTipoArancel,nRecnoArancel,nRecno,cPlan,cCobertura
local nGasto,nArancel,cCausa,nNrecno,cTipo,cNomencla,cEmpresa
local nTipoPrestador,nTipoEfector,nCategorizacion,lTipoInternacion,nLugar
local gtotal,gcosegu,htotal,hcosegu

Store 0 to nRecno,nGasto,nArancel,gtotal,gcosegu,htotal,hcosegu,nNrecno
cCausa=" "

NCATEGORIZACION=1
if !D_CONSUM.(dbseek(str(CONSUMO.nro_lote)+str(CONSUMO.nro_presta)))
   Return(nil)
endif
if (D_CONSUM.h_fijos#0 or D_CONSUM.g_fijos#0)
   Return(nil)
endif
if ENTIDAD.(!dbseek(CONSUMO.prestador))
   Return(nil)
endif
nTipoPrestador = ENTIDAD.p_tipo
if ENTIDAD.(!dbseek(CONSUMO.efector))
   Return(nil)
endif
nTipoEfector = ENTIDAD.p_tipo
fija_arancel(@ntipoarancel,@nrecnoarancel,@ntipogasto,@nrecnogasto,CONSUMO.O_SOCIAL,CONSUMO.EFECTOR,CONSUMO.G_EFECTOR,CONSUMO.prestaDOR)
if nTipoArancel=CLINICA
   CONV_CLI.(dbgoto(nRecnoArancel))
   cCausa  = CONSUMO.t_prestac
   do case
      case (CONSUMO.t_prestac$"P")
           cNomencla = CONV_CLI.p_nomencla
      case (CONSUMO.t_prestac="C")
           cNomencla = CONV_CLI.c_nomencla
      case (CONSUMO.t_prestac="M")
           cNomencla = CONV_CLI.mod_nomen
      case (CONSUMO.t_prestac="A")
           cNomencla = CONV_CLI.an_nomencl
      case (CONSUMO.t_prestac="O")
           cNomencla = CONV_CLI.o_nomen
      case (CONSUMO.t_prestac="F")
           cNomencla = "   "
      otherwise
           cNomencla = CONSUMO.nomenclado
   endcase
else
   CONV_MED.(dbgoto(nRecnoArancel))
   cCausa  = CONSUMO.t_prestac
   do case
      case (CONSUMO.t_prestac$"P")
           cNomencla = CONV_MED.p_nomencla
      case (CONSUMO.t_prestac="C")
           cNomencla = CONV_MED.c_nomencla
      case (CONSUMO.t_prestac="M")
           cNomencla = CONV_MED.mod_nomen
      case (CONSUMO.t_prestac="A")
           cNomencla = CONV_MED.an_nomencl
      case (CONSUMO.t_prestac="O")
           cNomencla = CONV_MED.o_nomen
      case (CONSUMO.t_prestac="F")
           cNomencla = "   "
      otherwise
           cNomencla = CONSUMO.nomenclado
   endcase
endif
if (cCausa#"F")
   if !(NOMENCLA.(dbseek(cNomencla+CONSUMO.p_codigo)))
      Return(nil)
   endif
else
   if !(REMEDIOS.(dbseek(CONSUMO.p_codigo)))
      Return(nil)
   endif
endif
cTipo   = iif(cCausa#"F",NOMENCLA.p_tipo,"F")
nNRecno = iif(cCausa#"F",NOMENCLA.(Recno()),REMEDIOS.(Recno()))
  if (CONSUMO.familiar="00")
        if AFILIADO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero))
            Return(nil)
        endif
        cEmpresa = AFILIADO.empresa
        cPlan    = AFILIADO.plan
  else
        if A_GRUPO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero+CONSUMO.familiar))
             Return(nil)
        endif
        cEmpresa = A_GRUPO.empresa
        cPlan    = A_GRUPO.plan
  endif
if (lGasto)
   do case
      case CONSUMO.t_prestac="F"
           if (CONSUMO.familiar="00")
              if AFILIADO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero))
                 Return(nil)
              endif
              cEmpresa = AFILIADO.empresa
              cPlan    = AFILIADO.plan
           else
              if A_GRUPO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero+CONSUMO.familiar))
               Return(nil)
            endif
            cEmpresa = A_GRUPO.empresa
            cPlan    = A_GRUPO.plan
           endif
           if !P_PLAN.(dbseek(cPlan+CONSUMO.o_social+cEmpresa))
              Return(nil)
           endif
           cCobertura = P_PLAN.cobertura
           GastosRemedios(@nGasto,CONSUMO.p_codigo,nNRecno,CONSUMO.p_fecha,nTipoGasto,nRecnoGasto,CONSUMO.nro_lote,CONSUMO.internado,cCobertura,consumo.cvalor,@gcosegu,@hcosegu)
           nArancel  = 0
           gtotal = ngasto
      case CONSUMO.internado and consumo.t_prestac#"F"
           D_INTERN.(dbseek(str(CONSUMO.nro_lote)))
           nLugar           = ascan(TipoInternacion(),{|x|x[1]=D_INTERN.i_tipo})
           lTipoInternacion = iif(TipoInternacion()[nLugar,3]=1,.T.,.F.)
           GsInternacion(@nGasto,cCausa,CONSUMO.p_codigo,CONSUMO.p_fecha,nNRecno;
                            ,nTipoGasto,nRecnoGasto,cNomencla,lTipoInternacion;
                            ,CONSUMO.EFECTOR,CONSUMO.G_EFECTOR,CONSUMO.O_SOCIAL,CONSUMO.PRESTADOR)
            GTOTAL=NGASTO
      case !CONSUMO.internado and consumo.t_prestac#"F"
           if (CONSUMO.familiar="00")
              if AFILIADO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero))
                 Return(nil)
              endif
              cEmpresa = AFILIADO.empresa
              cPlan    = AFILIADO.plan
           else
              if A_GRUPO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero+CONSUMO.familiar))
                 Return(nil)
              endif
              cEmpresa = A_GRUPO.empresa
              cPlan    = A_GRUPO.plan
           endif
                      gcosegu=0;gtotal=0
                      GsAmbulatorio(@nGasto,cCausa,CONSUMO.p_codigo,CONSUMO.p_fecha,nNRecno;
                            ,nTipoGasto,nRecnoGasto,cNomencla,consumo.o_social,CPLAN,CEMPRESA,@GTOTAL,@GCOSEGU;
                            ,CONSUMO.EFECTOR,CONSUMO.G_EFECTOR,CONSUMO.PRESTADOR)
   endcase
endif
if (lHonorario)
   do case
      case CONSUMO.t_prestac="F"
           nArancel  = 0
      case CONSUMO.internado and consumo.t_prestac#"F"
           D_INTERN.(dbseek(str(CONSUMO.nro_lote)))
           nLugar           = ascan(TipoInternacion(),{|x|x[1]=D_INTERN.i_tipo})
           lTipoInternacion = iif(TipoInternacion()[nLugar,3]=1,.T.,.F.)
           HSInternacion(@nArancel,nGasto,cCausa,CONSUMO.p_codigo,CONSUMO.p_fecha;
                             ,nNRecno,nTipoArancel,nRecnoArancel,lTipoInternacion,CONSUMO.nro_lote;
                             ,CONSUMO.EFECTOR,CONSUMO.G_EFECTOR,CONSUMO.O_SOCIAL,CONSUMO.PRESTADOR)
            GTOTAL=NGASTO
            HTOTAL=NARANCEL
      case !CONSUMO.internado and consumo.t_prestac#"F"
           if (CONSUMO.familiar="00")
              if AFILIADO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero))
                 Return(nil)
              endif
              cEmpresa = AFILIADO.empresa
              cPlan    = AFILIADO.plan
           else
              if A_GRUPO.(!dbseek(CONSUMO.o_social+CONSUMO.a_numero+CONSUMO.familiar))
                 Return(nil)
              endif
              cEmpresa = A_GRUPO.empresa
              cPlan    = A_GRUPO.plan
           endif
           Hcosegu=0;Htotal=0
           HSAmbulatorio(@nArancel,nGasto,cCausa,CONSUMO.p_codigo,CONSUMO.p_fecha;
               ,nNRecno,nTipoArancel,nRecnoArancel,consumo.o_social,CPLAN,CEMPRESA,@HTOTAL,@HCOSEGU;
               ,CONSUMO.EFECTOR,CONSUMO.G_EFECTOR,CONSUMO.PRESTADOR)
                  IF (CONSUMO.T_PRESTAC="C")
                       if (P_PLAN.(dbseek(cPlan+CONSUMO.O_SOCIAL+cEmpresa)))
                       nArancel = nArancel-(P_PLAN.consulta)
                       endif
                  ENDIF
   endcase
endif
CONSUMO.(Modi())
CONSUMO.(fieldput(18,cCausa))
do case
   case (cCausa="P")
        CONSUMO.(fieldput(20,iif(nTipoArancel=CLINICA,CONV_CLI.p_factura;
                                                     ,CONV_MED.p_factura)))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.p_precio;
                                                     ,CONV_MED.p_precio)))
   case (cCausa="C")
        CONSUMO.(fieldput(20,iif(nTipoArancel=CLINICA,CONV_CLI.c_factura;
                                                     ,CONV_MED.c_factura)))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.c_precio;
                                                     ,CONV_MED.c_precio)))
   case (cCausa="A")
        CONSUMO.(fieldput(20,iif(nTipoArancel=CLINICA,CONV_CLI.an_factura;
                                                     ,CONV_MED.an_factura)))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.an_precio;
                                                     ,CONV_MED.an_precio)))
   case (cCausa="M")
        CONSUMO.(fieldput(20,1))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.mod_lista;
                                                     ,CONV_MED.mod_lista)))
   case (cCausa="F")
        CONSUMO.(fieldput(20,1))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.m_lista;
                                                     ,CONV_MED.m_lista)))
   case (cCausa="O")
        CONSUMO.(fieldput(20,1))
        CONSUMO.(fieldput(21,iif(nTipoArancel=CLINICA,CONV_CLI.o_lista;
                                                     ,CONV_MED.o_lista)))
endcase
CONSUMO.(DBUNLOCK())
D_CONSUM.(dbseek(str(CONSUMO.nro_lote)+str(CONSUMO.nro_presta)))
if D_CONSUM.(found())
   do while (d_consum.nro_presta=consumo.nro_presta and d_consum.nro_lote=consumo.nro_lote)
      d_consum.(modi())
           if consumo.t_prestac#"F"
              d_consum.(fieldput(4,nArancel*nCategorizacion*(1+(D_CONSUM.recargo/100))))
              d_consum.(fieldput(20,htotal))
              IF CONSUMO.MIGRO=.F.
                 d_consum.(fieldput(21,hcosegu))
                 D_CONSUM.(FIELDPUT(23,0))
              ELSE
                 d_consum.(fieldput(23,hcosegu))
                 D_CONSUM.(FIELDPUT(21,0))
              ENDIF
           else
              d_consum.(fieldput(4,0))
              d_consum.(fieldput(20,0))
              d_consum.(fieldput(21,0))
           endif
          if consumo.t_prestac#"F"
             d_consum.(fieldput(5,nGasto*(1+(D_CONSUM.recargo/100))))
             d_consum.(fieldput(18,gtotal))
              IF CONSUMO.MIGRO=.F.
                 d_consum.(fieldput(19,Gcosegu))
                 D_CONSUM.(FIELDPUT(22,0))
              ELSE
                 d_consum.(fieldput(22,Gcosegu))
                 D_CONSUM.(FIELDPUT(19,0))
              ENDIF
          else
             d_consum.(fieldput(5,gtotal-gcosegu))
             d_consum.(fieldput(18,gtotal))
             d_consum.(fieldput(19,gcosegu))
          endif
       d_consum.(dbunlock())
       d_consum.(dbskip())
   enddo
else
   D_CONSUM.(suma())
   D_CONSUM.(fieldput(1,CONSUMO.nro_lote))
   D_CONSUM.(fieldput(2,CONSUMO.nro_presta))
   D_CONSUM.(fieldput(4,nArancel*nCategorizacion))
   D_CONSUM.(fieldput(5,nGasto))
   D_CONSUM.(fieldput(10,0))
   D_CONSUM.(FIELDPUT(18,GTOTAL))
   D_CONSUM.(FIELDPUT(19,GCOSEGU))
   D_CONSUM.(FIELDPUT(20,HTOTAL))
   D_CONSUM.(FIELDPUT(21,HCOSEGU))
   if consumo.t_prestac="F"
       D_CONSUM.(fieldput(4,0))
       D_CONSUM.(fieldput(5,gtotal-gcosegu))
       D_CONSUM.(FIELDPUT(18,GTOTAL))
       D_CONSUM.(FIELDPUT(19,GCOSEGU))
       D_CONSUM.(FIELDPUT(20,0))
       D_CONSUM.(FIELDPUT(21,0))
    endif
   D_CONSUM.(DBUNLOCK())
endif
Release nTipoGasto,NRecnoGasto,nTipoArancel,nRecnoArancel
Release nGasto,nArancel,cCausa,nNrecno,cTipo
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function hsAmbulatorios(nArancel,nGastos,cCausa,cPrestacion,dFecha;
                       ,nRecnoPrestacion,nTipoConvenio,nRecnoArancel,XOBRA,XPLAN,XEMPRESA;
                       ,HTOTAL,HCOSEGU,hspresta,gspresta,lpresta)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGaleno=0,COSEGURO=0
local hstipo=0,gstipo=0,ncolor=setcolor(),NAREADBF,NAREA
nAreaDbf = select()
nArea  = select("INSTALL")
if (nArea=0)
   Abra("SYS\INSTALL")
else
    dbselectarea(nArea)
endif
if hspresta=gspresta and lpresta#gspresta
   gspresta=lpresta
endif
entidad.(dbsetorder(1))
entidad.(dbseek(lpresta))
do case
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              Messagebox("El prestador informado no tiene convenio definido")
              Release aVigencia,nLugar,nUnidadGaleno
              Return(nil)
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
*           ntipoGASTO=2
*           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                 Messagebox("El prestador informado no tiene convenio definido")
                 Release aVigencia,nLugar,nUnidadGaleno
                 Return(nil)
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
*              ntipoGASTO=1
*              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                 Messagebox("El prestador informado no tiene convenio definido")
                 * "-"+INSTALL.GENERAL+"-"
                 * "-"+XOBRA+"-"
                 Release aVigencia,nLugar,nUnidadGaleno
                 Return(nil)
              else
                  ntipoconvenio=1
                  nrecnoarancel=conv_cli.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                  IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                     Messagebox("El prestador informado no tiene convenio definido")
                     * "-"+INSTALL.GENERAL+"-"
                     * "-"+XOBRA+"-"
                     Release aVigencia,nLugar,nUnidadGaleno
                     Return(nil)
                  else
                      ntipoconvenio=1
                      nrecnoarancel=conv_cli.(recno())
                  endif
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
endcase
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoArancel));
                            ,CONV_MED.(dbgoto(nRecnoArancel)))
NOMENCLA.(dbgoto(nRecnoPrestacion))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_abona,CONV_MED.h_abona))
   nArancel = 0
   do case
      case (NOMENCLA.columna=1)
           nArancel = nArancel+nGastos
           nGastos  = 0
      case (NOMENCLA.columna=2)
           nGastos  = nGastos+nArancel
           nArancel = 0
   endcase
   Release aVigencia,nLugar,nUnidadGaleno
   Return(nil)
endif
do case
   case (cCausa="P")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel+LISTA.ayuda_1
           nArancel = nArancel+LISTA.ayuda_2
           nArancel = nArancel+LISTA.ayuda_3
           nArancel = nArancel+LISTA.ayuda_4
           nArancel = nArancel+LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel+LISTA.anestesia
           endif
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel+LISTA.ayuda_1
           nArancel = nArancel+LISTA.ayuda_2
           nArancel = nArancel+LISTA.ayuda_3
           nArancel = nArancel+LISTA.ayuda_4
           nArancel = nArancel+LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel+LISTA.anestesia
           endif
        endif
endcase
nArancel = nArancel*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_1,CONV_MED.honor_1)/100)
nGastos  = nGastos*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_1,CONV_MED.gastos_1)/100)
do case
   case (NOMENCLA.columna=1)
        nArancel = nArancel+nGastos
        nGastos   = 0
   case (NOMENCLA.columna=2)
        nGastos  = nGastos+nArancel
        nArancel  = 0
endcase

      HTOTAL=NARANCEL
      hcosegu=0;coseguro=0
      COSEGuroambulatorio(XOBRA,XPLAN,XEMPRESA,CPRESTACION,@COSEGURO,dfecha,1,NRECNOPRESTACION)
      NARANCEL=round((NARANCEL-COSEGURO),2)
      HCOSEGU=round(COSEGURO,2)
if (nArea=0)
   INSTALL.(dbclosearea())
ENDIF
select(nareadbf)

Release aVigencia,nLugar,nUnidadGaleno
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function fija_arancel(nTipoConvenio,nRecnoArancel,ntipogasto,nrecnogasto,XOBRA,hspresta;
                     ,gspresta,lpresta)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGaleno=0,COSEGURO=0
local hstipo=0,gstipo=0,ncolor=setcolor(),NAREADBF,NAREA
nAreaDbf = select()
nArea  = select("INSTALL")
if (nArea=0)
   Abra("SYS\INSTALL")
else
    dbselectarea(nArea)
endif
if hspresta=gspresta and lpresta#gspresta
   gspresta=lpresta
endif
entidad.(dbsetorder(1))
entidad.(dbseek(lpresta))
do case
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              Messagebox("El prestador informado no tiene convenio definido")
              Release aVigencia,nLugar,nUnidadGaleno
              Return(nil)
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
              ntipoGASTO=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
           ntipoGASTO=2
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                 Messagebox("El prestador informado no tiene convenio definido")
                 Release aVigencia,nLugar,nUnidadGaleno
                 Return(nil)
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
                 ntipoGASTO=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
              ntipoGASTO=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
           ntipoGASTO=2
           nrecnoGASTO=conv_med.(recno())
        endif
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                 Messagebox("El prestador informado no tiene convenio definido")
                 * "-"+INSTALL.GENERAL+"-"
                 * "-"+XOBRA+"-"
                 Release aVigencia,nLugar,nUnidadGaleno
                 Return(nil)
              else
                  ntipoconvenio=1
                  nrecnoarancel=conv_cli.(recno())
                  ntipoGASTO=1
                  nrecnoGASTO=conv_cli.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
              ntipoGASTO=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
           ntipoGASTO=2
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+space(10)+INSTALL.GENERAL))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                  IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                     Messagebox("El prestador informado no tiene convenio definido")
                     * "-"+INSTALL.GENERAL+"-"
                     * "-"+XOBRA+"-"
                     Release aVigencia,nLugar,nUnidadGaleno
                     Return(nil)
                  else
                      ntipoconvenio=1
                      nrecnoarancel=conv_cli.(recno())
                      ntipoGASTO=1
                      nrecnoGASTO=conv_cli.(recno())
                  endif
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
                 ntipoGASTO=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
              ntipoGASTO=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
           ntipoGASTO=2
           nrecnoGASTO=conv_med.(recno())
        endif
endcase
if (nArea=0)
   INSTALL.(dbclosearea())
ENDIF
select(nareadbf)

return(nil)

*--------------------------------------------------------------------------------------------                      
Function GsAmbulatorios(nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion;
                       ,nTipoConvenio,nRecnoGasto,cDefNomenclador,XOBRA,XPLAN,XEMPRESA;
                       ,GTOTAL,GCOSEGU,hspresta,gspresta,lpresta)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGasto=0,cNomenclador=space(3),COSEGURO=0
local hstipo=0,gstipo=0,ncolor=setcolor(),NAREADBF,NAREA
nAreaDbf = select()
nArea  = select("INSTALL")
if (nArea=0)
   Abra("SYS\INSTALL")
else
    dbselectarea(nArea)
endif
IF CCAUSA#"M"
   HSPRESTA=GSPRESTA
ENDIF
if hspresta=gspresta and lpresta#gspresta
   gspresta=lpresta
endif
entidad.(dbsetorder(1))
entidad.(dbseek(lpresta))
do case
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              Messagebox("El prestador informado no tiene convenio definido")
              Release aVigencia,nLugar,nUnidadGasto
              Return(nil)
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                 Messagebox("El prestador informado no tiene convenio")
                 Release aVigencia,nLugar,nUnidadGasto
                 Return(nil)
              else
                 ntipoconvenio=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_med.(recno())
        endif
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                 Messagebox("El prestador informado no tiene convenio definido")
                 * "-"+INSTALL.GENERAL+"-"
                 * "-"+XOBRA+"-"
                 Return(nil)
              else
                 ntipoconvenio=1
                 nrecnoGASTO=conv_cli.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                  IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                     Messagebox("El prestador informado no tiene convenio definido")
                     * "-"+INSTALL.GENERAL+"-"
                     * "-"+XOBRA+"-"
                     Return(nil)
                  else
                     ntipoconvenio=1
                     nrecnoGASTO=conv_cli.(recno())
                  endif
              else
                 ntipoconvenio=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_med.(recno())
        endif
endcase
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoGasto));
                            ,CONV_MED.(dbgoto(nRecnoGasto)))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.g_abona,CONV_MED.g_abona))
   nGastos   = 0
   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
   Return(nil)
endif
do case
   case (cCausa="P")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_nomencla,CONV_MED.p_nomencla)
   case (cCausa="C")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_nomencla,CONV_MED.c_nomencla)
   case (cCausa="M")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_nomen,CONV_MED.mod_nomen)
   case cCausa="A"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_nomencl,CONV_MED.an_nomencl)
   case cCausa="O"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_nomen,CONV_MED.o_nomen)
endcase
if (cNomenclador#cDefNomenclador)
   if !NOMENCLA.(dbseek(cNomenclador+cPrestacion))
      nGastos   = 0
      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
      Return(nil)
   endif
else
   NOMENCLA.(dbgoto(nRecnoPrestacion))
endif
do case
   case (cCausa="P")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_factura,CONV_MED.p_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_precio,CONV_MED.p_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                Release aVigencia,nLugar,nUnidadGasto
                Return(nil)
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
endcase

      GTOTAL=NGASTOS
      gcosegu=0;coseguro=0
      COSEGuroambulatorio(XOBRA,XPLAN,XEMPRESA,CPRESTACION,@COSEGURO,dfecha,2,NRECNOPRESTACION)
      NGASTOS=round((NGASTOS-COSEGURO),2)
      GCOSEGU=round(COSEGURO,2)
if (nArea=0)
   INSTALL.(dbclosearea())
ENDIF
select(nareadbf)

Release aVigencia,nLugar,nUnidadGasto,cNomenclador
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function HSInternaCION(nArancel,nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion;
                      ,nTipoConvenio,nRecnoArancel,lTipoClinica,nLote,HSPRESTA,GSPRESTA;
                      ,XOBRA,lpresta,dIFecha)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGaleno=0,dPrimeraCobertura,dSegundaCobertura
local hstipo=0,gstipo=0,ncolor=setcolor(),NAREADBF,NAREA
nAreaDbf = select()
nArea  = select("INSTALL")
if (nArea=0)
   Abra("SYS\INSTALL")
else
    dbselectarea(nArea)
endif
if hspresta=gspresta and lpresta#gspresta
   gspresta=lpresta
endif
entidad.(dbsetorder(1))
entidad.(dbseek(lpresta))
do case
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              Messagebox("El prestador informado no tiene convenio definido")
              Release aVigencia,nLugar,nUnidadGaleno
              Return(nil)
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                 Messagebox("El prestador informado no tiene convenio definido")
                 Release aVigencia,nLugar,nUnidadGaleno
                 Return(nil)
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                  Messagebox("El prestador informado no tiene convenio definido")
                  * "-"+INSTALL.GENERAL+"-"
                  * "-"+XOBRA+"-"
                  Release aVigencia,nLugar,nUnidadGaleno
                  Return(nil)
              else
                  ntipoconvenio=1
                  nrecnoarancel=conv_cli.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                  IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                     Messagebox("El prestador informado no tiene convenio definido")
                     * "-"+INSTALL.GENERAL+"-"
                     * "-"+XOBRA+"-"
                     Return(nil)
                  else
                      ntipoconvenio=1
                      nrecnoarancel=conv_cli.(recno())
                  endif
              else
                 ntipoconvenio=2
                 nrecnoarancel=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoarancel=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoarancel=conv_med.(recno())
        endif
endcase
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoArancel));
                            ,CONV_MED.(dbgoto(nRecnoArancel)))
NOMENCLA.(dbgoto(nRecnoPrestacion))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_abona,CONV_MED.h_abona))
   nArancel = 0
   do case
      case (NOMENCLA.columna=1)
           nArancel = nArancel+nGastos
           nGastos   = 0
      case (NOMENCLA.columna=2)
           nGastos  = nGastos+nArancel
           nArancel  = 0
   endcase
   Release aVigencia,nLugar,nUnidadGaleno
   Return(nil)
endif
do case
   case (cCausa="P")
        do case
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   nArancel = nUnidadGaleno*NOMENCLA.honorario
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_1
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_2
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_3
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.ayuda_4
                   nArancel = nArancel+nUnidadGaleno*NOMENCLA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGaleno
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.p_tipo="P")
                           nUnidadGaleno = S_UNIDAD.p_galeno
                      case (NOMENCLA.p_tipo="Q")
                           nUnidadGaleno = S_UNIDAD.q_galeno
                      case (NOMENCLA.p_tipo="C")
                           nUnidadGaleno = S_UNIDAD.c_galeno
                      case (NOMENCLA.p_tipo="R")
                           nUnidadGaleno = S_UNIDAD.r_galeno
                      case (NOMENCLA.p_tipo="L")
                           nUnidadGaleno = S_UNIDAD.l_galeno
                   endcase
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+nUnidadGaleno*NOMENCLA.anestesia
                   endif
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGaleno
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nArancel = LISTA.honorario
                   nArancel = nArancel+LISTA.ayuda_1
                   nArancel = nArancel+LISTA.ayuda_2
                   nArancel = nArancel+LISTA.ayuda_3
                   nArancel = nArancel+LISTA.ayuda_4
                   nArancel = nArancel+LISTA.instrumen
                   if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
                      nArancel = nArancel+LISTA.anestesia
                   endif
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel = LISTA.honorario
           nArancel = nArancel+LISTA.ayuda_1
           nArancel = nArancel+LISTA.ayuda_2
           nArancel = nArancel+LISTA.ayuda_3
           nArancel = nArancel+LISTA.ayuda_4
           nArancel = nArancel+LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel+LISTA.anestesia
           endif
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGaleno
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nArancel  = LISTA.honorario
           nArancel = nArancel+LISTA.ayuda_1
           nArancel = nArancel+LISTA.ayuda_2
           nArancel = nArancel+LISTA.ayuda_3
           nArancel = nArancel+LISTA.ayuda_4
           nArancel = nArancel+LISTA.instrumen
           if (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.factura_an,CONV_MED.factura_an))
              nArancel = nArancel+LISTA.anestesia
           endif
        endif
endcase
if nLote#0
   if D_INTERN.(dbseek(str(nLote,6)))
      dPrimeraCobertura = D_INTERN.i_fecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_1,CONV_MED.h_dias_1)
      dSegundaCobertura = D_INTERN.i_fecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_2,CONV_MED.h_dias_2)
      do case
         case (dtos(dFecha)<=dtos(dPrimeraCobertura))
              nArancel = nArancel*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_1,CONV_MED.honor_1)/100)
              nGastos  = nGastos*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_1,CONV_MED.gastos_1)/100)
         case (dtos(dFecha)<=dtos(dSegundaCobertura))
              nArancel = nArancel*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_2,CONV_MED.honor_2)/100)
              nGastos  = nGastos*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_2,CONV_MED.gastos_2)/100)
         otherwise
              nArancel = 0
              nGastos  = 0
      endcase
   endif
else
      dPrimeraCobertura = dIfecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_1,CONV_MED.h_dias_1)
      dSegundaCobertura = dIfecha+iif(nTipoConvenio=CON_CLINICA,CONV_CLI.h_dias_2,CONV_MED.h_dias_2)
      do case
         case (dtos(dFecha)<=dtos(dPrimeraCobertura))
              nArancel = nArancel*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_1,CONV_MED.honor_1)/100)
              nGastos  = nGastos*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_1,CONV_MED.gastos_1)/100)
         case (dtos(dFecha)<=dtos(dSegundaCobertura))
              nArancel = nArancel*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.honor_2,CONV_MED.honor_2)/100)
              nGastos  = nGastos*(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.gastos_2,CONV_MED.gastos_2)/100)
         otherwise
              nArancel = 0
              nGastos  = 0
      endcase
endif
do case
   case (NOMENCLA.columna=1)
        nArancel = nArancel+nGastos
        nGastos   = 0
   case (NOMENCLA.columna=2)
        nGastos  = nGastos+nArancel
        nArancel  = 0
endcase
if (nArea=0)
   INSTALL.(dbclosearea())
ENDIF
select(nareadbf)
Release aVigencia,nLugar,nUnidadGaleno
Return(nil)

*--------------------------------------------------------------------------------------------                      
Function GsInternaCION(nGastos,cCausa,cPrestacion,dFecha,nRecnoPrestacion;
                      ,nTipoConvenio,nRecnoGasto,cDefNomenclador,lTipoClinica,HSPRESTA;
                      ,GSPRESTA,XOBRA,lpresta)
*--------------------------------------------------------------------------------------------                      
local aVigencia={},nLugar,nUnidadGasto=0,cNomenclador=space(3)
local hstipo=0,gstipo=0,ncolor=setcolor(),NAREADBF,NAREA
nAreaDbf = select()
nArea  = select("INSTALL")
if (nArea=0)
   Abra("SYS\INSTALL")
else
    dbselectarea(nArea)
endif
if ccausa#"M"
  HSPRESTA=GSPRESTA
endif
if hspresta=gspresta and lpresta#gspresta
   gspresta=lpresta
endif
entidad.(dbsetorder(1))
entidad.(dbseek(lpresta))
do case
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              Messagebox("El prestador informado no tiene convenio definido")
              Release aVigencia,nLugar,nUnidadGasto
              Return(nil)
           else
              ntipoconvenio=1
              nrecnogasto=conv_cli.(recno())
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnogasto=conv_med.(recno())
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.T.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                 Messagebox("El prestador informado no tiene convenio definido")
                 Release aVigencia,nLugar,nUnidadGasto
                 Return(nil)
              else
                 ntipoconvenio=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_med.(recno())
        endif
   case entidad.p_tipo=1 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+lpresta+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                 Messagebox("El prestador informado no tiene convenio definido")
                 * "-"+INSTALL.GENERAL+"-"
                 * "-"+XOBRA+"-"
                 Release aVigencia,nLugar,nUnidadGaSTO
                 Return(nil)
              else
                 ntipoconvenio=1
                 nrecnoGASTO=conv_cli.(recno())
              ENDIF
           else
              ntipoconvenio=1
              nrecnogasto=conv_cli.(recno())
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnogasto=conv_med.(recno())
           nrecnoGASTO=conv_MED.(recno())
        endif
   case entidad.p_tipo=2 and INSTALL.VAL_CONV=.F.
        if !conv_med.(dbseek(xobra+space(10)+hspresta))
           if !conv_cli.(dbseek(xobra+lpresta))
              if !conv_med.(dbseek(xobra+lpresta+hspresta))
                  IF !CONV_CLI.(DBSEEK(XOBRA+INSTALL.GENERAL))
                     Messagebox("El prestador informado no tiene convenio definido")
                     * "-"+INSTALL.GENERAL+"-"
                     * "-"+XOBRA+"-"
                     Return(nil)
                  else
                     ntipoconvenio=1
                     nrecnoGASTO=conv_cli.(recno())
                  endif
              else
                 ntipoconvenio=2
                 nrecnoGASTO=conv_med.(recno())
              endif
           else
              ntipoconvenio=1
              nrecnoGASTO=conv_cli.(recno())
           endif
        else
           ntipoconvenio=2
           nrecnoGASTO=conv_med.(recno())
        endif
endcase
iif(nTipoConvenio=CON_CLINICA,CONV_CLI.(dbgoto(nRecnoGasto));
                            ,CONV_MED.(dbgoto(nRecnoGasto)))
if !(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.g_abona,CONV_MED.g_abona))
   nGastos   = 0
   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
   Return(nil)
endif
do case
   case (cCausa="P")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.p_nomencla,CONV_MED.p_nomencla)
   case (cCausa="C")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_nomencla,CONV_MED.c_nomencla)
   case (cCausa="M")
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_nomen,CONV_MED.mod_nomen)
   case cCausa="A"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_nomencl,CONV_MED.an_nomencl)
   case cCausa="O"
        cNomenclador = iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_nomen,CONV_MED.o_nomen)
endcase
if (cNomenclador#cDefNomenclador)
   if !NOMENCLA.(dbseek(cNomenclador+cPrestacion))
      nGastos   = 0
      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
      Return(nil)
   endif
else
   NOMENCLA.(dbgoto(nRecnoPrestacion))
endif
do case
   case (cCausa="P")
        do case
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_tipopago,CONV_MED.c_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.cl_precio,CONV_MED.cl_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=SET_UNIDAD))
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (!lTipoClinica and (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_tipopago,CONV_MED.q_tipopago)=LISTA_PRECIO))
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.q_precio,CONV_MED.q_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="C")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=SET_UNIDAD)
                if S_UNIDAD.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)))
                   S_UNIDAD.(dbeval({||aadd(aVigencia,{dtos(S_UNIDAD.v_fecha),recno()})},;
                                    ,{||S_UNIDAD.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                   if (len(aVigencia)=0)
                      Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                      Return(nil)
                   endif
                   asort(aVigencia,,,{|x,y|x[1]>y[1]})
                   nLugar = ascan(aVigencia,{|x|x[1]<=dtos(dFecha)})
                   nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                   S_UNIDAD.(dbgoto(aVigencia[nLugar,2]))
                   do case
                      case (NOMENCLA.g_tipo=1)
                           nUnidadGasto = S_UNIDAD.o_gasto
                      case (NOMENCLA.g_tipo=2)
                           nUnidadGasto = S_UNIDAD.p_gasto
                      case (NOMENCLA.g_tipo=3)
                           nUnidadGasto = S_UNIDAD.r_gasto
                      case (NOMENCLA.g_tipo=4)
                           nUnidadGasto = S_UNIDAD.l_gasto
                      case (NOMENCLA.g_tipo=5)
                           nUnidadGasto = S_UNIDAD.otro_gasto
                   endcase
                   nGastos   = nUnidadGasto*NOMENCLA.gastos
                endif
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_factura,CONV_MED.c_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.c_precio,CONV_MED.c_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="A")
        do case
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=SET_UNIDAD)
                Release aVigencia,nLugar,nUnidadGasto,cNomenclador
                Return(nil)
           case (iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_factura,CONV_MED.an_factura)=LISTA_PRECIO)
                F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                                ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)}))
                if (len(aVigencia)=0)
                   Release aVigencia,nLugar,nUnidadGasto
                   Return(nil)
                endif
                asort(aVigencia,,,{|x,y|x>y})
                nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
                nLugar = iif(nLugar=0,len(aVigencia),nLugar)
                if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.an_precio,CONV_MED.an_precio)+aVigencia[nLugar]+cPrestacion))
                   nGastos   = LISTA.gastos
                endif
        endcase
   case (cCausa="M")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.mod_lista,CONV_MED.mod_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
   case (cCausa="O")
        F_LISTA.(dbeval({||aadd(aVigencia,dtos(F_LISTA.v_fecha))};
                        ,{||F_LISTA.codigo=iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)}))
        if (len(aVigencia)=0)
           Release aVigencia,nLugar,nUnidadGasto,cNomenclador
           Return(nil)
        endif
        asort(aVigencia,,,{|x,y|x>y})
        nLugar = ascan(aVigencia,{|x|x<=dtos(dFecha)})
        nLugar = iif(nLugar=0,len(aVigencia),nLugar)
        if LISTA.(dbseek(iif(nTipoConvenio=CON_CLINICA,CONV_CLI.o_lista,CONV_MED.o_lista)+aVigencia[nLugar]+cPrestacion))
           nGastos   = LISTA.gastos
        endif
endcase
if (nArea=0)
   INSTALL.(dbclosearea())
ENDIF
select(nareadbf)
Release aVigencia,nLugar,nUnidadGasto,cNomenclador
Return(nil)

