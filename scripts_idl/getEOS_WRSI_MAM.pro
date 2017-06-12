getEOS_WRSI_MAM
;turns out i ran the WRSI for the Belg May2Sept (march?) so it is only for ethiopia.
;Nov29 ran the long rains...
; Use this script for the 1993-present comparisons with shrad.
; make another than does the extra 10 years. 
;this script extracts the WRSI value from Feb 20 of each season and plots it using the WRSI colors
;set path to here or recompile: /raid/chg-users/source/husak/idl_functions/make_wrsi_cmap.pro
;updated on 12/17 to include all of kenya'a admin zones & districts where there are maize yields (for the stats model)
;i may want to set this up so that it outputs the whole csv file rather than me adding columns willy nilly.
;1/2/14 adding in the VIC data...
;1/6/14 i think this is set for export to R
;1/10/14 mask out only the bimodal regions.
;5/13/14 not sure what this masking is about...
;
;;SOS/LGP mask
;;average SOS mask? this looks like the OND season...
;ifile3 = file_search('/home/chg-mcnally/regionmasks/lgp_etw7*.bil');OND
;;ifile3 = file_search('/home/chg-mcnally/regionmasks/ekw7*.bil');MAM
;
;ingrid3 = bytarr(751,801)
;openr,1,ifile3
;readu,1,ingrid3
;close,1
;ingrid3 = reverse(float(ingrid3),2)
;ingrid3(where(ingrid3 eq 60)) = !values.f_nan
;ingrid3(where(ingrid3 eq 0)) = !values.f_nan
;
;;ugh, what is my box again? llat-11.750, urlat22.050, lllon= 22.950, urlon= 51.350
;
;;clip this to WRSI window (or shrad's window), maybe i should round these?
;top = (801-(40-22.05)/0.10)-1 ;179.5
;bot = (40-11.75)/0.10
;left = ((20+22.95)/0.10)-1
;right = ((20+51.350)/0.10)-1
;
;Wmask = ingrid3[left:right, bot:top]
;wmask(where(wmask lt 6.))= !values.f_nan
;wmask(where(wmask gt 9.))= !values.f_nan
;wmask(where(finite(wmask))) = 1.
;
;p1 = image(wmask,image_dimensions=[285/10,339/10], image_location=[23.2,-11.5], $
;           RGB_TABLE=62,  MIN_VALUE=-0.01) 
;c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, $
;              font_size=24)
;  p1 = MAP('Geographic',LIMIT = [-11.5, 23.2,22 ,51], /overplot)
;  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 18 &$
;  p1 = MAPCONTINENTS(/COUNTRIES, thick=2,  COLOR = [120, 120, 120])


;read in the historic WRSI longrains data....if I don't specify the order then don't come out right...
exps=['L83','L84', 'L85','L86','L87','L88','L89','L90','L91','L92','L93','L94', 'L95','L96','L97','L98','L99','L00','L01','L02',$
      'L03','L04','L05','L06','L07','L08','L09','L10','L11','L12', 'L13']

nx = 285
ny = 339
nz = 40

;Just get the EOS WRSI from Nov31 of each year:
ifile11 = strarr(n_elements(exps))
ingrid11 = fltarr(nx,ny,nz)
heos11 = fltarr(nx,ny,n_elements(ifile11))

for i = 0,n_elements(exps)-1 do begin &$
  ff11 = file_search(strcompress('/home/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/????11300000.d01.gs4r', /remove_all)) &$   
  openr,1,ff11 &$
  readu,1,ingrid11  &$
  close,1 &$
  heos11[*,*,i] = ingrid11[*,*,3] &$
endfor

;heos11(where(heos11 ge 253))=!values.f_nan

;ofile = '/home/mcnally/EOS_WRSI_NOV30.1983.2012'
;openw,1,ofile
;writeu,1,heos11
;close,1

 ;******read in dekadal rainfall, and calculate seasonal total*******
 ;;all 36 dekads * 31 years = 1116.
ingrid = fltarr(nx,ny,40)
exprain = fltarr(nx,ny,36,n_elements(exps))
expswi = fltarr(nx,ny,36,n_elements(exps))
;expwrsi = fltarr(nx,ny,36,n_elements(exps))

for i = 0,n_elements(exps)-1 do begin &$  
  ff11 = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/????11300000.d01.gs4r', /remove_all)) &$  
  openr,1,ff11 &$
  readu,1,ingrid11  &$
  close,1 &$
  heos11[*,*,i] = ingrid11[*,*,3] &$ 
  
  ff = file_search(strcompress('/raid/chg-mcnally/LISWRSI_OUTPUT/postprocess/EXP'+exps[i]+'/*.gs4r', /remove_all)) &$  
  for f = 0,n_elements(ff)-1 do begin &$
    openr,1,ff[f] &$
    readu,1,ingrid &$
    close,1 &$
  
    exprain[*,*,f,i] = ingrid[*,*,0] &$
    expswi[*,*,f,i] = ingrid[*,*,7] &$
    ;expwrsi[*,*,f,i] = ingrid[*,*,3] &$
  
  endfor


longrain = total(exprain,3,/nan)


;**read in montly the microwave data...feb to june
;just one month at a time....this is different that the way that shrad's data is formated. 
ifile2 = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_{19,20}??02.tif')
ifile3 = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_{19,20}??03.tif')
ifile4 = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_{19,20}??04.tif')
ifile5 = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_{19,20}??05.tif')
ifile6 = file_search('/raid/chg-mcnally/ECV_soil_moisture/monthly/horn/ECV_SM_{19,20}??06.tif')

nx = 285
ny = 339

stack2 = fltarr(nx,ny, n_elements(ifile2))
stack3 = fltarr(nx,ny, n_elements(ifile3))
stack4 = fltarr(nx,ny, n_elements(ifile4))
stack5 = fltarr(nx,ny, n_elements(ifile5))
stack6 = fltarr(nx,ny, n_elements(ifile6))


for i = 0,n_elements(ifile2)-1 do begin &$
   ingrid2 = read_tiff(ifile2[i],R,G,B,geotiff=geotiff) &$
   stack2[*,*,i] = ingrid2 &$
   
   ingrid3 = read_tiff(ifile3[i],R,G,B,geotiff=geotiff) &$
   stack3[*,*,i] = ingrid3 &$
   
   ingrid4 = read_tiff(ifile4[i],R,G,B,geotiff=geotiff) &$
   stack4[*,*,i] = ingrid4 &$
   
   ingrid5 = read_tiff(ifile5[i],R,G,B,geotiff=geotiff) &$
   stack5[*,*,i] = ingrid5 &$
   
   ingrid6 = read_tiff(ifile6[i],R,G,B,geotiff=geotiff) &$
   stack6[*,*,i] = ingrid6 &$
endfor

;This indexing makes the ECV start at 1983 - 2010
soilfeb = stack2[*,*,3:30]
soilmar = stack3[*,*,3:30]
soilapr = stack4[*,*,3:30]
soilmay = stack5[*,*,3:30]
soiljun = stack6[*,*,3:30]

;******agregate all data by district (except VIC)************
;In envi I subset the GAUL2 shape file by GAUL0=Kenya.then saved it as kenya_admin2_classmap 
;for the 77 districts in kenaya I have data for 39ish
nx = 285
ny = 339

;read in the district map i made in ENVI
classmap = file_search('/home/chg-mcnally/GAULshp/Kenya_Admin2_classmap')
ingrid = bytarr(nx,ny)
openr,1,classmap
readu,1,ingrid
close,1

;districts are numbered 1-77 (0/NAN = unlcassified, outside of kenya)
;the order of these is in "names", Turkana is first, NA, Marsabit
ingrid = float(reverse(ingrid,2))
ingrid(where(ingrid eq 0)) = !values.f_nan

nfile = file_search('/home/chg-mcnally/GAULshp/Kenya_Admin2_namelist.txt')   
names = read_csv(nfile)
names = names.field1
   
;39 districts of interest where i have yield data (in alphabetic order)
Aname = ['Baringo', 'Bomet', 'Buret', 'Embu',  'Isiolo' , 'Kajiado', 'Keiyo', 'Kericho', 'Kiambu' , 'Kirinyaga' ,'Kitui', $
  'Koibatek' , 'Laikipia' , 'Machakos' , 'Makueni', 'Maragua' ,'Marakwet','Marsabit' , 'Mbeere' , 'Meru Central', $
  'Meru North',  'Meru South' ,'Moyale',  'Muranga', 'Mwingi' , 'Nakuru',  'Nandi North', 'Nandi South', 'Narok', 'Nyandarua', $
  'Nyeri' ,'Samburu', 'Tharaka', 'Thika', 'Trans Mara',  'Trans Nzoia' ,'Turkana', 'Uasin Gishu', 'West Pokot']

;so this keeps track of ENVU order, rather than alphabetical order...
codes = fltarr(n_elements(aname))
for d=0,n_elements(aname)-1 do begin &$
  codes[d] = where(names eq string(Aname[d])) &$
endfor

;Turkana, Marsabit, Moyale....
enviorder = names(codes(sort(codes)))

;initialize arrays for average district MW soil moisture Feb-June as well as EOS WRSI and rain total
MW2 = fltarr(n_elements(aname),n_elements(soilfeb[0,0,*]))
MW3 = fltarr(n_elements(aname),n_elements(soilmar[0,0,*]))
MW4 = fltarr(n_elements(aname),n_elements(soilapr[0,0,*]))
MW5 = fltarr(n_elements(aname),n_elements(soilmay[0,0,*]))
MW6 = fltarr(n_elements(aname),n_elements(soiljun[0,0,*]))

rain = fltarr(n_elements(aname),n_elements(soilfeb[0,0,*]))
wrsi = fltarr(n_elements(aname),n_elements(soilfeb[0,0,*]))

;this gives the district's mean (39) for each of the 31 years
;this keeps them in ENVI order 0-38 w/ turkana being first 

;for each district where we have yield data...
for i = 0,n_elements(aname)-1 do begin &$
  ;this finds where ingrid = 1 (turkana)
  dist = where(ingrid eq i+1, count) & print, count &$
  ;for each year...
  for y = 0, n_elements(soilfeb[0,0,*])-1 do begin &$
    ;grab the map for a given year
    buffer2 = soilfeb[*,*,y] &$
    buffer3 = soilmar[*,*,y] &$
    buffer4 = soilapr[*,*,y] &$
    buffer5 = soilmay[*,*,y] &$
    buffer6 = soiljun[*,*,y] &$
  
    buffer7 = heos11[*,*,y] &$
    buffer8 = longrain[*,*,y] &$
  ;take the mean of that district (1=turkana) 
  ;so, now the data is in this array in ENVI order 
  MW2[i,y] = mean(buffer2(dist), /nan) &$
  MW3[i,y] = mean(buffer3(dist), /nan) &$
  MW4[i,y] = mean(buffer4(dist), /nan) &$
  MW5[i,y] = mean(buffer5(dist), /nan) &$
  MW6[i,y] = mean(buffer6(dist), /nan) &$
  
  wrsi[i,y] = mean(buffer7(dist), /nan) &$
  rain[i,y] = mean(buffer8(dist), /nan) &$
  endfor &$
endfor 

;get the anomalies for these datas?using the 1983-2008 mean for the anomalies.
;these are still in ENVI order (turkana = 0) but subset to districts of interest 39 of 77...
anom_rain = fltarr(39,28) ;
anom_wrsi = fltarr(39,28) ;
anom_mw2 = fltarr(39,28) ;
anom_mw3 = fltarr(39,28) ;
anom_mw4 = fltarr(39,28) ;
anom_mw5 = fltarr(39,28) ;
anom_mw6 = fltarr(39,28) ;
dist = strarr(39,28)

;did i have to do another set of re-ordering?
for n = 0, n_elements(rain[*,0])-1 do begin &$  
  dist[n,*] = enviorder[n] &$
endfor

 yr = fltarr(39,28)
 yearvect = indgen(28)+1983
  for i = 0,n_elements(rain[0,*])-1 do begin &$
    anom_rain[*,i] = rain[*,i] - mean(rain[*,0:25],dimension=2,/nan)  &$
    anom_wrsi[*,i] = wrsi[*,i] - mean(wrsi[*,0:25],dimension=2,/nan)  &$
    anom_mw2[*,i] = mw2[*,i] - mean(mw2[*,0:25],dimension=2,/nan)  &$
    anom_mw3[*,i] = mw3[*,i] - mean(mw3[*,0:25],dimension=2,/nan)  &$
    anom_mw4[*,i] = mw4[*,i] - mean(mw4[*,0:25],dimension=2,/nan)  &$
    anom_mw5[*,i] = mw5[*,i] - mean(mw5[*,0:25],dimension=2,/nan)  &$
    anom_mw6[*,i] = mw6[*,i] - mean(mw6[*,0:25],dimension=2,/nan)  &$   
    ;this does repmat(7)
    yr[*,i] = yearvect[i] &$
  endfor

;this just prints out the years of interest and in a single vector for R(envi order turkana=1)
nameout = reform(transpose(dist[*,17:23]),39*7)
yrout = reform(transpose(yr[*,17:23]),39*7)

;raw values
rainout = reform(transpose(rain[*,17:23]),1,39*7)
wrsiout = reform(transpose(wrsi[*,17:23]),1,39*7)
MW2out = reform(transpose(MW2[*,17:23]),1,39*7)
MW3out = reform(transpose(MW3[*,17:23]),1,39*7)
MW4out = reform(transpose(MW4[*,17:23]),1,39*7)
MW5out = reform(transpose(MW5[*,17:23]),1,39*7)
MW6out = reform(transpose(MW6[*,17:23]),1,39*7)

;anomalies
arainout = reform(transpose(anom_rain[*,17:23]),1,39*7)
awrsiout = reform(transpose(anom_wrsi[*,17:23]),1,39*7)
aMW2out = reform(transpose(anom_MW2[*,17:23]),1,39*7)
aMW3out = reform(transpose(anom_MW3[*,17:23]),1,39*7)
aMW4out = reform(transpose(anom_MW4[*,17:23]),1,39*7)
aMW5out = reform(transpose(anom_MW5[*,17:23]),1,39*7)
aMW6out = reform(transpose(anom_MW6[*,17:23]),1,39*7)

;array = [rainout, arainout, wrsiout, awrsiout, MW2out, aMW2out,MW3out, aMW3out,MW4out, aMW4out, MW5out, aMW5out, $
;         MW6out, aMW6out] & help, array

;;;*********clippping Shrad's soil mositure 
;;******************SHRAD's VIC data*******
;smaller domain/differnt and coarser resolution than the other data. where did i reaf_tiff these?
nx = 55
ny = 40
;these data are from 1982 to 2008....make them the same length as the other data? 1983 - 2010? (i no need to pad out to 2013 for this, right?)
ifile = file_search('/home/chg-mcnally/mon_SM2.img')
sm2grid = fltarr(nx,ny,324)

openr,1,ifile
readu,1,sm2grid
close,1

ifile = file_search('/home/chg-mcnally/mon_PCP.img')
PCPgrid = fltarr(nx,ny,324)
openr,1,ifile
readu,1,PCPgrid
close,1

;why did i write these out upside-down? maybe for envi....
sm2grid = reverse(sm2grid,2)
;pad out 2009 and 2010
pad2 = fltarr(55, 40, 24)
pad2[*,*,*]=!values.f_nan
sm2pad = [[[sm2grid]],[[pad2]]]

;********pad out 2009 and 2010 the rainfall doens't look absurdly different....it would be better if i subset my big window to shrad's 
; -1.875 deg S to 7.875 deg N and 36.125 deg E and 49.625 deg E.
pad2 = fltarr(55, 40, 24)
pad2[*,*,*]=!values.f_nan
PCPpad = [[[PCPgrid]],[[pad2]]]
pcp2yr = reform(PCPpad,nx,ny,12,29);i thouht that i had changed the number of yrs here....
long = pcp2yr[*,*,2:10,*]
longtot = total(pcp2yr,3, /nan)
; what is shrad's window??


;requires its own class map becasue it covers a different region and is at 0.25 degree resolution. 
nx = 55
ny = 40

;first i extract by district name....
classmap = file_search('/home/chg-mcnally/GAULshp/Kenya_Admin2_classmap4VIC_SM')
ingrid = bytarr(nx,ny)
openr,1,classmap
readu,1,ingrid
close,1

ingrid = float(reverse(ingrid,2))
ingrid(where(ingrid eq 0)) = !values.f_nan

;i made this txt file w/ awk and the envi header. it seemed to work & match the other classmap. 
nfile = file_search('/home/chg-mcnally/GAULshp/Kenya_Admin2_namelist4VIC.txt')   
names = read_csv(nfile)
names = names.field1

;so I want it to return soil moisture values in this order (I don't care about code perse, just neg -1)
;first, where ingrid = 8 then mean(soil), if -1 skip, skip, where(ingrid eq 21)
codes = fltarr(n_elements(aname))
for d=0,n_elements(aname)-1 do begin &$
  codes[d] = where(names eq string(Aname[d])) &$
endfor

;Shrad's window has 23 districts, as opposed to the full 39
VICdist = Aname(where(codes ne -1))
VICcode = codes(where(codes ne -1))

;sm2pad is 1982-2010 (I only need 1983, so this should be one yr longer than the others, but take it off the front end
soil2 = fltarr(n_elements(aname),n_elements(sm2pad[0,0,*]))
soil2[*,*] = !value.f_nan

;;this gives the district's mean (39) for each of the 31 years
;this will just pull out data for the district of interest from shrad's list. 
;somehow i think i need to be using the codes....
for i = 0,n_elements(aname)-1 do begin &$
  ;identify a district fromt the classmap
  ;these codes allow it to match the order of the other class map. 
  if codes[i] eq -1 then continue &$
  dist = where(ingrid eq codes[i], count) & print, count &$
  for y = 0, n_elements(sm2pad[0,0,*])-1 do begin &$
  buffer = sm2pad[*,*,y] &$
  soil2[i,y] = mean(buffer(dist), /nan) &$
  endfor &$
endfor 

;I need the monthly values for Mar-Jun 2000-2006 4X6 = 24 values. 
;so, just print out 1-5 month indices....
soil2yr = reform(soil2,39,12,29);i thouht that i had changed the number of yrs here....
soil2yr = soil2yr[*,*,1:28]
;this is avg monthly soil moisture at each district, use this to calc. anomalies. 
mean_soil2 = reform(mean(soil2yr, dimension=3, /nan))

as2feb = fltarr(39,28)
as2mar = fltarr(39,28)
as2apr = fltarr(39,28)
as2may = fltarr(39,28)
as2jun = fltarr(39,28)

for i = 0,n_elements(soil2yr[0,0,*])-1 do begin &$
  as2feb[*,i] = soil2yr[*,1,i] - mean_soil2[*,1] &$
  as2mar[*,i] = soil2yr[*,2,i] - mean_soil2[*,2] &$
  as2apr[*,i] = soil2yr[*,3,i] - mean_soil2[*,3] &$
  as2may[*,i] = soil2yr[*,4,i] - mean_soil2[*,4] &$
  as2jun[*,i] = soil2yr[*,5,i] - mean_soil2[*,5] &$
endfor
  
;****************************************************************
 soil2out_feb = reform(transpose(soil2yr[*,1,17:23]),1,39*7)
 soil2out_mar = reform(transpose(soil2yr[*,2,17:23]),1,39*7)
 soil2out_apr = reform(transpose(soil2yr[*,3,17:23]),1,39*7)
 soil2out_may = reform(transpose(soil2yr[*,4,17:23]),1,39*7)
 soil2out_jun = reform(transpose(soil2yr[*,5,17:23]),1,39*7)
 
 asoil2out_feb = reform(transpose(as2feb[*,17:23]),1,39*7)
 asoil2out_mar = reform(transpose(as2mar[*,17:23]),1,39*7)
 asoil2out_apr = reform(transpose(as2apr[*,17:23]),1,39*7)
 asoil2out_may = reform(transpose(as2may[*,17:23]),1,39*7)
 asoil2out_jun = reform(transpose(as2jun[*,17:23]),1,39*7)
 
;print these out later when the yield data is organized.
;ENVU order turkana=0
;array = [transpose(yrout), rainout, arainout, wrsiout, awrsiout, MW2out, aMW2out,  MW3out, aMW3out,  MW4out, aMW4out,   MW5out, aMW5out, $
;         MW6out, aMW6out, soil2out_feb, asoil2out_feb,  soil2out_mar, asoil2out_mar,  soil2out_apr, asoil2out_apr, $
;         soil2out_may, asoil2out_may,  soil2out_jun, asoil2out_jun] & help, array
;;nameout has the order of districts.        
;ofile = '/home/mcnally/var4R.csv'
;write_csv, ofile, array

;*******YIELD DATA****************
;then we have the yield data! rearrage hari' excel spread sheet...to be in the same order as the other data and a format
;that works for R...
ifile = file_search('/home/mcnally/yield4IDL.csv')

hari = read_csv(ifile)
region = hari.field1
admin2 = hari.field2
y00 = float(hari.field3)
y01 = float(hari.field4)
y02 = float(hari.field5)
y03 = float(hari.field6)
y04 = float(hari.field7)
y05 = float(hari.field8)
y06 = float(hari.field9)

;this array is 40x7 -- 39 districts, plus the year (column=0) x 7 years (rows). 
;the first entry here should be....district[0], Baringo[1]
box = [ [y00], [y01], [y02],[y03], [y04],[y05], [y06] ]
year = box[0,*] ;thse are the years, in the first col.
;noyr is 39 (distr) x 7 yrs -- this needs to be reformed for R...

ind = indgen(40)
place = [string(transpose(ind)), transpose(region), transpose(admin2)]

reorder  = fltarr(39)
;this is the order of the districts for the other data....
;hack fixes:
nameout(where(nameout eq 'Buret')) = 'Bureti'
nameout(where(nameout eq 'Meru South')) = 'Meru south'

temp = reform(nameout,7,39)

for i = 0, n_elements(temp[0,*])-1 do begin &$
  ;this is reordering alphabetical....
  reorder[i] = where(place[2,*] eq temp[0,i]) &$
  ;reorder[i] = where(place[2,*] eq aname[i]) &$
endfor

;ok, this seems to work and where name = 'district' there is no data.
re_place = place[*, reorder]
re_box = box[reorder,*]

;R needs these formated in a long string. now match up with the names
yieldout = reform(transpose(re_box),1,39*7)

 ;so, what order are these in? probably in ENVU order turkana=0
array = [transpose(yrout), yieldout, rainout, arainout, wrsiout, awrsiout, MW2out, aMW2out,  MW3out, aMW3out,  MW4out, aMW4out,   MW5out, aMW5out, $
         MW6out, aMW6out, soil2out_feb, asoil2out_feb,  soil2out_mar, asoil2out_mar,  soil2out_apr, asoil2out_apr, $
         soil2out_may, asoil2out_may,  soil2out_jun, asoil2out_jun] & help, array
;nameout has the order of districts.        
ofile = '/home/mcnally/var4R.csv'
write_csv, ofile, array

reg = strarr(7,39)
nam = strarr(7,39)
;also print out the place names...I need them repleted 7 times.
  for i = 0, n_elements(box[0,*])-1 do begin &$
    for j = 0, n_elements(re_place[0,*])-1 do begin &$
    ;num[i,j] = re_place[0,j] &$
    reg[i,j] = re_place[1,j] &$
    nam[i,j] = re_place[2,j] &$
    
  endfor &$
 endfor 
;this just prints out the years of interest and in a single vector (envi order turkana=1)
regout = transpose(reform(reg,39*7))
nout = transpose(reform(nam,39*7))

;name out is from early in the code and isn't missing values like 'nout'.
strout = [regout, transpose(nameout)]
;other headers are...
;rainout, arainout, wrsiout, awrsiout, MW2out, aMW2out,  MW3out, aMW3out,  MW4out, aMW4out,   MW5out, aMW5out, MW6out, aMW6out, soil2out_feb, asoil2out_feb,  soil2out_mar, asoil2out_mar,  soil2out_apr, asoil2out_apr, soil2out_may, asoil2out_may,  soil2out_jun, asoil2out_jun]


;anom_sm2 = fltarr(39,12, 28) ;
;for i = 0,n_elements(rain[0,*])-1 do begin &$
;  anom_sm2[*,i] = soil2[*,i] - mean_soil2  &$
;  district[i] = adminame
;endfor
;print, reform(transpose(anom_sm2[*,17:23]),1,39*7)


;these were for printing to excel....
help,reform(rain[*,17:23] , [wrsi[*,17:23]], [MW[*,17:23]] ]
print, rain[9,*]
print, rain[9,*]-mean(rain[9,*], /nan)


         
;*********ok! finally, count the number of times a region is WRSI below 80******
;how do i merge these two maps??
freq = fltarr(n_elements(admin2))
freqmap = ingrid
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2)-1 do begin &$
    temp = where(wrsi[d,*] ge 80, complement=poor) &$
    freq[d] = n_elements(poor) &$
    freqmap(where(freqmap eq d+1)) = n_elements(poor) &$
  endfor

freqE = fltarr(n_elements(admin2e))
freqmapE = ingride
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2e)-1 do begin &$
    temp = where(ewrsi[d,*] ge 80, complement=poor) &$
    freqE[d] = n_elements(poor) &$
    freqmapE(where(freqmapE eq d+1)) = n_elements(poor) &$
  endfor

;how to I merge these maps? I hope there is no overlap....
merge = total([[[freqmap]], [[freqmape]]], 3,/nan)
;take care of the 7 pixels that overlap
merge2=merge
merge2(where(merge2 gt 31))=31
;padout ingrid to match ECV (for now)
;remove the first pixel along left endge & add one on right edge
;rpad = fltarr(10,ny)
;rpad[*,*] = !values.f_nan
;ingrid=reverse(ingrid,2)
;
;ingrid2=[ingrid[10:284,*],rpad] & help, ingrid2  

;*******FINAL PLOT***********  
;vals = where(finite(merge2), complement = nulls)
;merge2(nulls)=-1
merge2(where(merge2 eq 0))=-31
ncolors = 10    ; set the number of colors in the colorbar
p1 = image(merge2/31, image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=62,  MIN_VALUE=-0.01, MAX_VALUE=1) ; i dumped "transparency".  what the hell is that?
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, $
              font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, 33, 5, 43], /overplot)
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=5,  COLOR = [120, 120, 120])
;************************************** 
  ;VARIANCE MAPS
;ok! finally, count the number of times a region is WRSI below 80
;how do i merge these two maps??
varmap = ingrid
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2)-1 do begin &$
    temp = variance(wrsi[d,*], /nan) &$
    varmap(where(varmap eq d+1)) = temp &$
  endfor

varmapE = ingride
;for y = 0,n_elements(wrsi[0,*])-1 do begin &$
  for d = 0, n_elements(admin2e)-1 do begin &$
    temp = variance(ewrsi[d,*], /nan) &$
    varmapE(where(varmapE eq d+1)) = temp &$
  endfor

;how to I merge these maps? I hope there is no overlap....
mergevar = total([[[varmap]], [[varmape]]], 3,/nan)
;take care of the 7 pixels that overlap
mergevar2=mergevar

;vals = where(finite(mergevar2), complement = nulls)
;mergevar2(nulls)=-1
mergevar2(where(mergevar2 eq 0)) =-1

ncolors = 5   ; set the number of colors in the colorbar
p1 = image(mergevar2, image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5], dimensions=[nx/100,ny/100], $
           RGB_TABLE=62,  MIN_VALUE=-0.05, MAX_VALUE=500) ; i dumped "transparency".  what the hell is that?
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
;rgbdump[*,0] = [255,255,255] ; set map values of zero to white, you can change the color
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, $
              font_size=24)
  p1 = MAP('Geographic',LIMIT = [-5, 33, 5, 43], /overplot)
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 18 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=5,  COLOR = [120, 120, 120])
  
  ;********
  ;
;nx = 285
;ny = 339  
;;it would probably be better to have these all merged...maybe next time.      
;ifile = file_search('/raid/chg-mcnally/Rift_Admin2_classmap')
;ifile2 = file_search('/raid/chg-mcnally/EastCentral_Admin2_classmap')
;
;ingrid = bytarr(nx,ny)
;ingride = bytarr(nx,ny)
;ingridc = bytarr(nx,ny)
;
;openr,1,ifile
;readu,1,ingrid
;close,1
;ingrid = float(ingrid)
;ingrid(where(ingrid eq 0.)) = !values.f_nan
;ingrid = reverse(ingrid,2)
;
;openr,1,ifile2
;readu,1,ingride
;close,1
;ingride = float(ingride)
;ingride(where(ingride eq 0.)) = !values.f_nan
;ingride = reverse(ingride,2)
;
;
;;these match up with results from ENVI.
;Admin2= ['Turkana', 'WestPokot', 'Samburu', 'Baringo', 'Marakwet', 'TransNzoia', 'UasinGishu', 'Laikipia', $
;         'Keiyo','NandiNorth', 'Koibatek', 'Nakuru', 'NandiSouth', 'Kericho', 'Buret', 'Narok', 'Bomet', 'TransMara', 'Kajiado']
;Admin2E =[ 'Marsabit', 'Moyale' , 'Isiolo' , 'MeruNorth' ,'MeruCentral' ,'Nyandarua' ,'Tharaka' ,'Nyeri' ,'Mwingi' , 'Kirinyaga' ,'Embu' , 'MeruSouth',$
;          'Mbeere' , 'Muranga' ,'Maragua' ,'Thika', 'Kiambu' , 'Machakos' , 'Kitui' ,'Makueni']
;;Admin2E = ['Marsabit',  'Moyale',  'Isiolo',  'Meru.north',  'Meru.central',  'Tharaka', 'Mwingi',  'Embu',  'Meru.south' , 'Mbeere',  'Machakos',  'Kitui', 'Makueni']
;;Admin2C = ['Nyandarua','Nyeri', 'Kirinyaga', 'Muranga', 'Maragua', 'Thika Kiambu'
     
   ; attributes: 0=lat, 1=lon, 2=code, 3=code, 4=code, 5=code, 6=country, 7=region, 8=code, 9=district, 10=continent, 11=big-region, 
;   adm_code = vals[userow].attribute_5
;   ; get the timing parameters for this row
;   som = vals[userow].attribute_20
;   eom = vals[userow].attribute_21


;hari alphabet order: ['Kiambu', 'Kirinyaga', 'Maragua', 'Muranga', 'Nyandarua', 'Nyeri', 'Thika']v   
   ; attributes: 0=lat, 1=lon, 2=code, 3=code, 4=code, 5=code, 6=country, 7=region, 8=code, 9=district, 10=continent, 11=big-region, 
;   adm_code = vals[userow].attribute_5
;   ; get the timing parameters for this row
;   som = vals[userow].attribute_20
;   eom = vals[userow].attribute_21


;hari alphabet order: ['Kiambu', 'Kirinyaga', 'Maragua', 'Muranga', 'Nyandarua', 'Nyeri', 'Thika']
;;'0-Turkana', '1-WestPokot', 2-'Samburu',   '3-Baringo', '4-Marakwet', '5-TransNzoia', '6-UasinGishu', '7-Laikipia',   8-'Keiyo',9-'NandiNorth', 
;10-'Koibatek' 11-'Nakuru', 12-'NandiSouth' 13'Kericho', 14-'Buret',   15-'Narok',     16-'Bomet',     17-'TransMara' 18-'Kajiado']

;alphaorder RIFT:
;0/3-Baringo       1/16-Bomet        2/14-Buret      3/18-Kajiado  4/8-Keiyo      5/13-Kericho          6/10-Koibatek 7/7-Laikipia     8/4-Marakwet  9/11-Nakuru  
;10/9/12-Nandi(N/S)  11/15-Narok     12/2-Samburu 13-TransMara 14-TransNzoia      15-Turkana 16-UasinGishu  17-WestPokot
;
;EAST:
;Embu  Isiolo  Kitui Machakos  Makueni Marsabit  Mbeere  Meru Central  Meru North  Meru south  Moyale  Mwingi  Tharaka
;Marsabit Moyale  Isiolo  Meru.north  Meru.central  Tharaka Mwingi  Embu  Meru.south  Mbeere  Machakos  Kitui Makueni (class map order)
;;;EAST
;for i = 0,n_elements(admin2e)-1 do begin &$
;  distE = where(ingride eq i+1, count) & print, count &$
;  for y = 0, n_elements(soil3[0,0,*])-1 do begin &$
;  buffer = soil3[*,*,y] &$
;  buffer2 = heos[*,*,y] &$
;  buffer3 = longrain[*,*,y] &$
;  
;  eMW[i,y] = mean(buffer(distE), /nan) &$
;  ewrsi[i,y] = mean(buffer2(distE), /nan) &$
;  erain[i,y] = mean(buffer3(distE), /nan) &$
;  endfor &$
;endfor
;Aname= ['Turkana', 'West Pokot', 'Samburu', 'Baringo', 'Marakwet', 'Trans Nzoia', 'Uasin Gishu', 'Laikipia', $
;         'Keiyo','Nandi North', 'Koibatek', 'Nakuru', 'Nandi South', 'Kericho', 'Buret', 'Narok', 'Bomet', 'Trans Mara', 'Kajiado', $
;         'Marsabit', 'Moyale' , 'Isiolo' , 'Meru North' ,'Meru Central' ,'Nyandarua' ,'Tharaka' ,'Nyeri' ,'Mwingi' , 'Kirinyaga' ,'Embu' , 'Meru South',$
;         'Mbeere' , 'Muranga' ,'Maragua' ,'Thika', 'Kiambu' , 'Machakos' , 'Kitui' ,'Makueni']


;if I need them in Hari's yield data order...
;alphaMW = [  MW[3,*], MW[16,*], MW[14,*],    MW[18,*], MW[8,*], MW[13,*],    MW[10,*], MW[7,*], MW[4,*], MW[11,*], $
;         transpose(mean([MW[9,*],MW[12,*]],dimension=1,/nan)) , MW[15,*], MW[2,*],    MW[17,*], MW[5,*], MW[0,*], MW[6,*], MW[1,*]  ] 
;
;alphaRN = [  rain[3,*], rain[16,*], rain[14,*],    rain[18,*], rain[8,*], rain[13,*],    rain[10,*], rain[7,*], rain[4,*], rain[11,*], $
;         transpose(mean([rain[9,*],rain[12,*]],dimension=1,/nan)) , rain[15,*], rain[2,*],    rain[17,*], rain[5,*], rain[0,*], rain[6,*], rain[1,*]  ] 
;
;alphaWR = [  wrsi[3,*], wrsi[16,*], wrsi[14,*],    wrsi[18,*], wrsi[8,*], wrsi[13,*],    wrsi[10,*], wrsi[7,*], wrsi[4,*], wrsi[11,*], $
;         transpose(mean([wrsi[9,*],wrsi[12,*]],dimension=1,/nan)) , wrsi[15,*], wrsi[2,*],    wrsi[17,*], wrsi[5,*], wrsi[0,*], wrsi[6,*], wrsi[1,*]  ] 
