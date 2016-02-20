pro deseasonalize

ifile=file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_Wnk1_Wnk2_file108.dat')

buffer=fltarr(2,144,3)
close,1
openr,1,ifile
readu,1,buffer
close,1

;I am going to use the 750m NDVI to start...figure out how to do all of them later... 
ndvi=buffer[0,*,1]
;reshape so that I can get the 4 year average for the season.
byyr=reform(ndvi,36,4)
stm=mean(byyr, dimension=2)
;then I take the moving average of this?
sstm=smooth(stm,3, /nan);use this as the filter...

filtered=byyr
filtered[*,0]=byyr[*,0]-sstm
filtered[*,1]=byyr[*,1]-sstm
filtered[*,2]=byyr[*,2]-sstm
filtered[*,3]=byyr[*,3]-sstm

outarr=transpose(filtered) ;year x dekads

;ofile='/jabber/Data/mcnally/AMMAVeg/Wank1_filteredNDVI2005_08.dat'
;openw,1,ofile
;writeu,1,outarr
;close,1

;***********deseasonalize the soil!******************************
;ifile='/jabber/Data/mcnally/AMMASOIL/WK1_field108_40cm_10dayavg.dat'
ifile='/jabber/Data/mcnally/AMMASOIL/WK1_gully108_68cm_10dayavg.dat'

;columns are: year, dekad, soil moisture..see readme.txt
buffer=fltarr(3,144)
close,1
openr,1,ifile
readu,1,buffer
close,1

soil=buffer[2,*]

soil=reform(soil,36,4)
soil=transpose(soil)
;fill in the holes that mess up the analysis....
;find the bad values and make a list of their indices
stm_soil=mean(soil,dimension=1)

sstm_soil=smooth(stm_soil,3,/nan); use this as the filter :)
filtered=soil

filtered[0,*]=soil[0,*]-sstm_soil
filtered[1,*]=soil[1,*]-sstm_soil
filtered[2,*]=soil[2,*]-sstm_soil
filtered[3,*]=soil[3,*]-sstm_soil

close,1
ofile='/jabber/Data/mcnally/AMMASOIL/WK1_gully108_68cm_anomalyTS.dat'
openw,1,ofile
writeu,1,filtered
close,1


;test plots before going home: make it into one long array (macaroni)
soilmac=[[filtered[0,*]], [filtered[1,*]],[filtered[2,*]],[filtered[3,*]]]
ndvimac=[[outarr[0,*]], [outarr[1,*]],[outarr[2,*]],[outarr[3,*]]]

end
