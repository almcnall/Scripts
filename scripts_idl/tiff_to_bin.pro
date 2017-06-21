pro tiff_to_bin
;  
;  this script was used with the fclimv4 data that Andrew had subset for Africa
;  to regrid to 0.25 degree and change to float (for unbiasing TRMMv6) or regrid to 0.1 (for unbiasing RFE2)
;  
;  you might want to check the script clipAfrica.pro which subset from globalFCLIMv8,regridded and changed to float. -AM 3/7
;  but given problems with newest fclim switched back to FCLIMv4 -AM 3/21
;
;add your workind directory here.... 
;wkdir=strcompress('/jower/dews/Data/FClim/Global-Andrew',/remove_all)
wkdir=strcompress("/jabber/LIS/Data/FCLIMv4/",/remove_all)
odir =strcompress("/jabber/LIS/Data/FCLIMv4_0.1_bin/", /remove_all)

file_mkdir, odir
cd, wkdir

onx=751. ;you might need to change these output file dimensions
ony=801.

inx=1500 ;you might need to change these input file dimensions
iny=1600
filter = '*tif' ; this needs to change with the filename too!
infiles = file_search(filter)
print, infiles

ingrid  = uintarr(inx,iny) ;might not need this with the read_tif function 
regrid  = uintarr(onx,ony) 
fltgrid = fltarr(onx,ony)  ;the array where the converted data will go...

 for i = 0, n_elements(infiles) - 1 do begin
  ; new file names look like: global_fclim_20110301_001.tif
  ; ofile=strcompress(strmid(infiles[i],0,25)+'.bin',/remove_all)
  
  openr,1,infiles[i]  ;opens one file at a time   
  ingrid = READ_TIFF(infiles[i],  R, G, B, GeoTiff=GeoTiff)
  close, 1
       
  regrid=congrid(ingrid,onx,ony) ;regrids the 0.1 degree to 0.25
  fltgrid=float(regrid)
  fltgrid[WHERE(fltgrid lt 0.)] = !VALUES.F_NAN
  
  ;set up output file names and paths
  ofile=strcompress(strmid(infiles[i],0,8)+'.bin',/remove_all); this line renames the outfile...you might need to change this...strmid is the function that splits up a string...right now it names ofile using the first though 8th character (first=position zero). 
  outgrid= strcompress(odir+ofile,/remove_all)
  
  openw,2,outgrid
  writeu,2,fltgrid
  close, 2
  
 endfor

end
