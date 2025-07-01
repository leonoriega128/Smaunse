* REPORTOUTPUT WRAPPER PRG

#INCLUDE REPORTOUTPUT.H

LPARAMETERS tvType, tvReference, tvUnload

EXTERNAL TABLE OUTPUTAPP_INTERNALDBF 

LOCAL oTemp, iType, iIndex, cType, cConfigTable, ;
   lSuccess, lSetTalkBackOn, lSafety, cFilter, cClass, cLib, cModule, ;
   oConfig, oError, lStringVar, lObjectMember, iParams, ;
   iUnload, iSelect, iSession, lSetTalkBackOnDefaultSession, vReturn, ;
   oSH
   
IF (SET("TALK") = "ON")
   SET TALK OFF
   lSetTalkBackOn = .T.
ENDIF

iParams = PARAMETERS()
iSession = SET("DATASESSION")

oSH = CREATEOBJECT("SH")

oSH.Execute(VFP_DEFAULT_DATASESSION)

iSelect = SELECT()

IF (SET("TALK") = "ON")
   SET TALK OFF
   lSetTalkBackOnDefaultSession = .T.
ENDIF


* if it is not integer, convert
* if it is lower than -1, 
* this is a value private to REPORTOUTPUT.APP, 
* potentially not even a ListenerType
* if it is not numeric, just set up the
* reference collection

DO CASE
CASE VARTYPE(tvType) # "N"
   vReturn = ReportOutputConfig(OUTPUTAPP_CONFIGTOKEN_SETTABLE, .F., .F., oSH)
   DO ReportOutputCleanup WITH ;
       iSelect, lSetTalkBackOnDefaultSession, ;
       iSession, lSetTalkBackOn, oSH
   RETURN vReturn
CASE ABS(tvType) # tvType AND tvType < LISTENER_TYPE_DEF 
   vReturn = ReportOutputConfig(tvType, @tvReference, tvUnload, oSH)
   DO ReportOutputCleanup WITH ;
       iSelect, lSetTalkBackOnDefaultSession, ;
       iSession, lSetTalkBackOn, oSH
   RETURN vReturn
OTHERWISE
  iType = INT(tvType)
ENDCASE

IF iParams = 3  
   iUnload = VAL(TRANSFORM(tvUnload))   
   IF VARTYPE(tvUnload) = "L"
      vReturn = UnloadListener(iType)
      DO ReportOutputCleanup WITH ;
         iSelect, lSetTalkBackOnDefaultSession, ;
         iSession, lSetTalkBackOn, oSH
      RETURN vReturn
   ELSE 
      IF iUnload > 0 
         IF iUnload = OUTPUTAPP_LOADTYPE_UNLOAD
            vReturn = UnloadListener(iType)
            DO ReportOutputCleanup WITH ;
               iSelect, lSetTalkBackOnDefaultSession, ;
               iSession, lSetTalkBackOn, oSH
            RETURN vReturn
         ELSE
            DO UnloadListener WITH iType
         ENDIF
      ENDIF
   ENDIF
ENDIF

DO ReportOutputDeclareReference  WITH ;
   iParams, tvReference, lObjectMember, lStringVar


IF iType = LISTENER_TYPE_DEF
   * always provide the reference fresh,
   * do not use the collection
   oTemp = CREATEOBJECT("ReportListener")

ELSE

   * check for public reference var (collection)
   * if it is not available create
   
   cType = TRANSFORM(iType)

   iIndex = -1
   
   DO CheckPublicListenerCollection WITH cType, iIndex
   
   IF iIndex > -1
      oTemp = OUTPUTAPP_REFVAR.ITEM[iIndex]
   ENDIF

   IF NOT TestListenerReference(oTemp)

      * if it is not available,
      * look for config file, choosing between built-in and
      * on-disk

      oError = NULL
      STORE "" TO cClass, cLib, cModule

      * try to open, error handle for
      * unavailability
      
      DO GetConfigObject WITH oConfig
      
      TRY
         SELECT 0
         
         iIndex = -1
         DO CheckPublicListenerCollection WITH ;
           TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE), iIndex
         
         IF iIndex > -1
            cConfigTable = OUTPUTAPP_REFVAR.ITEM[iIndex]
         ELSE
            cConfigTable = oConfig.GetConfigTable()
            * the collection will have been created by 
            * CheckPublicListenerCollection
            OUTPUTAPP_REFVAR.ADD(cConfigTable,TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE))                      
         ENDIF

         USE (cConfigTable ) ALIAS OutputConfig SHARED 

         IF oConfig.VerifyConfigTable("OutputConfig")

            * look for filter records first:

            * OBJTYPE   110   identifies a configuration record
            * OBJCODE   1    Configuration item type. 1= registry filter
            * OBJNAME   not used
            * OBJVALUE   not used
            * OBJINFO   Filter expression
             
            SELECT OutputConfig  
            SET ORDER TO 0
            LOCATE && GO TOP
            LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_CONFIG AND ;
                       ObjCode = OUTPUTAPP_OBJCODE_FILTER AND ;
                       NOT (EMPTY(ObjInfo) OR DELETED())
            IF FOUND()
               cFilter = " AND (" + ALLTR(ObjInfo) + ")"
            ELSE
               cFilter = ""   
            ENDIF

            * check for type record for the passed type and 
            * not deleted and in the filter

            * OBJTYPE   100   identifies a Listener registry record
            * OBJCODE   Listener Type   values -1, 0, 1, and 2 supported by default
            * OBJNAME   Class to instantiate   may be ReportListener (base class)
            * OBJVALUE   Class library or procedure file   may be blank
            * OBJINFO   Module/Application containing library   may be blank

            LOCATE && GO TOP

            LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_LISTENER AND ;
                                 (ObjCode = iType)  ;
                                 &cFilter AND (NOT DELETED())
            IF FOUND()
               * get values
               cClass = ALLTRIM(ObjName)
               cLib = ALLTRIM(ObjValue)
               cModule = ALLTR(ObjInfo)

            ELSE

               DO GetSupportedListenerInfo WITH ;
                  iType, cClass, cLib, cModule
            ENDIF                                 

         ELSE   
         
            IF ISNULL(oError) && should be
               oError = CREATEOBJECT("Exception")
               oError.Message = OUTPUTAPP_CONFIGTABLEWRONG_LOC 
            ENDIF   
            
            IF OUTPUTAPP_DEFAULTCONFIG_AFTER_CONFIGTABLEFAILURE
               DO GetSupportedListenerInfo WITH ;
                  iType, cClass, cLib, cModule         
            ENDIF

         ENDIF
         
         IF USED("OutputConfig")
            USE IN OutputConfig  
         ENDIF   

         IF NOT EMPTY(cClass)
            IF NOT INLIST(UPPER(JUSTEXT(cModule)),"APP","EXE", "DLL")
               * frxoutput can be built into the current app or exe
               cModule = ""
            ENDIF
            oTemp = NEWOBJECT(cClass, cLib, cModule)
         ENDIF
      CATCH TO oError
         EXIT  
      FINALLY
         * oSH.Execute(iSession)
         * SET DATASESSION TO (iSession)
      ENDTRY
      
      IF NOT ISNULL(oError)
         DO ReportOutputCleanup WITH ;
          iSelect, lSetTalkBackOnDefaultSession, ;
          iSession, lSetTalkBackOn, oSH
         HandleError(oError)
      ELSE   
       
         IF TestListenerReference(oTemp) AND ;
            PEMSTATUS(oTemp,"ListenerType",5)
            * see notes below, we don't
            * prevent the assignment if not
            * a listener but we do not want it
            * in the collection nonetheless

            #IF OUTPUTAPP_ASSIGN_TYPE 
             IF UPPER(oTemp.BaseClass) == UPPER(oTemp.Class)
                oTemp.ListenerType = iType
             ENDIF   
            #ENDIF   
            OUTPUTAPP_REFVAR.ADD(oTemp,cType)
         ENDIF   

      ENDIF   

      STORE NULL TO oConfig, oError

   ENDIF

ENDIF


lSuccess = TestListenerReference(oTemp)

   * we don't test for listener baseclass --
   * they could hide the property --
   * also we get a more consistent
   * error message letting the product
   * handle things if the object does
   * not descend from ReportListener
   * however, we have to assign type as needed,
   * and that will require a test.


IF lSuccess

   #IF OUTPUTAPP_ASSIGN_OUTPUTTYPE
       TRY
         oTemp.OutputType =iType
       CATCH WHEN .T.
         * in case they
         * hid or protected it,
         * or have an assign method that errored
       ENDTRY  
   #ENDIF

   DO CASE
   CASE iParams = 1
      * nothing to assign, just store in the collection
   CASE lStringVar OR lObjectMember
      IF lStringVar AND TYPE(tvReference) = "U"
         PUBLIC &tvReference   
      ENDIF   
      STORE oTemp TO (tvReference)
      #IF OUTPUTAPP_ASSIGN_TYPE 
      IF PEMSTATUS(&tvReference,"ListenerType",5) AND ;
         UPPER(oTemp.BaseClass) == UPPER(oTemp.Class)
         &tvReference..ListenerType = iType
      ENDIF   
      #ENDIF
   OTHERWISE
      tvReference = oTemp
      #IF OUTPUTAPP_ASSIGN_TYPE 
      IF PEMSTATUS(tvReference,"ListenerType",5) AND ;
         UPPER(oTemp.BaseClass) == UPPER(oTemp.Class)
         tvReference.ListenerType = iType
      ENDIF   
      #ENDIF
   ENDCASE
ELSE
   DO CASE
   CASE iParams = 1
      * nothing to assign   
   CASE lStringVar OR lObjectMember
      STORE NULL TO (tvReference)
   OTHERWISE
      tvReference = NULL
   ENDCASE
ENDIF

DO ReportOutputCleanup WITH ;
      iSelect, lSetTalkBackOnDefaultSession, ;
      iSession, lSetTalkBackOn,oSH

RETURN lSuccess  && not used by the product but might be used by somebody

PROC ReportOutputCleanup( ;
   tiSelect, tlResetTalkDefaultSession, tiSession,tlResetTalk,toSH )
   toSH.Execute(VFP_DEFAULT_DATASESSION)  && JIC
   SELECT (tiSelect)
   IF tlResetTalkDefaultSession
      SET TALK ON
   ENDIF
   toSH.Execute(tiSession)
   IF tlResetTalk
      SET TALK ON
   ENDIF
   toSH = NULL
ENDPROC   

PROC TestListenerReference(toRef)

   RETURN (VARTYPE(toRef) = "O") && AND ;
     && (UPPER(toRef.BASECLASS) == "REPORTLISTENER")

PROC GetSupportedListenerInfo(tiType, tcClass, tcLib, tcModule)
   DO CASE 
   CASE OUTPUTAPP_XBASELISTENERS_FOR_BASETYPES AND ;
        tiType = LISTENER_TYPE_PRN
      tcClass = OUTPUTAPP_CLASS_PRINTLISTENER
      tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB

   CASE OUTPUTAPP_XBASELISTENERS_FOR_BASETYPES AND ;
        tiType= LISTENER_TYPE_PRV
      tcClass = OUTPUTAPP_CLASS_PREVIEWLISTENER
      tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB

   CASE INLIST(tiType,LISTENER_TYPE_PRN,;
                      LISTENER_TYPE_PRV, ;
                      LISTENER_TYPE_PAGED, ;
                      LISTENER_TYPE_ALLPGS)
      tcClass = "ReportListener"
   CASE tiType = LISTENER_TYPE_HTML
      tcClass = OUTPUTAPP_CLASS_HTMLLISTENER
      tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   CASE tiType = LISTENER_TYPE_XML
      tcClass = OUTPUTAPP_CLASS_XMLLISTENER
      tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   CASE tiType = LISTENER_TYPE_DEBUG
      tcClass = OUTPUTAPP_CLASS_DEBUGLISTENER
      tcLib = OUTPUTAPP_BASELISTENER_CLASSLIB
   OTHERWISE
      * ERROR here?  
      * No, let product handle it consistently. 
   ENDCASE

ENDPROC

PROC ReportOutputConfig(tnType, tvReference, tvUnload, toSH)
    * NB: early quit in case somebody
    * calls the thing improperly, 
    * even from the command line with a SET PROC
    IF VARTYPE(tnType) # "N"
       RETURN .F.
    ENDIF
    * can support other things besides writing the
    * table here
    LOCAL iSession, oSession, oError, oConfig, cDBF, lSuccess, cType, iIndex
    oError = NULL
    oConfig = NULL
    iSession = SET("DATASESSION")    
    lSuccess = .F.
    TRY        
       DO CASE
       CASE tnType = OUTPUTAPP_CONFIGTOKEN_SETTABLE AND ;
            VARTYPE(tvReference) = "C" AND ;
            FILE(FULLPATH(FORCEEXT(TRANSFORM(tvReference),"DBF"))) 
             * use FILE() because it can be in the app                         
       
            cDBF = FULLPATH(FORCEEXT(TRANSFORM(tvReference),"DBF"))
            iIndex = -1
            cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
            DO CheckPublicListenerCollection WITH cType, iIndex
            IF iIndex # -1
               OUTPUTAPP_REFVAR.REMOVE[iIndex]
            ENDIF
            OUTPUTAPP_REFVAR.ADD(cDBF,cType)          
            lSuccess = .T.
      CASE tnType = OUTPUTAPP_CONFIGTOKEN_WRITETABLE
            oSession = CREATEOBJECT("session")
            lSafety = SET("SAFETY") = "ON"
            toSH.Execute(oSession.DataSessionID)
            IF lSafety
               SET SAFETY ON
            ENDIF
            DO GetConfigObject WITH oConfig, .T.
            * use XML class, not config superclass, 
            * to write both sets of records, base config outline 
            * and base listener's nodenames
            cDBF = FORCEEXT(FORCEPATH(OUTPUTAPP_EXTERNALDBF, JUSTPATH(SYS(16,0))),"DBF")
            oConfig.CreateConfigTable(cDBF)
            IF NOT EMPTY(SYS(2000,cDBF))
               iIndex = -1
               cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
               DO CheckPublicListenerCollection WITH cType, iIndex               
               IF iIndex # -1
                  OUTPUTAPP_REFVAR.REMOVE[iIndex]
               ENDIF
               OUTPUTAPP_REFVAR.ADD(cDBF,cType)          
               USE (cDBF) 
               LOCATE FOR ObjType = OUTPUTAPP_OBJTYPE_LISTENER AND ;
                          ObjCode = LISTENER_TYPE_DEBUG AND ;
                          UPPER(ALLTRIM(ObjName)) == 'DEBUGLISTENER' AND ;
                          ObjValue = OUTPUTAPP_BASELISTENER_CLASSLIB AND ;
                          DELETED()
               IF EOF()           
                  INSERT INTO (ALIAS()) VALUES ;
                  (OUTPUTAPP_OBJTYPE_LISTENER ,LISTENER_TYPE_DEBUG,'DebugListener',OUTPUTAPP_BASELISTENER_CLASSLIB,SYS(16,0))
                  DELETE NEXT 1
               ENDIF   
*!*	            SELECT  ObjType, ObjCode, ObjName, ObjValue , ;
*!*	                    LEFT(ObjInfo,30) AS Info FROM (cDBF) ;
*!*	                    INTO CURSOR STRTRAN(OUTPUTAPP_CONFIGTABLEBROWSE_LOC," ","")
*!*	            SELECT (STRTRAN(OUTPUTAPP_CONFIGTABLEBROWSE_LOC," ",""))
*!*	            BROWSE TITLE OUTPUTAPP_CONFIGTABLEBROWSE_LOC  FIELDS ;
*!*	              ObjType, ObjCode, ObjName, ObjValue , Info = LEFT(ObjInfo,30), ObjInfo
               BROWSE TITLE OUTPUTAPP_CONFIGTABLEBROWSE_LOC  
               USE
               lSuccess = .T.
            ELSE
               lSuccess = .F.
            ENDIF   
       OTHERWISE 
            iIndex = -1
            cType = TRANSFORM(OUTPUTAPP_CONFIGTOKEN_SETTABLE)             
            DO CheckPublicListenerCollection WITH cType, iIndex
            IF iIndex = -1
               * don't disturb it if it's there
               DO GetConfigObject WITH oConfig
               cDBF = oConfig.GetConfigTable()
               OUTPUTAPP_REFVAR.ADD(cDBF,cType)                       
               tvReference = cDBF
            ELSE
               tvReference= OUTPUTAPP_REFVAR.ITEM[iIndex]   
            ENDIF
            lSuccess = .T.
       ENDCASE
    CATCH WHEN WTITLE() =  OUTPUTAPP_CONFIGTABLEBROWSE_LOC 
       * MESSAGEBOX("here")
       * error 57 on the browse -- no table open ad nauseum
    CATCH TO oError
       lSuccess = .F.
    FINALLY
       toSH.Execute(iSession)
    ENDTRY           
    
    IF NOT ISNULL(oError)
       HandleError(oError)
    ENDIF
    
    RETURN lSuccess   

ENDPROC

PROCEDURE GetConfigObject(toCfg, tXML)
   LOCAL lcModule
   lcModule = _REPORTOUTPUT
   IF NOT INLIST(UPPER(JUSTEXT(lcModule)),"EXE","APP","DLL")
      lcModule = SYS(16,0)
   ENDIF
   IF NOT INLIST(UPPER(JUSTEXT(lcModule)), "EXE","APP","DLL")
      lcModule = ""
   ENDIF
   IF tXML
      toCfg = NEWOBJECT(OUTPUTAPP_CLASS_XMLLISTENER,OUTPUTAPP_BASELISTENER_CLASSLIB, lcModule)         
   ELSE
      toCfg = NEWOBJECT(OUTPUTAPP_CLASS_UTILITYLISTENER,OUTPUTAPP_BASELISTENER_CLASSLIB, lcModule)   
   ENDIF            
   IF VARTYPE(toCfg) = "O"
      toCfg.QuietMode = .T.
      toCfg.AppName = OUTPUTAPP_APPNAME_LOC 
   ENDIF
ENDPROC

PROCEDURE ReportOutputDeclareReference( ;
   tiParams, tvReference, tlObjectMember, tlStringVar)
   LOCAL iDotPos
   IF tiParams > 1 AND ;
      TYPE("tvReference") = "C" 
      iDotPos = RAT(".",tvReference)
      IF iDotPos > 1 AND ;
         iDotPos < LEN(tvReference)
         IF TYPE(tvReference) = "U"
           IF TYPE(LEFT(tvReference,iDotPos-1)) = "O"
              AddProperty(EVAL(LEFT(tvReference,iDotPos-1)),SUBSTR(tvReference,iDotPos+1))
              tlObjectMember = .T.
           ENDIF
         ELSE
           tlObjectMember = .T.      
         ENDIF
      ELSE
         tlStringVar = .T.
      ENDIF    
   ENDIF   
ENDPROC

PROCEDURE UnloadListener(tiType)
   LOCAL lUnload, cType
   
   IF VARTYPE(OUTPUTAPP_REFVAR) # "O" OR ;
      NOT (UPPER(OUTPUTAPP_REFVAR.CLASS) == ;
      UPPER(OUTPUTAPP_REFVARCLASS))
      
      * nothing to do

   ELSE
      cType = TRANSFORM(tiType)
      * look for reference to a listener of the appropriate type
      FOR iIndex = 1 TO OUTPUTAPP_REFVAR.COUNT 
         IF OUTPUTAPP_REFVAR.GETKEY(iIndex) == cType
            OUTPUTAPP_REFVAR.Remove(iIndex)
            lUnload = .T.
            EXIT
         ENDIF
      NEXT

   ENDIF
  
   RETURN lUnload
ENDPROC

PROCEDURE HandleError(toE)
  DO CASE
  CASE NOT ISNULL(toE) 
     IF EMPTY(toE.ErrorNo)
        ERROR toE.Message
     ELSE
        ERROR toE.ErrorNo, toE.Details
     ENDIF
  CASE NOT EMPTY(MESSAGE())
     ERROR MESSAGE()
  OTHERWISE
     ERROR OUTPUTAPP_UNKNOWN_ERROR_LOC
  ENDCASE   
ENDPROC

PROCEDURE CheckPublicListenerCollection(tcType, tiIndex)

    LOCAL iIndex

   IF VARTYPE(OUTPUTAPP_REFVAR) # "O" OR ;
         NOT (UPPER(OUTPUTAPP_REFVAR.CLASS) == ;
              UPPER(OUTPUTAPP_REFVARCLASS))
      * could be a collection subclass
      * in which case look for
      * AINSTANCE(aTemp, <classname>)

      PUBLIC OUTPUTAPP_REFVAR
      STORE CREATEOBJECT(OUTPUTAPP_REFVARCLASS) TO ([OUTPUTAPP_REFVAR])

   ENDIF
   
   IF NOT EMPTY(tcType)

       FOR iIndex = 1 TO OUTPUTAPP_REFVAR.COUNT
           IF OUTPUTAPP_REFVAR.GETKEY(iIndex) == tcType
              tiIndex = iIndex
              EXIT
            ENDIF
       NEXT
       
    ENDIF   

ENDPROC

DEFINE CLASS SH AS Custom
   PROCEDURE Execute(tiSession)
      SET DATASESSION TO (tiSession)
   ENDPROC
ENDDEFINE