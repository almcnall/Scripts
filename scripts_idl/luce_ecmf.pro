 pro luce_ecmf
 
;LATITUDE - (Deg.decDeg)
;LONGITUDE - (Deg.decDeg)
;YEAR - (yyyy)
;MONTH - (mm)
;DEKAD - [1-2-3]
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
;FFAV - average wind speed - (m/s)
;VAPAV - avearge water vapour pressure - (hPa)


wkdir='C:\Users\mcnally\Documents\Dissertation\ecmwf\'
odir ='C:\Users\mcnally\Documents\Dissertation\ecmwf\sites\'
file_mkdir, odir
  ; open the shapefile, get the properties for all attributes, and get all the data
  ecmwf96 = OBJ_new('IDLffShape',wkdir+'a41fe2e4f21d7531f2882c83855fac3f6\a41fe2e4f21d7531f2882c83855fac3f6.shp')
  ;ecmwf97 = OBJ_new('IDLffShape',wkdir+'a0d77753f990a3030c8a4085b76f0c3ee\a0d77753f990a3030c8a4085b76f0c3ee.shp')
  ;ecmwf98 = OBJ_new('IDLffShape',wkdir+'a934b3283bb9dd9bdf880a313f63c33e5\a934b3283bb9dd9bdf880a313f63c33e5.shp')
  ;ecmwf99 = OBJ_new('IDLffShape',wkdir+'ab6f20bfc9faae6ab88f46002ca0e65e6\ab6f20bfc9faae6ab88f46002ca0e65e6.shp')
  
 ecmwf96->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals96 = ecmwf96->getAttributes( /ALL)
 
  Tlat = vals96[*].attribute_0
  Tlon = vals96[*].attribute_1
  Tavg = vals96[*].attribute_5 
  Tmax = vals96[*].attribute_6 
  Tmin = vals96[*].attribute_7 

;Site lat(dd) lon(dd) source  Shp_lat Shp_lon

xycords = 'C:\Users\mcnally\Documents\LUCE\xycords_arc.csv'
valid = QUERY_ASCII(xycords, info) & print, valid, info
line = info.lines

buffer=strarr(line)  & sites=strarr(line) & lats=fltarr(line) & lons=fltarr(line) & sources=strarr(line)
shp_lats=fltarr(line) & shp_lons=fltarr(line)

site='' & lat=0.  & lon=0.  & source='' & shp_lat=0.  & shp_lon=0.

openr,1,xycords
readf,1,buffer

for k=0,line-1 do begin 
  ;if k eq 0 then continue
  parse=strsplit(buffer(k),',',/extract)
  
  site = parse(0)
  lat = parse(1)
  lon = parse(2)
  source = parse(3)
  shp_lat = parse(4)
  shp_lon = parse(5)
 
 sites(k)=site & lats(k)= lat & lons(k)=lon  & sources(k)=source  & shp_lats(k)=shp_lat & shp_lons(k)=shp_lon
endfor ;

close,1  
i=Long(1)
  
for m = 0,line-1 do begin 
  j = 0
  tavgsite = fltarr(36)
  tminsite = fltarr(36)
  tmaxsite = fltarr(36) 
  dek = intarr(36)
  for i=0L,n_elements(Tlat)-1 do begin
    if (Tlat[i] eq shp_lats[m]) AND (Tlon[i] eq shp_lons[m]) then begin
      tavgsite[j]=Tavg[i]
      tminsite[j]=Tmin[i]
      tmaxsite[j]=Tmax[i]
      dek[j]=j+1
      j++
    endif
   ; print, i
  endfor;i
  ofile=strcompress(odir+'Temp'+sites[m]+'.csv', /remove_all)
  openw,2,ofile
  write_csv,ofile,dek,tavgsite,tminsite,tmaxsite
  close, 2
endfor
print, i
end
    
  
  