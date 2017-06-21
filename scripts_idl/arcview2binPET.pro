pro arcview2binPET
;the purpose of this script to to read in the EROSpet.bil file and write them to binary.
;or maybe just pull out the time series of interest for now and do the rest later. not sure. 
;-180 to +180 longitude by -90 to +90 latitude...i read in the bils extracted the pixel of interest, created yr, month, day vectors and then 
;agregated the data to dekads. 

indir= strcompress("/jabber/Data/mcnally/EROSPET/",/remove_all)
odir = strcompress("/jabber/Data/mcnally/EROSPET/binary", /remove_all)

file_mkdir, odir

nx=360
ny=181

ox=75
oy=80

ifile = file_search(indir+'*/*.bil') 
ingrid  = uintarr(nx,ny) ; the .bil are unsigned integers 

;af=fltarr(75,80) ;one degree
wankama = uintarr(n_elements(ifile))
WKdek=uintarr(146) ; deks per year....
count=0
cnt=0
dek=uintarr(10)

for i=0, n_elements(ifile)-1 do begin
  openr,1,ifile[i]            ;opens one file at a time   
  readu,1,ingrid              ;reads the file into ingrid
  close,1  
  byteorder,ingrid,/XDRTOF   ;these things come in big endian, not idl friendlu
  ingrid=reverse(ingrid,2)
  
  ;clip out africa, use this later for now just figure out what is my pixel of interest
  ;afr=ingrid[160:234,50:130]
  ;what is the 1 degree box around my study site? 13-14, 2-3
  ;180+2, 180+3, 90+13, 90+14
  wankama[i]=ingrid[182,103]
;  dek[count]=ingrid[182,103]
;  count ++
;  if count eq 9 then begin 
;    dekavg=mean(dek)
;    WKdek[cnt]=dekavg
;    print, 'dek'+cnt
;    cnt++ 
;    count=0 
;  endif 
endfor

;silly way of making days of the years, months, days....
days = [31,28,31, 30,31,30, 31,31,30, 31,30,31]
ldays = [31,29,31, 30,31,30, 31,31,30, 31,30,31]
moy =[1,2,3,4,5,6,7,8,9,10,11,12]

for d=0,n_elements(days)-1 do begin &$
  month=indgen(days[d])+1 &$
  if d eq 0 then array=month else array=[month,array] &$
  m=intarr(days[d]) &$
  m[*]=moy[d] &$
  if d eq 0 then monthvec=m else monthvec=[monthvec,m] &$
endfor;d 


for d=0,n_elements(ldays)-1 do begin &$
  month=indgen(ldays[d])+1 &$
  if d eq 0 then larray=month else larray=[month,larray] &$
   m=intarr(ldays[d]) &$
  m[*]=moy[d] &$
  if d eq 0 then lmonthvec=m else lmonthvec=[lmonthvec,m] &$
endfor;d 

array=transpose(array)
larray=transpose(larray)
monthvec=transpose(monthvec)
lmonthvec=transpose(lmonthvec)

dayarray=[[array],[array],[array],[larray]]
montharray=[[monthvec],[monthvec],[monthvec],[lmonthvec]]

yr=intarr(4,365)
yr[0,*]=2005
yr[1,*]=2006
yr[2,*]=2007
yr[3,*]=2008

yrmac=[[yr[0,*]],[yr[1,*]],[yr[2,*]],[yr[3,*]],[yr[3,0]]]
;shew now I can use the old code to make this into dekads....
yrday=[yrmac,montharray,dayarray,transpose(wankama)]
sbuffer=yrday


sdeks=fltarr(144) ;do I want other stuff in this array? how many dekads will there be in 4 years? 36*4
cnt=0
emptydek=!VALUES.F_NAN

for y=2005,2008 do begin
  for m=1,12 do begin
    ;where year=year and month=month
    index=where(sbuffer[0,*] eq y AND sbuffer[1,*] eq m, count) 
    if count eq 0 then begin
      print, 'a whole month missing wtf?!'
      sdek1=emptydek
      sdeks[cnt]=sdek1 & cnt++
      sdek2=emptydek
      sdeks[cnt]=sdek2 & cnt++
      sdek3=emptydek
      sdeks[cnt]=sdek3 & cnt++
    ;continue 
    endif
    ;dekad1 are the days/hrs/mon where day (sbuffer(3)) is less than 11   
    d1=where(sbuffer[2,index] lt 11, count) & print, count
    
    ;take the average of the SM col (sbuffer6), ignoring nan's
    if count gt 0 then sdek1=mean(sbuffer[3,index[d1]], /nan) else sdek1=emptydek
    ;record this average for the dekad.
    sdeks[cnt]=sdek1 & cnt++
    
    ;bad coding practice -- i added in an exception for one particular instance...but it works :p
    d2=where(sbuffer[2,index] ge 11 AND sbuffer[2,index] le 20, count) & print, count
    ;if count eq 1 then sdek2=sbuffer[*,index[d2]] else $ 
    if count gt 0 then sdek2=mean(sbuffer[3,index[d2]],/nan) else sdek2=emptydek
    sdeks[cnt]=sdek2 & cnt++
    
    d3=where(sbuffer[2,index] ge 21, count) & print, count
    if count gt 0 then sdek3=mean(sbuffer[3,index[d3]],/nan) else sdek3=emptydek
    sdeks[cnt]=sdek3 
    ;if cnt eq 141 then continue else cnt++
    ;if cnt eq 141 then continue else 
    cnt++
    print, 'm='+string(m)
    print, 'cnt='+string(cnt)
    
   endfor;m
   print, 'y='+string(y)
   print, 'cnt='+string(cnt)
endfor;y

  print, 'hold here'
  ;scale the PET , divide by 100?
  ;fltgrid[WHERE(fltgrid lt 0.)] = !VALUES.F_NAN
  
;  ofile   = indir+'wankama_dekadPET_2005_2008.dat'
;  openw,1,ofile
;  writeu,1,sdeks
;  close,1

;
end
