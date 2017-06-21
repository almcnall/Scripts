pro AMMArain
;this script reads amma data from csv files. the orginial files are sparse (only rainfall events recorded)
;and different lat lons denote different stations (108?) The purpose of this script is to populate a square (full)
;array with the data that exsists and separate the different stations into different dimensions...the resulting array is 
;108 stations X 4 columns (year, month, day, rainfall) X 1461 days (365*4+1 days)
;AM 6/9/11

indir= '/jabber/Data/mcnally/AMMARain/'
cd, indir

ff= file_search('143-CL.Rain_Nc.csv')
;ff= file_search('110-AE.H2OFlux_Ncw.csv')
;ff= file_search('132-CE.Rain_Nc.csv')
;ff= file_search('133-CL.Rain_N.csv')

fname= indir+ff
valid= query_ascii(fname,info) ;checks compatability with read_ascii
print, valid

myTemplate = ASCII_TEMPLATE(fname); this allows me to recognize field001 is a date/time string.
rain143 = read_ascii(fname, delimiter=';' ,template=myTemplate)
flag = -9999.90

datetime  = rain143.FIELD01 ; date i need to fill in this vector
  yr = strmid(datetime,0,4)
  mo = strmid(datetime,5,2)
  dy = strmid(datetime,8,2)

lat = rain143.FIELD02 ; latitude 
lon = rain143.FIELD03 ; longitude
  latlons=[ reform(lat,1,n_elements(lat)), reform(lon,1,n_elements(lon)) ]

alt = rain143.FIELD04 ; altitude
;sunang  = rain142.FIELD05 ; hauteur sol

;***************dealing with duplicate latlons************************
;; Step 1: Map your columns 2 and 3 into a single unique index
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
  unqlatlon = reform(unqlatlon(where(finite(unqlatlon))),2,108) ;the 108 will have to change when reading other files
;***********************************************************************

;drpnum  = rain110.FIELD06 ; Droplet Number(no unit), no vals 110
;drpsiz  = rain110.FIELD07 ; Droplet Size(mm), no vals 110
;drpdis  = rain110.FIELD08 ; Drop Size Distribution(m-4), no 110vi 11
;falvel  = rain110.FIELD09 ; Fall velocity(m/s);no 110
;liqwat  = rain110.FIELD10 ; Liquid Water Content(g.m-3) ;no 110
pramnt  = rain143.FIELD11  ; Precipitation Amount(mm);no 110, yes, 143
;prv12h  = rain110.FIELD12 ; Precipitation Amount (previous 12 hours)(mm), no143
;prv24h  = rain110.FIELD13 ; Precipitation Amount (previous 24 hours)(mm). no143, yes132
;prv30m  = rain110.FIELD14 ; Precipitation Amount (previous 30 minutes)(mm) ;171 vals 110-appears to be only for 2005, no 143
;prv03h  = rain110.FIELD15 ; Precipitation Amount (previous 3 hours)(mm); no 143
;prv05m  = rain110.FIELD16 ; Precipitation Amount (previous 5 minutes)(mm)
;prv06h  = rain110.FIELD17 ; Precipitation Amount (previous 6 hours)(mm)
;prv01h  = rain110.FIELD18 ; Precipitation Amount (previous hour)(mm)
;prv01s  = rain110.FIELD19 ; Precipitation Amount (previous second)(mm) ; 2933 of 3105 vals 110
;prvJan  = rain110.FIELD20 ; Precipitation Amount (since January 1)(mm) ; all 3105 vals 110
;prate1  = rain110.FIELD21 ; Precipitation Rate(mm/h);2933 vals...I thought that this would be a good place to start but data is a lil' weird
;prate2  = rain110.FIELD22 ; Precipitation Rate HASSE(mm/h);no vals
;prate3  = rain110.FIELD23 ; Precipitation Rate ORG(mm/h);no vals

   buffer = intarr(1461);356*4+1=1461
   movector=intarr(1461)
   datevec = fltarr(n_elements(unqlatlon[0:*]),4,1461); day, month, yr, val 4 cols, 1461 rows
     datevec(*,0,0:364) = 2005
     datevec(*,0,365:729) = 2006
     datevec(*,0,730:1094) = 2007
     datevec(*,0,1095:1460) = 2008

 ;******my slick (?) way of creating a month/year vector....there was prolly an old fashioned easier way***

 
 for l=0,n_elements(unqlatlon[0,*])-1 do begin; ;this is not working, what is up with my day counts
   k=1
   i=0
   daycount=0
   olddaycount=0
   site1 = where(unqlatlon[0,l] eq lat AND unqlatlon[1,l] eq lon);so this sorts out the different sites...
   index = intarr(n_elements(unqlatlon),n_elements(site1))
   ;testplot
   ;p1=plot(pramnt(site1),yrange=[0,80], title=unqlatlon[0:1,l])
   
   ;so I think that this makes an nice square array for one site. 
   for j=0,48-1 do begin ;48=12 months*4 years
     if datevec(l,0,daycount-1) MOD 4 ne 0 then days = [31,28,31, 30,31,30, 31,31,30, 31,30,31] $
     else days = [31,29,31, 30,31,30, 31,31,30, 31,30,31] ;this way of subscripting datevec seems fine, but maybe unecessary?
     
     olddaycount=daycount ;since there is no 'minus one' it will fill in the next avail index
     daycount=daycount+days[i] ;and add in the next set of days in the next month
     buffer(olddaycount:daycount-1) = indgen(days[i])+1 ;so this should be ok, it says oldday count (0): 31-1 but it breaks when we move to next site
     movector(olddaycount:daycount-1) = k
      i++
      k++
      if i eq 12 then i=0
      if k eq 13 then k=1
    endfor;j
 
 ;datevec(j,*) = yrvec  ;yr 
  datevec(l,1,*) = movector  ;month
  datevec(l,2,*) = buffer ;day
  datevec(l,3,*) = flag   ;value
 
 ;record the indices where the rainfall event from the site matches the date in the square array.
  for m=0,n_elements(pramnt(site1))-1 do begin  ;is this part correct? - the problem is that this will be variable, no?
   ;this index relates to the date....now how do I get the rainfall there? 
    index[l,m]=where( yr(site1[m]) eq  datevec(l,0,*) AND mo(site1[m]) eq datevec(l,1,*) AND dy(site1[m]) eq string(format='(I2.2)',datevec(l,2,*)))
    datevec(l,3,index(l,m))=pramnt(site1[m]); 
  endfor;m
endfor; l 

; uh! how do I know if this is working properly?? I think that it is it is just REALLY sparse....I should figure out the dates
; that correspond with the rainy season, so that I can ignore the rest of the year. 
 print, 'hi'
 ;return, unqlatlon ;uh, i don't wanna create a structure!!!
 end
