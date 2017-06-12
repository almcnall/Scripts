pro AMMA_AET4hari  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
;I redid this code ...it looks like it was never really run, since the v2 was not in the title
;pull out the AET of the old run and the new run ( I could do both Malawi and Niger I suppose) 
;*************************************************************************
device,decomposed=0
;EXP025:ubRFE2 at 0.25 degrees with 25KM standard UMD Vegetation
;EXP027:ubRFE2 at 0.25 degree with all grass (rooting depth = 0.6 (maybe this is closer to maize-- rather than 2m);
; look at the AMMA inputs (rain) and outputs (UMD 5km veg) - show the AET precip ratio here.
;  
;indir25 = strcompress("/gibber/lis_data/OUTPUT/EXP025/NOAH/month_total_units/", /remove_all)
indir25 = strcompress("/gibber/lis_data/OUTPUT/EXP025/NOAH/month_total_units/", /remove_all)


cd, indir25

;I should probably pad out these arrays so that I can actually work with them....
;fileE = file_search('rain*.img');no spaces! this had not been fixed when I started dinking...
fileE = file_search('rain_???{3,4,5,6,7}*.img')
;fileE = file_search('evap_???{3,4,5,6}*.img')

nx     = 301.
ny     = 321.

mx = 8.
my = 14.

ngx=3
ngy=3

ingrid = fltarr(nx,ny)
;timeseries = fltarr(nx,ny,n_elements(fileE))
MalAOI = fltarr(mx,my)
SMalTS = fltarr(n_elements(fileE))

NAOI = fltarr(ngx,ngy)
NTS = fltarr(n_elements(fileE))

jcount = 0 ;counter for the month cubes
fcount = 0
mcount = 0

jncnt = 0
jlcnt = 0
acnt = 0
scnt = 0

;figure out the number of bands and initialize the month cubes
njans=file_search('evap_????01_tot.img')
nfebs=file_search('evap_????02_tot.img')
nmars=file_search('evap_????03_tot.img')

njuns=file_search('evap_????06_tot.img')
njuls=file_search('evap_????07_tot.img')
naugs=file_search('evap_????08_tot.img')
nspts=file_search('evap_????09_tot.img')

jans=fltarr(mx,my,n_elements(njans));9
febs=fltarr(mx,my,n_elements(nfebs));9
mars=fltarr(mx,my,n_elements(nfebs));just keep it square...

juns=fltarr(ngx,ngy,n_elements(nspts));5
juls=fltarr(ngx,ngy,n_elements(nspts));5
augs=fltarr(ngx,ngy,n_elements(nspts));5
spts=fltarr(ngx,ngy,n_elements(nspts));5

;mars=fltarr(mx,my,n_elements(nmars));8 

jancubie = fltarr(n_elements(njans))
febcubie = fltarr(n_elements(nfebs))
marcubie = fltarr(n_elements(nfebs))

juncubie = fltarr(n_elements(nspts))
julcubie = fltarr(n_elements(nspts))
augcubie = fltarr(n_elements(nspts))
sptcubie = fltarr(n_elements(nspts))

nxy=fltarr(4)
;marcubie = fltarr(n_elements(nmars))

;Niger AOI
;nxmx=2.55
;nxmn=2.85
;
;nymx=13.65
;nymn=13.45
;
;nxy[0] = ceil(reform((nxmx+20)*4))
;nxy[1] = floor(reform((nxmn+20)*4))
;
;nxy[2]= ceil(reform((nymx+40)*4)) ;there are 60 pixels to the equator
;nxy[3]= floor(reform((nymn+40)*4));


for i=0,n_elements(fileE)-1 do begin
;FOR EXP025 and EXP027*********************
  openu,1,fileE[i]
  readu,1,ingrid
  close,1
  ingrid=reverse(ingrid,2)
  MalAOI=ingrid(216:223,92:105) ;2nd number is how far notyh
  NAOI = ingrid(90:92,213:215)
;******************************************
  
  NTS[i]=mean(NAOI,/nan)
  SMalTS[i]=mean(MalAOI, /nan)
  
  if strmid(fileE[i],9,2) eq '01' then begin
    jans[*,*,jcount]=MalAOI
    jancubie[jcount]=mean(MalAOI,/nan)
    jcount++
  endif
  if strmid(fileE[i],9,2) eq '02' then begin
    febs[*,*,fcount]=MalAOI
    febcubie[fcount]=mean(MalAOI,/nan)
    fcount++
  endif
  if strmid(fileE[i],9,2) eq '03' then begin
    mars[*,*,mcount]=MalAOI
    marcubie[mcount]=mean(MalAOI,/nan)
    mcount++
  endif
  
;niger rainy season! june-sept
 if strmid(fileE[i],9,2) eq '06' then begin
   juns[*,*,jncnt]=NAOI
   juncubie[jncnt]=mean(NAOI,/nan)
   jncnt++
 endif
 if strmid(fileE[i],9,2) eq '07' then begin
   juls[*,*,jlcnt]=NAOI
   julcubie[jlcnt]=mean(NAOI,/nan)
   jlcnt++
 endif
 if strmid(fileE[i],9,2) eq '08' then begin
   augs[*,*,acnt]=NAOI
   augcubie[acnt]=mean(NAOI,/nan)
   acnt++
 endif
 if strmid(fileE[i],9,2) eq '09' then begin
   spts[*,*,scnt]=NAOI
   sptcubie[scnt]=mean(NAOI,/nan)
   scnt++
 endif
 
endfor;i 

;pull out relevant vars for south malawi and niger
;xnames=['2002','2003','2004','2005','2006','2007','2008','2009']
;;p1=plot(SMalTS) ;how do i take the areal average?
;p1=barplot(jancubie(1:8), thick=2) & print, jancubie
;p1=barplot(febcubie(1:8), thick=2,/overplot,color='green') 
;p1=barplot(marcubie(1:7), thick=2,/overplot, color='green', xtickname=xname)

;cut and past this part into excel....
;print, [transpose(jancubie), transpose(febcubie), transpose(marcubie)]
print, [transpose(juncubie), transpose(julcubie), transpose(augcubie), transpose(sptcubie)]

;started to make a cum dist. but got sleepy
;cumts=fltarr(n_elements(nts))
;for j=0,n_elements(nts)-1 do begin
;  if j eq 0 then cumts[k,l]=nts[j] 
;  if j gt 0 then cumts[k,l]=nts[j]+cumts[j-1]
;endfor
  

print, 'holdhere'
end