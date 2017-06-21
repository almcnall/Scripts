pro make_dekads_ubRFE2
;making adjustments to v_2 for the second round of unbiasing of the raw, rather than lis-processed data -AM 4/4/11
;In addition to summing up dekads of rainfall this multiplies them (?)
;9/19/12 making dekads for the ubRFE2 created in 02/2012 -- going to calculate API with them
;11/3/12 making dekads for the RFE2 -- for cacluating API
;11/23/12 aand updating to include 2011-12

;indir  = strcompress("/jabber/LIS/Data/CPCOriginalRFE2/",/remove_all)
;outdir = strcompress("/jabber/LIS/Data/CPCOriginalRFE2/update/",/remove_all)

indir  = strcompress("/jabber/LIS/Data/ubRFE04.19.2013/",/remove_all)
outdir = strcompress("/jabber/LIS/Data/ubRFE04.19.2013/dekads/",/remove_all)

FILE_MKDIR,outdir
cd,indir

;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

nx     = 751.
ny     = 801.

;initialize arrays
buffer = fltarr(nx,ny)
dek1   = fltarr(nx,ny)
dek2   = fltarr(nx,ny)
dek3   = fltarr(nx,ny)

year   = ['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012'] 

;for each yr and each month files for days 1-10 will open,read, and sum precip\
;then days 11-20 and finally the rest of the month 

for j = 0, n_elements(year)-1 do begin      ;year loop
  dek = 0                        
    
  for k = 1,12 do begin   ;month loop
    mm = STRING(FORMAT='(I2.2)',k)   ;two digit month
    files = file_search('all_products.bin*'+year[j]+mm+'*') ;find all files from given month
     
    for h = 0,n_elements(files)-1 do begin              ;day loop (max)
     buffer = fltarr(nx,ny)
     openr,1,files[h]           
     readu,1,buffer                ;reads the file into the buffer      
     byteorder,buffer,/XDRTOF      ;change to little endian for WRSI
     ;buffer = reverse(buffer,2)      ;transpose for WRSI -- this will flip UB upsidedown i thinks, but that shouldn't matter
     close,1
     
     ;eak is this part correct? 
;     if (h lt 10) then dek1=dek1+buffer else $   ;then adds up dekads....
;     if (h gt 9) AND (h lt 20) then dek2=dek2+buffer else $
;     if (h gt 19) then dek3=dek3+buffer else break 
     
       if (h lt 11) then dek1=dek1+buffer else $   ;then adds up dekads....
       if (h gt 10) AND (h lt 21) then dek2=dek2+buffer else $
       if (h gt 20) then dek3=dek3+buffer else break
       
   endfor ;h 
             
   ; open and write dekads in subdirectory -- I should merge this with re-format step...
   dek=dek+1
   openw,2, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all) ; first time should be 1,2,3 then 4,5,6 then 7,8,9
   writeu,2,dek1
   close,2
     
   dek=dek+1
   openw,3, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)
   writeu,3,dek2
   close,3
     
   dek=dek+1
   openw,4, strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all)      
   writeu,4,dek3
   close,4
   
   dek1     = fltarr(nx,ny)
   dek2     = fltarr(nx,ny)
   dek3     = fltarr(nx,ny)

 endfor ;end k
 print, 'writing'+strcompress(+outdir+year[j]+STRING(FORMAT='(I2.2)',dek)+".img",/remove_all);just to see something happening
endfor ;end j
print, 'hold'
end

;see if they look ok....they do.
;ifile = file_search('/jabber/LIS/Data/ubRFE2/dekads/new/201204.img')
;nx = 751
;ny = 801
;ingrid = fltarr(nx,ny)
;
;openr,1,ifile
;readu,1,ingrid
;close,1
;
;temp = image(ingrid)
;****map it***********
;  p1 = image(ingrid, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           rgb_table=20)
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

 