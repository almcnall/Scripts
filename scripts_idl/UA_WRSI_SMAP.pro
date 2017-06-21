pro UA_WRSI_SMAP
;modified from RFE_quantiles_SOS
;6/18/14 this code includes my rainfall simulations to quantify the uncertainty associated with ubRFE errors and WRSI errors.
;some of this was shown in Verdin and Klaver (2002), hopefully my results agree
;I was thinking of testing the simulations on 2002 and 2005 since they were obvious wet and dry years in Senegal
;6/25/14 
;7/25/14 moved one of the other UA scripts here. 

;;;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;*********************************************************************
ifile = file_search('/home/sandbox/people/mcnally/ubRFE04.19.2013/dekads/sahel/2*.img');these are 2001-2012

nx = 720
ny = 350
nz = n_elements(ifile);432 = 12*36

ingrid = fltarr(nx,ny)
rcube = fltarr(nx,ny,nz)

;make a big stack and then reform...
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  rcube[*,*,i] = ingrid &$
endfor

RSTDEV_05 = STDDEV(RCUBE,dimension=3, /NAN)*0.5
RVAR = VARIANCE(RCUBE,dimension=3,/NAN)
byyear = reform(rcube,nx,ny,36,12)

;****simulate some rainfall timeseries*******does this start 2001
;pick a random number between +/- 20% and modify the rainfall for a given day by that amount
;2002 and 2005 to see what happens to Senegal
;I want the new range to be from 0.2 to 1.2, width =1, shift by 0.2

yr2002 = byyear[*,*,*,1]
pert = 0.2 ;assume 20% error 
seed = 6
;how do i make this a random number between 1.2 and 0.8 (+/-20%)?
E = randomu(seed,100*36)*0.4+0.8
sims02 = fltarr(nx,ny,36,100)

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
       sims02[*,*,d,y] = yr2002[*,*,d]*E[count] &$
       count++ &$
  endfor &$
endfor

;ofile = '/home/sandbox/people/mcnally/ubfe_2002_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,sims02
;close,1
;tot02 = total(sims02,3)
;p1= plot(tot02[wxind,wyind,*], /overplot)


yr2005 = byyear[*,*,*,4]
pert = 0.4 ;assume 20% error 
seed = 6
E = randomu(seed,100*36)*0.4+0.8
sims05 = fltarr(nx,ny,36,100)

;check and see how this gets read into the WRSI file before writing it out. 

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
       sims05[*,*,d,y] = yr2005[*,*,d]*E[count] &$
       count++ &$
  endfor &$
endfor

;ofile = '/home/sandbox/people/mcnally/ubfe_2005_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,sims05
;close,1

;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
for i = 0,100-1 do begin &$
  temp = plot(sims05[wxind,wyind,*,i], /overplot) &$
endfor

;*****************************************************************************
;**********soil moisture simulation with the original data (not scaled)********

lfile = file_search('/home/chg-mcnally/sm0x2grid_720.250.396_2001.2011.bin')
mfile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'); this needs to be divided by 10,000 for VWC (or 100 for %)

;typical file dimensions
nx = 720
ny = 350
nz = 431
yy = 250

SM0Xgrid = fltarr(nx,yy,396)

openr,1,Lfile
readu,1,sm0xgrid
close,1

sm02cube = reform(sm0xgrid,nx,ny,36,11)
sm2002 = sm02cube[*,*,*,1]
seed = 6
E = randomu(seed,100*36)*0.4+0.8
simsSM02 = fltarr(nx,ny,36,100)

;check and see how this gets read into the WRSI file before writing it out.

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
  simsSM02[*,*,d,y] = sm2002[*,*,d]*E[count] &$
  count++ &$
endfor &$
endfor

mpawcube = fltarr(nx,ny,36,10)

openr,1,mfile
readu,1,mpawcube
close,1
mpawgrid = reform(mpawcube,720,350,360)

;pad this out so it is as long as the other time series. 2001-2011?
pad = fltarr(nx,350,36)
pad[*,*,*] = !values.f_nan
mpawgrid = [ [[mpawgrid]], [[pad]] ]
mpawcube = reform(mpawgrid, nx, 350, 36,11)

nx = 720
ny = 350

sm02cube = reform(mpawgrid,nx,ny,36,11)
sm2002 = sm02cube[*,*,*,4]
seed = 6
E = randomu(seed,100*36)*0.4+0.8
simsSM02 = fltarr(nx,ny,36,100)

;check and see how this gets read into the WRSI file before writing it out.

count = 0
for y = 0,100-1 do begin &$
  for d = 0, 36-1 do begin &$
    simsSM02[*,*,d,y] = sm2002[*,*,d]*E[count] &$
    count++ &$
  endfor &$
endfor


;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
for i = 0,100-1 do begin &$
  temp = plot(simsSM02[wxind,wyind,*,i]/100, /overplot) &$
endfor

ofile = '/home/sandbox/people/mcnally/ECVMWorg_2005_sim_720.350.36.100.bin'
openw,1,ofile
writeu,1,simsSM02
close,1

;ofile = '/home/sandbox/people/mcnally/NOAH1m_2005_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,simsSM05
;close,1



;***********soil moisture simulations************************
;ifile = file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img');not sure what this looks like
;
;
;nx = 720
;ny = 350
;nz = 396; 2001-2010 that is what it says in the /home/chg-mcnally/ECV_soil_moisture/dekads/sahel
;
;;this can be used for sm01, sm02
;;WRSI appears to be very high for SM0X3...
;MW0X  = fltarr(nx,ny,nz)
;;sm0X = fltarr(nx,ny,36,11); 2001-2011
;openr,1,ifile
;readu,1,MW0X
;close,1
;
;MWcube = reform(MW0x,nx,ny,36,11)
;MW02 = MWcube[*,*,*,4] ;and 2005
;seed = 6
;E = randomu(seed,100*36)*0.4+0.8
;simsMW02 = fltarr(nx,ny,36,100)
;
;;check and see how this gets read into the WRSI file before writing it out.
;
;count = 0
;for y = 0,100-1 do begin &$
;  for d = 0, 36-1 do begin &$
;  simsMW02[*,*,d,y] = MW02[*,*,d]*E[count] &$
;  count++ &$
;endfor &$
;endfor
;
;
;;nx,ny,dek,yr is an acceptable format. Then i won't have to re-form
;for i = 0,100-1 do begin &$
;  temp = plot(simsMW02[wxind,wyind,*,i], /overplot) &$
;endfor
;
;ofile = '/home/sandbox/people/mcnally/ECVSM_2005_sim_720.350.36.100.bin'
;openw,1,ofile
;writeu,1,simsMW02
;close,1


;july 14, 2014 - now i need to figure out how to analyze the outputs,...
;I guess that I do these with raw values for now and not anomalies. I think I have to mask out places with no variability like in kenya
;
;ifile = file_search('/home/sandbox/people/mcnally/wrsi_grid_2005_750.350.sim100.img')
ifile = file_search('/home/sandbox/people/mcnally/wrsi_grid_2002_750.350.sim100.img')


map_ulx = -20.00 & map_lrx = 52
map_uly =  30.00 & map_lry = -5
;greg's way of nx, ny-ing
ulx = (180.+map_ulx)*10. & lrx = (180.+map_lrx)*10.
uly = (50.-map_uly)*10. & lry = (50.-map_lry)*10.
gNX = lrx - ulx
gNY = lry - uly

NX = 720
NY = 350
NS = 100

ingrid = fltarr(nx,ny,ns)
openr,1,ifile
readu,1,ingrid
close,1

;***************************************
;*********67th percentile******************************
;probability that a pixel in 2013 is above the historic 67th percentile (1/2 stdev).
;for the forecasts comparisons ajust by eoswrsi[9:293,0:338,*]...this seems to aligh better [0:290,5:338,*]
;these results look the same as they did with the old data...
;EOSWRSI = eoswrsi[9:293,0:338,*]
;why doesn't this really work? it seems like everything is wet wet wet!

EOSWRSI = ingrid

eoswrsi(where(eoswrsi le 0, count)) = !values.f_nan & print, count
eoswrsi(where(eoswrsi ge 253, count)) = !values.f_nan & print, count ;non of these were produced in IDL WRSI

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

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

x = wxind
y = wyind
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

  ;  per75 = sorted(index75) &$
  ;  h75[x,y] = per75 &$
  ;
  ;  per25 = sorted(index25) &$
  ;  h25[x,y] = per25 &$

  ;****now count the number of ensemble members that are above/below***
  ;so something funny happens here.
  ;1. sort the values.
  ;2. count the number of values above/below percentile.

  wet67 = where(eosWRSI[x,y,*] ge per67, count67) &$
  dry33 = where(eosWRSI[x,y,*] le per33, dcount33) &$

  prob67[x,y] = float(count67)/100. &$
  prob33[x,y] = float(dcount33)/100. &$

  ;  wet = where(eosWRSI[x,y,*] ge per75, count1) &$
  ;  dry = where(eosWRSI[x,y,*] le per25, dcount1) &$
  ;
  ;  prob75[x,y] = float(count1)/100. &$
  ;  prob25[x,y] = float(dcount1)/100. &$

endfor  &$;x
endfor;y

;what was the green-brown color bar that i used for the pptx? 66? blue/red = 72
;fix up this one to match other mappies.
prob25(where(prob25 eq 1))=!values.f_nan
prob75(where(prob75 eq 1))=!values.f_nan

prob67(where(prob67 eq 1))=!values.f_nan
prob33(where(prob33 eq 1))=!values.f_nan

;map_ulx = 22.05 & map_lrx = 51.35
;map_uly = 22.95 & map_lry = -11.75



ncolors = 7
w = WINDOW(WINDOW_TITLE='Plotting Stuff',DIMENSIONS=[600,600])
p1 = image(prob33, image_dimensions=[NX/10,NY/10], image_location=[map_ulx,map_lry], $
  RGB_TABLE=74, MIN_VALUE=0.01,max_value=0.75, title = 'Prob of Sept30 WRSI below 33th percentile', /CURRENT)
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
p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)



;***********soil moisture simulations************************
ifile = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI.img')
mfile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img')


;nx = 720
;ny = 350
;nz = 396; 2001-2011
;
;;this can be used for sm01, sm02
;;WRSI appears to be very high for SM0X3...
;SM0X  = fltarr(nx,ny,nz)
;;sm0X = fltarr(nx,ny,36,11); 2001-2011
;openr,1,ifile
;readu,1,SM0X
;close,1




;***rainfall mask****************
;ifile = file_search('/home/chg-mcnally/RAINmask.img')
;mask = fltarr(NX,NY)
;openr,1,ifile
;readu,1,mask
;close,1
;
;mask(where(mask gt 0)) = 1
;;repeat the mask however many times i need to fill out the matrix
;mask = rebin(mask,nx,ny,396)

