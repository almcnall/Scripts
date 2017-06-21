pro EA_MAM_monitor

;6/13/14: copy & modify from  getEOS_percentiles_EastAfrica.pro
;6/27/14 contiue with SSudan analysis...
;Small grains WRSI using rainfall to date + May 28-Sept 30 
;rainfall from each year of the RFE climatology and the typical WRSI SOS decision r
   
;********get the different SOS outputs from April 30 - this will help illuminate some differences 
;in the SOS representation - not sure if there is a too-late-to-start option in LIS-WRSI
;If SOS>climSOS+LGP*0.4 then X,Y=no start (254)

;make an SOS mask from the SOSclim file: ./GeoWRSI_PARAMS/data/Africa/SOS/eew7033dt
ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/EA_MAY2NOV_SOS_inst_CHIRPS_monitor_APR30.nc')
fileID = ncdf_open(ifile, /nowrite) &$
sosID = ncdf_varid(fileID,'SOS_inst') &$
ncdf_varget,fileID, sosID, SOS
dims = size(SOS, /dimensions)
NX = dims[0]
NY = dims[1]
;********************************************************
;Sept 30 outcomes per Chris H. request
ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/LIS7/EA_MAY2NOV_WRSIinst_CHIRPS_monitor_SEP30.nc')
fileID = ncdf_open(ifile, /nowrite) &$
wrsiID = ncdf_varid(fileID,'WRSI_inst') &$
ncdf_varget,fileID, wrsiID, WRSI
dims = size(WRSI, /dimensions)
NX = dims[0]
NY = dims[1]

.compile '/home/source/mcnally/scripts_idl/make_cmap.pro'

;East africa domain
map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75
;greg's way of nx, ny-ing
;ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.-1
;uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.-1
;NX = lrx - ulx + 2 ;not sure why i have to add 2...
;NY = lry - uly + 2

med_wrsi = median(WRSI,dimension=3)
med_wrsi(where(med_wrsi eq -9999.0))=!values.f_nan

ncolors=30
p1 = image(med_wrsi[0:290,5:338,*], image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MIN_VALUE=5, $
            title = 'median expected Sept30 WRSI as of June1')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
 
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;*********67th percentile******************************
;probability that a pixel in 2013 is above the historic 67th percentile (1/2 stdev).
;for the forecasts comparisons ajust by eoswrsi[9:293,0:338,*]...this seems to aligh better [0:290,5:338,*]
;these results look the same as they did with the old data...
;EOSWRSI = eoswrsi[9:293,0:338,*]
EOSWRSI = wrsi

eoswrsi(where(eoswrsi lt -999, count)) = !values.f_nan & print, count
eoswrsi(where(eoswrsi ge 253, count)) = !values.f_nan & print, count

dims = SIZE(eosWRSI, dimension=1)
nx = dims[0]
ny = dims[1]
nz = dims[2]

prob67 = fltarr(nx,ny)
prob33 = fltarr(nx,ny)

prob75 = fltarr(nx,ny)
prob25 = fltarr(nx,ny)

h67 = fltarr(nx,ny)
h33 = fltarr(nx,ny)
h75 = fltarr(nx,ny)
h25 = fltarr(nx,ny)

;ranks position of the 67th and 33rd percentiles
index67 = (nz-1)*0.67
index33 = (nz-1)*0.33
index75 = (nz-1)*0.75
index25 = (nz-1)*0.25

for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
    ;skip nans
    test = where(finite(EOSWRSI[x,y,*]),count) &$
    if count eq -1 then continue &$

    ;look at one pixel time series at a time 
     pix = EOSWRSI[x,y,*] &$      
     ;this sorts the historic timeseries from smallest to largest
        index = sort(pix) &$
        sorted = pix(index) &$
     ;then find the index of the 67th percentile
        
        ;return the value
        per67 = sorted(index67) &$
        h67[x,y] = per67 &$
        
        per33 = sorted(index33) &$
        h33[x,y] = per33 &$
        
        per75 = sorted(index75) &$
        h75[x,y] = per75 &$

        per25 = sorted(index25) &$
        h25[x,y] = per25 &$
        
        ;****now count the number of ensemble members that are above/below****FIX THIS
;        wet = where(eosWRSI[x,y,*] ge per67, count1) &$
;        dry = where(eosWRSI[x,y,*] le per33, dcount1) &$
       
        wet = where(eosWRSI[x,y,*] ge per75, count1) &$
        dry = where(eosWRSI[x,y,*] le per25, dcount1) &$
          
;        prob67[x,y] = float(count1)/30. &$
;        prob33[x,y] = float(dcount1)/30. &$

       prob75[x,y] = float(count1)/30. &$
       prob25[x,y] = float(dcount1)/30. &$
          
  endfor  &$;x
endfor;y

;what was the green-brown color bar that i used for the pptx? 66? blue/red = 72
;fix up this one to match other mappies.
prob25(where(prob25 eq 1))=!values.f_nan
prob75(where(prob75 eq 1))=!values.f_nan

prob67(where(prob67 eq 1))=!values.f_nan
prob33(where(prob33 eq 1))=!values.f_nan

map_ulx = 22.05 & map_lrx = 51.35
map_uly = 22.95 & map_lry = -11.75

ncolors = 7
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[600,600])
  p1 = image(prob67, image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], $
            RGB_TABLE=74, MIN_VALUE=0.01,max_value=0.75, title = 'Prob of Sept30 WRSI above 67th percentile', /CURRENT)
rgbind = reverse(FIX(FINDGEN(ncolors)*255./(ncolors-1)))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]

;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
;p1.rgb_table = reverse(rgbdump,2)  ; reassign the colorbar to the image
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.06,0.7,0.09], font_size=24)

;  
p1 = MAP('Geographic',LIMIT = [map_lry,map_ulx,map_uly ,map_lrx], /overplot)

;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18   
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;***********and the 'observed 2014/2011 end-of-season**********
;this bit of code needs some work June 3, 2014
obsEOS = eosWRSI[*,*,29]; 32=2013/2014 29=2010/11

;show what percentile each pixel in 2013/14 is in in the context of the 30 yr record
PEOS = fltarr(nx,ny)
for x = 0, nx-1 do begin &$
  for y = 0, nx-1 do begin &$
    ;skip nans
    test = where(finite(EOSwrsi[x,y,0:31]),count) &$
    if count eq -1 then continue &$

    ;look at one pixel time series at a time 
     pix = EOSwrsI[x,y,0:31] &$      
     pix = [transpose(pix),obsEOS[x,y] ] &$
     ;this sorts the historic timeseries from smallest to largest
        index = sort(pix) &$
        sorted = pix(index) &$
       val = where(obsEOS1011[x,y] eq sorted, count) &$
       if val[0] eq -1 then continue &$
       pEOS[x,y] = float(val[0])/n_elements(index) &$
   endfor &$
 endfor

;why does this one alighn ok?
ncolors = 10
  p1 = image(pEOS, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=72, MIN_VALUE=0,max_value=1, title = 'observed percentile')
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)

;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18   
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)    
     
;***********************************************************

;ugh, too bad these images are not the same size....
;next calculate the anomalies and the differences.
diffNov15 = med_feos15 - OBSEOS[9:293,0:338]
diffNov1 = med_feos1 - OBSEOS[9:293,0:338]


ncolors = 10
p1 = image(diffNov15*mask, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[285/10,339/10],image_location=[22.95,-11.75], $
            min_value=-40, max_value=40, title='Nov15 vs OBS diff')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
 
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;calculate the anomalies...make sure this is right before using it....
;OBSEOS[9:293,0:338]
anom1 = (med_feos1/med_heos)*100
anom15 = (med_feos15/med_heos)*100
anomOBS = (obseos[9:293,0:338]/med_heos)*100

;anomaly plot
ncolors = 10
 p1 = image(byte(anomOBS), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),MIN_VALUE=50, max_value=150,title = 'OBS anomalies LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

; diff between anoms
diff_anomNov1 =  anom1-anomOBS
diff_anomNov15 =  anom15-anomOBS

ncolors = 10
 p1 = image(diff_anomNov1, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
            RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),min_value=-100, max_value=100,title = 'Nov1 anom_diff LIS-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  
tmpclr = p1.rgb_table
tmpclr[*,0] = [211,211,211]
p1.rgb_table = tmpclr
;  
p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])


;ok, what do i want to do? what is the median outcome of the Nov1 forecasts?
;take the average of each map and sort them?

;exps=['083','084', '085','086','087','088','089','090','091','092','093','094', '095','096','097','098','099','100','101','102',$
;      '103','104','105','106','107','108','109','110','111','112']
;ifile = strarr(n_elements(exps))
;for i = 0,n_elements(exps)-1 do begin &$
;  ff = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/????02{28,29}0000.d01.gs4r', /remove_all)) &$
;  ifile[i] = ff &$
;endfor
;nx = 285 ;294, 348 ugh different dimensions
;ny = 339
;nz = 40
;ingrid = fltarr(nx,ny,nz)
;heos = fltarr(nx,ny,n_elements(ifile))
;for i=0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid  &$
;  close,1 &$
;  
;  heos[*,*,i] = ingrid[*,*,3] &$
;endfor

;i shouldn't need this part anymore..now that historic and actual matchup
;what percentile was the actual observed WRSI?
;CHIRPS
;ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/201402_WRSI_CHIRPS/LIS_HIST_201402280000.d01.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;obsEOSID = ncdf_varid(fileID,'WRSI_inst') &$
;ncdf_varget,fileID, obsEOSID, obsEOS 
;OBSeos(where(OBSeos ge 253))=!values.f_nan
;OBSeos(where(OBSeos lt 0))=!values.f_nan

;CHIRPS
;ifile = file_search('/home/chg-mcnally/LISWRSI_OUTPUT/201102_WRSI_CHIRPS/LIS_HIST_201102280000.d01.nc')
;fileID = ncdf_open(ifile, /nowrite) &$
;obsEOSID = ncdf_varid(fileID,'WRSI_inst') &$
;ncdf_varget,fileID, obsEOSID, obsEOS 
;OBSeos(where(OBSeos ge 253))=!values.f_nan
;OBSeos(where(OBSeos lt 0))=!values.f_nan

;;***********and the 'observed 2010/11 end-of-season**********
;;what percentile was the actual observed WRSI?
;
;;calculate percent of normal with historic...get this on the same grid (again)
;temp = image(obsEOS)
;;where is this calculation? above?
;
;ncolors = 10
;  p1 = image(pEOS, image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
;            RGB_TABLE=72, MIN_VALUE=0,max_value=1, title = 'observed percentile in OND 2010/11')
;rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
;rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
;rgbdump[*,0] = [200,200,200]
;;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
;p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;
;;  
;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
;p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18   
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2) 



;;NYY is the Nov 15 forecast 
;exps15=['N00','N01','N02','N03','N04','N05','N06','N07','N08','N09','N10','N11','N12','N13','N14', 'N15','N16','N17','N18','N19', $
;      'N20','N21','N22','N23','N24','N25','N26','N27','N28','N29' ]
;
;;this grabs the end-of-season forecast from each of the simulations
;ifile = strarr(n_elements(exps1))
;for i = 0,n_elements(exps1)-1 do begin &$
;  ff = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps15[i]+'/201402200000.d01.gs4r', /remove_all)) &$
;  ifile[i] = ff &$
;endfor
;
;nx = 285
;ny = 339
;nz = 40
;ingrid = fltarr(nx,ny,nz)
;feos15 = fltarr(nx,ny,n_elements(ifile))
;
;for i=0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid  &$
;  close,1 &$
;  
;  feos15[*,*,i] = ingrid[*,*,3] &$
;endfor
;
;;i don't want the flags in there when i compute the median...
;;feos15(where(feos15 ge 253))=!values.f_nan
;
;med_feos15 = median(feos15,dimension=3)
;;
;;;! figure out how to put back in the colors to match EROS (maybe take an average and impose that?)
;p1 = image(byte(med_feos15), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
;            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'median forecast LIS-WRSI: Nov 15')
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;  
;tmpclr = p1.rgb_table
;tmpclr[*,0] = [211,211,211]
;p1.rgb_table = tmpclr  
;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
;p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
;
;exps1=['F00','F01','F02','F03','F04','F05','F06','F07','F08','F09','F10','F11','F12','F13','F14', 'F15','F16','F17','F18','F19', $
;      'F20','F21','F22','F23','F24','F25','F26','F27','F28','F29' ]      
;
;;this grabs the end-of-season forecast from each of the simulations, maybe i should be looking at the 2nd dek in Feb just in case.
;
;ifile = strarr(n_elements(exps1))
;indir = '/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/'
;for i = 0,n_elements(exps1)-1 do begin &$
;  ff = file_search(strcompress(indir+'EXP'+exps1[i]+'/201402200000.d01.gs4r', /remove_all)) &$
;  ifile[i] = ff &$
;endfor
;
;nx = 285
;ny = 339
;nz = 40
;ingrid = fltarr(nx,ny,nz)
;feos1 = fltarr(nx,ny,n_elements(ifile))
;
;for i=0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid  &$
;  close,1 &$
;  
;  feos1[*,*,i] = ingrid[*,*,3] &$
;endfor
;
;;looks better without this line. nice to see the no starts
;;feos1(where(feos1 ge 253))=!values.f_nan
;med_feos1 = median(feos1,dimension=3)
;
;p1 = image(byte(med_feos1), image_dimensions=[285/10,339/10], image_location=[22.95,-11.75], $
;            RGB_TABLE=make_wrsi_cmap(),MIN_VALUE=0, title = 'median forecast LIS-WRSI: Nov 1')
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
;  
;tmpclr = p1.rgb_table
;tmpclr[*,0] = [211,211,211]
;p1.rgb_table = tmpclr
;;  
;p1 = MAP('Geographic',LIMIT = [-10, 24,10 ,51], /overplot)
;p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18
;p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

