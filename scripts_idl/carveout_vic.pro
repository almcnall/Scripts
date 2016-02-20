pro carveout_vic ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this program is to carveout the data for malawi and south west
; Niger from the global VIC model monthly data at 1deg 
; Malawi   32.75 - 35.85 E, -17.05 - -9.35S (34.5E, 13S)
; SW Niger 2.55 to 2.85E, 13.45 to 13.65N (13.55N, 2.7E)
;******************************************

datadir = strcompress('/jabber/Data/michael/historical/MONTHLY/soilm/', /remove_all)
sandman = strcompress('/jabber/sandbox/mcnally/')
cd, datadir
fnames = file_search('*{2003,2004,2005,2006,2007,2008}*.SM{1,2}.gz') 

nx = 360
ny = 150
nfiles=n_elements(fnames)/2

infile = fltarr(nx,ny)
SM1 = fltarr(nx,ny,nfiles)
SM2 = fltarr(nx,ny,nfiles)
cnt1=0
cnt2=0

for i = 0,n_elements(fnames)-1 do begin
  ;copies the files of interest over to the sandbox -mm and pp style
 ; spawn, strcompress('cp ' + fnames[i]+ ' ' + sandman + fnames[i] )
  
  ;unzips the files
  ;spawn, strcompress('gunzip ' + sandman + fnames[i])
  openr, 1, strcompress(sandman + strmid(fnames[i],0,14))
  readu, 1, infile;they at least need to be put into SM1 and SM2 catagories. 
  close, 1
  if strmid(fnames[i],13,1) eq '1' then begin
    SM1[*,*,cnt1]=reverse(infile,2) 
    cnt1++
    endif else begin
    SM2[*,*,cnt2]=reverse(infile,2)
    cnt2++
    endelse
;clean up the files after reading them
  cd, sandman
  spawn, strcompress('rm -f ' + sandman + fnames[i]) 
  cd, datadir
endfor

;**********now look at the precip data*******************
pdir=strcompress('/jabber/Data/michael/historical/MONTHLY/prcp/prcp_global', /remove_all)
cd, pdir
pnames = file_search('*{2003,2004,2005,2006,2007,2008}*.prcp.gz') 
prcp = fltarr(nx,ny,n_elements(pnames))
i=0
for i = 0,n_elements(pnames)-1 do begin
  ;copies the files of interest over to the sandbox -mm and pp style
 ; spawn, strcompress('cp ' + pnames[i]+ ' ' + sandman + pnames[i] )
  
  ;unzips the files
 ; spawn, strcompress('gunzip ' + sandman + pnames[i])
  openr, 1, strcompress(sandman + strmid(pnames[i],0,17))
  readu, 1, infile;they at least need to be put into SM1 and SM2 catagories. 
  close, 1
   prcp[*,*,i]=reverse(infile,2) 
    
;clean up the files after reading them
  cd, sandman
  spawn, strcompress('rm -f ' + sandman + pnames[i]) 
  cd, pdir
endfor

print, 'holdhere'

mxy=fltarr(2)
nxy=fltarr(2)

;find my x, y values in global files  13.55, 2.7
mlon =  34.5
mlat = -14

nlon = 2.7
nlat = 13.55

mxy[0] = reform((mlon+180))
mxy[1]= reform((mlat+60)) ;there are 60 pixels to the equator

nxy[0] = reform((nlon+180))
nxy[1]= reform((nlat+60)) ;there are 60 pixels to the equator

xtickname =['03','04','05','06','07','08']
;p1=plot(prcp(mxy[0], mxy[1], *), color='grey', title='CMAP precip in GLDAS: South Malawi', thick=3)
;p1=plot(SM2(214,46,*)/150,color='blue', thick=3, /overplot)
;p1=plot(SM1(214,46,*)/10,color='green', thick=3, /overplot, $
;        title = 'S. Malawi Soil moisture @ 5cm, 80cm 2003-08 from VIC 1 degree', $
;        xtickname=xtickname)

;***************************************************************************************************
;I should compare this to the RFE2 and station data that I used...where are they?
;read in rfe2 and extract for malawi and niger
;p1=plot(prcp(mxy[0], mxy[1], *), color='grey', title='CMAP precip in GLDAS: South Malawi', thick=3)

rfedir=strcompress('/jabber/LIS/Data/CPCOriginalRFE2/month_tot/', /remove_all)
rfile=file_search(+rfedir+'*{2003,2004,2005,2006,2007,2008}??.img') ;grab files 2003-2008

rinfile=fltarr(751,801)
rfe=fltarr(751,801,n_elements(rfile))
for i=0,n_elements(rfile)-1 do begin
  openr,1,rfile[i]
  readu,1,rinfile
  close,1
  rfe[*,*,i]=reverse(rinfile,2)
endfor; rfe loop

regrid=fltarr(75,80,n_elements(rfile)) ;oops this is only to 0.25 degree....
regrid=congrid(rfe,75,80,n_elements(rfile))

urfedir=strcompress('/jabber/LIS/Data/ubRFE2/month_tot/', /remove_all)
urfile=file_search(+urfedir+'*{2003,2004,2005,2006,2007,2008}??.img') ;grab files 2003-2008

urinfile=fltarr(751,801)
urfe=fltarr(751,801,n_elements(urfile))
for i=0,n_elements(urfile)-1 do begin
  openr,1,urfile[i]
  readu,1,urinfile
  close,1
  urfe[*,*,i]=reverse(urinfile,2)
endfor; rfe loop

uregrid=fltarr(75,80,n_elements(urfile))
uregrid=congrid(urfe,75,80,n_elements(urfile))

rfeplot=fltarr(75,80)
rfeplot[*,*]=mean(regrid,dimension=3)

urfeplot=fltarr(75,80)
urfeplot[*,*]=mean(regrid,dimension=3)

tvim, urfeplot

;find x,y coords in the Africa window
amxy=fltarr(2)
anxy=fltarr(2)

;find my x, y values in global files  13.55, 2.7
;mlon =  34.5
;mlat = -14

;nlon = 2.7
;nlat = 13.55

amxy[0] = reform((mlon+20))
amxy[1]= reform((mlat+40)) 

anxy[0] = reform((nlon+20))
anxy[1]= reform((nlat+40)) 

;**************************plots*********************************
p1=plot(regrid(amxy[0],amxy[1],*), color='grey', thick=3)
p1=plot(uregrid(amxy[0],amxy[1],*), color='orange', thick=2, /overplot)
p1=plot(prcp(mxy[0], mxy[1], *)*30, color='blue', title='CMAP (blue), RFE2 (grey), ubrfe (orange) precip in GLDAS: South Malawi', thick=3,/overplot)

p1=plot(regrid(anxy[0],anxy[1],*), color='grey', thick=3)
p1=plot(uregrid(anxy[0],anxy[1],*), color='orange', thick=2, /overplot)
p1=plot(prcp(nxy[0],nxy[1], *)*30, color='blue', title='CMAP (blue), RFE2 (grey), ubrfe (orange) precip in GLDAS: Niger', thick=3,/overplot)
print, 'stoppy'

print, 'stoppy'
  
end 
