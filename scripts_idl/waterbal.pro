pro waterbal

;the purpose of this program is to caluculate the annual water
;balance from Noah model outputs to see how things are going. Ideally I'll be a able to use these again
;after re-running the model...The box used for EXPA02 is
;run domain lower left lat:                  -4.95  
;run domain lower left lon:                 -19.95  
;run domain upper right lat:                 29.95
;run domain upper right lon:                 51.95
;run domain resolution (dx):                  0.1
;run domain resolution (dy):                  0.1


expdir = 'EXPA02'
wkdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/month_total_units/",/remove_all)
cd, wkdir
;read in the data precip, evap, runoff (surf+subsurf), soil moisture (sm1+sm2+sm3+sm4)

vars = ['evap','Qsuf','Qsub','rain']  
stor = ['sm01','sm02','sm03','sm04']; 
nx = 720.
ny = 350.
ifile=fltarr(nx,ny)
mofile=fltarr(nx,ny)
antot=fltarr(nx,ny,n_elements(vars))
POI=fltarr(2)
buffer=fltarr(nx,ny,5,n_elements(vars)); 5 yrs of totals

; this part isn;t working quite right. to get the matching value from what I extracted as upopercenter in ENVI I need to use 
; 226, 165. this is not what I get when I enter in the lat lons and subtract from the edges....
lon=2.7
lat=13.5

POI[0]=(lon+19.95)*10 ;given the way that the image is rotated it needs to shift right by ~20 and since 'zero'=29.95 I have to adjust accordingly
POI[1]=(29.95-lat)*10

cntr = 0
yrcount = 0
;lets start with just evap for our pixel of interest (upper center)
;for i = 0,n_elements(vars)-1 do begin
;  ;i=0
;  fname = file_search(vars[i]+'*.img') & print, fname
;   n_bands = n_elements(fname)
;    
;  for j=0,n_elements(fname)-1 do begin
;    ;j=0
;    openr,1,fname[j]
;    readu,1,ifile
;    close,1
;    mofile[*,*] = ifile+mofile
;    cntr++
;    if cntr eq 12 then begin
;      buffer[*,*,yrcount,i] = mofile ;this is where I accumulate values.....
;      cntr = 0
;      yrcount++
;      mofile[*,*] = 0
;    endif
;  endfor;j  
;  yrcount = 0
;  ;vars = ['evap','Qsuf','Qsub','rain'] 
;  if i eq 1 OR i eq 2 then buffer[*,*,*,i] = buffer[*,*,*,i]*86400 ;conver to mm
;  ;p1=barplot(buffer[226,165,*,i], title=vars[i]+' annual total',xtickname=['04','05','06','07','08']) ;to get the same result as my envi extraction
;endfor;i
 
 ;calculate the change in soil water storage March-March...
 stor = ['sm01','sm02','sm03','sm04']; 

;for i=0,n_elements(stor)-1 do begin
; ;i=0
; fname=file_search(stor[i]+'*03_tot.img'); look at the storage for both jan-jan and march to march
; buff=fltarr(nx,ny,n_elements(fname)); 5 yrs of totals
;  for j=0,n_elements(fname)-1 do begin
;    openu,1,fname[j]
;    readu,1,ifile
;    close,1
;    buff[*,*,j]=ifile
;  endfor; j
; 
;  print, buff[226,165,*]
;  print, buff[226,165,2]-buff[226,165,1]
;  print, buff[226,165,3]-buff[226,165,2]
;  print, buff[226,165,4]-buff[226,165,3]
;endfor;i

for i=0,n_elements(stor)-1 do begin
 ;i=0
 fname=file_search(stor[i]+'*_tot.img'); look at the storage for both jan-jan and march to march
 buff=fltarr(nx,ny,n_elements(fname)); 5 yrs of totals
  for j=0,n_elements(fname)-1 do begin
    openu,1,fname[j]
    readu,1,ifile
    close,1
    buff[*,*,j]=ifile
  endfor; j
   print, buff[226,165,*];these are not flipped is that wrong or right?
endfor;i
 print, 'just checkin' 
 end  