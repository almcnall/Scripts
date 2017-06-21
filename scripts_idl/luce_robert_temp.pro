pro luce_robert_temp
 
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
   ecmwf96 = obj_new('idlffshape',wkdir+'a41fe2e4f21d7531f2882c83855fac3f6/a41fe2e4f21d7531f2882c83855fac3f6.shp')
;  ecmwf02 = obj_new('idlffshape',wkdir+'a2a0f1aeab4c08d2f19f725803ef7fa18/a2a0f1aeab4c08d2f19f725803ef7fa18.shp')
;  ecmwf03 = OBJ_new('IDLffShape',wkdir+'af683499594a9ac7f27e14a4702040345/af683499594a9ac7f27e14a4702040345.shp')
;  ecmwf04 = OBJ_new('IDLffShape',wkdir+'a8cab9e58466dfbc7d407a12454271c59/a8cab9e58466dfbc7d407a12454271c59.shp')

; 
 ecmwf96->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals96 = ecmwf96->getAttributes( /ALL) ;can I cat the years here?
; 
; ecmwf02->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
; vals02 = ecmwf02->getAttributes( /ALL) ;can I cat the years here?
; 
; ecmwf03->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
; vals03 = ecmwf03->getAttributes( /ALL) ;can I cat the years here?
; 
; ecmwf04->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
; vals04 = ecmwf04->getAttributes( /ALL) ;can I cat the years here?
 
 valcat=vals96
; valcat=[vals02,vals03,vals04]
 
  Tlat = valcat[*].attribute_0
  Tlon = valcat[*].attribute_1
  yr   = valcat[*].attribute_2
  mo   = valcat[*].attribute_3
  dek  = valcat[*].attribute_4
  Tavg = valcat[*].attribute_5 
  Tmax = valcat[*].attribute_6 
  Tmin = valcat[*].attribute_7 

;just pulling data for one site Roberts
;19 degrees  14 minutes  35 seconds  South
;46 degrees  16 minutes  22 seconds East 

;lat = -19.24305556  
;lon = 46.27277778

;Robert et al. 2006
;site = 'Antananarivo_Madagascar'
shp_lats = -19.25
shp_lons = 46.25

;La Pépinière/Amboasary  25°63’  46°38’
site = 'laPepiniereAmbosary_Madagascar'
shp_lats = -25.5
shp_lons = 46.25

;for k=0,line-1 do begin 
;  ;if k eq 0 then continue
;  parse=strsplit(buffer(k),',',/extract)
;  ;COUNTRY  LOCALITY  LAT LONG  shp_lat shp_lon MONTH YEAR  CATCH SPECIES IDEN  NUMBER  REFERENCE
;  
;  country = parse(0)
;  locality = parse(1)
;  lat = parse(1)
;  lon = parse(2)
;  shp_lat = parse(3)
;  shp_lon = parse(4)
; 
; countries(k)=country & localities(k)=locality & lats(k)= lat & lons(k)=lon  
; shp_lats(k)=shp_lat & shp_lons(k)=shp_lon
;endfor ;

close,1  
i=Long(1)
nyrs=1

;for m = 0,line-1 do begin ;for each site
  j = 0
  d = 0
  tavgsite = fltarr(36*nyrs) 
  tminsite = fltarr(36*nyrs)
  tmaxsite = fltarr(36*nyrs) 
  Tdek = intarr(36*nyrs)
  Tyr = intarr(36*nyrs)
  
  ;how does this change with only 1 lat lon?
  for i=0L,n_elements(Tlat)-1 do begin ;for all yrs
    if (Tlat[i] eq shp_lats) AND (Tlon[i] eq shp_lons) then begin ;if the pixel matches the site
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
  ofile=strcompress(odir+'Temp'+site+'.csv', /remove_all)
  openw,2,ofile
  write_csv,ofile,Tyr,Tdek,tavgsite,tminsite,tmaxsite
  close, 2
;endfor
print, i
end
    
  
