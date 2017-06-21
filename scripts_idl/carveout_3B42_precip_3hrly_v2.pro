pro carveout_3B42_precip_3hrly_V2
;This program need to convert the 3hlry HDF files to binary; 
;
indir = '/jower/dews/Data/TRMM/3B42/3-hourly/'
Outdir  = '/gibber/lis_data/TRMM_amy'


xdim=1440 
ydim=400
all_precip=fltarr(xdim,ydim)

hours  = ['00','03','06','09','12','15','18','21']
months = ['01','02','03','04','05','06','07','08','09','10','11','12']
years  = ['2001','2002','2003','2004','2005','2006','2007','2008','2009']


for i=0, n_elements(years)-1 do begin 
   for m=0, n_elements(months)-1 do begin; this month loop creates new directories and helps generate filenames
   file_mkdir,Outdir+"/"+years[i]+months[m]
   end
   
   YYYY=years[i]
   ;go into the yYYYY directory!
   datadir=strcompress(indir+'y'+YYYY, /remove_all) 
   cd, datadir
   
   files = file_search('*HDF') 
   OFiles=strarr(n_elements(files))
   Global_ofile=strarr(n_elements(files))
   count=0
  for d=0, n_elements(files)-1 do begin;; this loop is for the months but is all the files in a year...
     day_of_month= strmid(files[d], 9,2) 
     month_of_yr=strmid(files[d],7,2)
     s_hr=strmid(files[d],12,1)
     d_hr=strmid(files[d],12,2)
       
   if (s_hr eq '0') OR (s_hr eq '3') OR (s_hr eq '6') or (s_hr eq '9') then begin
     Global_ofile(d) = Outdir+"/"+years[i]+month_of_yr+"/3B42V6."+years[i]+month_of_yr+day_of_month+'0'+s_hr
   endif else begin
   ;if (d_hr eq '12') or (d_hr eq '15') or (d_hr eq '18') or (d_hr eq '21')then begin
     Global_ofile(d) = Outdir+"/"+years[i]+month_of_yr+"/3B42V6."+years[i]+month_of_yr+day_of_month+d_hr
   endelse
  end;file loop

    
;now that we have a list of out files we can read the data in order and write to Ofile list 
for j=0, n_elements(files)-1 do begin    
      sd_id = hdf_sd_start( datadir+'/'+files[j], /read )	&	hdf_sd_fileinfo, sd_id, nsds, ngatt 
      sds_id = hdf_sd_select( sd_id, hdf_sd_nametoindex( sd_id, "precipitation" ) )
      hdf_sd_getdata, sds_id, precip ; gets the data and reads it into precip
      hdf_sd_getinfo, sds_id, ndims = ndim, natts = natt, dims = dim_size ;and gets the info from the hdf file

      badprecip = where(precip lt 0, bp_count)
      if(bp_count gt 0) then precip(badprecip) = -9.
      all_precip(*,*) = transpose(precip) 
      hdf_sd_end, sd_id

      bad_tps = where(all_precip lt 0, bad_tps_count)
      if(bad_tps_count gt 0) then all_precip(bad_tps) = -9.
      byteorder,all_precip,/XDRTOF
      
      ;name of out files from, year loop, month loop and hr loop and pulls day of month from file.      
      ;Ofile_names=Ofile_names+Global_ofiles[h] ;this makes array of out file names
       print, " " 
       print, Global_ofile
       print, " " 
      
       openw,2,Global_ofile[j]	&	writeu,2,all_precip;this writes stuff into a variable....where was I supposed to declare this?
  
       close,/all
  endfor ;j al files  
endfor   ;i all y-Years

end








