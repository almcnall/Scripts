pro make_dekads_from_day_v2
;In addition to summing up dekads of rainfall this multiplies them (?)

expdir = 'EXP017'
pname  = 'trmm'

;be sure to change the strmid line depending on biased or unbiased data...
;indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily_cap/",/remove_all)
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily_ubrf/",/remove_all)
outdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/ub_dekads_"+pname+"/",/remove_all)
FILE_MKDIR,outdir

cd,indir

files = file_search('*img') ;all the .img files in the daily dir (ignore .hdr)
nx    = 301. 
ny    = 321.

;initialize arrays
buffer   = fltarr(nx,ny)
dek1     = fltarr(nx,ny)
dek2     = fltarr(nx,ny)
dek3     = fltarr(nx,ny)

;list 'um instead of looping
month  = ['01','02','03','04','05','06','07','08','09','10','11','12']
year   = ['2001','2002','2003','2004','2005','2006','2007','2008','2009'] 

;for each yr and each month files for days 1-10 will open,read, and sum precip\
;then days 11-20 and finally the rest of the month 

count=0 ;initialize file counter    
  for j=0, n_elements(year)-1 do begin      ;year loop
       dek=0                        
    for k=0, n_elements(month)-1 do begin   ;month loop
      for h=1,31 do begin                   ;day loop (max)
       buffer = fltarr(nx,ny)
       openr,lun,files[count],/get_lun ;opens one file at a time   
       readu,lun,buffer                ;reads the file into the buffer
       ;buffer = (buffer*86400.0)        ;converts units from kg/m2/s to mm/day [not needed for unbiased data...]              
       close,/ALL 
       free_lun,lun
       
       if (year[j] eq '2001') AND (month[k] eq '01') AND (h lt 10) then continue ;becasue the model run starts on Jan 10, 2001
       if (j eq n_elements(year)-1) AND (k gt 1) then break ; and ends March 1, 2009
       
       ;filename conventions are different for the unbiased data 
       ;smonth= strmid(files[count],9,2)            ;extracts month from biased file name
       smonth= strmid(files[count],14,2)            ;extracts month from unbiased file name
       
       if (h lt 11) then dek1=dek1+buffer else $   ;then adds up dekads....
       if (h gt 10) AND (h lt 21) then dek2=dek2+buffer else $
       if (h gt 20) AND (smonth eq month[k]) then dek3=dek3+buffer else break ;this will catch if lt 31 days in month
        
      ;advance to next day
       count=count+1 
       print, h
       
     endfor ;h 
     
     if (j eq n_elements(year)-1) AND (k gt 1) then break ; becasue model ends March 1, 2009    
     
     ; open and write dekads in subdirectory
     dek=dek+1
     openw, lun, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all) ; first time should be 1,2,3 then 4,5,6 then 7,8,9
     ;dek1=dek1*100 for scaling if converting to .bil (integer) but WRSI can't handle it.
     writeu,lun,dek1
     free_lun,lun
     print, 'writing'+strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
     
     dek=dek+1
     openw, lun, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)
     ;dek2=dek2*100
     writeu,lun,dek2
     free_lun,lun
     print, 'writing'+strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
     
     dek=dek+1
     openw, lun, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)      
     ;dek3=dek3*100
     writeu,lun,dek3
     free_lun,lun
     print, 'writing'+strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
     
     dek1     = fltarr(nx,ny); if I initialize inside this loop will they clear between months?
     dek2     = fltarr(nx,ny)
     dek3     = fltarr(nx,ny)

 endfor ;end k
endfor ;end j

;end program
end
 