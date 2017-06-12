;this script compares the station data at KLEE to the ubRFE data that I am using for the API model.
;tom thought that it looked like my rainfall data was bad -- and that is certainly a source of error when going from 
;stations to satellites.
;Ah, these are degrees min (no sec)
;N: Oo 17.46' N, 36o 51.96' E = 36.866,0.291
;C: Oo 17.13' N, 36o 52.12' E = 36.8687,0.2855
;S: Oo 16.85' N, 36o 51.12' E = 36.852,0.28083

;*******************FIGURE 1 on PAPER 2*****************************************
; FIGURE 1 for paper #2 
;************make cummulative precip at a point*****************************
ifile = file_search('/jabber/chg-mcnally/KLEE.North_10dayavg_PRCP.csv')
ifile = file_search('/jabber/chg-mcnally/KLEE.Central_10dayavg_PRCP.csv')
ifile = file_search('/jabber/chg-mcnally/KLEE.South_10dayavg_PRCP.csv')

knsrain = read_csv(ifile)

rfile = file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/{2011,2012}*.img') & print, rfile
allgrid = fltarr(720,350,72)
allgrid[*,*,*] = !values.f_nan
ingrid = fltarr(720,350)

for i = 0, n_elements(rfile)-1 do begin &$
  openr,1,rfile[i] &$
  readu,1,ingrid &$
  close,1 &$
  
  allgrid[*,*,i] = ingrid &$
endfor 

  ;lat/lons of the sites of interest
;KLEE North: 2011-2012
kxind = FLOOR((36.866 + 20.) / 0.10)
kyind = FLOOR((0.291 + 5) / 0.10)

ubrfe = allgrid[kxind,kyind,*]
ubcube = transpose(reform(ubrfe,36,2))
;first cube into years & for barplot change nans to zeros
rain = float(knsrain.field1)
good = where(finite(rain), complement = zeros)
rain(zeros) = 0

rain = transpose(reform(rain,36,2))

cum = fltarr(2,36)
for y = 0,n_elements(rain[*,0])-1 do begin &$
  for i = 0,n_elements(rain[0,*])-1 do begin &$
    cum[y,0] = ubcube[y,0] &$
    cum[y,i] = cum[y,i-1] + ubcube[y,i] &$
  endfor &$
endfor  
sta = cum
ub = cum

;read in the soil moisture data....
kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

p1 = plot(sta[1,*],'b', name = 'sta 2012', thick = 3)
p2 = plot(ub[1,*],'g', name = 'ubRFE 2012', thick = 3, /overplot) 
lgr2 = LEGEND(TARGET=[p1,p2])
p1.title = 'KLEE North Rainfall 2011 & 2012'

temp = barplot(rain)
temp = plot(KLEE, /overplot, thick = 3)
temp.title = 'KLEE station rainfall (blue), ubrfe/2 (orange) and soil moisture 2011-2012'
temp = barplot(ubrfe/2, fill_color='orange', /overplot)
temp.title.font_size = 18 
temp.xtickfont_size = 14
temp.ytickfont_size = 14

;plot the klee rainfall and soil moisture data togther...