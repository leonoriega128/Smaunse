   �   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              HORIENTATION=0
PAPERSIZE=9
PAPERLENGTH=2794
PAPERWIDTH=2159
COLOR=1
ENTATION=0
PAPERSIZE=9
PAPERLENGTH=2794
PAPER      `Top = 92
Left = 169
Width = 540
Height = 338
DataSource = .NULL.
Name = "Dataenvironment"
                              dataenvironment                                               Courier New                                                   Arial Narrow                                                  Courier New                                                   'CTEMPCOMP'                                                   
'CTEMPPAG'                                                    %"Listado de Ordenes de Pago Emitidas"                         "@!I"                                                         Courier New                                                   "Emitidas a   :"                                              Courier New                                                   	pEMITIDOS                                                     Courier New                                                   date()                                                        Courier New                                                   "Obra Social  :"                                              Courier New                                                   pOs                                                           Courier New                                                   "Emitida el"                                                  Courier New                                                   pDir                                                          Courier New                                                   '"Ordenes de Pago Emitidas por un Total"                       Arial                                                         pTOTAL                                                        "999,999,999.99"                                              Arial                                                         "..\icono\cli_logo.jpg"s\megasistema\smaunse\sistema_med      Arial                                                         "O.de Pago N�"                                                Arial Narrow                                                  orden                                                         (padl(alltrim(str(cTempOrd.orden)),8,'0')                      Arial                                                         	"Entidad"                                                     Arial Narrow                                                  presta                                                        cTempOrd.presta                                               Arial                                                         "Total"                                                       Arial Narrow                                                  total                                                         cTempOrd.total                                                "99,999,999.99"                                               Arial                                                         	"Emisi�n"                                                     Arial Narrow                                                  fechai                                                        cTempOrd.fechai                                               Arial                                                         "Comprobante"                                                 Arial Narrow                                                  pDetalle2=1                                                   
comprobant                                                    CTEMPCOMP.comprobante                                         Arial Narrow                                                  pDetalle2=1                                                   	"Periodo"                                                     Arial Narrow                                                  pDetalle2=1                                                   periodo                                                       CTEMPCOMP.periodo                                             Arial Narrow                                                  pDetalle2=1                                                   	"Importe"                                                     Arial Narrow                                                  pDetalle2=1                                                   importe                                                       CTEMPCOMP.importe                                             "99,999,999.99"                                               Arial Narrow                                                  pDetalle2=1                                                   "Medio de Pago"                                               Arial Narrow                                                  pDetalle3=1                                                   tipop                                                         iif(CTEMPPAG.tipop='C','CHEQUE',iif(CTEMPPAG.tipop='T','TRANSFERENCIA',iif(CTEMPPAG.tipop='R','Notas de Recupero','EFECTIVO')))                                                               Arial Narrow                                                  pDetalle3=1                                                   banco                                                         CTEMPPAG.banco                                                Arial Narrow                                                  pDetalle3=1                                                   "Serie"                                                       Arial Narrow                                                  $pDetalle3=1 and !empty(CTEMPPAG.suc)                          suc                                                           CTEMPPAG.suc                                                  Arial Narrow                                                  #pDetalle3=1and !empty(CTEMPPAG.suc)                           "N�mero"                                                      Arial Narrow                                                  $pDetalle3=1 and !empty(CTEMPPAG.num)                          num                                                           CTEMPPAG.num                                                  Arial Narrow                                                  $pDetalle3=1 and !empty(CTEMPPAG.num)                          	"Importe"                                                     Arial Narrow                                                  pDetalle3=1                                                   importe                                                       CTEMPPAG.importe                                              "99,999,999.99"                                               Arial Narrow                                                  pDetalle3=1                                                   "Fecha Emisi�n:"                                              Courier New                                                   	pFECHAING                                                     Courier New                                                   pDetalle2=1                                                   pDetalle3=1 or pDetalle2=1                                    "j"                                                           Courier New                                                   pDetalle3=1 or pDetalle2=1                                    "de"                                                          Arial Narrow                                                  $pDetalle3=1 and !empty(CTEMPPAG.suc)                          Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   Courier New                                                   Arial                                                         Arial Narrow                                                  Arial                                                   