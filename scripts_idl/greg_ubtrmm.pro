pro ubias_trmm

indir    = strcompress("/jabber/LIS/Data/TrmmAfr/",/remove_all)
fclimdir = strcompress("/jabber/LIS/Data/FCLIMv4_regrid_bin/", /remove_all)
outdir   = strcompress("/jabber/LIS/Data/ubTRMM/", /remove_all)

FILE_MKDIR,outdir

cd,indir

nx     = 301.
ny     = 321.
nbands = 1. 
small  = 10

buffer   = fltarr(nx,ny)
data_in  = fltarr(nx,ny)
PON      = fltarr(nx,ny)    

;get rid of envi header files
;file_delete,(file_search('*/*.hdr', /fold_case))

;loop throught month directories
for i=1,12 do begin

  mm=STRING(FORMAT='(I2.2)',i)   ;two digit month
  files=file_search('*'+mm+'/*') ;find all files from given month
  data_in=data_in*0              ; initalizes array to zeros

tmpout = FLTARR(nx,ny,N_ELEMENTS(files))
  
  bad = intarr(nx,ny,n_elements(files));initializes bad value array
  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all hrs,all days) into data_in
    openr,1, files[j]
    readu,1, buffer
    close,1

    byteorder,buffer,/XDRTOF   ;change to little endian to match fclim
    buffer=reverse(buffer,2)   ;transpose to match fclim
tmpout(*,*,j) = buffer

    
    ;bad data handling...
    err=total(buffer lt 0)
    if err ge 1 then print, 'eak -999999999s?!'
    mve, buffer
    neg=where(buffer lt 0, count)
    
    ;buffer[WHERE(buffer lt 0.)] = -9999
    ;nan  = WHERE(finite(buffer,/NAN),complement=other) ;these are the indices where there are nan's, other are the good/bads 96621
    
    
    data_in=data_in+buffer*3 ;changes 3hrly units to hr
  endfor
asdf;    
  yrs   = file_search('*'+mm)
  data_in= data_in/n_elements(yrs) ;average monthly total (short term mean)
  
  openr,2,strcompress(fclimdir+mm+'africa.bin', /remove_all)
  readu,2,buffer ;fclim
  close,2

  PON = (small+buffer)/(data_in+small) ;fclim/stm
  
  ;is this working?
    openw,1,strcompress('/home/mcnally/PON.img', /remove_all)
    writeu,1,PON
    close, 1

  for j=0,n_elements(files)-1 do begin
    ; read all of the data (all days all bands) into data_in
    openr,3,files[j]
    readu,3,buffer
    close,3
    buffer=buffer*PON ;correct it!
    
    file_mkdir,strcompress(outdir+strmid(files[j],0,7), /remove_all)
    
    openw,4,strcompress(outdir+files[j], /remove_all)
    writeu,4,buffer
    close,4
    print, 'writing ub '+files[j]
    
  endfor;j
endfor;i

; end program
end

;other random stuff that was done to fine out where/how much bad data that there was
;IDL> for x=0,300 & for y=0,320 & dump = where(tmpout(x,y,*) lt 0.00,count) & for y=IDL> for x=0,300 do begin & for y=0,320 do begin & dump = where(tmpout(x,y,*) lt 0.
;IDL> negcount(x,y) = count & endfor & endfor
;% Variable is undefined: NEGCOUNT.
;% Execution halted at: UBIAS_TRMM         56 /home/source/mcnally/scripts_idl/greg_
;%                      $MAIN$
;IDL> negcount = LONARR(nx,ny)
;IDL> for x=0,300 do begin & for y=0,320 do begin & dump = where(tmpout(x,y,*) lt 0.
;IDL> negcount(x,y) = count & endfor & endfor
;IDL> tvim,negcount
;IDL> tvim,negcount
;IDL> print,max(negcount)
;           6


