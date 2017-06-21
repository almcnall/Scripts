pro AMMAsoil_mill_fallow210

;the purpose of this script is to read and mess with the data from the wankama and millet sites

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

indir= '/jabber/Data/mcnally/AMMASOIL/'
cd, indir
fname = file_search('wankama*.csv');
i=0 ;0=fallow 1=millet
;lets start with the millet sites to make the foodies happy
  myTemplate = ASCII_TEMPLATE(fname[i]); go to line 41
  buffer = read_ascii(fname[i], delimiter=';' ,template=myTemplate);
  flag=-9999.9

;first create a whole new table structure that gets ride of the bad lines and columns
;this will also involve including a unique site ID and maybe a unique day ID (might need to be a string)
datetime = buffer.FIELD01[*]
datetime = [transpose(datetime), transpose(datetime)]

yr = fix(strmid(datetime[0,*],0,4))
mo = fix(strmid(datetime[0,*],5,2))
dy = fix(strmid(datetime[0,*],8,2))
hr = fix(strmid(datetime[0,*],10,2))

good = where(yr ne 0 AND mo ne 0 AND dy ne 0, complement=name)
sitenam = where(STRMID(datetime,0,3) ne '200', count)

yr(name) = flag
mo(name) = flag
dy(name) = flag
hr(name) = flag

doy = YMD2DN(yr, mo,dy)
  
lat = buffer.FIELD02[*] 
lon = buffer.FIELD03[*]
depth = buffer.field05 ;min = -2440, max=-40.00
sm = buffer.FIELD16[*]

siteID=fltarr(n_elements(yr[0,*]))

table=[yr, mo, dy, doy, hr, transpose(lon), transpose(lat), transpose(siteID), transpose(depth), transpose(sm)]

good=where(table[0,*] ne -9999., count)

;from now on only use table and datetime
table = table[*,good]
datetime = datetime[*,good]
;;***************dealing with duplicate latlons************************
;; Step 1: Map your columns 2 and 3 into a single unique index
latlons = table[5:6,*]
;table=[yr, mo, dy, doy, hr transpose(lon), transpose(lat), transpose(siteID), transpose(depth), transpose(sm)]

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
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,10) ;the 11 for millet 10 for fallow will have to change when reading other files
  ;assign unq site ID (1-11)
  temp=transpose([1,2,3,4,5,6,7,8,9,10]);change this to 11 for the millet.
  unqlatlon = [temp,unqlatlon]
 ;**************************************************************************************
 print, 'pause here'
 ; Give sites an ID rather than refering to thier latlons
  for i=0,n_elements(unqlatlon[0,*])-1 do begin
    site=where(table[5,*] eq unqlatlon[1,i] AND table[6,*] eq unqlatlon[2,i])
    
    table[7,site]=i+1
    datetime[1,site]=string(i+1)
  endfor;i
  
  ;make arrays of unique depths (17/29) and dates (71/68) 
  datearray  = datetime[0,rem_dup(datetime[0,*])]
  deptharray =reverse(table[8,rem_dup(table[8,*])],2); 
  SMout=fltarr(n_elements(unqlatlon[0,*]),n_elements(deptharray), n_elements(datearray))
  SMout[*,*,*]=-999.

;**********reformat the data into sites, depths, dates***************************
;i = 3 ;use this i to look at one site at a time
for i = 0,n_elements(unqlatlon[0,*])-1 do begin
  for j=0,n_elements(datearray)-1 do begin
   for k=0,n_elements(deptharray)-1 do begin
     ;data is at the site done, day one, depth one
      data = where(table[7,*] eq i+1 AND datetime[0,*] eq datearray[j] AND table[8,*] eq deptharray[k], count)
      if count eq 0 then continue ;seems to handle duplicates cases fine e.g. first 2 rows of fallow do not get repeated.
      SMout[i,k,j]=table[9,data[0]] ;added this in 1/29 - is there really a duplicate between 7886 and 7898?
     endfor;k
  endfor;j
endfor;i

nans=where(SMout eq -999., count)
SMout(nans)=!VALUES.F_NAN

;ofile='/jabber/Data/mcnally/AMMASOIL/wankama_fallow_cube.dat'
;openw,1,ofile
;writeu,1,SMout
;close,1


;parse the datearray so that I can match it with the rainfall data that is in bin time.
;ascii time DOW MON DD HH:MM:SS YYYY amma time: 2005-03-18 00:00:00.0

yr = fix(strmid(datearray[0,*],0,4))
mo = fix(strmid(datearray[0,*],5,2))
dy = fix(strmid(datearray[0,*],8,2))
hr = fix(strmid(datearray[0,*],10,2))
doy = YMD2DN(yr, mo,dy)

smdates=[yr,mo,dy,hr,doy]

;ofile='/jabber/Data/mcnally/AMMASOIL/smdates4rainlag_fallow.dat'
;openw,1,ofile
;writeu,1,smdates

;**************stuff below is plotting and summary stats, can move elsewhere************************
;***********maybe move this when detailing each site and its characteristics************************
;calculate the coefficient of variation for each day: this is how variable measurements are between sites on a given day. 
SMavg=fltarr(n_elements(datearray), n_elements(deptharray))
SMstd=fltarr(n_elements(datearray), n_elements(deptharray))

;make a 1x17x71 array of the mean soil profile for each date. maybe i should write this out...
;for j=0,n_elements(datearray)-1 do begin
;   for k=0,n_elements(deptharray)-1 do begin
;     SMavg[j,k]=mean(SMout[*,k,j],/nan)
;     SMstd[j,k]=stddev(SMout[*,k,j],/nan)
;   endfor
;endfor
;print, 'hold here' 
;
;SMcv = SMstd/SMavg
;SMsn = SMavg/SMstd ;and signal to noise ratio
;
;avgSMstd=mean(SMstd, dimension=1,/nan) ;what is the average std dev over time? (this should highlight the shallow and deep var)
;avgSMavg=mean(SMavg, dimension=1,/nan) ;what is the average avg SM? I need this to calculate the average coeff. of variation.
;
;avgSMcv = avgSMstd/avgSMavg ;find the average variability with respect to depth. 
;
;;super averages!
;SM=SMcv ;change SM to the variable that i want to plot
;p1=plot(SM,deptharray,'black',thick=4); I should make this a thick black overplot

;use this to label the plots with lat/lon
;s=11 ;site, there are 10 or 11....first dimension.
;q=where(table[4,*] eq s+1)
;d are the days that I am plotting for each year
;d=fix([1,4,6,7,10,11,12,13,14.15,16,17,18,19,20]);mar 05-06
;d=[21,23,24,25,26,27,28,29,30,31,33,36,37,40];mar06-07
;d=[42,43,44,45,46,47,48,49,50,51,52,53,54,55];mar07-mar08
;d=[54,55,56,57,58,59,60,61,62,63,64,65,66,67];mar08-09
;
;*******for the sake of ploting just set SM to what ever var you are interested in e.g. SMavg, or SMcv*********************
;p1=plot(SM(d[0],*),deptharray,/overplot,'orange')
;p2=plot(SM(d[1],*), deptharray,/overplot,'g') 
;p3=plot(SM(d[2],*), deptharray,/overplot,'yellow') 
;p4=plot(SM(d[3],*),deptharray,/overplot,'b')
;p5=plot(SM(d[4],*),deptharray,/overplot,'-*')
;p6=plot(SM(d[5],*),deptharray,/overplot,'-.r')
;p7=plot(SM(d[6],*),deptharray,/overplot,'-.g')
;p8=plot(SM(d[7],*),deptharray,/overplot,'-.b')
;p9=plot(SM(d[8],*),deptharray,/overplot,'-.c'); 18,19,20 all look about the same below 400cm
;p10=plot(SM(d[9],*),deptharray,/overplot,'-.o'); but there is some interesting something at 300cm
;p11=plot(SM(d[10],*),deptharray,/overplot,'--.m');
;p12=plot(SM(d[11],*),deptharray,/overplot,'--.g')
;p13=plot(SM(d[12],*),deptharray,/overplot,'--.b')
;p14=plot(SM(d[13],*),deptharray,/overplot,'--.r', $
;         title='CV in fallow profile',$
;         xtitle='coefficient of variation', ytitle='depth(cm)',$;this seems to work
;         yrange=[-600,0],xrange=[0,0.5])
;
;p1.name = strmid(datearray[0,d[0]],0,10)
;p2.name = strmid(datearray[0,d[1]],0,10)
;p3.name = strmid(datearray[0,d[2]],0,10)
;p4.name = strmid(datearray[0,d[3]],0,10)
;p5.name = strmid(datearray[0,d[4]],0,10)
;p6.name = strmid(datearray[0,d[5]],0,10)
;p7.name = strmid(datearray[0,d[6]],0,10)
;p8.name = strmid(datearray[0,d[7]],0,10)
;p9.name = strmid(datearray[0,d[8]],0,10)
;p10.name = strmid(datearray[0,d[9]],0,10)
;p11.name = strmid(datearray[0,d[10]],0,10)
;p12.name = strmid(datearray[0,d[11]],0,10)
;p13.name = strmid(datearray[0,d[12]],0,10)
;p14.name = strmid(datearray[0,d[13]],0,10)
;
;
;!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14], position=[0.2,0.3]) 
;!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11], position=[0.2,0.3]) 


end   
  