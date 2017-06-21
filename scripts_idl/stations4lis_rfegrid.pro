pro stations4lis_rfegrid
;the purpose of this program is to replace the grid cells over a region in west africa 10:15N, 0:5E
;with the wankama East 132.1 station timeseries. 

odir = strcompress('/jabber/Data/mcnally/AMMARain/WankamaEast_gridv2/', /remove_all)

;station data file
sfile = file_search('/jabber/Data/mcnally/AMMARain/wankamaEast_6hrly_2005_2008.dat')

;rfe_gdas six hourly files
rfile = file_search('/jower/LIS/data/Biased_Orig/{2005,2006,2007,2008}*/rfe*')

;make directories for output files...
;for i=0,n_elements(rfile)-1 do begin &$
;  dirname=odir+strmid(rfile[i],28,7)  &$
;  file_mkdir, dirname  &$
;endfor

;station file dimensions
ncol = 3 ;year, doy, rain(mm)
;nrow = 11680 ;365*4*8 (8 values per day, 4 day)
nrow=5840;365*4*4 
WEast=fltarr(ncol,nrow)

openr,1,sfile
readu,1,wEast
close,1

nx=751
ny=801

ingrid=fltarr(nx,ny)
stack=fltarr(nx,ny)

;ocheck=fltarr(nx,ny,n_elements(rfile))

;maybe I should cover africa in the rainfall pixels or just theo's domain?
for i=0,n_elements(rfile)-1 do begin &$
;for i=1704,1952 do begin &$;just check out 200603-200605
 ;read in the rfe2_gdas 0.1 degree grid
 openu,1,rfile[i] &$
 print, rfile[i] &$
 readu,1,ingrid &$
 
 ;make it idl readable (little endian)
 byteorder,ingrid,/XDRTOF  &$
 close,1 &$
 
;stack them up so that I can make sure that I have the dimensions correct
;stack=ingrid+ stack  &$
 
 ;make a copy
 ogrid=ingrid
 ;convert to kg/m2/s for six hrly divide by 60*60*6=21600
 ;find theo's grid cells of interest 13-14, 2-3
stn_latS = 10.0
stn_latN = 15.0
stn_lonW = 0.0
stn_lonE = 5.0
xindS = FLOOR((stn_lonW + 20.05) * 10.0)
xindN = FLOOR((stn_lonE + 20.05) * 10.0)

yindS = FLOOR((stn_latS + 40.05) * 10.0) 
yindN = FLOOR((stn_latN + 40.05) * 10.0) 

;print, [xindS,xindN,yindS,yindN]

;test = ingrid
;test(xindS:xindN,yindS:yindN) = 800
;replace the pixels of interest with the station data for the yrmodyhr
 ogrid(xindS:xindN,yindS:yindN)=wEast[2,i]/21600
; mve,  ogrid(xindS:xindN,yindS:yindN)
; print, wEast[2,i]
 
 ;ocheck[*,*,i]=ogrid
 
 ofile=strcompress(odir+strmid(rfile[i],28,32))
 byteorder,ogrid,/XDRTOF ;switich it back to big-endian
 
print, 'hold'

;how do i get them in the appropriate output directories? it is built into the file name
; openw,1,ofile
; writeu,1,ogrid
; close,1
endfor


;temp=total(ocheck,3)
print, 'hold here'


p1 = image(ogrid, image_dimensions=[75.1,80.1], image_location=[-20,-40], dimensions=[751,801], $
           rgb_table=20)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
p1 = MAP('Geographic',LIMIT = [-40, -20, 40, 55], /overplot)
p1 = MAPCONTINENTS(/COUNTRIES)

;check the new files with the station data...looks fine, although the 'ne' statement doesn't really work.

ifile=file_search('/jabber/Data/mcnally/AMMARain/WankamaEast_gridv2/*/*')
ingrid=fltarr(751,801)
for i=0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
  ;good, the files I wrote are big endian
  byteorder,ingrid,/XDRTOF &$
  ;also good they are in kg/m2/s re:6hrly data
  val=ingrid[225,525]*21600 &$
  if float(wEast[2,i]) ne float(val) then print, 'problem at'+ifile[i]+'which is i='+string(i)+string(val)+' not eq'+string(wEast[2,i]) &$
end