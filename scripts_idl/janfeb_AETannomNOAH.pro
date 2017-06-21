PRO janfeb_AETannomNOAH

;this program averages the months of january and february for
; each year in the run. The result should be X files.

name  = 'cmap'
exp   = '024'

wdir = strcompress("/gibber/lis_data/OUTPUT/EXP"+exp+"/NOAH", /remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/EXP"+exp+"/NOAH/malawi_evap_annom",/remove_all)
FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

inx    = 12.
iny    = 31.
ibands = 9.

outx   =  31.
outy   =  77.
;obands =   7.


avgfile = fltarr(inx,iny) ;floats for the EXP data
datain  = fltarr(inx,iny,ibands)
tmp     = fltarr(inx,iny,ibands)
dataout = fltarr(outx,outy,ibands)

   stack  = file_search(strcompress('Mal'+exp+'JFevap',/remove_all));finds all the files in a month for a particular variable
   malmean= file_search(strcompress('AvgMal'+exp+'JFevap',/remove_all))
  
   openr,1,stack
   openr,2,malmean 
   
   readu,1,datain
   readu,2,avgfile   
  
  for i=0, ibands-1 do begin
   for x=0,inx-1 do for y=0,iny-1 do begin ;take mean
    tmp[x,y,i] = datain[x,y,i]-avgfile[x,y]; data-average
  endfor ;the difference loop 
  dataout[*,*,i] = congrid(tmp[*,*,i],outx,outy,1);figure out in the morning... 
  
  dataout[WHERE(dataout eq 0)] = !VALUES.F_NAN

   
   of1 = strcompress(odir+'/AnomMal'+exp+'JFevap.img',/remove_all)
   openw,3,of1
   writeu,3,dataout
   
   close,/all
   print,"wrote " + of1 
   
   endfor ;bands
 end
   