do while !afiliado->(eof())
  ++ncanalt
  xedad:=edad(afiliado->n_fecha,date())
  if xedad<=36.and.afiliado->estado=1.and.val(afiliado->plan)>1
     if a_grupo->(dbseek(afiliado->o_social+afiliado->a_numero))
        senxx:=0
        do while !a_grupo->(eof()).and.a_grupo->a_numero=afiliado->a_numero
          if a_grupo->estado=1
             senxx:=1
             afiliado->(modi())
             afiliado->categoria:="04"
             afiliado->(dbunlock())
             ++ncanmod
          endif
          a_grupo->(dbskip())
        enddo
        if senxx=0
           afiliado->(modi())
           afiliado->categoria:="02"
           afiliado->(dbunlock())
           ++ncanmod
        endif
     else
       afiliado->(modi())
       afiliado->categoria:="02"
       afiliado->(dbunlock())
       ++ncanmod
        ncanmod2:=1
     endif
  endif
  if xedad>36.and.afiliado->estado=1.and.val(afiliado->plan)>1
     if a_grupo->(dbseek(afiliado->o_social+afiliado->a_numero))
        senxx:=0
        do while !a_grupo->(eof()).and.a_grupo->a_numero=afiliado->a_numero
          if a_grupo->estado=1
             afiliado->(modi())
             afiliado->categoria:="04"
             afiliado->(dbunlock())
             senxx:=1
             ++ncanmod
          endif
          a_grupo->(dbskip())
        enddo
        if senxx=0
           afiliado->(modi())
           afiliado->categoria:="03"
           afiliado->(dbunlock())
           ++ncanmod
        endif
     else
       afiliado->(modi())
       afiliado->categoria:="03"
       afiliado->(dbunlock())
       ++ncanmod
       ncanmod2:=1
     endif
  endif
  if afiliado->estado=1.and.val(afiliado->plan)=1
     afiliado->(modi())
     afiliado->categoria:="01"
     afiliado->(dbunlock())
     ++ncanmod
     ncanmod2:=1
  endif
  @  8, 31 say str(nCanalt,6)
  @  8, 51 say str(nCanmod,6)
  ncanmod2:=0
  afiliado->(dbskip())
enddo
*** recategorizo los familiares
a_grupo->(dbgotop())
nCanAlt:=0
nCanMod:=0
nroant:=a_grupo->a_numero
do while !a_grupo->(eof())
  if afiliado->(dbseek(a_grupo->a_numero))
     if val(a_grupo->plan)>1
        a_grupo->(modi())
        a_grupo->categoria:="40"
        a_grupo->(dbunlock())
     else
        a_grupo->(modi())
        a_grupo->categoria:="41"
        a_grupo->(dbunlock())
     endif
  else
     a_grupo->(modi())
     a_grupo->categoria:="99"
     a_grupo->(dbunlock())
  endif
  if a_grupo->a_numero#nroant
     padre:=5
     nroant:=a_grupo->a_numero
  endif
  ncanmod:=0
  ++ncanalt
  xedad:=edad(a_grupo->n_fecha,date())
**** acomodando esposas
  if a_grupo->estado=1.and.val(a_grupo->plan)>1
     a_grupo->(modi())
     a_grupo->categoria:=str(padre,2)
     a_grupo->categoria:=pluscero(val(a_grupo->categoria))
     a_grupo->(dbunlock())
     ++padre
     ++ncanmod
     ncanmod2:=1
  endif
  if a_grupo->estado=1.and.val(a_grupo->plan)=1
     a_grupo->(modi())
     a_grupo->categoria:=str(padre,2)
     a_grupo->categoria:=pluscero(val(a_grupo->categoria))
     a_grupo->(dbunlock())
     ++ncanmod
     ncanmod2:=1
  endif
  a_grupo->(dbskip())
enddo

