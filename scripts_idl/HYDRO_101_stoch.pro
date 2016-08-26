;;stochastic hydro 101

;what is the difference between different daily disagregations of CHIRPS? PDF, CDF?
;how does this impact the ET, RO and SM for a given day and month?

;read in RFE2_CHIRPS subdaily file
;options big_endian
;TITLE CPC RFE2.0 Daily PPT for Africa
;UNDEF -999.0
;XDEF    751  LINEAR  -20.0  0.1
;YDEF    801  LINEAR  -40.0  0.1
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro


yr = 2005
mo = 1

;;;READ IN CHIRPS 6hrly RFE2-formated binary continental Africa files;;;;;;;
indir = '/discover/nobackup/projects/fame/MET_FORCING/CHIRPSv2/6-hrly/'

ifile = file_search(indir+'201501/rfe_gdas.bin.201501*') & print, ifile

CHP6HR = fltarr(751,801, n_elements(ifile))
temp = fltarr(751,801)

for i = 0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,temp &$
  close,1 &$
  byteorder,temp,/XDRTOF &$
  temp(where(temp lt 0)) = !values.f_nan &$
  
  CHP6HR[*,*,i] = temp &$
endfor

map_ulx = -20.
map_lrx = 55
map_uly = 40
map_lry = -40

;subset to lake tangenika 3S, 10S, 28E, 32E
ymap_ulx = 28. & ymap_lrx = 32.
ymap_uly = -3. & ymap_lry = -10.

left = floor((ymap_ulx-map_ulx)/0.1)  & right= floor((ymap_lrx-map_ulx)/0.1)
top= floor((ymap_uly-map_lry)/0.1)   & bot= floor((ymap_lry-map_lry)/0.1)

;tanganika box 20.5 x 48
tNX = right - left + 1
tNY = top - bot + 1

TCHP6HR = CHP6HR[left:right, bot:top,*]
w = window(dimensions=[600,600])
temp = image(mean(tchp6hr, dimension=3), /current, title = 'avg 6-hrly rainfall CHIRPS')
temp.rgb_table=73
c=colorbar()
temp.max_value = 0.00015

;ok so what are my questions?
;(1) am i in the same location as kristi?
;(2) what does the time series look like for the 6hrly inputs?
;(3) what was the question about the distribution? i think it was that different 6 hrly 
;realizations would result in different ET, SM, RO.
;maybe its more interesting to look at thier CDFs
temp = plot(mean(mean(tchp6hr*4,dimension=1, /nan), dimension=1, /nan), title = 'mm/6hrs')

cum = total(mean(mean(tchp6hr,dimension=1, /nan), dimension=1, /nan), /cumulative)
temp = plot(cum, title = 'cumulative 6hrs Jan 2015') ;n = 124 = 31*4

;;READ IN daily LIS-output - then plot CDF
indir2 = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/SURFACEMODEL/'
ifile2 = file_search(indir2+'201501/LIS_HIST*') & print, ifile2
;ifile3 = file_search(data_dir+STRING(FORMAT='(''FLDAS'',I4.4,''.nc'')',y)) &$

;just read these data from HYRO_101 or read_
params = get_domain01('EA')

eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

P = fltarr(eNX,eNY, n_elements(ifile2))
VOI = 'Rainf_f_tavg' 
For j = 0, n_elements(ifile2)-1 do begin &$
  temp = get_nc(VOI, ifile2[j]) &$
  P[*,*,j] = temp &$
endfor
P(where(P lt 0))= !values.f_nan
;now subset to tanganika...
eleft = floor((ymap_ulx-emap_ulx)/0.1)  & eright= floor((ymap_lrx-emap_ulx)/0.1)
etop= floor((ymap_uly-emap_lry)/0.1)   & ebot= floor((ymap_lry-emap_lry)/0.1)

;tanganika box 20.5 x 48
etNX = right - left + 1
etNY = top - bot + 1

PdayCHP = P[eleft:eright, ebot:etop,*]
temp = image(mean(PdayCHP, dimension=3, /nan))
;avg daily 6-hrly rainfall cummulative? must be why i have to *4
Pdaycum = total(mean(mean(PdayCHP,dimension=1, /nan), dimension=1, /nan), /cumulative)

p1 = plot(rebin(pdaycum*4, 31*4), 'b', /overplot)
temp = plot(total(mean(mean(PdayCHP,dimension=1, /nan), dimension=1, /nan), /cumulative))

