PRO make_stms
;this file takes the monthly cubes and makes short term means

inx    = 300.   ; 301 for rfe and others number of columns in input data
iny    = 320.   ; 321 for rfe and others number of rows in input data
nyears=5. ;2001-2008

mdata_in= fltarr(inx,iny,nyears) ;initialize monthly_cube array
stm     = fltarr(inx,iny) ; this contains the short-term monthly means

exp  ='EXP027' ;rfe2
name = 'prsn' ;has to be caps for indir...

;month_cube_indir = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/month_cube_'+name, /remove_all)
;/gibber/lis_data/OUTPUT/persiann/month_cube_prsn
month_cube_indir = strcompress('/gibber/lis_data/OUTPUT/persiann/month_cube_'+name, /remove_all)
stm_odir         = strcompress('/gibber/lis_data/stm03_08', /remove_all)
file_mkdir, stm_odir

cd, month_cube_indir
mfiles  = file_search('*.img') ;ignore the envi .hdrs
  
  for i=0, n_elements(mfiles)-1 do begin
   openr,lun,mfiles[i],/get_lun  ;open the month file
   readu,lun,mdata_in 
     for x=0,inx-1 do for y=0,iny-1 do begin ;get the mothly mean 
       stm[x,y]= mean((mdata_in[x,y,*]),/nan); this averages the bands together so that we have one value for each month
     endfor ;mean loop
 
   of2 = strcompress(+stm_odir+'/stm'+strmid(mfiles[i],4,18),/remove_all)
   print, of2
   
   close,/all
   
   openw ,2,of2
   writeu,2,stm
   
   close,/all
 endfor ; mfiles loop
 
 end