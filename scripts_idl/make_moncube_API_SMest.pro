pro make_moncube_API_SMest

;I am trying to do the ranked correlations here between API and NDVI estimated SM
;chris says look at growing season....JAS cubes in west africa only to start.That is what this script does
;make month cubes from the API and est SM-NDVI data (dekads). 

;read in the API map & read in the SM est map -- orgnaize into dek cubes....

nfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/SM*.img');
afile = file_search('/jabber/LIS/Data/API_sahel/APIsahel*.img')

amm = strmid(afile,40,2) & print, amm
ayr = strmid(afile,36,4) & print, ayr

nmm = strmid(nfile,53,2) & print, nmm
nyr = strmid(nfile,48,4) & print, nyr

nx = 720
ny = 350
nz = 425 
nza = 429

;skipping the monthly step....
;now I need to aggregate these files to JJA or JAS..
;API names are MMD   APIsahel_2012102.img
;nDVI names are MMD: SMest_data.2012.102.img

;first make the NDVI cubes
ingrid = fltarr(nx,ny)
stack  = fltarr(nx,ny,9)
stack[*,*,*] = !values.f_nan
cube   = fltarr(nx,ny,108)

cnt = 0
;use n's for the NDVI and a's for the API
for y = 2001,2012 do begin &$
  yyyy = strcompress(y, /remove_all) &$
  mm = STRING(FORMAT='(I2.2)',cnt+1) &$   ;two digit month
  
  ;for the API
  ;yfile = afile(where(ayr eq yyyy))  &$
  ;this agregates JAS but maybe I want to do the 3 months and the pattern should match?
  ;season = yfile(where(strmid(yfile,40,2) eq '07' OR strmid(yfile,40,2) eq '08' OR strmid(yfile,40,2) eq '09')) &$
  ;ofile = strcompress('/jabber/LIS/Data/API_sahel/moncubie/API_sahel_'+mm+'.img', /remove_all) & print, ofile &$
  ;ofile = strcompress('/jabber/LIS/Data/API_sahel/moncubie/avgAPI_sahel_JJA.img', /remove_all) & print, ofile  &$
  
;  ;For the NDVI
  yfile = nfile(where(nyr eq yyyy))  &$
  season = yfile(where(strmid(yfile,53,2) eq '07' OR strmid(yfile,53,2) eq '08' OR strmid(yfile,53,2) eq '09')) &$
  ;ofile = strcompress('/jabber/chg-mcnally/filterNDVI_sahel/moncubie/SMest_JJA'+mm+'.img') &$
  ofile = strcompress('/jabber/chg-mcnally/filterNDVI_sahel/moncubie/SMest_JJA.img') &$
  
  for s = 0,n_elements(season)-1 do begin &$
   openr,1,season[s] &$
   readu,1,ingrid &$
   close,1 &$
   
   stack[*,*,s] = ingrid &$
  endfor &$
  cube[*,*,cnt] = mean(stack, dimension = 3,/nan) &$
  cnt++ &$
  ;I also need to agregate them by month (12x12) then i can look at the months of interest?
  
  ;is there a way to make this cube bigger? increment by 9s
;  cube[*,*,cnt:cnt+8] = stack &$
;  cnt = cnt + 9  &$
  print, cnt &$
endfor
;  openw,1,ofile &$
;  writeu,1,cube[*,*,0:11] &$
;  close,1 &$
print, 'hold'

;check out a time series...not sure if i should use spearman or kendal tau
;output both results so that i can make a significance mask...
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

temp = plot(cube[wxind,wyind,0:11])
temp = plot(filtercube[mxind,myind,*], /overplot, 'b')

print, 'kendal =',r_correlate(apicube[mxind,myind,*],filtercube[mxind,myind,*], /KENDALL)
print, 'spearman =',r_correlate(apicube[mxind,myind,*],filtercube[mxind,myind,*])
print, 'pearson =',correlate(apicube[mxind,myind,*],filtercube[mxind,myind,*])
end 