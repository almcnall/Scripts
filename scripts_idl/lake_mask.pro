pro lake_mask 

;**************************************************************************
; The purpose of this program is to create a mask of NaNs and 1's. NaN * value = NaN & 1*value=value
; I'll use this to mask out the lakes in Africa....AM 2/1/10
;*************************************************************************
 
wkdir = strcompress("/gibber/lis_data/OUTPUT/", /remove_all)

cd, wkdir

lake=file_search('temp4mask.img')

nx     = 301.
ny     = 321.
nbands = 1.
ingrid = fltarr(nx,ny,nbands)

 openr,1,lake    ;opens the file
 readu,1,ingrid  ;reads it into ingrid  
 close,1
 
mve,ingrid                 ;print out the max min mean and std deviation of var
 
other = 0   

index  = WHERE(finite(ingrid,/NAN),complement=other) ;these are the indices where there are nan's, other are the goods
ingrid[other]=1 & ingrid[index]= -999. ;this sets the nan's to -999 and the others to 1. 

ofile = strcompress('afrlake_mask.img', /remove_all)
 
  openw,2,ofile
  writeu,2,ingrid
  close, 2
end ;end program

;indir = strcompress("/gibber/lis_data/output/"+exp+"/noah/daily", /remove_all)
;cd, indir
;
;infile=file_search('*.img')
;
;afr=fltarr(nx,ny,nbands)
;openu,1,infile
;readu,1,buffer                                ;persiann data starting at 0.125 deg chopping africa
;close,1   
;
;
;for i=0,ibands-1 do begin 
