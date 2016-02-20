pro make_month_trmm
;this program makes monthly totals of the original (and unbiased) RFE2 data. The first version of this used the lis model
;outputs, but we are re-doing the analysis with the raw products.
;AM 5/11/2011

indir  = strcompress("/jabber/LIS/Data/ubTRMM/",/remove_all)
outdir = strcompress("/jabber/LIS/Data/ubTRMM/month_tot/",/remove_all)

FILE_MKDIR,outdir
cd,indir

;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

nx = 301.
ny = 321.

;initialize arrays
buffer = fltarr(nx,ny)

year   = ['2001','2002','2003','2004','2005','2006','2007','2008','2009'] 

;for each yr and each month files for days 1-10 will open,read, and sum precip\
;then days 11-20 and finally the rest of the month 

for j=0, n_elements(year)-1 do begin      ;year loop
  for k=1,12 do begin   ;month loop
    mm=STRING(FORMAT='(I2.2)',k)   ;two digit month
    files=file_search(year[j]+mm+'/*') ;find all files from given month
    days=n_elements(files)
    month= fltarr(nx,ny,days)
    
    for h=0,n_elements(files)-1 do begin              ;day loop (max)
     openr,1,files[h]           
     readu,1,buffer  
     close,1              ;reads the file into the buffer      
     byteorder,buffer,/XDRTOF      ;change to little endian?
     month[*,*,h]=buffer           ;it is only saving the last one....
    endfor ;h 
   
 for x=0,nx-1 do for y=0,ny-1 do begin ;convert units    
   buffer[x,y]= total(month[x,y,*]*3, /NAN)  
 endfor      
 
   openw,2,strcompress(+outdir+"ubtrmm_"+year[j]+mm+".img",/remove_all) 
   writeu,2,buffer
   close,2

 endfor ;end k
endfor ;end j

;end program
end
 