pro luce_ecmf_10yravg

;The purpose of this script is to read the ecmwf data and average over the 10 year period so that i have short-term mean fields for 
;tmin, tmax, tavg for the continent of africa. The mean fields are then written out to another file. I'll read this file
;into another script that extracts the specific sites for the luce study. 
;
;these data are at 0.25 degree in by dekad (36/yr * 10yrs)
;0 LATITUDE - (Deg.decDeg)
;1 LONGITUDE - (Deg.decDeg)
;2 YEAR - (yyyy)
;3 MONTH - (mm)
;4 DEKAD - [1-2-3]
;5 TAV - average temperature - (°C)
;6 TMAX - maximum temperature - (°C)
;7 TMIN - minimum temperature - (°C)
;8 RRR - precipitation sum - (mm = liters/m2)
;9 E0 - evapo-transpiration sum (over water) - (mm = liters/m2)
;10 ES0 - evapo-transpiration sum (bare soil) - (mm = liters/m2)
;11 ET0 - evapo-transpiration sum (Penman-Monteith) - (mm = liters/m2)
;12 RAD - global radiation sum - (kJ/m2 per dekad)
;13 SDAV - average snow depth - (cm)
;14 SDMIN - minimum snow depth - (cm)
;15 SDMAX - maximum snow depth - (cm)
;16 CWB - climatic water balance - (mm = liters/m2)
;17 FFAV - average wind speed - (m/s)
;18 VAPAV - avearge water vapour pressure - (hPa)


wkdir='/jabber/LIS/Data/ecmwf/'
odir ='/jabber/LIS/Data/ecmwf/sites/'
file_mkdir, odir
  ; open the shapefile, get the properties for all attributes, and get all the data
  ; I know that at some point chris got the binary data from these guys for the 0.25 degree...what was the time period there?
  ;see some emails from Sept 16, 2011
  
;ecmwf94 = OBJ_new('IDLffShape',wkdir+'a490916ca4cb58ae36ca4ad2b7b1132f2/a490916ca4cb58ae36ca4ad2b7b1132f2.shp')
;ecmwf95 = OBJ_new('IDLffShape',wkdir+'ab8d47f9eae57064ea13d840247066d1f/ab8d47f9eae57064ea13d840247066d1f.shp')
  
  
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

 valcat=[ [[vals96]], [[vals97]], [[vals98]], [[vals99]], [[vals00]], [[vals01]], $
          [[vals02]], [[vals03]], [[vals04]], [[vals05]] ] ;maybe if i cat these so that I have a 10x12 array

;I should probably write this out so that I can deal with the condensed dataset. I think that this is daily?
  Tlat = mean(valcat.attribute_0, dimension=3) ;this seems to work, just now each year is separate.
  Tlon = mean(valcat.attribute_1, dimension=3)
  Tavg = mean(valcat.attribute_5, dimension=3) 
  Tmax = mean(valcat.attribute_6, dimension=3)
  Tmin = mean(valcat.attribute_7, dimension=3)
  
  ;29.66; -4.37a
  tTlat = valcat.attribute_0 ;this seems to work, just now each year is separate.
  tTlon = valcat.attribute_1
  tTavg = valcat.attribute_5 
  tTmax = valcat.attribute_6
  tTmin = valcat.attribute_7
oarray=[transpose(tlat), transpose(tlon), transpose(tavg), transpose(tmax), transpose(tmin)]

write_csv,'/home/mcnally/mburundi.csv', mburundi

ofile='/home/mcnally/luce_sites/ECMWF_10yravg.dat'
openw,1,ofile
writeu,1,oarray

end