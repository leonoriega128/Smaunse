#include "Inkey.ch"          && ®no
#include "Setcurs.ch"
#include "Error.ch"

note ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
note º Funcion : ARME_LCPRA           ³ Autor: Fernando   ³ Fecha: 03/03/1995 º
note ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
note º Objetivo: Generacion del LIBRO de IVA COMPRA                           º
note ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

Function LISTE_3LCMPRA(lFinal)
Local xpanta:=Savescreen(,,,),cCursor:=SetCursor()
Local nMes:=Month(Date()),nAnio:=Year(Date()),GetList:={}
Local dFecIni,dFecMax,aMovim:={}
Local P1:=savescreen(0,0,24,79),nRecno,nPos_x:=2,nPos_y:=2
Local nDirectiva,nLargoTexto,cColchon,lError:=.F.,nLineaPie
Local nCursor:=SetCursor(),i,nAncho:=48,nLargo:=16,nColor:=setcolor()
Local oNombre,oBrowse,cKey,cClave:="",nPie
Local nMesIni,nMesMax,nAnioIni,nAnioMax,nFil:=2,nCol:=1
Local nNeto_Hac,nNeto_Gasto,nNeto_Serv,nNeto_Graba,nNeto_NoGra
Local nExcentos,nIva,nRg3337,nRg3624,nTotal,nMovim,aPanta:={}
Local aArchi:={},nOpenArchi:=0,aDatLib:={},nMesAnt:=99,nAnioAnt:=9999
Local op,xpantaing,xpantacar,nIvaInsc,nIvaNInsc

field codigo,nombre,empresa,tipo_comp,sucursal,numero,imp_tipcom,imp_sucurs,imp_numero,prv_cod
Field Fecha,ANIO,MES,INSCRIPTO,EXENTOS,NOINSCR,FINALES,NORESP,ANO
setcursor(0)

Abra("ctb\CONC_CTE",,@lError)
Abra("ctb\Y_CTACTE",{{"ctb\YCTAptsn","PRV_COD+TIPO_COMP+SUCURSAL+NUMERO",{||PRV_COD+TIPO_COMP+SUCURSAL+NUMERO}}})
Abra("ctb\R_CTACTE",{{"ctb\RCTAptsn","PRV_COD+TIPO_COMP+SUCURSAL+NUMERO",{||PRV_COD+TIPO_COMP+SUCURSAL+NUMERO}}})
Abra("ctb\P_CTACTE",{{"ctb\PCTAptsn","PRV_COD+TIPO_COMP+SUCURSAL+NUMERO",{||PRV_COD+TIPO_COMP+SUCURSAL+NUMERO}}})
Abra("iva\CTL_IVA",{{"iva\ctlfec","str(ano,4)+str(mes,2)",{||str(ano,4)+str(mes,2)}}},@lError)
Abra("ctb\CONCEPTO",{{"ctb\CONtsn","TIPO_COMP+SUCURSAL+NUMERO",{||TIPO_COMP+SUCURSAL+NUMERO}}},@lError)
Abra("dbf\ENTIDAD",{{"dbf\ENTcod","CODIGO",{||CODIGO}};
                   ,{"dbf\ENTnom","NOMBRE",{||NOMBRE}}})
Abra("dbf\PROVEDOR",{{"dbf\PROcod","CODIGO",{||CODIGO}};
                   ,{"dbf\PROnom","NOMBRE",{||NOMBRE}}})

if lError
   Setcursor(nCursor)
   restscreen(0,0,24,79,P1)
   P1:=nRecno:=nPos_x:=nPos_y:=nDirectiva:=nLargoTexto:=cColchon:=lError:=nil
   nLineaPie:=nCursor:=GetList:=i:=nAncho:=nLargo:=nColor:=oNombre:=nil
   oBrowse:=cKey:=cClave:=nPie:=nil
   dbcloseall()
   Return(nil)
endif

if use_no_shared("CTB\IVA_COMC")
   IVA_COMC->(dbcreateindex("CTB\IVACMESC","str(ANIO,4)+str(MES,2)",{||str(ANIO,4)+str(MES,2)}))
endif

Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Fecha",IVA_COMC->(FieldPos("FECHA"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Tipo",IVA_COMC->(FieldPos("TIPO_COMP"))})
*Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Comprobante",IVA_COMC->(FieldPos("DESCRIP"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Sucursal   ",IVA_COMC->(FieldPos("SUCURSAL"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Numero     ",IVA_COMC->(FieldPos("numero"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Prestador",IVA_COMC->(FieldPos("NOMBRE"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Cuit",IVA_COMC->(FieldPos("CUIT"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Tipo I.V.A.",IVA_COMC->(FieldPos("TIPOIVA"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Inscripto",IVA_COMC->(FieldPos("INSCRIPTO"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"No Inscrip.",IVA_COMC->(FieldPos("NOINSCR"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Exentos",IVA_COMC->(FieldPos("EXENTOS"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Cos. Final",IVA_COMC->(FieldPos("FINALES"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"No Respons.",IVA_COMC->(FieldPos("NORESP"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Monotributo",IVA_COMC->(FieldPos("MONOTRI"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"IVA        ",IVA_COMC->(FieldPos("IVA"))})
Aadd(aDatLib,{ {NIL,NIL,NIL,"No es Posible modificar esto datos"},"Total",IVA_COMC->(FieldPos("TOTAL"))})

IVA_COMC->(DbSetOrder(1))
IVA_COMC->(Dbgotop())
nMesIni :=IVA_COMC->mes
nAnioIni:=IVA_COMC->anio
IVA_COMC->(Dbgobottom())
nMesMax :=IVA_COMC->mes
nAnioMax:=IVA_COMC->anio

SetCursor(1)
@ 1,0 clear to 24,79

WINDOWS(3,5,7,28,"Periodo de Analisis","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±")
WINDOWS(3,49,7,67,"Periodo Mes-A¤o","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±")
@ 4,50 say "De      :" + Str(nMesIni,2)+"-"+Str(nAnioIni,4)
@ 6,50 say "Hasta   :" + Str(nMesMax,2)+"-"+Str(nAnioMax,4)

IVA_COMC->(DbSetOrder(1))
xpantaing:=SaveScreen(,,,)
Do While .T.
   RestScreen(,,,,xpantaing)
   Do while .t.
      MENSAGE("Ingrese mes de analisis, desde "+Str(nMesIni,2)+"-"+Str(nAnioIni,4);
                                      +" hasta "+Str(nMesMax,2)+"-"+Str(nAnioMax,4))
      @ 4,6 say "Mes Nro: " get nMes picture "99"
      read
      if LastKey()=K_ESC
         exit
      Endif
      if nMes<1
         loop
      endif
      @ 4,16 say Transform(nMes,"99")+" "+MES(nMes)
      MENSAGE("Ingrese Anio de analisis, desde "+Str(nMesIni,2)+"-"+Str(nAnioIni,4);
                                      +" hasta "+Str(nMesMax,2)+"-"+Str(nAnioMax,4))
      @ 6,6 say "A¤o Nro: " get nAnio picture "9999"
      read
      @ 6,16 say Transform(nAnio,"9999")
      if LastKey()=K_ESC
         exit
      Endif
      if nAnio > nAnioMax .or. nAnio < nAnioIni
         MENSAGE("No existe informaci¢n del mes y a¤o solicitado",.T.,2)
         LOOP
      Endif
      exit
   Enddo
   if LastKey()=K_ESC
      exit
   Endif
   
   xpantacar:=SaveScreen(,,,)
   DbGotop()
   DbClearFilter()
   SetCursor(0)
   MENSAGE("! Estoy Trabajando !",.T.)
   if nMes#nMesAnt .or. nAnio#nAnioAnt
      IVA_COMC->(DbCreateIndex("LIBCMFEC.NTX","NOMBRE",{||NOMBRE}))
      IVA_COMC->(DbsetFilter({|| nMes=IVA_COMC->mes .and. nAnio=IVA_COMC->anio .and. alltrim(IVA_COMC->cuit)#'ANULADA'};
                        ,"nMes=IVA_COMC->mes .and. nAnio=IVA_COMC->anio .and. alltrim(IVA_COMC->cuit)#'ANULADA'"))
      IVA_COMC->(DbGotop())
      nExcentos:=nIva:=nTotal:=nMovim:=nIvaInsc:=nIvaNInsc:=0
      IVA_COMC->(Dbeval({|| nMovim++;
                 ,nTotal +=IVA_COMC->IMPORTE,nExcentos +=IVA_COMC->EXENTOS,nIvainsc +=IVA_COMC->INSCRIPTO,nIvaNinsc +=IVA_COMC->NOINSCR};
               ,{|| IVA_COMC->mes=nMes .and. IVA_COMC->anio=nAnio}))
      WINDOWS(nFil,nCol+63,nFil+20,nCol+62+14,"  Totales","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±",aPanta)
      @ nFil+20,nCol+63 say "ÃÄTotalÄÄÄÄÄÄÄ´"
      @ nFil+21,nCol+63 say "³"+Transform(nTotal,"9999999999.99")+"³"
      @ nFil+22,nCol+63 say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
   EndIf
   IVA_COMC->(DbGotop())
   MENSAGE("Para ver los datos muevase con las flechas")
   tbdema("IVA_COMC",NIL,nFil,nCol;
                           ,nFil+19,nCol+60;
                           ,NIL;
                           ,.F.,aDatLib,"Libro de IVA Compras")

   Tone(120,3)
   Restscreen(,,,,xpantacar)
   MENSAGE("")
   setcolor("i")
   @ 24,3 say "Elija Opcion"
   setcolor("w/n")
   @ 24,16 say " "
   @ 24,17 prompt "  Consulta  "
   @ 24,31 prompt "  Finaliza  "
   @ 24,45 prompt "  Imprime   "
   menu to op
   setcursor(0)
   do case
      case op = 1
        loop
      case op=2 .or. op=0
        exit
      case op=3
        IMP_LIBCPA(nMes,nAnio,nMovim,lFinal)
   Endcase

Enddo
WIN_CLOSE(aPanta)
DBCLOSEALL()
RestScreen(,,,,xpanta)
Setcursor(cCursor)
nOpenArchi:=aArchi:=NIL
op:=xpantaing:=xpantacar:=nIvaInsc:=nIvaNInsc:=NIL
return(NIL)

note ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
note º Programa: IMP_LIBCPA           ³ Autor: PEDRO      ³ Fecha: 23/03/1996 º
note ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
note º Objetivo: Impresion del Libro de IVA COMPRAS                           º
note ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

static Function IMP_LIBCPA(nMes,nAnio,xthojas,lFinal)
Local xhoja,xlin,primera:=.t.,xlinea,salto:=0;
     ,xpanta:=SaveScreen(1,0,24,79),op;
     ,getlist:={},xtothacien:=0,xtotimpue:=0;
     ,xtottotal:=0,xtotserv:=0,xtotgasto:=0,nPagIni:=0,xtotfin:=0,xtotnore:=0;
     ,xtotexce:=0,xtotiva:=0,xtotimpu1:=0,xtotcgra:=0,xtotngra:=0

MENSAGE("! Estoy trabajando !",.T.)
IVA_COMC->(DbsetFilter({|| nMes=IVA_COMC->mes .and. nAnio=IVA_COMC->anio .and. alltrim(IVA_COMC->cuit)#'ANULADA'};
                       ,"nMes=IVA_COMC->mes .and. nAnio=IVA_COMC->anio .and. alltrim(IVA_COMC->cuit)#'ANULADA'"))
IVA_COMC->(DbGotop())
xthojas:=xthojas/35
IVA_COMC->(DbGotop())
xthojas:=if(xthojas<1,1,xthojas+1)

SetCursor(1)
WINDOWS(3,49,5,73,"N£mero Inicial","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±")
MENSAGE("Ingrese el numero que debe llevar la primera pagina del Libro")
@ 4,50 say "Desde Pagina Nro.: " get nPagIni Picture ("9999") valid(nPagIni>0)
read
SetCursor(0)

WINDOWS(13,29,18,50,"Lea...","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±")
@ 14,30 say "Necesitar  "+ Transform(xthojas,"9999") + " hojas"
@ 16,30 say "Comienza el Listado"
@ 17,33 prompt  "  Si  "
@ 17,40 prompt  "  No  "
menu to op
if op=0 .or. op=2 .or. nPagIni=0
   IVA_COMC->(DbClearFilter())
   RestScreen(1,0,24,79,xpanta)
   xhoja:=xlin:=primera:=xlinea:=xpanta:=op:=NIL
   getlist:=xtothacien:=xtotimpue:=xtottotal:=xtotfin:=xtotnore:=NIL
   xtotserv:=xtotgasto:=xtotexce:=xtotiva:=xtotimpu1:=NIL
   xtotcgra:=xtotngra:=nPagIni:=NIL
   Return(NIL)
Endif

xhoja:=nPagIni-1
xlin:=999
RestScreen(1,0,24,79,xpanta)
MENSAGE("Para cancelar la impresi¢n presione <ESC>")
BEGIN SEQUENCE
xhoja++
set(_SET_DEVICE,"PRINTER")
INIT_PRINT("A")
@ Prow()+1,1 say Tipo_Print("NoCondensado")+" "+rtrim(Nombre_Empresa())+Space(10)+"DETALLE DE FACTURAS"+Space(10)+"Hoja Nro. :" + Transform(xhoja,"9999")
@ prow()+1,1 say rtrim(Domicilio_Empresa())+Space(20)+"Mes y A¤o: "+Mes(nMes) + " de " + Transform(nAnio,"9999")
@ prow()+1,1 say Pcia_Empresa()+" - "+Cpost_Empresa()+"     C.U.I.T. : "+Cuit_Empresa()+" - Tel.  : "+Telefono_Empresa()+Tipo_Print("Condensado")
@ prow()+1,1 say "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
@ prow()+1,1 say "³ Datos de los Comprobantes ³  Datos del Proveedor o Prestador          ³                 ³             ³           Importes           ³"
@ prow()+1,1 say "³ÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ³"
@ prow()+1,1 say "³  Fecha   ³Ti³Suc.³ Numero ³   Nombre y/o Razon Social                 ³ Posici¢n  I.V.A.³ C.U.I.T.    ³  Gravado ³  Iva   ³  Total   ³"
@ prow()+1,1 say "³          ³po³    ³ Comprob³                                           ³                 ³             ³          ³        ³ Facturado³"
@ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´"
Do While .not. IVA_COMC->(Eof())
   if IVA_COMC->mes = nMes .and. IVA_COMC->anio=nAnio
      inkey(0.05)
      if Lastkey()=K_ESC
         set(_SET_DEVICE,"SCREEN")
         MENSAGE("Listado Cancelado")
         Tone(80,10)
         exit
      Endif
      If Prow() > 72
         salto := 1
         @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´"
         xlinea = "³        T R A N S P O R T E     ---------------->          "
         xlinea += space(44)+"³"
         xlinea += Transform(xtotimpue,"9999999.99")+"³"
         xlinea += Transform(xtotgasto,"99999.99")+"³"
*         xlinea += Transform(xtotexce,"99999999.99")+"³"
*         xlinea += Transform(xtotfin,"99999999.99")+"³"
*         xlinea += Transform(xtotnore,"99999999.99")+"³"
         xlinea += Transform(xtottotal,"9999999.99")+"³"
         @ prow()+1,1 say xlinea
         @ prow()+1,1 say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ"
         @ prow()+2,50 say "Continua en la pr¢xima p gina..."
         xhoja++
         set(_SET_DEVICE,"SCREEN")
         @ 18,37 say Transform(xhoja,"9999")+" - "+Transform((npagini+xthojas),"9999")
         set(_SET_DEVICE,"PRINTER")
         Form_Feed()
         INIT_PRINT("A")
         @ Prow()+1,1 say Tipo_Print("NoCondensado")+" "+rtrim(Nombre_Empresa())+Space(10)+"DETALLE DE FACTURAS"+Space(10)+"Hoja Nro. :" + Transform(xhoja,"9999")
         @ prow()+1,1 say rtrim(Domicilio_Empresa())+Space(20)+"Mes y A¤o: "+Mes(nMes) + " de " + Transform(nAnio,"9999")
         @ prow()+1,1 say Pcia_Empresa()+" - "+Cpost_Empresa()+"     C.U.I.T. : "+Cuit_Empresa()+" - Tel.  : "+Telefono_Empresa()+Tipo_Print("Condensado")
         @ prow()+1,1 say "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
         @ prow()+1,1 say "³ Datos de los Comprobantes ³  Datos del Proveedor o Prestador          ³                 ³             ³           Importes           ³"
         @ prow()+1,1 say "³ÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ³"
         @ prow()+1,1 say "³  Fecha   ³Ti³Suc.³ Numero ³   Nombre y/o Razon Social                 ³ Posici¢n  I.V.A.³ C.U.I.T.    ³  Gravado ³  Iva   ³  Total   ³"
         @ prow()+1,1 say "³          ³po³    ³ Comprob³                                           ³                 ³             ³          ³        ³ Facturado³"
         @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´"
      End
      if primera
         set(_SET_DEVICE,"SCREEN")
         WINDOWS(17,36,19,44,"Listando...","ÛÛÛÛÛÛÛÛÛ","±±±±±±±±±")
         SetColor("i*")
         @ 16,36 say "Listando..."
         SetColor("w/n")
         primera=.f.
         @ 18,37 say Transform(xhoja,"9999")+" - "+Transform((npagini+xthojas),"9999")
         set(_SET_DEVICE,"PRINTER")
      Endif
      if xhoja > 1 .and. salto = 1   && para que imprima los transp. apartir de la 2 hoja
         @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´"
         if !empty(xlinea)
            @ prow()+1,1 say xlinea
            salto := 0
          endif
          @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´"
      else
          @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ÄÄÄÄÄÄÄÄÄÄÄÄÄ´ÄÄÄÄÄÄÄÄÄÄ´ÄÄÄÄÄÄÄÄ´ÄÄÄÄÄÄÄÄÄÄ´"
      Endif
      xtotimpue+= if(IVA_COMC->iva>0,IVA_COMC->inscripto+IVA_COMC->noinscr+IVA_COMC->exentos+IVA_COMC->finales+IVA_COMC->noresp+IVA_COMC->monotri,0)
      xtotgasto+= IVA_COMC->iva
*      xtotexce+=  IVA_COMC->exentos
      xtottotal+= IVA_COMC->total
*      xtotfin+=   IVA_COMC->finales
*      xtotnore+=  IVA_COMC->noresp

      xlinea := "³"+Dtoc(IVA_COMC->fecha)+"³"+IVA_COMC->tipo_comp+"³"
      xlinea += IVA_COMC->SUCURSAL+"³"
      xlinea += IVA_COMC->NUMERO+"³"+left(IVA_COMC->nombre,43)+"³"
      xlinea += left(IVA_COMC->tipoiva,17)+"³"
      xlinea += IVA_COMC->cuit+"³"
      xlinea += Transform(if(IVA_COMC->iva>0,IVA_COMC->inscripto+IVA_COMC->noinscr+IVA_COMC->exentos+IVA_COMC->finales+IVA_COMC->noresp+IVA_COMC->monotri,0),"9999999.99")+"³"
      xlinea += Transform(IVA_COMC->iva,"99999.99")+"³"
*      xlinea += Transform(IVA_COMC->exentos,"99999999.99")+"³"
*      xlinea += Transform(IVA_COMC->finales,"99999999.99")+"³"
*      xlinea += Transform(IVA_COMC->noresp,"99999999.99")+"³"
      xlinea += Transform(IVA_COMC->total,"9999999.99")+"³"
      @ prow()+1,1 say xlinea
   Endif
   IVA_COMC->(DbSkip())
Enddo

if xtottotal>0
   if  Prow()<=72
       @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´"
       xlinea = "³        T O T A L   G E N E R A L -------------->          "
       xlinea += space(44)+"³"
       xlinea += Transform(xtotimpue,"9999999.99")+"³"
       xlinea += Transform(xtotgasto,"99999.99")+"³"
*       xlinea += Transform(xtotexce,"99999999.99")+"³"
*       xlinea += Transform(xtotfin,"99999999.99")+"³"
*       xlinea += Transform(xtotnore,"99999999.99")+"³"
       xlinea += Transform(xtottotal,"9999999.99")+"³"
       @ prow()+1,1 say xlinea
       @ prow()+1,1 say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ"
   Else
       xhoja++
       set(_SET_DEVICE,"SCREEN")
       @ 18,37 say Transform(xhoja,"9999")+" - "+Transform((npagini+xthojas),"9999")
       set(_SET_DEVICE,"PRINTER")
       @ prow()+2,50 say "Continua en la pr¢xima p gina..."
       Form_Feed()
       INIT_PRINT("A")
       @ Prow()+1,1 say Tipo_Print("NoCondensado")+" "+rtrim(Nombre_Empresa())+Space(10)+"DETALLE DE FACTURAS"+Space(10)+"Hoja Nro. :" + Transform(xhoja,"9999")
       @ prow()+1,1 say rtrim(Domicilio_Empresa())+Space(20)+"Mes y A¤o: "+Mes(nMes) + " de " + Transform(nAnio,"9999")
       @ prow()+1,1 say Pcia_Empresa()+" - "+Cpost_Empresa()+"     C.U.I.T. : "+Cuit_Empresa()+" - Tel.  : "+Telefono_Empresa()+Tipo_Print("Condensado")
       @ prow()+1,1 say "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
       @ prow()+1,1 say "³ Datos de los Comprobantes ³  Datos del Proveedor o Prestador          ³                 ³             ³           Importes           ³"
       @ prow()+1,1 say "³ÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ³"
       @ prow()+1,1 say "³  Fecha   ³Ti³Suc.³ Numero ³   Nombre y/o Razon Social                 ³ Posici¢n  I.V.A.³ C.U.I.T.    ³  Gravado ³  Iva   ³  Total   ³"
       @ prow()+1,1 say "³          ³po³    ³ Comprob³                                           ³                 ³             ³          ³        ³ Facturado³"
       @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´"
       @ prow()+1,1 say "ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´"
       xlinea = "³        T O T A L   G E N E R A L -------------->          "
       xlinea += space(44)+"³"
       xlinea += Transform(xtotimpue,"9999999.99")+"³"
       xlinea += Transform(xtotgasto,"99999.99")+"³"
*       xlinea += Transform(xtotexce,"99999999.99")+"³"
*       xlinea += Transform(xtotfin,"99999999.99")+"³"
*       xlinea += Transform(xtotnore,"99999999.99")+"³"
       xlinea += Transform(xtottotal,"9999999.99")+"³"
       @ prow()+1,1 say xlinea
       @ prow()+1,1 say "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ"
   End
endif
Form_Feed()
set(_SET_DEVICE,"SCREEN")
END SECUENCE
if lFinal=.T.
   IVA_COMC->(DbGotop())
   Do While .not. IVA_COMC->(Eof())
      if IVA_COMC->mes = nMes .and. IVA_COMC->anio=nAnio
         do case
            case IVA_COMC->archivo="P_CTACTE"
                 if P_CTACTE->(dbseek(IVA_COMC->PRV_COD+IVA_COMC->TIPO_COMP+IVA_COMC->SUCURSAL+IVA_COMC->NUMERO))
                    P_CTACTE->(modi())
                    P_CTACTE->mesiva:=IVA_COMC->mes
                    P_CTACTE->anoiva:=IVA_COMC->anio
                    P_CTACTE->(dbunlock())
                 endif
            case IVA_COMC->archivo="R_CTACTE"
                 if R_CTACTE->(dbseek(IVA_COMC->PRV_COD+IVA_COMC->TIPO_COMP+IVA_COMC->SUCURSAL+IVA_COMC->NUMERO))
                    R_CTACTE->(modi())
                    R_CTACTE->mesiva:=IVA_COMC->mes
                    R_CTACTE->anoiva:=IVA_COMC->anio
                    R_CTACTE->(dbunlock())
                 endif
            case IVA_COMC->archivo="Y_CTACTE"
                 if Y_CTACTE->(dbseek(IVA_COMC->PRV_COD+IVA_COMC->TIPO_COMP+IVA_COMC->SUCURSAL+IVA_COMC->NUMERO))
                    Y_CTACTE->(modi())
                    Y_CTACTE->mesiva:=IVA_COMC->mes
                    Y_CTACTE->anoiva:=IVA_COMC->anio
                    Y_CTACTE->(dbunlock())
                 endif
         endcase
      endif
      IVA_COMC->(DbSkip())
   Enddo
   P_CTACTE->(dbcommit())
   R_CTACTE->(dbcommit())
   Y_CTACTE->(dbcommit())
   if !CTL_IVA->(Dbseek(str(nAnio,4)+str(nMes,2)))
      CTL_IVA->(SUMA())
      CTL_IVA->MES := nmes
      CTL_IVA->ANO := nanio
      CTL_IVA->operador   := Set_Usuario()
      CTL_IVA->dia        := Date()
      CTL_IVA->hora       := left(time(),5)
      CTL_IVA->(dBunlock())
   else
      CTL_IVA->(MODI())
      CTL_IVA->operador   := Set_Usuario()
      CTL_IVA->dia        := Date()
      CTL_IVA->hora       := left(time(),5)
      CTL_IVA->(dBunlock())
   ENDIF
endif
IVA_COMC->(DbClearFilter())
RestScreen(1,0,24,79,xpanta)
xhoja:=xlin:=primera:=xlinea:=xpanta:=op:=NIL
getlist:=xtothacien:=xtotimpue:=xtottotal:=NIL
xtotserv:=xtotgasto:=xtotexce:=xtotiva:=xtotimpu1:=NIL
xtotcgra:=xtotngra:=nPagIni:=NIL
return(NIL)
