pro Niger_yields

;the purpose of this script is to read in the data that i pulled from ENVI to excel (there must be a better way to do that)
;i can also pull this data with the classmap that i generated in ENVI (thanks greg!)
;tomorrow keep working on the crop mask and check out the WRSI results.

;add in the yield data that chris just pointed me to:

;*********************************************************************
;****************try just for national level**************************
;*********************************************************************
;this is the three month average for 2001-2012
afile = file_search('/raid/chg-mcnally/avgAPI_sahel_JJA.img')
wfile = file_search('/raid/chg-mcnally/all_Index_EOS_SAHELwindow.bil');what are the yrs for this? 2000-2011 (is that really what diego sent?)
natfile = file_search('/raid/chg-mcnally/niger_crop_admin2_classmap_merge'); 1=8 bit byte
nfile = file_search('/raid/chg-mcnally/SMest_JJA.img') 

;from hari...
;natyield = [13839,  14090, 11779, 8900,  10576, 12216, 11081]
;FAO stat
natyield = [4615, 4490,  4756,  3636,  4500,  4829,  4509,  5226,  4111,  5299,  4149];(Hg/Ha)

nx = 720
ny = 350
nz = 12 ;for 12 years, these are actually the 3month average (i think) - where did i do this??

classmap = bytarr(nx,ny)
api = fltarr(nx,ny,nz)
smn = fltarr(nx,ny,nz)
wrsi = fltarr(nx,ny,nz)

openr,1,natfile
readu,1,classmap
close,1
classmap = reverse(classmap,2)

openr,1,afile
readu,1,api
close,1

openr,1,nfile
readu,1,smn
close,1

openr,1,wfile
readu,1,wrsi
close,1

;how about just the areas where there are crops? Do I capture drought?
smavg = fltarr(nz)
apiavg = fltarr(nz)
cropavg = fltarr(nz)

  index = where(classmap eq 1, complement=other, count) &$
  for z = 0,nz-1 do begin &$
    soil = smn[*,*,z] &$
    apie = api[*,*,z] &$
    crop = wrsi[*,*,z] &$
    
    smavg[z] = mean(soil(index),dimension = 1,/nan) &$
    apiavg[z] = mean(apie(index),dimension = 1,/nan) &$
    cropavg[z] = mean(crop(index),dimension = 1,/nan) &$
    
  endfor
pad = fltarr(4)
pad[*] = !values.f_nan
natyield = [natyield,pad]

;I guess this works minus the placement of y-axis2
 xticks = ['2001','2002','2003','2004', '2005','2006','2007','2008','2009','2010','2011' ]
p3 = plot((cropavg[1:11])-mean((cropavg[1:10]),/nan),thick = 3,name = 'WRSI',/overplot,  $
         MARGIN = [0.15,0.2,0.15,0.1],linestyle = 1, $
         ;xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         AXIS_STYLE=0, yminor = 0, yrange=[-10,10])
p4 = plot(natyield/100-mean(natyield/100, /nan), thick = 3,name='millet yield', /overplot,AXIS_STYLE=0, yminor = 0,/CURRENT, yrange=[-20,20])        
yax2 = AXIS('Y',LOCATION=[MAX(p3.xrange),0],TITLE='Anomalies: WRSI & yield (hg/ha*100)', $
       TEXTPOS=1,tickfont_size=16, minor = 0, yrange=[-20, 20])
p1 = plot((smavg[0:10]*100-mean(smavg[0:10]*100)), thick = 3,  name = 'NSM', xminor = 0, yminor = 0, linestyle = 2, 'grey', $
         MARGIN = [0.15,0.2,0.15,0.1], $
         ;xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
         xtickname = xticks,$
         YTITLE='Anomalies: API & NSM (%VWC)',AXIS_STYLE=1,/CURRENT)
p2 = plot((apiavg[0:10]*100-mean(apiavg[0:10]*100)), thick = 3, linestyle = 2, 'light grey', name='API', /overplot)

p1.xtickfont_size = 14
p1.ytickfont_size = 14
yax2.tickfont_size = 14
;p1.title = 'Deviations from average: crop zones Niger'
;p1.title.font_size = 24 
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14, color='w', shadow=0)
ax = p2.AXES
;ax[0].TITLE = 'X axis'
;ax[1].TITLE = 'Y axis'
ax[2].HIDE = 1 ; hide top X axis
ax[3].HIDE = 1 ; hide right Y axis

p1.Save, strcompress("/home/mcnally/McNally_Figure8.png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT 


;p1 = plot(cropavg[1:11]/1000)
;p2 = plot(smavg[0:10], /overplot,'g')
;p3 = plot(apiavg[0:10], /overplot,'b')
;p4 = plot(natyield/100000, /overplot,'orange')
;p4.title = '2004 drought yield=orange, wrsi=black, sm_ndvi=green, API=blue'

;xticks = ['2001','2002','2003','2004', '2005','2006','2007','2008','2009','2010','2011' ]
;p3 = plot(cropavg[1:11],thick = 3,name = 'WRSI',/overplot,  $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         ;xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
;         xtickname = xticks,$
;         AXIS_STYLE=0, yminor = 0,/CURRENT)
;p4 = plot(natyield/100, thick = 3, 'b', name='millet yield', /overplot,AXIS_STYLE=0, yminor = 0,/CURRENT)        
;yax2 = AXIS('Y',LOCATION=[MAX(p3.xrange),0],TITLE='WRSI & yield (hg/ha*100)', $
;       TEXTPOS=1)
;p1 = plot(smavg[0:10]*100, thick = 3,  name = 'SM est', xminor = 0, yminor = 0, linestyle = 2, 'g', $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;          ;xtickvalues = [0,  6,  12,  18,  24,  30,  36], $
;         xtickname = xticks,$
;         YTITLE='API & SM est (%VWC)',AXIS_STYLE=1,/CURRENT,/NOERASE)
;p2 = plot(apiavg[0:10]*100, thick = 3, linestyle = 2, 'orange', name='API', /overplot)
;
;p1.xtickfont_size = 14
;p1.ytickfont_size = 18
;yax2.font_size = 18
;p1.title = 'Average conditions over crop zones Niger'
;p1.title.font_size = 24 
;!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14)
;
; 
; rcor_WN = r_correlate(cropavg[1:11],smavg[0:10]) & print, rcor_WN
; rcor_WY = r_correlate(cropavg[1:11],natyield[0:10]) & print, rcor_WY
; rcor_WA = r_correlate(cropavg[1:11],apiavg[0:10]) & print, rcor_WA
; rcor_NA = r_correlate(smavg[0:10],apiavg[0:10]) & print, rcor_NA
; rcor_NY = r_correlate(smavg[0:10],natyield[0:10]) & print, rcor_NY
; rcor_AY = r_correlate(natyield[0:10],apiavg[0:10]) & print, rcor_AY
; 
; ;without wonky 2011...need to figure out if WRSI crashed or if the rain was that little?
; rcor_WN = r_correlate(cropavg[1:10],smavg[0:9]) & print, 'W_N = ', rcor_WN
; rcor_WY = r_correlate(cropavg[1:10],natyield[0:9]) & print, 'W_Y = ', rcor_WY
; rcor_WA = r_correlate(cropavg[1:10],apiavg[0:9]) & print, 'W_A = ', rcor_WA
; rcor_NA = r_correlate(smavg[0:9],apiavg[0:9]) & print, 'N_A = ', rcor_NA
; rcor_NY = r_correlate(smavg[0:9],natyield[0:9]) & print, 'N_Y = ', rcor_NY
; rcor_AY = r_correlate(natyield[0:9],apiavg[0:9]) & print, 'A_Y =',rcor_AY


;admfile = file_search('/jabber/LIS/Data/shp/niger_crop_admin2_classmap'); 1=8 bit byte
;nmfile = file_search('/jabber/chg-mcnally/admin_names_niger_fromenvi.txt')
;nfile = file_search('/jabber/chg-mcnally/filterNDVI_sahel/moncubie/stack_SMest.img')
;afile = file_search('/jabber/LIS/Data/API_sahel/moncubie/stack_API_sahel.img')
;yfile = file_search('/jabber/chg-mcnally/Niger_SM_admin2_yields_ARCorder.csv')
;cfile = file_search('/jabber/LIS/Data/shp/niger_crop_classmap')
;wfile = file_search('/jabber/chg-mcnally/EROS_WRSI/west_Africa/all_Index_EOS_SAHELwindow.bil')
;
;natfile = file_search('/jabber/LIS/Data/shp/niger_crop_admin2_classmap_merge'); 1=8 bit byte
;natyield = [13839,  14090, 11779, 8900,  10576, 12216, 11081]
;
;nx = 720
;ny = 350
;nz = 12 ;for 12 years, these are actually the 3month average (i think)
;
;classmap = bytarr(nx,ny)
;cropmap = bytarr(nx,ny)
;api = fltarr(nx,ny,nz)
;smn = fltarr(nx,ny,nz)
;wrsi = fltarr(nx,ny,nz)
;
;openr,1,natfile
;readu,1,classmap
;close,1
;classmap = reverse(classmap,2)
;temp = image(classmap, rgb_table=4)
;
;openr,1,cfile
;readu,1,cropmap
;close,1
;cropmap = reverse(cropmap,2)
;temp = image(cropmap, rgb_table=4)
;
;openr,1,afile
;readu,1,api
;close,1
;
;;filtered NDVI (SM est from NDVI)
;openr,1,nfile
;readu,1,smn
;close,1
;
;openr,1,wfile
;readu,1,wrsi
;close,1
;
;addname = read_csv(nmfile) & help, addname
;addname = addname.field1
;
;yield = read_csv(yfile) & help, yield ;rows=site, cols=yr 2001-2009
;
;yieldmat = float([[yield.field1], [yield.field2], [yield.field3], [yield.field4], $
;            [yield.field5], [yield.field6], [yield.field7]]) & help, yieldmat
;
;null = where(yieldmat lt 0)
;yieldmat(null) = !values.f_nan
;smavg = fltarr(nz)
;apiavg = fltarr(nz)
;sm_admin = fltarr(n_elements(addname),nz)
;api_admin = fltarr(n_elements(addname),nz)
;
;;gosh, what am i doing here? I think this was supposed to pull for individual adminzones...
;;maybe this was before the classmap was just 0/1
;;for c = 0,n_elements(addname)-1 do begin &$
;;  index = where(classmap eq c+1, complement=other, count) &$
;;  for z = 0,nz-1 do begin &$
;;    
;;    soil = smn[*,*,z] &$
;;    apie = api[*,*,z] &$
;;    
;;    
;;    smavg[z] = mean(soil(index),dimension = 1,/nan) &$
;;    apiavg[z] = mean(apie(index),dimension = 1,/nan) &$
;;    
;;  endfor &$
;;  sm_admin[c,*] = smavg &$
;;  api_admin[c,*] = apiavg &$
;;  
;;endfor  
;
;rcor_an = fltarr(n_elements(addname),2)
;rcor_ay = fltarr(n_elements(addname),2)
;rcor_ny = fltarr(n_elements(addname),2)
;
;;how about just the areas where there are crops? Do I capture drought?
;smavg = fltarr(nz)
;apiavg = fltarr(nz)
;sm_admin = fltarr(8,nz)
;api_admin = fltarr(8,nz)
;
;for c = 0,7 do begin &$
;  index = where(cropmap eq c+1, complement=other, count) &$
;  for z = 0,nz-1 do begin &$
;    soil = smn[*,*,z] &$
;    apie = api[*,*,z] &$
;    
;    smavg[z] = mean(soil(index),dimension = 1,/nan) &$
;    apiavg[z] = mean(apie(index),dimension = 1,/nan) &$
;    
;  endfor &$
;  sm_admin[c,*] = smavg &$
;  api_admin[c,*] = apiavg &$
;  
;endfor  
;;zone 6 doesn't look the same....
;;looks like 2004 is dry and 2007 is dry...the NDVI might be a little more cohesive. 
;
;
;
;;double checked these and i think that i can trust them
;for i = 0,n_elements(addname) -1 do begin &$
; ;p1=plot(sm_admin[i,*], name = addname[i],'g') & print, addname[i]
; ;p1=plot(api_admin[i,*], title = addname[i], /overplot, 'b') 
; ;print, correlate(sm_admin[i,*], api_admin[i,*])
; rcor_an[i,*] = r_correlate(sm_admin[i,0:6], api_admin[i,0:6]) &$
; rcor_ny[i,*] = r_correlate(sm_admin[i,0:6], yieldmat[i,*]) &$
; rcor_ay[i,*] = r_correlate(api_admin[i,0:6], yieldmat[i,*]) &$
; 
; ;print, r_correlate(sm_admin[i,*], api_admin[i,*], /kendall)
;endfor;i




;*********this is when i pulled out the values by hand, i am redoing this part.
;yfile = file_search('/jabber/chg-mcnally/Niger_SM_admin2_yields.csv')
;sfile = file_search('/jabber/chg-mcnally/Niger_SM_admin2.csv')
;yield = read_csv(yfile, missing_value = -999);fields are yrs 2001-2007
;
;yieldmat = [[yield.field1], [yield.field2], [yield.field3], [yield.field4], $
;            [yield.field5], [yield.field6], [yield.field7]] & help, yieldmat
;            
;sm = read_csv(sfile, missing_value = -999.)
;smmat = [[sm.field01], [sm.field02], [sm.field03], [sm.field04], $
;            [sm.field05], [sm.field06], [sm.field07]] 
;            
;;so i want to do rank correlations and have the output be a vector of 30.
;cors = fltarr(n_elements(admin2),2)
;for s = 0, n_elements(admin2)-1 do begin &$
;   cors[s,*] = r_correlate(smmat[s,*], yieldmat[s,*], /kendall) &$
;endfor
;
;;find out which admin zones correlate best
;good = where(cors[*,0] gt 0.4, count)
;print, transpose(admin2(good)), count
