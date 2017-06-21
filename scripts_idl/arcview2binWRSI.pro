pro arcview2binWRSI
;
name='RFE2'
wkdir=strcompress('/gibber/lis_data/OUTPUT/BiasWRSI_from_Hari/'+name+'/',/remove_all)
odir =strcompress('/gibber/lis_data/OUTPUT/BiasWRSI_from_Hari/'+name+'/binary/', /remove_all)
;wkdir=strcompress('/gibber/lis_data/OUTPUT/wrsi'+name+'/',/remove_all)
;odir =strcompress('/gibber/lis_data/OUTPUT/wrsi'+name+'/binary/', /remove_all)
file_mkdir, odir
print, wkdir

cd, wkdir
nx=486
ny=390

;filter = '*do.bil' ; this need to change with the filename too!
infiles = file_search('*ve_e*.bil') ;01 januart
;infiles2= file_search('*fr*.bil') ;02 february
;regrid  = uintarr(301,321) 
ingrid  = bytarr(486,390)
;ingrid  = uintarr(486,390) ;use this for the veg and flowering aet and water requirement 
;ingrid2 = uintarr(486,390) ; the .bil are byte integers 
fltgrid  = fltarr(486,390)  ;the array where the converted data will go...
;fltgrid2 = fltarr(486,390)

for i=0, n_elements(infiles)-1 do begin
  ofile=strcompress(odir+strmid(infiles[i],0,9)+name+'01.img',/remove_all)
  ;ofile2=strcompress(odir+strmid(infiles2[i],0,9)+name+'02.img',/remove_all)
  
  openr,1,infiles[i] ;opens januaries  
  readu,1,ingrid              ;reads the file into ingrid
  close,1  
  
  ;regrid=congrid(ingrid, 301,321) ;regrids the 0.1 degree to 0.25
  fltgrid=float(ingrid)
  fltgrid[WHERE(fltgrid gt 252)] = !VALUES.F_NAN
  ;ingrid[WHERE(ingrid gt 500)] = !VALUES.F_NAN
  
  openw,2,ofile
  writeu,2,fltgrid
  print, 'wrote'+ofile
  close, /all
  
  ;openr,3,infiles2[i] ;opens februaries   
  ;readu,3,ingrid2             ;reads the file into ingrid
 ; close,3  
  
 ;fltgrid2=float(ingrid2)
 ;fltgrid2[WHERE(fltgrid2 gt 500)] = !VALUES.F_NAN
  ;ingrid2[WHERE(ingrid2 gt 500)] = !VALUES.F_NAN
  ;openw,4,ofile2
  ;writeu,4,fltgrid2
  ;print, 'wrote'+ofile2
  print
  close, /all
  
 
  
endfor

;
end
