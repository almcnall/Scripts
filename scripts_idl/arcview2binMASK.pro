pro arcview2binMASK
; the purpose of this program is to convert the stupid arcmap rast bil files to binary
; East Africa (1) Mar to Sep: ekwmask.bil (2) May-Nov: eewmask.bil and (3) Oct-Feb: etwmask.bil.
; xdim 0.1,    ydim 0.1
;turns out that I could do all of this quick and easy in ENVI...
;
;eewmask
;ncols 445,   nrows 579
;ulxmap 7.05  ulymap 23.035

;ekwmask
;ncols 297     nrows 351
;ulxmap 21.88  ulymap 23.05

;ETWMASK same dims as ekwmask
;ncols 297     nrows 351
;ulxmap 21.88  ulymap 23.05

;sawmask
;ncols 751   nrows 801
;ulxmap -20  ulymap 40

;wawmask
;ncols 751   nrows 801
;ulxmap -20  ulymap 40

wkdir=strcompress('/home/mcnally/regionmasks/',/remove_all)
cd, wkdir

nx = 445
ny = 579

fname = file_search('*.bil') 


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
