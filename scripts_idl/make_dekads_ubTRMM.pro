pro make_dekads_ubTRMM
;making adjustments to v_2 for the second round of unbiasing of the raw, rather than lis-processed data -AM 4/4/11
;In addition to summing up dekads of rainfall this multiplies them (?)

indir  = strcompress("/jabber/LIS/Data/TrmmAfr",/remove_all)
outdir = strcompress("/jabber/LIS/Data/TrmmAfr_dekads/",/remove_all)

;indir  = strcompress("/jabber/LIS/Data/ubTRMM/",/remove_all)
;outdir = strcompress("/jabber/LIS/Data/ubTRMM_dekads/",/remove_all)

FILE_MKDIR,outdir
cd,indir

;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

nx     = 301.
ny     = 321.

;initialize arrays
buffer = fltarr(nx,ny)
dek1   = fltarr(nx,ny)
dek2   = fltarr(nx,ny)
dek3   = fltarr(nx,ny)

year   = ['2001','2002','2003','2004','2005','2006','2007','2008','2009'] 

;for each yr and each month files for days 1-10 will open,read, and sum precip\
;then days 11-20 and finally the rest of the month 

for j=0, n_elements(year)-1 do begin      ;year loop
  dek=0                        
    
  for k=1,12 do begin   ;month loop
    mm=STRING(FORMAT='(I2.2)',k)   ;two digit month
    files=file_search(+year[j]+mm+'/*') ;find all files from given month
    
    for h=0,n_elements(files)-1 do begin              ;day loop (max)
     ;dd = strmid(files[h],21,2)
     buffer = fltarr(nx,ny)
     openr,1,files[h]           
     readu,1,buffer                ;reads the file into the buffer      
     byteorder,buffer,/XDRTOF      ;change to little endian for WRSI
     buffer=reverse(buffer,2)      ;transpose for WRSI
     close,1
       
     if (h lt 80) then dek1=dek1+buffer else $   ;then adds up dekads....
     if (h gt 79) AND (h lt 160) then dek2=dek2+buffer else $
     if (h gt 159) then dek3=dek3+buffer else break 
       
   endfor ;h 
             
   ; open and write dekads in subdirectory -- I should merge this with re-format step...
   dek=dek+1
   openw,2, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all) ; first time should be 1,2,3 then 4,5,6 then 7,8,9
   writeu,2,dek1*3 ;uh! 3 not 8!
   close,2
     
   dek=dek+1
   openw,3, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)
   writeu,3,dek2*3
   close,3
     
   dek=dek+1
   openw,4, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)      
   writeu,4,dek3*3
   close,4
   print, 'writing'+strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
     
   dek1     = fltarr(nx,ny)
   dek2     = fltarr(nx,ny)
   dek3     = fltarr(nx,ny)

 endfor ;end k
endfor ;end j

;end program
end
 