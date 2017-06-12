pro  mve,var
;+
; ROUTINE:                 mve
;
; AUTHOR:                 Terry Figel, ESRG, UCSB 10-21-92
;
; CALLING SEQUENCE:        mve,var
;
; INPUT:   
;              var         an array
;
; PURPOSE:                 print out the max min mean and std deviation of var
;-
on_error,2
sz=size(var)
ndim=sz(0)
;
;                 variable types
;
types=['byte   ','integer','long   ','float  ','double ','complex','not_used','not_used','not_used','not_used','not_used','insigned Int']

case sz(ndim+1) of
  0: message , 'Illegal variable type'
  7: message , 'String variables not allowed'
  8: message , 'Structures not allowed' 
  else:
endcase

vtype=types(sz(ndim+1)-1)

if ndim eq 0 then begin
  if vtype eq 'complex' then begin 
    print,'single complex value = ',var 
  endif else begin
    print,'single scalar value =',var
  endelse
  return
endif

str='('+string(sz(1))
for i=1,ndim-1 do str=str+','+string(sz(i+1))
str=strcompress(str+')',/remove)
str=str+' = '+strcompress(string(sz(ndim+2)),/remove_all)
str=strcompress(str)

if vtype eq 'complex' then begin

  vr=float(var)
  vi=imaginary(var)
  rstd=stdev(vr,rmean)
  istd=stdev(vi,imean)
  rmin=min(vr,max=rmax)
  imin=min(vi,max=imax)

  print,form='(4a13)','real     mean','std dev','minimum','maximum'
  print,form='(4g13.5)',rmean,rstd,rmin,rmax
  print,form='(5a13)','imagnry  mean','std dev','minimum','maximum',$
                      'n_elements'
  print,form='(4g13.5,$)',imean,istd,imin,imax
  print,form='(3x,a)',str

endif else begin

  std=stdev(var,mean)

  print,form='(a7,a6,4a13)',vtype,'mean','std dev','minimum','maximum',$
                          'n_elements'
  print,form='(4g13.5,$)',mean,std,min(var,max=max),max
  print,form='(3x,a)',str

endelse
return
end



