pro check_runs
;just a script to quickly look at the lis outputs before doing more runs and post processing the changed soil layers...
;what dO I want to do to compare these data?
;well I can look at the water and energy balance just like I did for AGU.
;differences being that I am only using 'crop' type of vegetation, and 
;I am using the RFE2 rainfall.

indir='/home/mcnally/EROS_test/'
indir='/jabber/LIS/OUTPUT/EXP000/postprocess/daily/'
indir='/jabber/LIS/OUTPUT/EXP000/postprocess/2002/20020801/'
indir='/jabber/LIS/OUTPUT/EXP000/NOAH32/2002/20020801/'


ifile=file_search(indir+'*gs4r')

nx=16
ny=11
nz30=30
nz31=31
nbands=23

data_in=fltarr(nx,ny,nbands,n_elements(ifile))
buffer=fltarr(nx,ny,nbands)
buffer1=fltarr(nx,ny,nz30)
buffer2=fltarr(nx,ny,nz31)


for i=0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,buffer &$
  close,1 &$
  byteorder,buffer,/XDRTOF &$
  data_in[*,*,*,i] = buffer &$
endfor
  data_in[where(data_in lt -9998)] = !VALUES.F_NAN
  
;*****checkout chirps compared to RFE2-GDAS so i can tell pete if they 
;*****are ok
 ifile = file_search('/home/CHIRPS/6-hrly/africa')
  