pro luce_EIR
; the purpose of this script is to get the relevant monthly temperature and rainfall data for sites
; listed in the EIR database from MARA http://www.mara.org.za/
; 
;these are at 1degree!! lat lons can be rounded using the round function
;when dealing with the 0.25 degree data lat lons can be rounded by multiplying by 4
;rounding and dividing by 4, for now I did the rounding in the excel csv file 6/28/11
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
;
;arrays=['TAV' ,'TMAX', 'TMIN' ,'RRR' ,'E0' ,'ES0' ,'ET0', 'RAD' ,'SDAV' ,'SDMIN' ,'SDMAX' ,'CWB']


wkdir='/gibber/Data/ecmwf/100KM/'
odir ='/gibber/Data/ecmwf/100KM/sites/'
file_mkdir, odir

  ; open the shapefile, get the properties for all attributes, and get all the data
  
  ;ecmwf1978-1996 100km?
  ecmwf78 = OBJ_new('IDLffShape',wkdir+'adbbfea9f6851c8e25d863cbc987e0571/adbbfea9f6851c8e25d863cbc987e0571.shp')
  ecmwf79 = OBJ_new('IDLffShape',wkdir+'aabe9c9de00332134e16bdb3951a42e39/aabe9c9de00332134e16bdb3951a42e39.shp')
  ecmwf80 = OBJ_new('IDLffShape',wkdir+'a95acb21dfbb5ef3fc8a17007efc8426f/a95acb21dfbb5ef3fc8a17007efc8426f.shp')
  ecmwf81 = OBJ_new('IDLffShape',wkdir+'aaf0a34db159fd5b246c1b12ee24af6bc/aaf0a34db159fd5b246c1b12ee24af6bc.shp')
  ecmwf82 = OBJ_new('IDLffShape',wkdir+'a11f3b6070434ae991426288446cb584b/a11f3b6070434ae991426288446cb584b.shp')
  ecmwf83 = OBJ_new('IDLffShape',wkdir+'a48d40ba497c7bc23c7a17bf58f6ee30c/a48d40ba497c7bc23c7a17bf58f6ee30c.shp')
  ecmwf84 = OBJ_new('IDLffShape',wkdir+'a0f81bb0bade5526dfe1fa446578d0d74/a0f81bb0bade5526dfe1fa446578d0d74.shp')
  ecmwf85 = OBJ_new('IDLffShape',wkdir+'a38c09f5ea29cebe2de597c83ede1edcf/a38c09f5ea29cebe2de597c83ede1edcf.shp')
  ecmwf86 = OBJ_new('IDLffShape',wkdir+'aa30054335d494d042dcd8e5439bd77be/aa30054335d494d042dcd8e5439bd77be.shp')
  ecmwf87 = OBJ_new('IDLffShape',wkdir+'a31197d4649426ad3b372fae62a766391/a31197d4649426ad3b372fae62a766391.shp')
  ecmwf88 = OBJ_new('IDLffShape',wkdir+'aebaab3ddf891d381d34898dd45f9aec9/aebaab3ddf891d381d34898dd45f9aec9.shp')
  ecmwf89 = OBJ_new('IDLffShape',wkdir+'a6ef441b8d29bf3094aaec776dce1ff4d/a6ef441b8d29bf3094aaec776dce1ff4d.shp')
  ecmwf90 = OBJ_new('IDLffShape',wkdir+'ac2e09357efb8b5192eecf3bede80b4d2/ac2e09357efb8b5192eecf3bede80b4d2.shp')
  ecmwf91 = OBJ_new('IDLffShape',wkdir+'a025487fc08e4a324f19f5ded87dadaab/a025487fc08e4a324f19f5ded87dadaab.shp')
  ecmwf92 = OBJ_new('IDLffShape',wkdir+'a0434a07be2ae213e032bcb93f4dd9b59/a0434a07be2ae213e032bcb93f4dd9b59.shp')
  ecmwf93 = OBJ_new('IDLffShape',wkdir+'a2184910c388c8b8091cd8af795105fd3/a2184910c388c8b8091cd8af795105fd3.shp')
  ecmwf94 = OBJ_new('IDLffShape',wkdir+'a490916ca4cb58ae36ca4ad2b7b1132f2/a490916ca4cb58ae36ca4ad2b7b1132f2.shp')
  ecmwf95 = OBJ_new('IDLffShape',wkdir+'ab8d47f9eae57064ea13d840247066d1f/ab8d47f9eae57064ea13d840247066d1f.shp')
  ecmwf96 = OBJ_new('IDLffShape',wkdir+'a922b395d7f14d7eb3efc38f94f7101d2/a922b395d7f14d7eb3efc38f94f7101d2.shp')
 
;
 ecmwf78->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals78 = ecmwf78->getAttributes( /ALL)
 
 ecmwf79->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals79 = ecmwf79->getAttributes( /ALL) 

 ecmwf80->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals80 = ecmwf80->getAttributes( /ALL) 
 
 ecmwf81->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals81 = ecmwf81->getAttributes( /ALL) 
 
 ecmwf82->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals82 = ecmwf82->getAttributes( /ALL)   

 ecmwf83->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals83 = ecmwf83->getAttributes( /ALL) 
 
 ecmwf84->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals84 = ecmwf84->getAttributes( /ALL) 
 
 ecmwf85->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals85 = ecmwf85->getAttributes( /ALL)  
 
 ecmwf86->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals86 = ecmwf86->getAttributes( /ALL) 

 ecmwf87->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals87 = ecmwf87->getAttributes( /ALL) 
 
 ecmwf88->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals88 = ecmwf88->getAttributes( /ALL)  
 
 ecmwf89->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals89 = ecmwf89->getAttributes( /ALL) 

 ecmwf90->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals90 = ecmwf90->getAttributes( /ALL)  
 
 ecmwf91->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals91 = ecmwf91->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf92->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals92 = ecmwf92->getAttributes( /ALL) ;can I cat the years here?  

 ecmwf93->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals93 = ecmwf93->getAttributes( /ALL) ;can I cat the years here?
 
 ecmwf94->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals94 = ecmwf94->getAttributes( /ALL) ;can I cat the years here?
; 
 ecmwf95->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals95 = ecmwf95->getAttributes( /ALL) ;can I cat the years here? 
 
 ecmwf96->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals96 = ecmwf96->getAttributes( /ALL) ;can I cat the years here?
 

valcat=[vals78,vals79,vals80,vals81,vals82,vals83,vals84,vals85,vals86,vals87,$
        vals88,vals89,vals90,vals91,vals92,vals93,vals94,vals95,vals96]

;arrays=['TAV' ,'TMAX', 'TMIN' ,'RRR' ,'E0' ,'ES0' ,'ET0', 'RAD' ,'SDAV' ,'SDMIN' ,'SDMAX' ,'CWB']
;is this the correct order for the 100km?? 
  shplat = valcat[*].attribute_0
  shplon = valcat[*].attribute_1
  yr   = valcat[*].attribute_2
  mo   = valcat[*].attribute_3
  dek  = valcat[*].attribute_4
  Tavg = valcat[*].attribute_5 
  Tmax = valcat[*].attribute_6 
  Tmin = valcat[*].attribute_7 
  rain = valcat[*].attribute_8

;ok, now for the file with the EIR site info, in a friendly csv fiel
xycords = '/home/mcnally/luce_sites/eir_100latlon_singlets.csv';change this for the mara data
valid = query_csv(xycords, info) & print, valid, info 
line = info.lines

;not sure 'header' is doing anything
buffer = read_csv(xycords,header=['site', 'lat', 'lon'])

country = buffer.field1[*]
EIRlon  = buffer.field2[*]
EIRlat  = buffer.field3[*]

close,1  

nyrs = 19
 
for m = 0,line-1 do begin ;for each lat/lon pare (there are 53)
   Tavgbuffer = fltarr(3)
   Tminbuffer = fltarr(3)
   Tmaxbuffer = fltarr(3)
   rainbuffer = fltarr(3)
   yrbuffer   = intarr(3)
  
  Tavgmonth = fltarr(12*nyrs)
  Tminmonth = fltarr(12*nyrs)
  Tmaxmonth = fltarr(12*nyrs)
  rainmonth = fltarr(12*nyrs)
  yrmonth  = intarr(12*nyrs)

;find the index for where the shapefile matches the csv file 
  mo=0
  blug=where(shplat eq EIRlat[m] and shplon eq EIRlon[m], count) & print, EIRlat[m], EIRlon[m], count; 
  ;if (count ge 36) then begin

  siteTavg = Tavg(blug)
  siteTmin = Tmin(blug)
  siteTmax = Tmax(blug)
  siterain = rain(blug)
  siteyr = yr(blug)
 ;endif
;find averages for Temperature and total for rainfall 
  count=0
  for n=0,n_elements(blug)-1 do begin
   Tavgbuffer[count] = siteTavg[n]
   Tminbuffer[count] = siteTmin[n]
   Tmaxbuffer[count] = siteTmax[n]
   rainbuffer[count] = siterain[n]
   yrbuffer[count] = siteyr[n]
   
   count++
   
   if count eq 3 then begin
    Tavgmonth[mo] = mean(Tavgbuffer[*])
    Tminmonth[mo] = mean(Tminbuffer[*])
    Tmaxmonth[mo] = mean(Tmaxbuffer[*])
    rainmonth[mo] = total(rainbuffer[*])
    yrmonth[mo]   = mean(yrbuffer[*])
    mo++
    count=0
  
  endif 
 endfor;n  
  ofile=strcompress(odir+'EIR_TP_lat'+string(EIRlat[m])+'lon'+string(EIRlon[m])+'.csv', /remove_all)
  openw,2,ofile
  write_csv,ofile,yrmonth,Tavgmonth,Tminmonth,Tmaxmonth,rainmonth
  close, 2

endfor ;m

end
    
  
