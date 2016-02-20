pro daily_total_gs4r_v3,year,date

;this program calls 'flip..' which removes the header and rotates the image. Instead of a loop
;it calls the file run_daily_total which has a list of the year and date arguments that are needed
; as input both here and 'flip_'. That list is created with /source/mcnally/scripts_bash/run_daily_list.sh

flip_AF_gs4r_v2,date,year 
expdir = 'EXP028' ;this is unbias trmm
close,/ALL

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/"+year+"/"+date+"/deyuk/",/remove_all)
;FILE_MKDIR,wdir

cd,wdir 

files = file_search('*gs4r')
; flip direction
direction = 2

nfiles = n_elements(files)

nx     = 301.
ny     = 321.
nbands = 12. ; 31 for unbiased runs..12 bands for my wierd EXP028 run

buffer   = fltarr(nx,ny,nbands)

data_in  = fltarr(nx,ny,nbands,nfiles)

for i=0,n_elements(files)-1 do begin
  ; read all of the data (all days all bands) into data_in
  openr,lun,files[i],/get_lun
  readu,lun,buffer
  byteorder,buffer,/XDRTOF
  data_in[*,*,*,i] = buffer
end

day_file=strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily")
FILE_MKDIR,day_file
;cd, day_file

data_in[where(data_in lt -9998)] = !VALUES.F_NAN


;of1 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/Qsub_" +date+".img",/remove_all)
;of2 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/rain_"  +date+".img",/remove_all)
;of3 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/evap_"  +date+".img",/remove_all)
;of4 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/runoff_"+date+".img",/remove_all)
;of5 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/soilm1_"+date+".img",/remove_all)
;of6 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/soilm2_"+date+".img",/remove_all)
;of7 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/soilm3_"+date+".img",/remove_all)
;of8 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/soilm4_"+date+".img",/remove_all)
;of9 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/airtem_"+date+".img",/remove_all)
of1 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/PoET_"+date+".img",/remove_all)
;of11 = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/daily/PoET_"+date+".img",/remove_all)


close,/ALL

;openw,1,of1
;openw,2,of2
;openw,3,of3
;openw,4,of4
;openw,5,of5
;openw,6,of6
;openw,7,of7
;openw,8,of8
;openw,9,of9
openw,1,of1

;initalize arrays
;rain   = fltarr(nx,ny)
;evap   = fltarr(nx,ny)
;runoff = fltarr(nx,ny)
;Qsub   = fltarr(nx,ny)
;soilm1 = fltarr(nx,ny)
;soilm2 = fltarr(nx,ny)
;soilm3 = fltarr(nx,ny)
;soilm4 = fltarr(nx,ny)
;airtem = fltarr(nx,ny)
PoET    = fltarr(nx,ny)

for x=0,nx-1 do for y=0,ny-1 do begin
;pull out the band that corrosponds with a spp variable from each 3hrly file
;
;   rain [x,y]  = mean(data_in[x,y,6, *],/NAN) ;check variable index in NOAHstats.d01.stats
;   evap [x,y]  = mean(data_in[x,y,7, *],/NAN)   
;   runoff[x,y] = mean(data_in[x,y,8, *],/NAN) 
;     Qsub[x,y] = mean(data_in[x,y,9, *],/NAN)
;   soilm1[x,y] = mean(data_in[x,y,15,*],/NAN) 
;   soilm2[x,y] = mean(data_in[x,y,16,*],/NAN) 
;   soilm3[x,y] = mean(data_in[x,y,17,*],/NAN) 
;   soilm4[x,y] = mean(data_in[x,y,18,*],/NAN) 
;   airtem[x,y] = mean(data_in[x,y,26,*],/NAN) 
   PoET[x,y] = mean(data_in[x,y,7,*],/NAN); now we are dealing with daily, rather than 3hrly data. 

end

;writeu,1,Qsub
;writeu,2,rain
;writeu,3,evap
;writeu,4,runoff
;writeu,5,soilm1
;writeu,6,soilm2
;writeu,7,soilm3
;writeu,8,soilm4
;writeu,9,airtem
writeu,1,PoET

;print,"wrote " + of1
;print,"wrote " + of2
;print,"wrote " + of3
;print,"wrote " + of4
;print,"wrote " + of5
;print,"wrote " + of6
;print,"wrote " + of7
;print,"wrote " + of8
;print,"wrote " + of9
print,"wrote " + of1
; end program
end
