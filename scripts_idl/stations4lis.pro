pro stations4lis 
;the purpose of this program is to replace the grid cells over all of africa (?!)
;with the wankama East 132.1 station timeseries. 

;station, trmm and out data directories
sdir = strcompress('/jabber/Data/mcnally/AMMARain/', /remove_all)
rdir = strcompress('/jabber/LIS/Data/3B42V6/', /remove_all)
odir = strcompress('/jabber/Data/mcnally/AMMARain/WankamaEast_grid/', /remove_all)

;station data file
sfile = file_search(sdir+'wankamaEast_3hrly_2005_2008.dat')

;trmm three hourly files
rfile = file_search(rdir+'{2005,2006,2007,2008}*/*')

;make directories for output files...
;for i=0,n_elements(rfile)-1 do begin &$
;  dirname=odir+strmid(rfile[i],24,7)  &$
;  file_mkdir, dirname  &$
;endfor

;station file dimensions
ncol = 3 ;year, doy, rain(mm)
nrow = 11680 ;365*4*8 (8 values per day, 4 day)
WEast=fltarr(ncol,nrow)

openr,1,sfile
readu,1,wEast
close,1

nx=1440
ny=400

ingrid=fltarr(nx,ny)
ocheck=fltarr(nx,ny,n_elements(rfile))

;maybe I should cover africa in the rainfall pixels or just theo's domain?
;for i=0,n_elements(rfile)-1 do begin
for i=1704,1952 do begin;just check out yr 1 
 openu,1,rfile[i]
 print, rfile[i]
 readu,1,ingrid
 byteorder,ingrid,/XDRTOF ;make it idl readable (little endian)
 close,1
 
 ogrid=ingrid
 ogrid(640:940,40:360)=wEast[2,i]
 mve, ogrid(640:940,40:360)
 print, wEast[2,i]
 
 ocheck[*,*,i]=ogrid
 
 ofile=strcompress(odir+strmid(rfile[i],24,24))
 byteorder,ogrid,/XDRTOF ;switich it back to big-endian

print, 'hold'
;I need to make the dirs first?
; openw,1,ofile
; writeu,1,ogrid
; close,1
endfor

;temp=total(ocheck,3)
print, 'hold here'

;looks like the values in the grid are fine so maybe it is something in my daily agregation script...they seemed to be multiplied by 3.
;
 ;how do I replace these values with something huge?
; afr= ingrid(640:940,40:360) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees 
; test = ingrid
; test(640:940,40:360)= 800

;look at the data...how is it oriented, where are the edges?
;stack=fltarr(nx,ny)
;for i=0,n_elements(rfile)-1 do begin &$
;  openu,1,rfile[i]  &$
;  readu,1,ingrid &$
;  byteorder,ingrid,/XDRTOF &$
;  stack=ingrid+stack &$
;  afr= ingrid(640:940,40:360) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees 

;  close, 1 &$
;endfor
;afr= stack(640:940,40:360) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees 
;test=image(stack)
;test=image(afr)

end