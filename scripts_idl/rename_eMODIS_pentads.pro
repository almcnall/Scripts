;this is another way to do pen2dek for eMODIS continetal
;i started to modify this script from greg but didn't finish
;AM 4/18/13

cd, '/jower/sandbox/mcnally/eMODIS_continental/')


fnames = FINDFILE('pd*.tif')
for i=0,N_ELEMENTS(fnames)-1 do print,i,'    ',fnames(i)

;ulx = 0
;uly = 3315
;lrx = 12846
;lry = 11604
for i=0,N_ELEMENTS(fnames)-1 do begin &$
   tmp = READ_TIFF(fnames[i],R, G, B) &$
   pentyrstr = strmid(fnames[i],2,(strpos(fnames[i],'.tif') - 2))   &$
   case strlen(pentyrstr) of   &$
      3: begin        &$
         pent = strmid(pentyrstr,0,1)   &$
         yr   = strmid(pentyrstr,1,2)   &$
         end   &$
      4: begin        &$
         pent = strmid(pentyrstr,0,2)   &$
         yr   = strmid(pentyrstr,2,2)   &$
         end   &$
      ELSE: print,'There is a problem at ' + fnames[i]   &$
   endcase   &$
   close,1    &$
   outstr = STRING(FORMAT='(''subset/easub.'',I2.2,I4.4)',FIX(pent),2000+FIX(yr))   &$
   openw,1,outstr   &$
   writeu,1,tmp(ulx:lrx,uly:lry)   &$
   close,1   &$
endfor
