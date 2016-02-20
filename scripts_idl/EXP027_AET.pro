pro EXP027_AET  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
;I redid this code ...it looks like it was never really run, since the v2 was not in the title
;pull out the AET of the old run and the new run ( I could do both Malawi and Niger I suppose) 
;*************************************************************************
device,decomposed=0
;EXP025:ubRFE2 at 0.25 degrees with 25KM standard UMD Vegetation
;EXP027:ubRFE2 at 0.25 degree with all grass (rooting depth = 0.6 (maybe this is closer to maize-- rather than 2m)
  
indir25 = strcompress("/gibber/lis_data/OUTPUT/EXP027/NOAH/month_total_units/", /remove_all)
cd, indir25

;I should probably pad out these arrays so that I can actually work with them....
fileE = file_search('evap*.img');no spaces! this had not been fixed when I started dinking...

nx     = 301.
ny     = 321.
mx = 8.
my = 14.
ingrid = fltarr(nx,ny)
;timeseries = fltarr(nx,ny,n_elements(fileE))
MalAOI = fltarr(mx,my)
SMalTS = fltarr(n_elements(fileE))

jcount = 0 ;counter for the month cubes
fcount = 0
mcount = 0

;figure out the number of bands and initialize the month cubes
njans=file_search('evap_????01_tot.img')
nfebs=file_search('evap_????02_tot.img')
nmars=file_search('evap_????03_tot.img')


jans=fltarr(mx,my,n_elements(njans));9
febs=fltarr(mx,my,n_elements(nfebs));9
mars=fltarr(mx,my,n_elements(nfebs));just keep it square...

;mars=fltarr(mx,my,n_elements(nmars));8 

jancubie = fltarr(n_elements(njans))
febcubie = fltarr(n_elements(nfebs))
marcubie = fltarr(n_elements(nfebs))

;marcubie = fltarr(n_elements(nmars))

for i=0,n_elements(fileE)-1 do begin
  openu,1,fileE[i]
  readu,1,ingrid
  close,1
  ingrid=reverse(ingrid,2)
  MalAOI=ingrid(216:223,92:105) ;I should also add a niger AOI....
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
endfor;i 

;pull out relevant vars for south malawi and niger
;xnames=['2002','2003','2004','2005','2006','2007','2008','2009']
;;p1=plot(SMalTS) ;how do i take the areal average?
;p1=barplot(jancubie(1:8), thick=2) & print, jancubie
;p1=barplot(febcubie(1:8), thick=2,/overplot,color='green') 
;p1=barplot(marcubie(1:7), thick=2,/overplot, color='green', xtickname=xname)

;cut and past this part into excel....
print, [transpose(jancubie), transpose(febcubie), transpose(marcubie)]


print, 'holdhere'
end