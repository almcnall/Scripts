pro AMMA_rain4har  ; indir, var ;add these when I understand how to run this from a script

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
;indir25 = strcompress("/gibber/lis_data/OUTPUT/EXP025/NOAH/month_total_units/", /remove_all)
indir25 = strcompress("/gibber/lis_data/OUTPUT/EXPA02/NOAH/month_total_units/", /remove_all)
cd, indir25

;I should probably pad out these arrays so that I can actually work with them....
;fileE = file_search('rain*.img');no spaces! this had not been fixed when I started dinking...
fileE = file_search('rain_???{4,5,6,7}*.img')
;fileE = file_search('evap_???{3,4,5,6}*.img')

;special section for dealing with the 0.1 degree outputs of EXPA02
fx = 720.
fy = 350.
indat=fltarr(fx,fy)
POI=fltarr(4)
sPOI=fltarr(4)

  nxmx=2.55
  nxmn=2.85
  
  nymx=13.65
  nymn=13.45


;lon=2.7
;lat=13.5

sPOI[0]=(nxmx+19.95)*10 
sPOI[1]=(nxmn+19.95)*10;given the way that the image is rotated it needs to shift right by ~20 and since 'zero'=29.95 I have to adjust accordingly
sPOI[2]=(29.95-nymx)*10
sPOI[3]=(29.95-nymn)*10
  
  ;POI[0]=(nxmx+19.95)*4 ;given the way that the image is rotated it needs to shift right by ~20 and since 'zero'=29.95 I have to adjust accordingly
  ;POI[1]=(nxmn+19.95)*4
  ;POI[2]=(29.95-nymx)*4
  ;POI[3]=(29.95-nymn)*4

ngx=1 ;4 ;changed for using smaller grid from 3 to 4
ngy=1 ;3

NAOI = fltarr(ngx,ngy)
NTS = fltarr(n_elements(fileE))

jncnt = 0
jlcnt = 0
acnt = 0
scnt = 0

;figure out the number of bands and initialize the month cubes

njuns=file_search('evap_????06_tot.img')
njuls=file_search('evap_????07_tot.img')
naugs=file_search('evap_????08_tot.img')
nspts=file_search('evap_????09_tot.img')

juns=fltarr(ngx,ngy,n_elements(nspts));5
juls=fltarr(ngx,ngy,n_elements(nspts));5
augs=fltarr(ngx,ngy,n_elements(nspts));5
spts=fltarr(ngx,ngy,n_elements(nspts));5

juncubie = fltarr(n_elements(nspts))
julcubie = fltarr(n_elements(nspts))
augcubie = fltarr(n_elements(nspts))
sptcubie = fltarr(n_elements(nspts))

nxy=fltarr(4)
;marcubie = fltarr(n_elements(nmars))

;Niger AOI
nxmx=2.55
nxmn=2.85

nymx=13.65
nymn=13.45

nxy[0] = ceil(reform((nxmx+20)*4))
nxy[1] = floor(reform((nxmn+20)*4))

nxy[2]= ceil(reform((nymx+40)*4)) ;there are 60 pixels to the equator
nxy[3]= floor(reform((nymn+40)*4));


for i=0,n_elements(fileE)-1 do begin
  openr,1,fileE[i]
  readu,1,indat
  ;indat=reverse(indat,2)
  close,1
  regrid=congrid(indat,288,140)
  ;NAOI=regrid(90:92,64:66); 
  ;NAOI=indat(225:228,163:165)
  NAOI=indat(226,165)
  
;*****************************************
  NTS[i]=mean(NAOI,/nan)
  
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

print, [transpose(juncubie), transpose(julcubie), transpose(augcubie), transpose(sptcubie)]
print, 'holdhere'
end