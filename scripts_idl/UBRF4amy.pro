PRO UBRF4amy,month
; routines developed by Greg Husak at the University of California,
; Santa Barbara.  the routines contained in this program are the
; property of Greg Husak.
; Amy McNally modified to code for unbaising trmm,cmap,gdas and rfe2 monthly data
; another script will unbias the daily values [11/10/10]

;somehthing wrong w/ code...11/23...vales tend to blow up rather than being shifted down 
;closer to mean....I fixed this, is this the correct version? 3/4/11

; this program takes the short term mean for 2001-2008 for 3 rainfall products 
; takes the ratio to fclimv4 giving me a percent of normal rainfall. 
; This will allow me to create an unbiased set of monthly data from
; 2001-2008 by multiplying the percent of normal to my monthly rainfall data.  
; I will then adjust each month from 2001-2008 by PON for each month

;exp    = 'EXP017'
exp='persiann'
name   = 'prsn'

small  = 10	  ; value used to keep from dividing by zero and from having really large percents
inx    = 300. ; 301 for rfe2 and others number of columns in input data
iny    = 320.	; 321 for rfe2 and others number of rows in input data
   
;year  =['2001','2002','2003','2004','2005','2006','2007','2008','2009']
year  =['2003','2004','2005','2006','2007','2008'] ;persiann dates
month =['01','02','03','04','05','06','07','08','09','10','11','12']
  
stmdir   = strcompress('/gibber/lis_data/stm03_08', /remove_all); changed for persiann
fclimdir = strcompress('/gibber/lis_data/fclimv4_regrid_bin', /remove_all); regridded the original to 0.25 deg and bin (not arc_crap)
;monthdir = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/month_total_units',/remove_all)
monthdir = strcompress('/gibber/lis_data/Africa_PERS',/remove_all)
odir     = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/ubrfv2/',/remove_all)  

file_mkdir, odir

cd,fclimdir
clim_files=file_search('*.img')

cd, stmdir
stm_files=file_search('*'+name+'.img');

stm_buffer  = fltarr(inx,iny)
clim_buffer = fltarr(inx,iny)
pon_buffer  = fltarr(inx,iny)
pon         = fltarr(inx,iny,12)     ; percent of normal for each month
 
for l=0,n_elements(clim_files)-1 do begin ;for each monthly_cube
  ;open and read all of the fclims into a single file w/ 12 bands
  cd,fclimdir
  openr,1,clim_files[l]  ; opens all of the files
  readu,1,clim_buffer    ; 
  
  cd, stmdir
    
  ;open and read each stm - one at a time.
  openr,2,stm_files[l]
  readu,2,stm_buffer
  
  pon_buffer=(clim_buffer+small)/(stm_buffer+small); this calculates the percent of normal for each time thru the loop
  pon[*,*,l]=pon_buffer ;this saves the values in an array
  ;openw,5,'/gibber/lis_data/pon/pon01_08_'+name+'.img
  ;writeu,5,pon ;write out the percent of normals so I can spot check. 
  close, /all 
endfor

cd, monthdir
month_files  =file_search('*.1gd4r'); there are 98 8*12 + Jan, Feb of 2009

ubrfout      = fltarr(inx,iny)	; output rainfall
month_buffer = fltarr(inx,iny)

count=0

for m=0,n_elements(month_files)-1 do begin ;for all 98 files...
  cd,monthdir ;go into the month_dir (month_total_units)
  openr,3,month_files[m]  ; opens all of the files one by one
  readu,3,month_buffer   
  ubrfout(*,*) = pon(*,*,count) * month_buffer ;percent of normal x raw month values!
  
  ofile = strcompress(+odir+'ubrfv2_'+strmid(month_files[m],0,6)+'_'+name+'.img', /remove_all); changed strmid for persiann
  
  openw ,4,ofile
  writeu,4,ubrfout ; write out the monthly unbiased rainfall
  print, 'writing '+ofile
 
  close, /all
  if (count eq 11) then count=0 else count=count+1;monthly counter restarts after Dec
  ;monthly counter
endfor   

end

