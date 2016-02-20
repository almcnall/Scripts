pro AMMAsoilv3
;this will read the files in the 201107210633233198/ that contain all of the soil moisture/CS615 data it will save the data
;if the location is within the RFE2 box: 13.65N to 13.45N, 2.55E to 2.85E
; this script is all for the 110-Wankama sites (millet and jachere) for 2005-2006 at 10,50,100,150,200,250cm soil moisture measurements
;
;1  date
;2 latitude
;3 longitude
;4 altitude
;5 hauteur sol - soil depth (units???)
;6 Soil Moisture/CS615 Period(ms)
;7 Soil Moisture/CS616 Period(?s)
;8 Soil Moisture/CS616 Period at depth 10 cm(?s)
;9 Soil Moisture/CS616 Period at depth 1.5 m(?s)
;10  Soil Moisture/CS616 Period at depth 1 m(?s)
;11  Soil Moisture/CS616 Period at depth 2.5 m(?s)
;12  Soil Moisture/CS616 Period at depth 2 m(?s)
;13  Soil Moisture/CS616 Period at depth 50 cm(?s)
;14  Soil Moisture/CS616 Period at depth 5 cm(?s)
;15  Soil Moisture/CS616 Period at depth 5 cm (2)(?s)
;16  Soil Moisture/Neutron Count Ratio(no unit)
;17  junk

indir= '/jabber/Data/mcnally/AMMASOIL/'
cd, indir

;107: this one is just one station but is inside the rfe2 pixels.
;110: both sites outside the 143 rainfall box by 8km to the north and south (but inside rfe2 grid)
;108: just one station but is inside the rfe2 pixels.
;210: just one station but is inside the rfe2 pixels.
;fname = file_search('{107*,110*,108*,210*}.csv'); come back to this when I am ready for all of them
fname = file_search('110*.csv');

for i=0,n_elements(fname)-1 do begin
  valid = query_ascii(fname[i],info) ;checks compatability with read_ascii
  print, valid
  myTemplate = ASCII_TEMPLATE(fname[i]); 
  ingrid = read_ascii(fname[i], delimiter=';' ,template=myTemplate);
  if i eq 2 then buffer107 = ingrid ;17, 81387, where 17 is a crazy number, not real
  if i eq 1 then buffer108 = ingrid ;17, 1723159
  if i eq 0 then buffer110 = ingrid ;17; 46006 ; changed this when testing just 110
  if i eq 3 then buffer210 = ingrid ;17, 42603

endfor
flag=-9999.9

  ; I want to pull out the lat/lons that are in the RFE2 range
  
  ;datetime107 = buffer107.FIELD01[*]
  datetime110 = buffer110.FIELD01[*]
  
  ;lat107 = buffer107.FIELD02[*] ; 
  lat110 = buffer110.FIELD02[*] ; 
  
  ;lon107 = buffer107.FIELD03[*]
  lon110 = buffer110.FIELD03[*]
  
;datetime108 = buffer108.FIELD01[*];
;datetime210 = buffer210.FIELD01[*];

;lat108 = buffer108.FIELD02[*]
;lat210 = buffer210.FIELD02[*] 

;lon108 = buffer108.FIELD03[*]
;lon210 = buffer210.FIELD03[*]

;where 13.65N to 13.45N, 2.55E to 2.85E
;they are all in the bounds??
;latmax = 13.65
;latmin = 13.45
;lonmax = 2.85
;lonmin = 2.55
;
;index107 = where(lat107 le latmax AND lat107 ge latmin AND $ 
;                 lon107 le lonmax AND lon107 ge lonmin, count)
;                 
;index110 = where(lat110 le latmax AND lat110 ge latmin AND $ 
;                 lon110 le lonmax AND lon110 ge lonmin, count, complement=out)
;                 
;index108 = where(lat108 le latmax AND lat108 ge latmin AND $ 
;                 lon108 le lonmax AND lon108 ge lonmin, count, complement=out);outs=Nan
;                 
;index210 = where(lat210 le latmax AND lat210 ge latmin AND $ 
;                 lon210 le lonmax AND lon210 ge lonmin, count,complement=out);out=Nan

;;***************dealing with duplicate latlons************************
;;; Step 1: Map your columns 2 and 3 into a single unique index
;lat = reform(lat, 1, n_elements(lat))
;lon = reform(lon, 1, n_elements(lon))
;latlons = [lat, lon]
;
;  col1ord = ord(latlons[0,*])
;  col2ord = ord(latlons[1,*])
;  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
;; Step 2: Use histogram to find which ones have the same unique index 
;  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
;; Step 3: Get the first one in each bin, and put back in sorted order 
;  keep = ri[ri[where(h gt 0)]] 
;  keep = keep[sort(keep)] 
;; Step 4: Print/write them out without the nans
;  unqlatlon = latlons[*,keep] 
;  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,50) ;the 50 will have to change when reading other files
;;***********************************************************************

;SM5cm107 = buffer107.FIELD14[*] ;yes,different from X5, why
;SM5cm107 = buffer107.FIELD15[*] ;yes

SM010cm110 = buffer110.FIELD08[*];yes -- do i have these in the right order??
SM150cm110 = buffer110.FIELD09[*];yes
SM100cm110 = buffer110.FIELD10[*];yes
SM250cm110 = buffer110.FIELD11[*];yes
SM200cm110 = buffer110.FIELD12[*];yes
SM050cm110 = buffer110.FIELD13[*];yes

;depth210 = buffer210.field05 ;min = -2440, max=-40.00
;SMNUTRN = buffer210.FIELD16[*];yes
;
;depth108 = buffer108.field05 ;this has the soil depths...
;SM0Xcm108 = buffer108.FIELD06[*];yes, what are these??
;SMXXcm108 = buffer108.FIELD07[*];yes
;SM10cm108 = buffer108.FIELD08[*];yes

;lets start looking at data...file 110 has 2 sites
; I need daily values
; site 1 = 13.6476      2.63370
; site 2 = 13.6440      2.62990 Wankama Mil
site1_110 = where(lat110 eq 13.6476 AND lon110 eq 2.63370, count, complement=site2_110) & print, count
 

yr = intarr(n_elements(datetime110))
mo = intarr(n_elements(datetime110))
dy = intarr(n_elements(datetime110))
doy = intarr(n_elements(datetime110))

for k=0,long(n_elements(datetime110))-1 do begin
  yr[k] = strmid(datetime110[k],0,4)
  mo[k] = strmid(datetime110[k],5,2)
  dy[k] = strmid(datetime110[k],8,2)
  doy[k] = YMD2DN(yr[k], mo[k],dy[k]) ;cool function, this might be good for agregating to daily...
  ;if fix(yr[k]) MOD 4 ne 0 then print ,'no' else print, 'leap'
endfor ;k

 doy(where(yr eq 0)) = flag ; this is an empty line with the platform name.

;so now if doy eq previous day of year add to the buffer, keep a counter and find the average
;*************************************
hcount = 0
dcount = 0
dayindex = string(yr)+string(doy)+string(lat110)
c = rem_dup(dayindex)

SMday010 = fltarr(n_elements(c))
SMday150 = fltarr(n_elements(c))
SMday100 = fltarr(n_elements(c))
SMday250 = fltarr(n_elements(c))
SMday200 = fltarr(n_elements(c))
SMday050 = fltarr(n_elements(c))

buffer010 = 0
buffer150 = 0 
buffer100 = 0
buffer250 = 0
buffer200 = 0
buffer050 = 0

yrdoy010=fltarr(4,n_elements(c))
yrdoy150=fltarr(4,n_elements(c))
yrdoy100=fltarr(4,n_elements(c))
yrdoy250=fltarr(4,n_elements(c))
yrdoy200=fltarr(4,n_elements(c))
yrdoy050=fltarr(4,n_elements(c))

;********************
;seems like a complicated way to aggregate to days if that is what i was thinking...
for l=0, n_elements(datetime110)-1 do begin
  if l eq 23419 then continue 
  if dcount gt (n_elements(c)) then break ;not sure why this has to be ge2
  if hcount eq 1 then begin
  buffer010 = SM010cm110[l]
  buffer150 = SM150cm110[l]
  buffer100 = SM100cm110[l]
  buffer250 = SM250cm110[l]
  buffer200 = SM200cm110[l]
  buffer050 = SM050cm110[l]
  endif
  ;debug
  if (dcount eq 980) or (dcount eq 981) then begin
    print, l, doy[l],dcount,hcount,buffer150,SM010cm110[l],SMday050[dcount] 
  endif
  
  if l eq 0 then test = 1 else $
  if (l eq (n_elements(datetime110)-1)) then test = 2 else $
  if (l gt 0) AND (doy[l] ne doy[l-1]) AND (doy[l] eq doy[l+1]) then test = 1 else $
  if (doy[l] eq doy[l-1]) AND (doy[l] ne doy[l+1]) then test = 2 else $ ;end of the day (does not match the next), take avg 
  if (doy[l] ne doy[l-1]) AND (doy[l] ne doy[l+1]) then test = 3 ;this should take care of the one day values

  CASE test OF 
    1: BEGIN 
         buffer010 = SM010cm110[l]+buffer010; my numbering is not totally consistant here...
         buffer150 = SM150cm110[l]+buffer150
         buffer100 = SM100cm110[l]+buffer100
         buffer250 = SM250cm110[l]+buffer250
         buffer200 = SM200cm110[l]+buffer200
         buffer050 = SM050cm110[l]+buffer050
       END
    2: BEGIN 
         SMday010[dcount] = buffer010/hcount; & dcount++ & hcount = 0
         SMday150[dcount] = buffer150/hcount; & dcount++ & hcount = 0
         SMday100[dcount] = buffer100/hcount; & dcount++ & hcount = 0
         SMday250[dcount] = buffer250/hcount; & dcount++ & hcount = 0
         SMday200[dcount] = buffer200/hcount; & dcount++ & hcount = 0
         SMday050[dcount] = buffer050/hcount; & dcount++ & hcount = 0         
         
         buffer010 = 0 & yrdoy010[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer150 = 0 & yrdoy150[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer100 = 0 & yrdoy100[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer250 = 0 & yrdoy250[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer200 = 0 & yrdoy200[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer050 = 0 & yrdoy050[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];  
         
         dcount++ & hcount = 0        
         
       END
    3: BEGIN 
         SMday010[dcount] = SM010cm110[l]; & dcount++ & hcount = 0 
         SMday150[dcount] = SM150cm110[l]; & dcount++ & hcount = 0 
         SMday100[dcount] = SM100cm110[l]; & dcount++ & hcount = 0 
         SMday250[dcount] = SM250cm110[l]; & dcount++ & hcount = 0 
         SMday200[dcount] = SM200cm110[l]; & dcount++ & hcount = 0 
         SMday050[dcount] = SM050cm110[l]; & dcount++ & hcount = 0 
         
         buffer010=0 & yrdoy010[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];not sure that these need to be repeated...
         buffer150=0 & yrdoy150[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer100=0 & yrdoy100[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer250=0 & yrdoy250[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer200=0 & yrdoy200[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         buffer050=0 & yrdoy050[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
         
         dcount++ & hcount = 0

       END
  ENDCASE
  hcount++ 

endfor ;l

;**************************************
;what if I only want to plot the rainy season? May-Oct DOY:121-274

site1=where(yrdoy010[2,*] eq 13.6476)
site2=where(yrdoy010[2,*] eq 13.6440)

yr1site1 = where((yrdoy010[0,*] eq 2005) AND yrdoy010[2,*] eq 13.6476);Wankama Jachere
yr2site1 = where((yrdoy010[0,*] eq 2006) AND yrdoy010[2,*] eq 13.6476)
yr1site2 = where((yrdoy010[0,*] eq 2005) AND yrdoy010[2,*] eq 13.6440);Wankama Mill
yr2site2 = where((yrdoy010[0,*] eq 2006) AND yrdoy010[2,*] eq 13.6440);

;some stats for the different sites and years
yr1site1mean010=mean(smday010(yr1site1)) & print, yr1site1mean010
yr1site2mean010=mean(smday010(yr1site2)) & print, yr1site2mean010
yr2site1mean010=mean(smday010(yr2site1)) & print, yr2site1mean010
yr2site2mean010=mean(smday010(yr2site2)) & print, yr2site2mean010

yr1site1std010=stdev(smday010(yr1site1)) & print, yr1site1std010
yr1site2std010=stdev(smday010(yr1site2)) & print, yr1site2std010
yr2site1std010=stdev(smday010(yr2site1)) & print, yr2site1std010
yr2site2std010=stdev(smday010(yr2site2)) & print, yr2site2std010

yr1site1mean050=mean(smday050(yr1site1)) & print, yr1site1mean050
yr1site2mean050=mean(smday050(yr1site2)) & print, yr1site2mean050
yr2site1mean050=mean(smday050(yr2site1)) & print, yr2site1mean050
yr2site2mean050=mean(smday050(yr2site2))& print, yr2site2mean050

yr1site1std050=stdev(smday050(yr1site1)) & print, yr1site1std050
yr1site2std050=stdev(smday050(yr1site2)) & print, yr1site2std050
yr2site1std050=stdev(smday050(yr2site1)) & print, yr2site1std050
yr2site2std050=stdev(smday050(yr2site2)) & print, yr2site2std050

yr1site1mean100=mean(smday100(yr1site1)) & print, yr1site1mean100
yr1site2mean100=mean(smday100(yr1site2)) & print, yr1site2mean100
yr2site1mean100=mean(smday100(yr2site1)) & print, yr2site1mean100
yr2site2mean100=mean(smday100(yr2site2)) & print, yr2site2mean100

yr1site1std100=stdev(smday100(yr1site1)) & print, yr1site1std100
yr1site2std100=stdev(smday100(yr1site2)) & print, yr1site2std100
yr2site1std100=stdev(smday100(yr2site1)) & print, yr2site1std100
yr2site2std100=stdev(smday100(yr2site2)) & print, yr2site2std100

yr1site1mean150=mean(smday150(yr1site1)) & print, yr1site1mean150
yr1site2mean150=mean(smday150(yr1site2)) & print, yr1site2mean150
yr2site1mean150=mean(smday150(yr2site1)) & print, yr2site1mean150
yr2site2mean150=mean(smday150(yr2site2)) & print, yr2site2mean150

yr1site1mean200=mean(smday200(yr1site1)) & print, yr1site1mean200
yr1site2mean200=mean(smday200(yr1site2)) & print, yr1site2mean200
yr2site1mean200=mean(smday200(yr2site1)) & print, yr2site1mean200
yr2site2mean200=mean(smday200(yr2site2)) & print, yr2site2mean200

yr1site1mean250=mean(smday250(yr1site1)) & print, yr1site1mean250
yr1site2mean250=mean(smday250(yr1site2)) & print, yr1site2mean250
yr2site1mean250=mean(smday250(yr2site1)) & print, yr2site1mean250
yr2site2mean250=mean(smday250(yr2site2)) & print, yr2site2mean250

;yr1 = where(yr eq 2005 AND DOY gt 121 AND DOY lt 274)
;yr2 = where(yr eq 2006 AND DOY gt 121 AND DOY lt 274)

;p01=plot(SM250cm[0:1000],XTICKNAME=strmid(datetime[0:1000:96],5,5))
;p02=plot(SM05cm[0:1000],/overplot, color='blue')

;print, 'stop'
end