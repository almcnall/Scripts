pro AMMAsoilvMatlab
;the purpose of this script is to arrange the data from the stations into monthly averages
;so that I can put them into matlab (monthly averages by year...) so there should be 50 data points for each 
; month over 4 years

;1  date
;2 latitude
;3 longitude
;4 altitude
;5 hauteur sol - soil depth (units???) *
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

;*************read in data***************
indir= '/jabber/Data/mcnally/AMMASOIL/'
cd, indir
fname = file_search('210*.csv');

  valid = query_ascii(fname,info) ;checks compatability with read_ascii
  print, valid
  myTemplate = ASCII_TEMPLATE(fname); go to line 41
  buffer210 = read_ascii(fname, delimiter=';' ,template=myTemplate);
  flag=-9999.9

  ; I want to pull out the lat/lons that are in the RFE2 range

datetime210 = buffer210.FIELD01[*]
yr = fix(strmid(datetime210,0,4))
mo = fix(strmid(datetime210,5,2))
dy = fix(strmid(datetime210,8,2))
good = where(yr ne 0 AND mo ne 0 AND dy ne 0, complement=name)
yr(name) = flag
mo(name) = flag
dy(name) = flag

doy = YMD2DN(yr, mo,dy)
  
lat210 = buffer210.FIELD02[*] 
lon210 = buffer210.FIELD03[*]
depth210 = buffer210.field05 ;min = -2440, max=-40.00
SMNUTRN = buffer210.FIELD16[*];yes


;;***************dealing with duplicate latlons************************
;; Step 1: Map your columns 2 and 3 into a single unique index
lat210 = reform(lat210, 1, n_elements(lat210))
lon210 = reform(lon210, 1, n_elements(lon210))
latlons = [lat210, lon210]

  col1ord = ord(latlons[0,*])
  col2ord = ord(latlons[1,*])
  index = col1ord + (max(col1ord)+1)*col2ord ;this turns the 2 cols into a single unique index
; Step 2: Use histogram to find which ones have the same unique index 
  h = histogram(index, reverse_indices=ri) ;list of subscripts that contribute to each bin
; Step 3: Get the first one in each bin, and put back in sorted order 
  keep = ri[ri[where(h gt 0)]] 
  keep = keep[sort(keep)] 
; Step 4: Print/write them out without the nans
  unqlatlon = latlons[*,keep] 
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,50) ;the 50 will have to change when reading other files
;;***********************************************************************
print, 'pause here, pls'
;************groups of soil moisture****************
;upper left, this is where 30/50 stations are...too bad only 5 rainfall stations...looks like I'll need to regrid.
;uldays=fltarr(1565)
;ulindex=where(unqlatlon[0,*] gt 13.55 AND unqlatlon[1,*] lt 2.65, count)
;for a=0,n_elements(ulindex)-1 do uldays(a)=where(lat210 eq unqlatlon[0,ulindex(a)] AND lon210 eq unqlatlon[1,ulindex(a)])
;
;;upper center
;ucindex=where(unqlatlon[0,*] gt 13.65 AND unqlatlon[0,*] lt 13.75 AND unqlatlon[1,*] gt 2.65 AND unqlatlon[1,*] lt 2.75, count);count=0
;
;;lower center
;lcindex=where(unqlatlon[0,*] lt 13.55 AND unqlatlon[1,*] gt 2.65 AND unqlatlon[1,*] lt 2.75, count)& print, count
;;lower right
;lrindex=where(unqlatlon[0,*] lt 13.55 AND unqlatlon[1,*] gt 2.75, count)& print, count
;;lower left
;llindex=where(unqlatlon[0,*] lt 13.55 AND unqlatlon[1,*] lt 2.65, count)& print, count
;*******************************************************************

;*********find depths at each site.**************************************
;k=0
;meas_z=fltarr(n_elements(unqlatlon[0,*]),28) ;50 sites, with max of 13 depths 
;meas_z[*,*] = flag ;fills in the places where no depth measurements are...alt I could use 
;for i=0,n_elements(unqlatlon[0,*])-1 do begin
;    m_depths = depth210(where(lat210 eq unqlatlon[0,i] AND lon210 eq unqlatlon[1,i]));finds all the depths recorded
;    unqindex = rem_dup(m_depths); finds the first index of the unique values
;    buffer = m_depths[unqindex] ;returns the non-duplicate measurement depths ranging from 12-14
;     for j=0,n_elements(buffer)-1 do begin
;       meas_z[i,k]=buffer[j]
;       k++
;       if k eq n_elements(buffer) then continue
;     endfor ;j
;     k=0
;endfor;i

;depths of interest
DOIS=[-40.0, -65., -90., -140., -190., -240., -340.] 
movec=[1,2,3,4,5,6,7,8,9,10,11,12]
yrvec=[2005,2006,2007,2008]
outarr=fltarr(6,45,n_elements(DOIS),n_elements(unqlatlon[0,*]));6vars,12*3+9=45,7,50
outarr[*,*,*,*]=flag ;initalizes the array to -9999 since there will be empty spaces the first time
l=0
m=0
n=0
p=0
q=0
r=0

;this organizes the data by station & depth and gives the monthly average (for export to matlab)
for l=0,n_elements(unqlatlon[0,*])-1 do begin ;for each lat lon 50 of these 
  for m=0,n_elements(DOIS)-1 do begin; for each depth of interest 7 of these...
    q=0
    for n=0,n_elements(yrvec)-1 do begin;for each yr from 2005 to 2008 4 of these ;maybe could replace these with 'where's
     for p=0,n_elements(movec)-1 do begin;for each month 12 of these
        
        sindex = where(lat210 eq unqlatlon[0,l] AND lon210 eq unqlatlon[1,l] AND yr eq yrvec[n] $
                      AND mo eq movec[p] AND depth210 eq DOIS[m],count)
        if count eq 0 then continue
        moavg = mean(smnutrn(sindex)) ;eak now this is super wrong! come back later....
        outarr[*,q,m,l]=[lat210(sindex[0]),lon210(sindex[0]),yrvec[n], movec[p],moavg,DOIS[m]]
        q++ ;advaces row in outarr if there are values in there. 
        r++ ;advance but never reset
      endfor;p
    endfor;n
  endfor;m
endfor;l

print, 'hold here'

;write out 7 files to be read into matlab for spatial stats analysis -- but this did not happen, how did I do it before?
;vars,n_rows,depth,station
;for q=0, n_elements(DOIS)-1 do begin
q=2
  lat=outarr[0,*,q,*]
  lon=outarr[1,*,q,*]
  yrs=outarr[2,*,q,*]
  mos=outarr[3,*,q,*]
  momean = outarr[4,*,q,*]
  depth = outarr[5,*,q,*]

; ofile=strcompress('/home/mcnally/lischeck/soil'+strmid(DOIS[q],6,2)+'_matlab.csv')
;  write_csv,ofile,lat,lon,yrs,mos,momean,depth
;endfor; q   

;is the stuff below here relevant?
print, 'hold here'

sindex = where(lat210 eq unqlatlon[0,0] AND lon210 eq unqlatlon[1,0] AND yr eq 2005 AND mo eq 1 AND depth210 eq -65., count)
print, count
print, [reform(lat210(sindex),1,n_elements(sindex)), reform(lon210(sindex),1,n_elements(sindex)),$
        reform(yr(sindex),1,n_elements(sindex)),reform(mo(sindex),1,n_elements(sindex)),reform(dy(sindex),1,n_elements(sindex)),$
        reform(smnutrn(sindex),1,n_elements(sindex))] 
moavg = mean(smnutrn(sindex))
print, lat210(sindex[0]), lon210(sindex[0]), yr(sindex[0]), mo(sindex[0]),moavg
  
        
       

;initialize output array and other stuff
vars = ['lat210','lon210','yr','doy','depth210','smnutr']
;dates = 365*3 ;days*number of yrs this will be too big....
;outdat=fltarr(n_elements(unqlatlon[0,*]), n_elements(meas_z[0,*]),n_elements(vars),dates)
;outdat[*,*,*,*] = flag
;l=0;site loop
;m=0;measurement depth loop
;p=0;days of measurement loop
;  for l=0,n_elements(unqlatlon[0,*])-1 do begin
;  ;for each depth
;    for m=0,n_elements(meas_z[0,*])-1 do begin
;      if meas_z[l,m] eq -9999.9 then continue ;meas_z is a list of the different potential depths...
;      index=where(lat210 eq unqlatlon[0,l] and lon210 eq unqlatlon[1,l] and depth210 eq meas_z[l,m])
;    
;       for n=0,n_elements(index)-1 do begin
;        outdat[l,m,*,p] = [lat210[l], lon210[l], yr(index[n]),doy(index[n]),depth210(index[n]),smnutrn(index[n])] ;index is going to be of variable length...
;        p++
;        if p eq n_elements(index) then continue
;       endfor;n
;       p=0
;      n = n_elements(index)        
;      print, [reform(yr(index),1,n), reform(doy(index),1,n),reform(depth210(index),1,n), $
;              reform(smnutrn(index),1,n)]  ;very irregular spacing of days....why and how do i deal with this?     
;    endfor;m
;   print, 'hi'
;  endfor;l
;
;;so now I want all soil moisture for 2005
;; print, SM at first site,first depth,and all days (I happen to know it is 59
;;c=where(yr eq 2006 AND depth210 eq -90 AND mo eq 12 AND lon210 lt 2.7, count) & print, count  
;c=where(yr eq 2006 AND depth210 eq -90 AND mo eq 12, count) & print, count  
;
;print, [reform(yr(c),1,n_elements(c)), reform(mo(c),1,n_elements(c)), $
;        reform(doy(c),1,n_elements(c)),reform(lat210(c),1,n_elements(c)), reform(lon210(c),1,n_elements(c)),$
;        reform(depth210(c),1,n_elements(c)),reform(smnutrn(c),1,n_elements(c))]
;print, mean(reform(smnutrn(c),1,n_elements(c)))       
;print, stdev(reform(smnutrn(c),1,n_elements(c))) 
;      
;site1_depth1 = where(lat210 eq unqlatlon[0,0] AND lon210 eq unqlatlon[1,0] AND depth210 eq -40.0);how do I know how
;site1_depth2 = where(lat210 eq unqlatlon[0,0] AND lon210 eq unqlatlon[1,0] AND depth210 eq meas_z[1]);many depths per site?
;
;site2_depth1 = where(lat210 eq unqlatlon[0,1] AND lon210 eq unqlatlon[1,1] AND depth210 eq -40.0);many depths per site?
;
;;tester
;n=n_elements(site1_depth1)
;;for i=0,n-1 do print,STRING(FORMAT='(I6.4,F10.2,F,F)',yr(i)
;;print,TRANSPOSE([[yr(site1_depth1)],[doy],[dept210],[smnutrn]])
;print, [reform(yr(site1_depth1),1,n), reform(doy(site1_depth1),1,n),reform(depth210(site1_depth1),1,n), $
;        reform(smnutrn(site1_depth1),1,n)]  ;very irregular spacing of days....why and how do i deal with this?
;
;n=n_elements(site2_depth1)        
;print, [reform(yr(site2_depth1),1,n), reform(doy(site2_depth1),1,n),reform(depth210(site2_depth1),1,n), $
;        reform(smnutrn(site2_depth1),1,n)]  ;very irregular spacing of days....why and how do i deal with this?
;
;n=n_elements(index)        
;print, [reform(yr(index),1,n), reform(doy(index),1,n),reform(depth210(index),1,n), $
;        reform(smnutrn(index),1,n)]  ;very irregular spacing of days....why and how do i deal with this?
;
;p1=plot(doy(site2_depth1),smnutrn(site2_depth1), '-r2+',linestyle=6); create a datestring so I can plot 'um
;
;
;;so now if doy eq previous day of year add to the buffer, keep a counter and find the average
;;*************************************
;hcount = 0
;dcount = 0
;dayindex = string(yr)+string(doy)+string(lat110)
;c = rem_dup(dayindex)
;
;SMday010 = fltarr(n_elements(c))
;SMday150 = fltarr(n_elements(c))
;SMday100 = fltarr(n_elements(c))
;SMday250 = fltarr(n_elements(c))
;SMday200 = fltarr(n_elements(c))
;SMday050 = fltarr(n_elements(c))
;
;buffer010 = 0
;buffer150 = 0 
;buffer100 = 0
;buffer250 = 0
;buffer200 = 0
;buffer050 = 0
;
;yrdoy010=fltarr(4,n_elements(c))
;yrdoy150=fltarr(4,n_elements(c))
;yrdoy100=fltarr(4,n_elements(c))
;yrdoy250=fltarr(4,n_elements(c))
;yrdoy200=fltarr(4,n_elements(c))
;yrdoy050=fltarr(4,n_elements(c))
;
;;********************
;for l=0, n_elements(datetime110)-1 do begin
;  if l eq 23419 then continue 
;  if dcount gt (n_elements(c)) then break ;not sure why this has to be ge2
;  if hcount eq 1 then begin
;  buffer010 = SM010cm110[l]
;  buffer150 = SM150cm110[l]
;  buffer100 = SM100cm110[l]
;  buffer250 = SM250cm110[l]
;  buffer200 = SM200cm110[l]
;  buffer050 = SM050cm110[l]
;  endif
;  ;debug
;  if (dcount eq 980) or (dcount eq 981) then begin
;    print, l, doy[l],dcount,hcount,buffer150,SM010cm110[l],SMday050[dcount] 
;  endif
;  
;  if l eq 0 then test = 1 else $
;  if (l eq (n_elements(datetime110)-1)) then test = 2 else $
;  if (l gt 0) AND (doy[l] ne doy[l-1]) AND (doy[l] eq doy[l+1]) then test = 1 else $
;  if (doy[l] eq doy[l-1]) AND (doy[l] ne doy[l+1]) then test = 2 else $ ;end of the day (does not match the next), take avg 
;  if (doy[l] ne doy[l-1]) AND (doy[l] ne doy[l+1]) then test = 3 ;this should take care of the one day values
;
;  CASE test OF 
;    1: BEGIN 
;         buffer010 = SM010cm110[l]+buffer010; my numbering is not totally consistant here...
;         buffer150 = SM150cm110[l]+buffer150
;         buffer100 = SM100cm110[l]+buffer100
;         buffer250 = SM250cm110[l]+buffer250
;         buffer200 = SM200cm110[l]+buffer200
;         buffer050 = SM050cm110[l]+buffer050
;       END
;    2: BEGIN 
;         SMday010[dcount] = buffer010/hcount; & dcount++ & hcount = 0
;         SMday150[dcount] = buffer150/hcount; & dcount++ & hcount = 0
;         SMday100[dcount] = buffer100/hcount; & dcount++ & hcount = 0
;         SMday250[dcount] = buffer250/hcount; & dcount++ & hcount = 0
;         SMday200[dcount] = buffer200/hcount; & dcount++ & hcount = 0
;         SMday050[dcount] = buffer050/hcount; & dcount++ & hcount = 0         
;         
;         buffer010 = 0 & yrdoy010[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer150 = 0 & yrdoy150[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer100 = 0 & yrdoy100[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer250 = 0 & yrdoy250[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer200 = 0 & yrdoy200[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer050 = 0 & yrdoy050[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];  
;         
;         dcount++ & hcount = 0        
;         
;       END
;    3: BEGIN 
;         SMday010[dcount] = SM010cm110[l]; & dcount++ & hcount = 0 
;         SMday150[dcount] = SM150cm110[l]; & dcount++ & hcount = 0 
;         SMday100[dcount] = SM100cm110[l]; & dcount++ & hcount = 0 
;         SMday250[dcount] = SM250cm110[l]; & dcount++ & hcount = 0 
;         SMday200[dcount] = SM200cm110[l]; & dcount++ & hcount = 0 
;         SMday050[dcount] = SM050cm110[l]; & dcount++ & hcount = 0 
;         
;         buffer010=0 & yrdoy010[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];not sure that these need to be repeated...
;         buffer150=0 & yrdoy150[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer100=0 & yrdoy100[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer250=0 & yrdoy250[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer200=0 & yrdoy200[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         buffer050=0 & yrdoy050[*,dcount]=[yr[l],doy[l], lat110[l], lon110[l]];
;         
;         dcount++ & hcount = 0
;
;       END
;  ENDCASE
;  hcount++ 
;
;endfor ;l
;
;;**************************************
;;what if I only want to plot the rainy season? May-Oct DOY:121-274
;
;site1=where(yrdoy010[2,*] eq 13.6476)
;site2=where(yrdoy010[2,*] eq 13.6440)
;
;yr1site1 = where((yrdoy010[0,*] eq 2005) AND yrdoy010[2,*] eq 13.6476);Wankama Jachere
;yr2site1 = where((yrdoy010[0,*] eq 2006) AND yrdoy010[2,*] eq 13.6476)
;yr1site2 = where((yrdoy010[0,*] eq 2005) AND yrdoy010[2,*] eq 13.6440);Wankama Mill
;yr2site2 = where((yrdoy010[0,*] eq 2006) AND yrdoy010[2,*] eq 13.6440);
;
;;some stats for the different sites and years
;yr1site1mean010=mean(smday010(yr1site1)) & print, yr1site1mean010
;yr1site2mean010=mean(smday010(yr1site2)) & print, yr1site2mean010
;yr2site1mean010=mean(smday010(yr2site1)) & print, yr2site1mean010
;yr2site2mean010=mean(smday010(yr2site2)) & print, yr2site2mean010
;
;yr1site1std010=stdev(smday010(yr1site1)) & print, yr1site1std010
;yr1site2std010=stdev(smday010(yr1site2)) & print, yr1site2std010
;yr2site1std010=stdev(smday010(yr2site1)) & print, yr2site1std010
;yr2site2std010=stdev(smday010(yr2site2)) & print, yr2site2std010
;
;yr1site1mean050=mean(smday050(yr1site1)) & print, yr1site1mean050
;yr1site2mean050=mean(smday050(yr1site2)) & print, yr1site2mean050
;yr2site1mean050=mean(smday050(yr2site1)) & print, yr2site1mean050
;yr2site2mean050=mean(smday050(yr2site2))& print, yr2site2mean050
;
;yr1site1std050=stdev(smday050(yr1site1)) & print, yr1site1std050
;yr1site2std050=stdev(smday050(yr1site2)) & print, yr1site2std050
;yr2site1std050=stdev(smday050(yr2site1)) & print, yr2site1std050
;yr2site2std050=stdev(smday050(yr2site2)) & print, yr2site2std050
;
;yr1site1mean100=mean(smday100(yr1site1)) & print, yr1site1mean100
;yr1site2mean100=mean(smday100(yr1site2)) & print, yr1site2mean100
;yr2site1mean100=mean(smday100(yr2site1)) & print, yr2site1mean100
;yr2site2mean100=mean(smday100(yr2site2)) & print, yr2site2mean100
;
;yr1site1std100=stdev(smday100(yr1site1)) & print, yr1site1std100
;yr1site2std100=stdev(smday100(yr1site2)) & print, yr1site2std100
;yr2site1std100=stdev(smday100(yr2site1)) & print, yr2site1std100
;yr2site2std100=stdev(smday100(yr2site2)) & print, yr2site2std100
;
;yr1site1mean150=mean(smday150(yr1site1)) & print, yr1site1mean150
;yr1site2mean150=mean(smday150(yr1site2)) & print, yr1site2mean150
;yr2site1mean150=mean(smday150(yr2site1)) & print, yr2site1mean150
;yr2site2mean150=mean(smday150(yr2site2)) & print, yr2site2mean150
;
;yr1site1mean200=mean(smday200(yr1site1)) & print, yr1site1mean200
;yr1site2mean200=mean(smday200(yr1site2)) & print, yr1site2mean200
;yr2site1mean200=mean(smday200(yr2site1)) & print, yr2site1mean200
;yr2site2mean200=mean(smday200(yr2site2)) & print, yr2site2mean200
;
;yr1site1mean250=mean(smday250(yr1site1)) & print, yr1site1mean250
;yr1site2mean250=mean(smday250(yr1site2)) & print, yr1site2mean250
;yr2site1mean250=mean(smday250(yr2site1)) & print, yr2site1mean250
;yr2site2mean250=mean(smday250(yr2site2)) & print, yr2site2mean250
;
;;yr1 = where(yr eq 2005 AND DOY gt 121 AND DOY lt 274)
;;yr2 = where(yr eq 2006 AND DOY gt 121 AND DOY lt 274)
;
;;p01=plot(SM250cm[0:1000],XTICKNAME=strmid(datetime[0:1000:96],5,5))
;;p02=plot(SM05cm[0:1000],/overplot, color='blue')
;
;;print, 'stop'
end