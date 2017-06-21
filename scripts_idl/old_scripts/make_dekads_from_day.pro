pro make_dekads_from_day
; modified from month_avg on Oct 21, 2010
; This program was based Candida's dekads, that are based on Charle Jone's pentads.pro 
; and computes 10-day accumulations of precipitation and potential evapotranspiration, and
; also climatological averages. 
; Contains a routine to convert data into image files (.bil)
;.............................................................................
; From Verdin and Klaver (2002):
; The dekad is the basic 10 day time step of agrometeorological
; monitoring in Africa. Each month of the year is divided into 3
; dekads: the 1st through the 10th, the 11th through the 20th, and a
; final dekad of 8, 9, 10 or 11 days. 'Dekad' is a technical term of
; the World Meteorological Organization. The dekad represents a
; compromise between a monthly time step, which is inadequate to
; resolve important crop growth stages, and a daily time step, which
; imposes a significant data-processing burden without a commensurate
; gain in agrometeorological information.
;
expdir = 'EXP014'
pname = 'gdas'
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/daily/",/remove_all)

outdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/TEMPLATE/dekads_"+pname+"/",/remove_all)
FILE_MKDIR,outdir

cd,indir

files = file_search('*img') ;all the .img files in the daily dir (ignore .hdr)
 ;filenames are used for their year/month/day info

nx     = 301. ;Pete's TRMM is 300, 320
ny     = 321.

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
                               
    for k=0, n_elements(month)-1 do begin   ;month loop
      for h=1,31 do begin                   ;day loop (max)
       buffer   = fltarr(nx,ny)
       openr,lun,files[count],/get_lun ;opens one file at a time   
       readu,lun,buffer                ;reads the file into the buffer
       buffer= (buffer*86400.0)        ;converts units from kg/m2/s to mm/day               
       close,/ALL 
       free_lun,lun
       
       if (year[j] eq '2001') AND (month[k] eq '01') AND (h lt 10) then continue ;becasue the model run starts on Jan 10, 2001
       if (j eq n_elements(year)-1) AND (k gt 1) then break ; and ends March 1, 2009
       
       smonth= strmid(files[count],9,2)            ;extracts month from file name
       
       if (h lt 11) then dek1=dek1+buffer else $   ;then adds up dekads....
       if (h gt 10) AND (h lt 22) then dek2=dek2+buffer else $
       if (h gt 21) AND (smonth eq month[k]) then dek3=dek3+buffer else break ;this will catch if lt 31 days in month
        
       ;advance to next day
       count=count+1 
       print, h
       
     endfor ;h 
     
     if (j eq n_elements(year)-1) AND (k gt 1) then break ; becasue model ends March 1, 2009    
     
     ; open and write dekads in subdirectory
     
     openw, lun, strcompress(+outdir+year[j]+month[k]+"_dk1.img",/remove_all)
     writeu,lun,dek1
     free_lun,lun
     print, 'writing'+strcompress(+outdir+year[j]+month[k]+"_dk1.img",/remove_all);just to see something happening
     
     openw, lun, strcompress(+outdir+year[j]+month[k]+"_dk2.img",/remove_all)
     writeu,lun,dek2
     free_lun,lun
     
     openw, lun, strcompress(+outdir+year[j]+month[k]+"_dk3.img",/remove_all)      
     writeu,lun,dek3
     free_lun,lun
     
     dek1     = fltarr(nx,ny); if I initialize inside this loop will they clear between months?
     dek2     = fltarr(nx,ny)
     dek3     = fltarr(nx,ny)

 endfor ;end k
endfor ;end j

;end program
end
 