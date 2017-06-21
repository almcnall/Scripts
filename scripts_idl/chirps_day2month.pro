pro chirps_day2month

;4/21/2014 i pulled this from the mlandvchirps script when i decided just to write out the file
;someday i could just call this function...if i were a proper programmer.
;9/30/14 updating to include 1981-1983 duh. This looks more like the data pete looks at than the 6hrly LIS outputs
;10/7/14 can i add RFE2 to this lot? There is already monthly RFE2 in /home/RFE2/monthly

cdir = '/home/sandbox/chirps/v1.8/daily_downscaled_by_monthly_full_rescale/p25/'
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
;m_stack = fltarr(300,320,12,30)
;year = indgen(30)+1984 & print, year
year = indgen(3)+1981 & print, year
m_stack = fltarr(300,320,12,3)


;make monthly chirps
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
   ; cfile = file_search(strcompress(cdir+string(year[y])+'/chirps.'+string(year[y])+'.'+mm[m]+'.??.tif', /remove_all)) &$
    cfile = file_search(strcompress(cdir+string(year[y])+'/chirps-v1.8.'+string(year[y])+'.'+mm[m]+'.??.tif', /remove_all)) &$

    stack = fltarr(300,320, n_elements(cfile)) &$
    for f = 0, n_elements(cfile)-1 do begin &$
      ingrid = read_tiff(cfile[f]) &$
      stack[*,*,f] = ingrid &$
    endfor &$
    mon_chirps = reverse(total(stack,3),2) &$
    m_stack[*,*,m,y] = mon_chirps &$
  
    ofile = strcompress("/home/sandbox/people/mcnally/CHIRPS_eval/chirps_mon_"+string(year[y])+string(mm[m])+".bil", /remove_all) &$
    print, ofile &$
    openw,1,ofile &$
    writeu,1,mon_chirps &$
    close,1  &$
  endfor  &$
endfor  

;make monthly ARC2 arc starts in 1983 but was missing some files in that January
;so i started in 1984. there are still some files missing...I am not sure how that
;will impact these monthly stats
;9/13/15 update thse to include 2014...all analysis can be up to Dec 2014
nx = 300
ny = 320
adir = '/home/ARC2/daily/'
mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
;year = indgen(30)+1984 & print, year
year = 2014
;ingrid = fltarr(751,801)
mon_arc2 = fltarr(nx,ny)
a_stack = fltarr(nx,ny,12,n_elements(year))

;ugh, there are missing days in here I guess that is ok and a whole month (DEC) in 1988?
for y = 0, n_elements(year)-1 do begin &$
  for m = 0,n_elements(mm)-1 do begin &$
    afile = file_search(strcompress(adir+'africa_arc.'+string(year[y])+mm[m]+'??.tif', /remove_all)) &$
    if n_elements(afile) le 1 then continue &$ 
    stack = fltarr(751,801, n_elements(afile)) &$
    for f = 0, n_elements(afile)-1 do begin &$
      ingrid = read_tiff(afile[f]) &$
      stack[*,*,f] = ingrid &$
    endfor &$
    if n_elements(afile) lt 25 then stack[*,*,*] = !values.f_nan &$
    mon_arc2 = congrid(reverse(total(stack,3, /nan),2),300,320) &$
    a_stack[*,*,m,y] = mon_arc2 &$
   
    ofile = strcompress("/home/sandbox/people/mcnally/CHIRPS_ARC2_eval/arc2_mon_"+string(year[y])+string(mm[m])+".bil", /remove_all) &$
    print, ofile &$
    openw,1,ofile &$
    writeu,1,mon_arc2 &$
    close,1  &$
  endfor  &$
endfor 




merra(where(merra lt 0))=!values.f_nan

