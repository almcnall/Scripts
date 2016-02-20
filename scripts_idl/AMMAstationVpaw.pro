pro AMMAstationVpaw
;this compares the station data vs WRSI PAW
;this code includes my rainfall simulations to quantify the uncertainty associated with ubRFE and station rainfall at Wankama.
;5/2/13: re-checking station-PAW vs observed soil moisture.
;
;******NIGER DATA******************
;this reads in the clim and dynamic SOS to be compared to the SM observations
;Make and SOS array so that it is easy to swap out climSOS and dynSOS
LGP = 10 ;Niger LGP = 10, Mali LGP = 7
nYR = 4
SOS = intarr(nYR)

;static/climatological SOS
;SOS[*] = 17 ;Niger SOS is 17 (Mali is 19)

;dynamic SOS 2001 to 2011, correlation is much better without the minus one....
SOS = [18, 18, 14]

;ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_avgTKWK06.11.csv')
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')
WK14 = read_csv(ifile[0])
WK47 = read_csv(ifile[1])
WK71 = read_csv(ifile[2])

sarray = transpose([[wk14.field1],[wk47.field1],[wk71.field1]]) & help, sarray
scube = reform(sarray*100,3,36,6);soil moisture data only from 2006 anyway...

;read in the ubRFE-PAW
ifile = file_search('/jabber/chg-mcnally/WKPAW_wfill_2006_2008_SOS.16.18.18.14_LGP16.csv')
;ifile = file_search('/jabber/chg-mcnally/WKPAW_wfill_2006_2008_SOS.16.18.18.14.csv')
;ifile = file_search('/jabber/chg-mcnally/WKPAW_q75_2005_2008_SOS.15.18.17.13.csv')
;ifile = file_search('/jabber/chg-mcnally/WKPAW_q50_2005_2008_SOS.15.19.17.13.csv')
;ifile = file_search('/jabber/chg-mcnally/WKPAW_q25_2005_2008_SOS.15.19.17.17.csv')
;ifile = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.15.19.17.17.csv')

;*****special case of using RFE with the station SOSs*************
;ifile13 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.13.13.13.13.csv')
;ifile14 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.14.14.14.14.csv')
;ifile15 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.15.15.15.15.csv')
;ifile16 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.16.16.16.16.csv')
;ifile17 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.17.17.17.17.csv')
;ifile18 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.18.18.18.18.csv')
;ifile19 = file_search('/jabber/chg-mcnally/WKPAW_RFE_2005_2008_SOS.19.19.19.19.csv')
;
;paw13 = read_csv(ifile13)
;paw14 = read_csv(ifile14)
;paw15 = read_csv(ifile15)
;paw16 = read_csv(ifile16)
;paw17 = read_csv(ifile17)
;paw18 = read_csv(ifile18)
;paw19 = read_csv(ifile19)

;invent my own time series here:
;(1) 15,19,17,13
;(2) 15,18,17,14
;the winning combo:
;SOS = [18, 18, 14]
;pcube = transpose([[paw15.field1],[paw18.field2],[paw17.field3],[paw17.field4]])
;****************************************************************
paw = read_csv(ifile) ; 12 fields (dekads) x 10 years (just changed this I think it is better...)
;skipping 2005 (field1) since we don't have observations. Might want to use it for station PAW/NSM compare.
pcube = transpose([[paw.field2], [paw.field3],[paw.field4]])

;****make a time series of the paw filling in the correct spaces 36*3 = 108 2006-2008
;***figure 1 paper 2******
PAWTS = fltarr(36,3)
;****2006******
PAWTS[0:16,0] = !values.f_nan
PAWTS[17:32,0] = paw.field2 & help, pawts
PAWTS[33:35,0] = !values.f_nan
;***2007*******
PAWTS[0:16,1] = !values.f_nan
PAWTS[17:32,1] = paw.field3
PAWTS[33:35,1] = !values.f_nan
;***2008*****
PAWTS[0:16,2] = !values.f_nan
PAWTS[13:28,2] = paw.field4
PAWTS[29:35,2] = !values.f_nan

;ugh, what is up with the one dekad shift?
p1 = plot(reform(PAWts,1,108), thick = 3, name = 'Station-PAW')
p2 = plot(wk14.field1[0:107]*1000, /overplot, 'orange', name = 'obs SM', title = 'station PAW (mm) vs obs WKwest SM (10-40cm)*1000 (%VWC), 2006-2008')
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14) ;

;read in the NSM data
;I need to re-do this again with the new NDVI data, prolly just repeat the last dekad of december so that i have n+1
ffile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img')

nx = 720
ny = 350
nz = 424

ingrid = fltarr(nx,ny,nz)

openr,1,ffile
readu,1,ingrid
close,1

pad = fltarr(nx,ny,432-nz)
pad[*,*,*] = !values.f_nan

nsm12 = [[[ingrid]],[[pad]]]
nsmgrd = reform(nsm12,nx,ny,36,12)

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

nsm0508 = reform(nsmgrd[wxind,wyind,*,4:7])

;*********station tester**************
PAW05 = pcube[0,*]
NSM05 = nsm0508[SOS[0]:SOS[0]+LGP-1,0]

;S06 = scube[0,SOS[0]:SOS[0]+LGP-1, 0]
PAW06 = pcube[1,*]
NSM06 = nsm0508[SOS[1]:SOS[1]+LGP-1,1]

;S07 = scube[0,SOS[1]:SOS[1]+LGP-1, 1]
PAW07 = pcube[2,*]
NSM07 = nsm0508[SOS[2]:SOS[2]+LGP-1,2]
;I think that the early SOS f's this one up
;S08 = scube[0,SOS[2]:SOS[2]+LGP-1, 2]
PAW08 = pcube[3,*]
NSM08 = nsm0508[SOS[3]:SOS[3]+LGP-1,3]

;*****************Figure 1 paper2********************************
p00 = plot(PAW05/15, 'g',linestyle=2,thick=2, /overplot,name='2005, R=0.55')
p0 = plot(NSM05*150, 'g',linestyle=3,thick=2, /overplot)
tmp = regress(reform(PAW05),reform(NSM05), correlation = corr, sigma=sigma) & print, corr
;p1 = plot(S06,thick=3, 'r', name='2006, R=0.41')
p2 = plot(PAW06/15, 'r',linestyle=2,thick=2, name='2006, R=0.48', /overplot)
p3 = plot(NSM06*150, 'r',linestyle=3,thick=2, /overplot)
;tmp = regress(s06,reform(NSM06), correlation = corr, sigma=sigma) & print, corr
tmp = regress(reform(PAW06),reform(NSM06), correlation = corr, sigma=sigma) & print, corr

;p4=plot(S07,thick=3, 'orange', name='2007, R=0.80',/overplot)
p5 = plot(PAW07/15, 'orange',linestyle=2,thick=2, /overplot,name='2007, R=0.64')
p6 = plot(NSM07*150, 'orange',linestyle=3,thick=2, /overplot)
;tmp = regress(S07,reform(NSM07), correlation = corr, sigma=sigma) & print, corr
tmp = regress(reform(PAW07),reform(NSM07), correlation = corr, sigma=sigma) & print, corr

;p7 = plot(S08,thick=3, 'b', name = '2008, R=0.42', /overplot)
p8 = plot(PAW08/15, 'b',linestyle=2, thick=2,/overplot,name = '2008, R=0.61')
p9 = plot(NSM08*150, 'b',linestyle=3, thick=2,/overplot)
;tmp = regress(S08,reform(NSM08), correlation = corr, sigma=sigma) & print, corr
tmp = regress(reform(PAW08),reform(NSM08), correlation = corr, sigma=sigma) & print, corr

;null = legend(target=[p1,p4,p7], position=[0.2,0.3],font_size=16, font_name='times') 
;p1.title='WK14(solid), NSM*150(dash),FIX_SOS=19,17,17, LGP=10'

null = legend(target=[p00,p2,p5,p8], position=[0.2,0.3],font_size=16, font_name='times') 
p2.title='NSM*150, RFE_PAW/15(dash),SOS=15,18,17,17, 14, LGP=10'
;*********************************************************************
;***************************Rainfall SIM******************************
;****************difference between station and UBRFE*************************
;*****I can look at a host of other stations if i need to in the 132 file ****
;*****************************************************************************
ifile = file_search('/jabber/LIS/Data/ubRFE04.19.2013/dekads/sahel/2*.img');these are 2001-2012

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

;Wankama 2006 - 2011 (13.6456,2.632 ) ;this is the soil moisture station, what are the rainfall stations?
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5.) / 0.10)

;west: (13.6455°N, 2.6211°E) >all in the same RFE pixel, shew!
;wxindw = FLOOR((2.6211 + 20.) / 0.10)
;wyindw = FLOOR((13.6455 + 5.) / 0.10)
;
;;east (13.6496°N,2.6964°E)
;wxinde = FLOOR((2.6964 + 20.) / 0.10)
;wyinde = FLOOR((13.6496 + 5.) / 0.10)

;reform to get 2005-2008
rdek = rcube[wxind,wyind,*]
rainyrly = reform(rdek,36,12) ;
wk0508 = reform(rainyrly[*,4:7],144)

;******try with the station rainfall**********
ifile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_dekads.csv')
efile = file_search('/jabber/chg-mcnally/AMMARain/RFE_and_station_dekads.csv');2005-2008, station & rfe
wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_filled_dekads.csv');2006-08

wrain = read_csv(wfile)
irain = read_csv(ifile)
erain = read_csv(efile)

wS = float(wrain.field1)
eS = float(erain.field1)

;****fix missed values******
;ws[0:35] = !values.f_nan
;ws[81:92] = !values.f_nan
;
;good = where(finite(ws), complement=fill, count) & help, fill
;ws(fill)=es(fill)
;
;ofile = '/jabber/chg-mcnally/AMMARain/wankamaWest_station_filled_dekads.csv'
;write_csv,ofile,ws
;****************************
wdiff = wk0508-wS & nve, wdiff

;ws and es are correlated at 0.95
WB1 = regress(wk0508,wS,correlation=corr,const=const,sigma=sigma,yfit=yfit ) & print, corr ;0.86 w/out 2008, 0.79
;EB1 = regress(wk0508[0:107],eS[0:107],correlation=corr,const=const,sigma=sigma,yfit=eyfit ) & print, corr ;0.82

;try this for each year? 2008 was a tough year to detect...
;wB105 = regress(wk0508[0:35], wS[0:35],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;e0.82;w0.82
;wB106 = regress(wk0508[36:71], wS[36:71],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;e0.92;w0.94
;wB107 = regress(wk0508[72:107], wS[72:107],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;e0.77;w0.84
;wB108 = regress(wk0508[108:143], wS[108:143],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;e0.73;w0.67

;calculate the root mean sq error
werr = mean((yfit-wS)^2)^0.5 & mve, werr
stderr = werr/mean(wS(where(ws ne 0)),/nan) & print, stderr ;0.433 ugh, this is bigger than ever, oh well.

;****simulate some rainfall timeseries*******
Sarry = fltarr(5,144)
whisdat = fltarr(2,144)
rsim = fltarr(1000000,144)

for i = 0,1000000-1 do begin &$  
  E = stderr*randomn(seed,144) &$ 
  rsim[i,*] = (const+wb1[0]*wk0508) * (1.0+E)   &$ 
endfor

rsim(where(rsim lt 0))=0
rsim2 = rsim
;make a loop for sorting each dekad
for i = 0,n_elements(rsim[0,*])-1 do begin &$
  ;this sorts the timeseries into their rank means/totals...now find the 25th and 75th percentiles
   index = sort(rsim[*,i]) &$
   rsim2[*,i] = rsim[index,i] &$
endfor 
rsim2 = rsim2[index,*]
rsim3 = rsim
rsim3 = rsim3[index,*]
;the minimum
sarry[0,*]=rsim2[0,*]

quant25 = long(n_elements(rsim2[*,0])-1)*0.25 & print, quant25
sarry[1,*] = rsim2[quant25,*]

;quant50 does match median when sort by dekad
quant50 = long(n_elements(rsim2[*,0]))*0.5 & print, quant50
sarry[2,*] = rsim2[quant50,*]
  med = median(rsim2,dimension=1)
quant75 = long(n_elements(rsim2[*,0])-1)*0.75 & print, quant75
sarry[3,*] = rsim2[quant75,*]
;the max
sarry[4,*] = rsim2[n_elements(rsim2[*,0])-1,*]
;cgHistoplot, rsim, BINSIZE=1.

;ofile = strcompress('/jabber/chg-mcnally/Sim_Rainfall_quantiles_RFE_station_wankama.csv')
;write_csv, ofile,sarry

;plot the rainfall envelops
p1 = plot(sarry[1,*],'r', name = '25th percentile')
p2 = plot(sarry[2,*],'orange', name = '50th percentile', /overplot)
p3 = plot(sarry[3,*],'g', name = '75th percentile', /overplot)
null = legend(target=[p1,p2,p3], position=[0.2,0.3],font_size=16, font_name='times') 
p2.title='Simulated rainfall, 25/50/75th percentiles, Wankama West'


;************MALI**********************************************
;**************************************************************
;read in the Agoufou data
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Agoufou*{0.7,0.6}*csv')

A106 = read_csv(ifile[0])
A206 = read_csv(ifile[1])

;A06 = mean([transpose(float(A106.field1)), transpose(float(A206.field1))], dimension=1, /nan)*100
A06 = float(a106.field1)

;read in the stationPAW
ifile = file_search('/jabber/chg-mcnally/AGPAW_2005_2008_SOS.20.18.19.20_LGP16.csv')
paw = read_csv(ifile) ; 7fields (dekads) x 12 years
array = [[temp.field1],[temp.field2], [temp.field3],[temp.field4]]

;ok, which dekads do i need to pull out of the AG soil moisture time series?
;SOS = dek19, LGP=7, we should really know RFE, station, and calculated SOS...
help, A06

;****make a time series of the paw filling in the correct spaces 36*3 = 108 2006-2008
;***figure 1 paper 2******
PAWTS = fltarr(36,4)
;****2005******
PAWTS[0:18,0] = !values.f_nan
PAWTS[19:34,0] = paw.field1 & help, pawts
PAWTS[35] = !values.f_nan
;***2006*******
PAWTS[0:16,1] = !values.f_nan
PAWTS[17:32,1] = paw.field2
PAWTS[33:35,1] = !values.f_nan
;***2007*****
PAWTS[0:17,2] = !values.f_nan
PAWTS[18:33,2] = paw.field3
PAWTS[34:35,2] = !values.f_nan
;****2008******
PAWTS[0:18,3] = !values.f_nan
PAWTS[19:34,3] = paw.field4 & help, pawts
PAWTS[35] = !values.f_nan

;ugh, what is up with the one dekad shift?
p1 = plot(reform(PAWts,1,144), thick = 3, name = 'Station-PAW')
p2 = plot(float(A106.field1)*2000, /overplot, 'c', name = 'obs SM', title = 'station PAW (mm) vs obs AG SM (10-40cm)*1000 (%VWC), 2006-2008')
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14) ;

;figure out how to automate the SOS
AG05 = A06[18:18+6, 0]
PAW05 = buffer[4,*]

AG06 = A06[20:20+6, 1]
PAW06 = buffer[5,*]

AG07 = A06[19:19+6, 2]
PAW07 = buffer[6,*]

AG08 = A06[20:20+6, 3]
PAW08 = buffer[7,*]

p1=plot(AG05,thick=3, 'r')
p1=plot(PAW05/15, 'r', linestyle=2,/overplot)
;I have to redo these regressions sinve they are all off bya  dekad...prollt fix figs too?
tmp = regress(AG05,reform(PAW05), correlation = corr, sigma=sigma) & print, corr, sigma; 0.35/0.08
print, r_correlate(AG05,PAW05);0.35

p1=plot(AG06,thick=3, 'orange', /overplot)
p1=plot(PAW06/15, 'orange',linestyle=2, /overplot)
tmp = regress(AG06,reform(PAW06), correlation = corr, sigma=sigma) & print, corr, sigma ;-0.05, 0.003

p1=plot(AG07,thick=3, 'g', /overplot)
p1=plot(PAW07/15, 'g',linestyle=2, /overplot)
tmp = regress(AG07,reform(PAW07), correlation = corr, sigma=sigma) & print, corr, sigma;0.37, 0.8

p1=plot(AG08,thick=3, 'b', /overplot)
p1=plot(PAW08/15, 'b',linestyle=2, /overplot)
tmp = regress(AG08,reform(PAW08), correlation = corr, sigma=sigma) & print, corr, sigma;0.73, -0.63

p1.title='Agoufou 2005-2008 (red-blue), dash = PAW/15, solid=obs, SOS=18-20, LGP=7'
