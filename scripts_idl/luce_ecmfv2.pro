pro luce_ecmfv2
;The purpose of this script is to read the ecmwf data that is on zippy...rather than what was on my desktop.
; 
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


wkdir='/jabber/LIS/Data/ecmwf/'
odir ='/jabber/LIS/Data/ecmwf/sites/'
file_mkdir, odir
  ; open the shapefile, get the properties for all attributes, and get all the data
  ecmwf96 = OBJ_new('IDLffShape',wkdir+'a41fe2e4f21d7531f2882c83855fac3f6/a41fe2e4f21d7531f2882c83855fac3f6.shp')
  ecmwf97 = OBJ_new('IDLffShape',wkdir+'a0d77753f990a3030c8a4085b76f0c3ee/a0d77753f990a3030c8a4085b76f0c3ee.shp')
  ecmwf98 = OBJ_new('IDLffShape',wkdir+'a934b3283bb9dd9bdf880a313f63c33e5/a934b3283bb9dd9bdf880a313f63c33e5.shp')
  ecmwf99 = OBJ_new('IDLffShape',wkdir+'ab6f20bfc9faae6ab88f46002ca0e65e6/ab6f20bfc9faae6ab88f46002ca0e65e6.shp')
  ecmwf00 = OBJ_new('IDLffShape',wkdir+'a671ec77d8b940dda926f5dc8859a7a62/a671ec77d8b940dda926f5dc8859a7a62.shp')
  ecmwf01 = OBJ_new('IDLffShape',wkdir+'a58bca12e315bf28521d3642c526287ca/a58bca12e315bf28521d3642c526287ca.shp')
  ecmwf02 = OBJ_new('IDLffShape',wkdir+'a2a0f1aeab4c08d2f19f725803ef7fa18/a2a0f1aeab4c08d2f19f725803ef7fa18.shp')
  ecmwf03 = OBJ_new('IDLffShape',wkdir+'af683499594a9ac7f27e14a4702040345/af683499594a9ac7f27e14a4702040345.shp')
  ecmwf04 = OBJ_new('IDLffShape',wkdir+'a8cab9e58466dfbc7d407a12454271c59/a8cab9e58466dfbc7d407a12454271c59.shp')
  ecmwf05 = OBJ_new('IDLffShape',wkdir+'af44d8b8f0bfffd8476720a339c11bb53/af44d8b8f0bfffd8476720a339c11bb53.shp')
  
 ecmwf96->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals96 = ecmwf96->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf97->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals97 = ecmwf97->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf98->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals98 = ecmwf98->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf99->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals99 = ecmwf99->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf00->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals00 = ecmwf00->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf01->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals01 = ecmwf01->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf02->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals02 = ecmwf02->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf03->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals03 = ecmwf03->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf04->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals04 = ecmwf04->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf05->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals05 = ecmwf05->getAttributes( /ALL) ;can I cat the years here?

 valcat=[vals96,vals97,vals98,vals99,vals00,vals01,vals02,vals03,vals04,vals05]
 
  Tlat = valcat[*].attribute_0
  Tlon = valcat[*].attribute_1
  yr   = valcat[*].attribute_2
  mo   = valcat[*].attribute_3
  dek  = valcat[*].attribute_4
  Tavg = valcat[*].attribute_5 
  Tmax = valcat[*].attribute_6 
  Tmin = valcat[*].attribute_7 

;Site lat(dd) lon(dd) source  Shp_lat Shp_lon

xycords = '/home/mcnally/luce_sites/xycords_arc2.csv'
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
  
for m = 0,line-1 do begin ;for each site
  j = 0
  d = 0
  tavgsite = fltarr(36*10) 
  tminsite = fltarr(36*10)
  tmaxsite = fltarr(36*10) 
  Tdek = intarr(36*10)
  Tyr = intarr(36*10)
  
  for i=0L,n_elements(Tlat)-1 do begin ;for all yrs
    if (Tlat[i] eq shp_lats[m]) AND (Tlon[i] eq shp_lons[m]) then begin ;if the pixel matches the site
      tavgsite[j]=Tavg[i] ;keep temperature from the pixel
      tminsite[j]=Tmin[i]
      tmaxsite[j]=Tmax[i]
      Tyr[j]=yr[i]
      Tdek[j]= d+1;
      j++
      d++ 
      if d eq 36 then d=0
    endif
   ; print, i
  endfor;i
  ofile=strcompress(odir+'Temp'+sites[m]+'.csv', /remove_all)
  openw,2,ofile
  write_csv,ofile,Tyr,Tdek,tavgsite,tminsite,tmaxsite
  close, 2
endfor
print, i
end
    
  
