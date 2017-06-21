pro NoahEROS_Ramier_soil

;the purpose of this program is to look at the outputs (AET,RO,P) from the Noah EXP002 and 003 runs that compare
;the difference in heat and moisture fluxes when i mess with the soil layers.

;use EXP002 (4 layers) and EXP003 (6 layers) w/ rfe2..it is better than gdas
;EXP006 is using the shrub vegetation to redo the AGU plots. 
indir = strcompress('/jabber/LIS/OUTPUT/EXP007/postprocess/daily/', /remove_all)

;EXP002
var=['albd' , 'ECan' , 'ESol' , 'evap' , 'Ghfl' , 'LWnt',  'PoET',  'Qlhf',  'Qshf',  'Qsub',  'Qsuf',  'rain', $  
     'sm01' , 'sm02' , 'sm03' , 'sm04' , 'SWIx' , 'SWnt' , 'TVeg' , 'wAET' , 'WRSI' , 'WRTS' , 'xtSM']

;EXP003     
;var=['albd' , 'ECan' , 'ESol' , 'evap' , 'Ghfl' , 'LWnt',  'PoET',  'Qlhf',  'Qshf',  'Qsub',  'Qsuf',  'rain', $  
;     'sm01' , 'sm02' , 'sm03' , 'sm04' ,'sm05' , 'sm06' , 'SWIx' , 'SWnt' , 'TVeg' , 'wAET' , 'WRSI' , 'WRTS' , 'xtSM']

for i=0,n_elements(var)-1 do begin
   ifile = file_search(indir+var[i]+'*200{2,3,4,5,6,7,8,9}*.img')

  ;just one yeat for starters so they all equal 365
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
  if var[i] eq 'rain' then rain=buffer & print, var[i]
  if var[i] eq 'Qlhf' then LHFX=buffer & print, var[i]
  if var[i] eq 'Qshf' then SHFX=buffer & print, var[i]
  if var[i] eq 'PoET' then PoET=buffer & print, var[i]
  if var[i] eq 'evap' then AET =buffer & print, var[i]
  if var[i] eq 'ESol' then soilEvap =buffer & print, var[i]
  if var[i] eq 'TVeg' then transp =buffer & print, var[i]
  if var[i] eq 'sm01' then soil01 =buffer & print, var[i]
  if var[i] eq 'sm02' then soil02 =buffer & print, var[i]
  if var[i] eq 'sm03' then soil03 =buffer & print, var[i]
  if var[i] eq 'sm04' then soil04 =buffer & print, var[i]
;  if var[i] eq 'sm05' then soil05 =buffer & print, var[i]
;  if var[i] eq 'sm06' then soil06 =buffer & print, var[i]
endfor;s

;************water balance plots*******************************
;**************rainfall!*******************
temp=mean(rain,dimension=1)
avgrain=mean(temp,dimension=1)*86400/3 ;uh, why do I need to divide by three to make this ok?
;rcube05=reform(rain[10,5,0:364],365)
rcube06=reform(rain[10,5,365+60:729+60]*86400/3,365);lets make this extend into Mar2007 to match the ramier figs
;rcube07=reform(rain[10,5,730:1094],365)

rcum06=fltarr(n_elements(rcube06))
rcum06[0]=rcube06[0]
for i=0,n_elements(rcube06)-1 do begin &$
  rcum06[i]=rcum06[i-1]+rcube06[i] &$
endfor;i
p1=plot(rcum06,'b')
p1=barplot(rcube06, /overplot,title='cummulative and daily rainfall Mar 2006-Mar 2007')

;**********Total Evaporation********************************
AET=AET*86400

;ecube05=reform(AET[10,5,0:364],365)
ecube06=reform(AET[10,5,365+60:729+60],365)
;ecube07=reform(AET[10,5,730:1094],365)
ecum06=fltarr(n_elements(ecube06))
ecum06[0]=ecube06[0]
for i=90,n_elements(rcube06)-1 do begin &$
  ecum06[i]=ecum06[i-1]+ecube06[i] &$
endfor;i
p1=plot(rcum06,'b', thick=3, /overplot)
p1.name = 'cummulative rainfall'


p2=plot(ecum06,'g',thick=3, /overplot) ;if I put in x3 too much rainfall this should be too high too....
p2.name = 'cummulative evaporation'

;**********soil storage**********************************
totsoil=soil01[10,5,*]+soil02[10,5,*]+soil03[10,5,*]+soil04[10,5,*]
;totsoil=soil01[10,5,*]+soil02[10,5,*]+soil03[10,5,*]+soil04[10,5,*]+soil05[10,5,*]+soil06[10,5,*]

scube06=reform(totsoil[365+60:729+60]-300,365); min at may17 247mm(4 layers), 271(6layers) -- this part changes between runs
scube06[0:77]=0 ;eliminates the early season stuff
p3=plot(scube06, thick=3,'orange', /overplot,yrange=[0,700])
p3.name = 'water storage in top 2m'

;***water balance***********
diff=rcum06-ecum06-scube06
p4=plot(diff, /overplot, thick=2,font_size=20,font_name='times',title='water cycle dynamics crop exp007', ytitle='mm', $
        yrange=[0,700],XTICKV=[30,90,150,210,270,330],XTICKNAME=['Apr06','Jun06','Aug06','Oct06','Dec06','Feb07'])
p4.name = 'Pc-Ec-S'

!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=20, font_name='times') ; not sure how this line works...

;*********************energy balance plots************************
mSHFX=SHFX[10,5,*]
mSHFX=reform(mshfx,1095)
smSHX=ts_smooth(mSHFX,15)
p6=plot(smshx[152:730+152],'orange', thick=3,font_name='times', font_size=20)
p6.name='sensible heat'

mLHFX=LHFX[10,5,*]
mLHFX=reform(mlhfx,1095)
smLHX=ts_smooth(mLHFX,15)
p5=plot(smlhx[152:730+152],/overplot, 'green',title='daily latent and sensible heat flux 15 day moving average crop EXP007', yrange=[0,200],$
        thick=3,font_name='times', font_size=20,XTICKV=[30,210,390,570,750],$
        XTICKNAME=['Jul05','Jan06','Jul06','Jan07', 'Jul07'], ytitle='Wm-2')
p5.name='latent heat flux'

!null = legend(target=[p5,p6], position=[0.2,0.3],font_name='times', font_size=20) ; not sure how this line works...
print, 'wait here'

;plotting stuff
p1=plot(AET[0,0,365:365+364],'b', thick=3,/overplot)
p1=plot(AET[10,10,365:365+364],'m', thick=3, /overplot)
p1.title='evap blue=lower wet corner'  
test=mean(soil02/200, dimension=3)
test=congrid(test,16*25, 11*25)
p1=image(test, /rgb_table)
; Add a colorbar. What should the range be?
cb = COLORBAR(TARGET=p1, ORIENTATION=1, $
POSITION=[0.22,0.05,0.29,0.9], $
TITLE='soil moisture 10-30cm')
p1.title='Noah3.2 EXP07 map of average soil moisture (10cm-30) 2005'



end