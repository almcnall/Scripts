pro carveout_vicAET ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this program is to carveout the data for malawi and south west
; Niger from the global VIC model monthly data at 1deg 
; Malawi   32.75 - 35.85 E, -17.05 - -9.35S (34.5E, 13S)
; SW Niger 2.55 to 2.85E, 13.45 to 13.65N (13.55N, 2.7E)
;******************************************

datadir = strcompress('/jabber/Data/michael/historical/MONTHLY/VICAET/', /remove_all)
cd, datadir
fnames = file_search('*{2003,2004,2005,2006,2007,2008}*.aet*') 
hdr = file_search('*{2003,2004,2005,2006,2007,2008}*.hdr') & print, n_elements(hdr)

nx = 360
ny = 150
numfiles=(n_elements(fnames)-n_elements(hdr))
nfiles=(n_elements(fnames)-n_elements(hdr))/4

infile  = fltarr(nx,ny)
wetcanE = fltarr(nx,ny,nfiles)
drycanE = fltarr(nx,ny,nfiles)
bsoilE  = fltarr(nx,ny,nfiles)
totalET = fltarr(nx,ny,nfiles)

cnt1=0
cnt2=0
cnt3=0
cnt4=0

for i = 0,n_elements(fnames)-1 do begin
   print,'ifs working'
  if strmid(fnames[i],15,3) eq 'hdr' OR strmid(fnames[i],16,3) eq 'hdr' then continue

  ;copies the files of interest over to the sandbox -mm and pp style
 ; spawn, strcompress('cp ' + fnames[i]+ ' ' + sandman + fnames[i] )
  
  ;unzips the files
  ;spawn, strcompress('gunzip ' + sandman + fnames[i])
  openr, 1, fnames[i] ;what will happen when i tell it to only open some?
  readu, 1, infile;they at least need to be put into SM1 and SM2 catagories. 
  close, 1
  
  if strmid(fnames[i],13,2) eq 't' then begin
    totalET[*,*,cnt1]=reverse(infile,2) 
    cnt1++
  endif
 if strmid(fnames[i],13,2) eq 'tc' then begin
    drycanE[*,*,cnt2]=reverse(infile,2) 
    cnt2++   
 endif
 if strmid(fnames[i],13,2) eq 'ti' then begin
    wetcanE[*,*,cnt3]=reverse(infile,2) 
    cnt3++
 endif 
 if strmid(fnames[i],13,2) eq 'ts' then begin
    bsoilE[*,*,cnt4]=reverse(infile,2) 
    cnt4++
 endif 

print, 'really, stop here'   
endfor

mxy=fltarr(2)
nxy=fltarr(2)

;find my x, y values in global files  13.55, 2.7
mlon =  34.5
mlat = -14

nlon = 2.7
nlat = 13.55

mxy[0] = reform((mlon+180))
mxy[1]= reform((mlat+60)) ;there are 60 pixels to the equator

nxy[0] = 183.;reform((nlon+180))
nxy[1]= 74. ;reform((nlat+60)) ;there are 60 pixels to the equator

p1=plot(bsoilE(nxy[0],nxy[1],*), color='green', linestyle='1', thick =3); for some reason there are only values at 182,74 ..not sure about the rest
p2=plot(wetcanE(nxy[0],nxy[1],*), /overplot, color='blue'); 
p3=plot(drycanE(nxy[0],nxy[1],*), /overplot, color='orange'); 
p4=plot(totalET(nxy[0],nxy[1],*), /overplot, color='black',thick=2, title='ET=bare soil + wet canopy + dry canopy: VIC SW Niger'); 

p1.name = 'bare soil'
p2.name = 'wet canopy/interception'
p3.name = 'dry canopy/transpiration'
p4.name = 'total ET'
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 


print,(bsoilE(180:184,70:73,*))
p1=plot(bsoilE(182,74,*));
tvim, bsoilE(180:182,64:73,6)
print, 'stoppy'
  
end 
