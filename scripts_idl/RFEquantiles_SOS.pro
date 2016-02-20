pro RFEquantiles_SOS
;this code includes my rainfall simulations to quantify the uncertainty associated with ubRFE and station rainfall at Wankama.
;this script is to classify how confident we are in a location's SOS. If we are not so confident
;we will refer to the NSM to pick the 'best' SOS.

;*********************************************************************
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
;*****do it the fake way by adding 0.71 and 0.77 percent to the time series and then calculating the SOS.
q25 = rcube*0.71
q75 = rcube*1.41
q50 = rcube
ofile = strcompress('/jabber/chg-mcnally/AMMARain/UBRFE_cube4WRSI_q50.img')
openw,1,ofile
writeu,1,q50
close,1

;******Calculate the standard error **********
;;;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)
;;reform to get 2005-2008
;rdek = rcube[wxind,wyind,*]
;rainyrly = reform(rdek,36,12) ;
;wk0508 = reform(rainyrly[*,4:7],144)
;
;wfile = file_search('/jabber/chg-mcnally/AMMARain/wankamaWest_station_filled_dekads.csv');2006-08
;wrain = read_csv(wfile)
;wS = float(wrain.field1)
;WB1 = regress(wk0508,wS,correlation=corr,const=const,sigma=sigma,yfit=yfit ) & print, corr ;0.86 w/out 2008, 0.79
;
;;;try this for each year? 2008 was a tough year to detect...
;;;wB105 = regress(wk0508[0:35], wS[0:35],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;w0.82
;;;wB106 = regress(wk0508[36:71], wS[36:71],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;w0.94
;;;wB107 = regress(wk0508[72:107], wS[72:107],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;w0.84
;;;wB108 = regress(wk0508[108:143], wS[108:143],correlation=corr,const=const,sigma=sigma, yfit=yfit) & print, corr ;w0.67
;;
;;;calculate the root mean sq error
;werr = mean((yfit-wS)^2)^0.5 & mve, werr
;stderr = werr/mean(wS(where(ws ne 0)),/nan) & print, stderr
;****simulate some rainfall timeseries*******
;****the lat/lons of the station of interest...
stderr = 0.433
wb1 = 1.17581
const = 1.72292

;make the NANs -9999s so I can skip them
good = where(finite(rcube), complement = nulls)
rcube(nulls) = -999.
q25map = fltarr(nx,ny,nz)
q25map[*,*,*] = !values.f_nan
q50map = q25map
q75map = q25map

for x = 270, nx-1 do begin 
  for y = 0, ny-1 do begin 
    ;skip nans
    print, x
    test = where(rcube[x,y,*] eq -999., count)
    if count gt 0 then continue  
   
    ;look at one pixel time series at a time 
    rdek = rcube[x,y,*] &$
    ;simulate a lotta time series    
      rsim = fltarr(1000000,432)
      for i = 0,1000000-1 do begin &$  
        E = stderr*randomn(seed,432) &$ 
        rsim[i,*] = (const+wb1*rdek) * (1.0+E)   &$ 
      endfor
      rsim(where(rsim lt 0)) = 0
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
     Sarry = fltarr(3,432)

     quant25 = long(n_elements(rsim2[*,0])-1)*0.25
     sarry[0,*] = rsim2[quant25,*]

;quant50 does match median when sort by dekad
     quant50 = long(n_elements(rsim2[*,0]))*0.5 
     sarry[1,*] = rsim2[quant50,*]
     quant75 = long(n_elements(rsim2[*,0])-1)*0.75 & print, quant75
     sarry[2,*] = rsim2[quant75,*]
;so then I have an sarray for each pixel...make a separate map for each?
    q25map[x,y,*] = sarry[0,*]
    q50map[x,y,*] = sarry[1,*]
    q75map[x,y,*] = sarry[2,*]
  endfor;x
endfor;y
;ofile = strcompress('/jabber/chg-mcnally/q25map.csv')
;write_csv, ofile,q25map
print, 'hold'
end


