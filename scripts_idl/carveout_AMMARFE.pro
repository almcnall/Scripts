pro carveout_AMMARFE  

;**************************************************************************
;8/9/11: i will abandon this code for a bit since I am just going to change the RFE2 file to station averages,
;rather than a comparative analysis.....
;
;the purpose of this program is to extract the rfe2 data for the relevant temporal and spatial 
;domain to go with the station data in 143-CL.Rain_Nc.csv. 
;spatial domain:13.5025 to 13.6146 and 2.637 to 2.75690
;temporal domain: 2005-05-01 to 2008-10-31
;
;first I'll check this out for one site and one day, one site and 3 days and 33 sites (2 pixels) over 3 days. 
;13.5904, 2.65470 20mm rain on 2005-09-02
;*************************************************************************

;the original OR unbiased rfe2 file
;
;rfe2dir = strcompress('/jabber/LIS/Data/ubRFE2/', /remove_all)
rfe2dir = strcompress('/jabber/LIS/Data/CPCOriginalRFE2/', /remove_all)
cd, rfe2dir

file = file_search('all_products.bin.200509{01,02,03}'); there was rain these three days
nx = 751
ny = 801

;lonmin = -19.95
;lonmax = 55.05
;latmin = -39.95
;latmax = 40.05

loncen = (lonmin + lonmax) / 2.0 ;not exactly sure what this does it is from map_afr_rfe
latcen = (latmin + latmax) / 2.0
;*********************************************************************

;allocate arrays
ingrid = fltarr(nx,ny) ;initializes the array 
AOI = fltarr(2,2,3) ; how big do I want this grid to be? 
buffer = fltarr(nx,ny,n_elements(file))

for i=0, n_elements(file)-1 do begin
  i=2
  openr,1,file[i] 
  readu,1,ingrid        
  byteorder,ingrid,/XDRTOF
  buffer[*,*,i]=ingrid
  close,1
endfor;i

;min/max from lat/lon recoded on 2005-09-02 (1 of 33 values)
;onelon = 2.66760
;onelat = 13.5015
lonmin = 2.637 
latmin = 13.5904
lonmax = 2.7035
latmax = 13.5967
 
;change the site lat lons into x and y so I can match rfe2 grid with their lat/lon value
 minx = reform((lonmin+19.95)*10); becasue it is -29.95W and (2.5*20 = 50pixels) 
 miny = reform((latmin+39.95)*10) ;becasue it is -39.95S
 ;minx = reform((onelon+19.95)*10); becasue it is -29.95W and (2.5*20 = 50pixels) 
 ;miny = reform((onelat+39.95)*10) ;becasue it is -39.95S
 maxx = reform((lonmax+19.95)*10)
 maxy = reform((latmax+39.95)*10)
 
 ;these values are really low for both biased and unbiased rfe2...maybe the timestamp is an issue...
 AOI = buffer(minx:maxx,miny:maxy,*); this should extract the relevant value from the rfe2 infile.  
 ;AOI = buffer(minx,miny,*); 
;end ;end program
