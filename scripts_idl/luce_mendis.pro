pro luce_mendis

;these are at 1degree!!
;Mendis et al. 2000
;-25*93'  32*51'E
site = 'MatolaMozambique'
 
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


wkdir='/jabber/LIS/Data/ecmwf/100KM/'
odir ='/jabber/LIS/Data/ecmwf/sites/'
file_mkdir, odir

;***************************************************
; open the shapefile, get the properties for all attributes, and get all the data
  ecmwf94 = OBJ_new('IDLffShape',wkdir+'a490916ca4cb58ae36ca4ad2b7b1132f2/a490916ca4cb58ae36ca4ad2b7b1132f2.shp')
  ecmwf95 = OBJ_new('IDLffShape',wkdir+'ab8d47f9eae57064ea13d840247066d1f/ab8d47f9eae57064ea13d840247066d1f.shp')
  ecmwf96 = OBJ_new('IDLffShape',wkdir+'a922b395d7f14d7eb3efc38f94f7101d2/a922b395d7f14d7eb3efc38f94f7101d2.shp')
 
 ecmwf94->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals94 = ecmwf94->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf95->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals95 = ecmwf95->getAttributes( /ALL) ;can I cat the years here? 
  
 ecmwf96->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals96 = ecmwf96->getAttributes( /ALL) ;can I cat the years here?
 
 valcat=[vals94,vals95,vals96]
 
  Tlat = valcat[*].attribute_0
  Tlon = valcat[*].attribute_1
  yr   = valcat[*].attribute_2
  mo   = valcat[*].attribute_3
  dek  = valcat[*].attribute_4
  Tavg = valcat[*].attribute_5 
  Tmax = valcat[*].attribute_6 
  Tmin = valcat[*].attribute_7 

close,1  
;******************************************************

i = Long(1)
nyrs = 3

;mendis et al. 
;lat = -25.93
;lon = 32.51
;
shp_lats = -26
shp_lons = 33
 
;for m = 0,line-1 do begin ;for each site there is only one site here....
  j = 0
  d = 0
  tavgsite = fltarr(36*nyrs) 
  tminsite = fltarr(36*nyrs)
  tmaxsite = fltarr(36*nyrs) 
  Tdek = intarr(36*nyrs)
  Tyr = intarr(36*nyrs)
  
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
;endfor ;m
print, i
end
    
  
