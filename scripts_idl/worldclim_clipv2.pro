pro worldclim_clipv2

;the purpose of this program is to read in the temperature and RO list and fill R0 values
;that correspond to temperatures. 

;*****read in the africa only temperature data********
;odir='/jabber/lis/data/worldclim/africa/templist/'
indir='/jabber/LIS/Data/worldclim/'
tfile=file_search(indir+'/africa/templist/tmean_*.csv')
rofile=file_search(indir+'/africa/templist/RO*.csv')
tmapfile=file_search(indir+'/africa/tmean_*bil')
  
inx=9001
iny=9601
;for each month of the year, open the temp map, the temp data and the r0 data

;read in one of the temperature maps to get the colorbar
mapfile=file_search('/jabber/LIS/Data/worldclim/africa/templist/*.img')
mapfile=file_search('/jabber/LIS/Data/worldclim/africa/*.bil')

;buffer=fltarr(inx,iny)
buffer=intarr(inx,iny)

openr,1,mapfile[0]
readu,1,buffer
close,1

null=where(buffer lt 0, complement=good)
buffer(null)=!values.f_nan
;; Add the colorbar. 5 IS OK, 12 IS OK...
JANMAP=IMAGE(buffer/10, RGB_TABLE=6)
JANMAP.RGB_TABLE=19
cbar = COLORBAR(ORIENTATION=1, $
POSITION=[0.90, 0.2, 0.95, 0.75])
jammap.title='january temp'




for j=0,8 do begin &$
  ;read in the temperature map
  afgrid=intarr(inx,iny) &$
  openr,1,tmapfile[j] &$
  readu,1,afgrid &$
  close,1 &$
  
  ;change the -9999s to nans
  index = where(afgrid gt 0, complement=nulls) &$
  
  afgrid = float(afgrid) &$
  afgrid(nulls) = !values.f_nan &$

  ;open the file with the list of temperatures and r0's for each month
  rbuffer=read_csv(rofile[j], dlimiter=",")
  tbuffer=read_csv(tfile[j], dlimiter=",")

  r0=rbuffer.field2
  temp=tbuffer.field1*10

  afro=afgrid

;now fill in the r0 values where the temperatures match
for i=0,n_elements(temp)-1 do begin &$
  index=where(temp[i] eq afgrid, count) &$
  afro(index)=r0[i] &$
endfor 
;and write out the data....
  ofile=strcompress(indir+'africa/templist/testR0_'+string(j+1)+'.img', /remove_all)
  openw,1,ofile
  writeu,1,kafro
  close,1
endfor ;j
;where temperature is less than 25 make R0
;this is standardixed where 1 and -1 are high R0 values--close to the 
;cool=where(temp lt 252,count, complement=warm)
;kAfr0=Afro
;klR0(cool)=r0(cool)*(-1)
;klr0_norm=klr0/max(klr0)
;FOR j=0,N_ELEMENTS(TEMP)-1 DO BEGIN &$
;  INDEX=WHERE(TEMP[j] EQ AFLAND, COUNT) &$
;  kafR0(INDEX)=klR0_norm[j] &$
;ENDFOR

;  ofile='/africa/templist/KLR0_0'+string[i]+'.img'
;  openw,1,ofile
;  writeu,1,KafRO
;  close,1
;  
;
;; Add the colorbar. 5 IS OK, 12 IS OK...
;JANMAP=IMAGE(AFRO, RGB_TABLE=13)
;JANMAP.RGB_TABLE=13
;cbar = COLORBAR(ORIENTATION=1, $
;POSITION=[0.90, 0.2, 0.95, 0.75])
;jammap.title='january Ro'
;
;febMAP=IMAGE(AFRO, RGB_TABLE=13)
;febMAP.RGB_TABLE=13
;cbar = COLORBAR(ORIENTATION=1, $
;POSITION=[0.90, 0.2, 0.95, 0.75])
;febmap.title='february Ro'
;
;
;;where temperature is less than 25 make R0
;;this is standardixed where 1 and -1 are high R0 values--close to the 
;cool=where(temp lt 252,count, complement=warm)
;kAfr0=Afro
;klR0(cool)=r0(cool)*(-1)
;klr0_norm=klr0/max(klr0)
;FOR I=0,N_ELEMENTS(TEMP)-1 DO BEGIN &$
;  INDEX=WHERE(TEMP[I] EQ AFLAND, COUNT) &$
;  kafR0(INDEX)=klR0_norm[I] &$
;ENDFOR
;
;kmap=image(kafr0,rgb_table=6)
;cbar = COLORBAR(ORIENTATION=1, $
;POSITION=[0.90, 0.2, 0.95, 0.75])
;kmap.rgb_table=reverse(kmap.rgb_table,2) ;thanks greg!
; this might all be repeat.
; this file should stop here********************************************
;
;
;*****read in the africa only temperature data********
;odir='/jabber/lis/data/worldclim/africa/templist/'
;indir='/jabber/LIS/Data/worldclim/'
;tfile=file_search(indir+'/africa/templist/tmean_*.csv')
;rofile=file_search(indir+'/africa/templist/RO*.csv')
;tmapfile=file_search(indir+'/africa/tmean_*bil')
;  
;inx=9001
;iny=9601
;;for each month of the year, open the temp map, the temp data and the r0 data
;for j=0,8 do begin &$
;  ;j=3
;  ;read in the temperature map
;  afgrid=intarr(inx,iny) &$
;  openr,1,tmapfile[j] &$
;  readu,1,afgrid &$
;  close,1 &$
;  
;  ;change the -9999s to nans
;  index = where(afgrid gt 0, complement=nulls) &$
;  
;  afgrid = float(afgrid) &$
;  afgrid(nulls) = !values.f_nan &$
;
;  ;make a list of possible temperatures....i could have just done this once...oh well  
;  ;  list = rem_dup(afland(index))
;  ;  tlist = afland(index(list))/10
;  
;  ;  ofile = odir+strmid(ifile[i],34,8)+'.csv'
;  ;  write_csv,ofile,tlist
;  ;  print, ' writing ' +ofile
;  ;endfor
;
;;open the file with the list of temperatures and r0's for each month
;rbuffer=read_csv(rofile[j], dlimiter=",")
;tbuffer=read_csv(tfile[j], dlimiter=",")
;
;r0=rbuffer.field2
;temp=tbuffer.field1*10
;
;;afro=afgrid
;kafro=afgrid
;
;;now fill in the r0 values where the temperatures match
;for i=0,n_elements(temp)-1 do begin &$
;;  index=where(temp[i] eq afgrid, count) &$
;;  afro(index)=r0[i] &$
;  
;  cool=where(temp lt 252,count, complement=warm)
;  klr0(cool)=r0(cool)*(-1)
;  klr0_norm=klr0/max(klr0)
;  kafro(index)=klro_norm[i] &$
;
;;  ofile='/africa/templist/klr0_0'+string[i]+'.img'
;;  openw,1,ofile
;;  writeu,1,kafro
;;  close,1
;endfor 
;  ofile=strcompress(indir+'africa/templist/KR0_'+string(j+1)+'.img', /remove_all)
;  openw,1,ofile
;  writeu,1,kafro
;  close,1
;endfor ;j
;;where temperature is less than 25 make R0
;;this is standardixed where 1 and -1 are high R0 values--close to the 
;;cool=where(temp lt 252,count, complement=warm)
;;kAfr0=Afro
;;klR0(cool)=r0(cool)*(-1)
;;klr0_norm=klr0/max(klr0)
;;FOR j=0,N_ELEMENTS(TEMP)-1 DO BEGIN &$
;;  INDEX=WHERE(TEMP[j] EQ AFLAND, COUNT) &$
;;  kafR0(INDEX)=klR0_norm[j] &$
;;ENDFOR
;
;;  ofile='/africa/templist/KLR0_0'+string[i]+'.img'
;;  openw,1,ofile
;;  writeu,1,KafRO
;;  close,1
;;  
;;
;;; Add the colorbar. 5 IS OK, 12 IS OK...
;;JANMAP=IMAGE(AFRO, RGB_TABLE=13)
;;JANMAP.RGB_TABLE=13
;;cbar = COLORBAR(ORIENTATION=1, $
;;POSITION=[0.90, 0.2, 0.95, 0.75])
;;jammap.title='january Ro'
;;
;;febMAP=IMAGE(AFRO, RGB_TABLE=13)
;;febMAP.RGB_TABLE=13
;;cbar = COLORBAR(ORIENTATION=1, $
;;POSITION=[0.90, 0.2, 0.95, 0.75])
;;febmap.title='february Ro'
;;
;;
;;;where temperature is less than 25 make R0
;;;this is standardixed where 1 and -1 are high R0 values--close to the 
;;cool=where(temp lt 252,count, complement=warm)
;;kAfr0=Afro
;;klR0(cool)=r0(cool)*(-1)
;;klr0_norm=klr0/max(klr0)
;;FOR I=0,N_ELEMENTS(TEMP)-1 DO BEGIN &$
;;  INDEX=WHERE(TEMP[I] EQ AFLAND, COUNT) &$
;;  kafR0(INDEX)=klR0_norm[I] &$
;;ENDFOR
;;
;;kmap=image(kafr0,rgb_table=6)
;;cbar = COLORBAR(ORIENTATION=1, $
;;POSITION=[0.90, 0.2, 0.95, 0.75])
;;kmap.rgb_table=reverse(kmap.rgb_table,2) ;thanks greg!

end
