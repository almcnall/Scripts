pro NoahEROS_Ramier

;the purpose of this program is to look at the outputs (AET,RO,P) from the Noah EXP002 and 003 runs that compare
;the difference in heat and moisture fluxes when i mess with the soil layers.

;use EXP002 (4 layers) and EXP003 (6 layers) w/ rfe2..it is better than gdas
indir = strcompress('/jabber/LIS/OUTPUT/EXP002/postprocess/daily/', /remove_all)


var=['albd' , 'ECan' , 'ESol' , 'evap' , 'Ghfl' , 'LWnt',  'PoET',  'Qlhf',  'Qshf',  'Qsub',  'Qsuf',  'rain', $  
     'sm01' , 'sm02' , 'sm03' , 'sm04' , 'SWIx' , 'SWnt' , 'TVeg' , 'wAET' , 'WRSI' , 'WRTS' , 'xtSM']
     
i = where(var eq 'evap')    
ifile = file_search(indir+var[i]+'*200{5,6,7}*.img')

;just one year for starters so they all equal 365
;there are different. for this run:
nx = 16.
ny = 11.
nd = n_elements(ifile) ;365days*3yrs = 1095

ingrid = fltarr(nx,ny)
buffer = fltarr(nx,ny,nd);2007 nd=365

;make yearly stacks of the vars:this upside-down: it must be upper right being near niger river
for j=0,n_elements(ifile)-1 do begin
  openr,1,ifile[j]
  readu,1,ingrid
  ingrid=reverse(ingrid, 2)
  close,1
  buffer[*,*,j]=ingrid
endfor

;I should think about smoothing these to the 15 day moving average and find the cords of the millet/fallow region
if var[i] eq 'rain' then rain=buffer & print, var[i]
if var[i] eq 'Qlhf' then LHFX=buffer & print, var[i]
if var[i] eq 'Qshf' then SHFX=buffer & print, var[i]
if var[i] eq 'PoET' then PoET=buffer & print, var[i]
if var[i] eq 'evap' then AET =buffer & print, var[i]
if var[i] eq 'ESol' then soilEvap =buffer & print, var[i]
if var[i] eq 'TVeg' then transp =buffer & print, var[i]

;I will probably want to look at cummulative rainfall too
;rain(where(rain lt 0))=!VALUES.F_NAN 
;rain = rain*86400 ;convert to mm

AET=AET*86400
mSHFX=sHFX[10,5,*]
mSHFX=reform(mshfx,1095)
smSHX=ts_smooth(mSHFX,15)
p1=plot(smshx, /overplot, 'orange',title='4 layer moving average=cyan, 6 layer moving averge=marroon, blue=shflx 6layers')
 

;PoET=PoET*86400
;SHFX=buffer
;LHFX=buffer
;rain=buffer
;intialize counters
cnt1=0 & cnt2=0 & cnt3=0 & cnt4=0 & cnt5=0 & cnt6=0
;I'd like to look at the early parts of each season so make a cube the is 0-365
ESolcube0=reform(soilEvap[5,5,0:364],365)
ESolcube1=reform(soilEvap[5,5,365:729],365)
ESolcube2=reform(soilEvap[5,5,730:1094],365)

;rcube05=reform(rain[10,5,0:364],365)
;rcube06=reform(rain[10,5,365:729],365)
;rcube07=reform(rain[10,5,730:1094],365)

;which layers did I integrate over for AGU?
scube05=reform(soil[10,5,0:364],365)
scube06=reform(soil[10,5,365:729],365)
scube07=reform(soil[10,5,730:1094],365)

rcube05=reform(AET[10,5,0:364],365)
rcube06=reform(AET[10,5,365:729],365)
rcube07=reform(AET[10,5,730:1094],365)

;ok, now I have to recreate the water balance figure...cummulative rainfall
;for 2006, cummulative evap, non-cum. soil storage, P-E-S
;start the AET at DOY74 
rcum06=fltarr(n_elements(rcube06))
rcum06[0]=rcube06[0]
for i=74,n_elements(rcube06)-1 do begin &$
  rcum06[i]=rcum06[i-1]+rcube06[i] &$
endfor;i


;timeseries for niger
;tevap = evap[xmin:xmax,ymin:ymax,*]
;tQsub = Qsub[xmin:xmax,ymin:ymax,*]
;tQsuf = Qsuf[xmin:xmax,ymin:ymax,*]
;train = rain[xmin:xmax,ymin:ymax,*]
;tTVeg = TVeg[xmin:xmax,ymin:ymax,*]
;tESol = ESol[xmin:xmax,ymin:ymax,*]


;********************************************************************
;totevap = total(tevap[p,q,*]*84600)
;totrain = total(train[p,q,*]*84600)
;totro = total(tqsuf[p,q,*]*84600)+total(tqsub[p,q,*]*86400)
;totsuf = total(tqsuf[p,q,*]*84600)
;totsub = total(tqsub[p,q,*]*86400)
;
;totTveg=total(tTVeg[p,q,*]) ;uh, what is going on here?!
;totEsol=total(tESol[p,q,*]*86400)


print, 'wait here'


end
