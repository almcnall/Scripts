pro ecmwf_shp
;this script reformats the year-dekad .shp files downloaded from !!this is the one degree data!!!
;the ecmwf website http://mars.jrc.it/mars/About-us/FOODSEC/Data-Distribution   
;LATITUDE LONGITUDE YEAR  MONTH DEKAD TAV TMAX  TMIN  RRR E0  ES0 ET0 RAD SDAV  SDMIN SDMAX CWB ACQDATE
;ERA40 - 1degree:
;
;TAV - average temperature - (°C)
;TMAX - maximum temperature - (°C)
;TMIN - minimum temperature - (°C)
;RRR - precipitation sum - (mm = liters/m2)
;E0 - evapo-transpiration sum (over water) - (mm = liters/m2)
;ES0 - evapo-transpiration sum (bare soil) - (mm = liters/m2)
;ET0 - evapo-transpiration sum (Penman-Monteith) - (mm = liters/m2)
;RAD - global radiation sum - (kJ/m2 per dekad)
;SDAV - average snow depth - (cm)
;SDMIN - minimum snow depth - (cm)
;SDMAX - maximum snow depth - (cm)
;CWB - climatic water balance - (mm = liters/m2)

arrays=['TAV' ,'TMAX', 'TMIN' ,'RRR' ,'E0' ,'ES0' ,'ET0', 'RAD' ,'SDAV' ,'SDMIN' ,'SDMAX' ,'CWB']

indir = '/jabber/LIS/Data/ecmwf/100KM/a0594a14969a68b0a3ddfebf2165b6df3_1deg2006/'
odir = '/jabber/LIS/Data/ecmwf/100KM/2006/' ;one degree!

file_mkdir,odir
cd, indir

;  open the shapefile, get the properties for all attributes, and get all the data;
afrain = OBJ_new('IDLffShape',indir+'a0594a14969a68b0a3ddfebf2165b6df3.shp')
afrain->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
vals = afrain->getAttributes( /ALL)
;lon=vals[*].attribute_1  & print, min(lon)   & print, max(lon)  ;-28 to 62 -- a little larger then rfe2 (91) (nx)
;lat=vals[*].attribute_0  & print, min(lat)   & print, max(lat)  ;-37 to 40 -- a little smaller than rfe2 grid (78) (ny)

lon = 91
lat = 78

temp = fltarr(n_elements(arrays))
africa = fltarr(lon,lat,12,n_elements(arrays)) ;lon,lat,mo, var

k=0L  ;this is a  loooong number
   for i=0,lat-1 do begin ;lat
     for j=0,lon-1 do begin ;lon varies along x-axis (91)
       m=0
       for t=0,36-1 do begin ;dekads per pixel
         for v=0,n_elements(arrays)-1 do begin ;the different vars(layers) in the shp file
           ;africa[i,j,t,v]=vals[k].(v+5)  ;for each pixel get the rainfall for the dekad
           temp[v] = temp[v] + vals[k].(v+5) ;sum the values
         endfor;v
         
         k++ ;advance row(k) after getting all column vars
         
         ;if t is a multple of 3 then store temp, clear temp and advance m
         if ((t+1) MOD 3) eq 0 then begin
           africa[j,i,m,*] = temp ;africa is now a 78x90x12x12 array. (rows=y, cols=x)
           temp[*] = 0 
           m++
         endif
       
       endfor; t
     endfor ;j
   endfor ;i


  for n=0,n_elements(arrays)-1 do begin
    ofile= strcompress(+odir+arrays[n]+"_tot.img",/remove_all) ;names the output file
    openw,1,ofile
    writeu,1,africa[*,*,*,n];opens the out file   (nx,ny,month,var)
    close,1
  endfor; n

print, 'done'         
end               