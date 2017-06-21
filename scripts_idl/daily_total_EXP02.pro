pro daily_total_EXP02
;this script parses out the variables of interest with my new output scheme
;adjusted on 6/15/2013 for newest experiment
nx     = long(720)
ny     = long(250);this is new
nbands = 3;this is new

data_in = fltarr(nx,ny,nbands)

;ifile = file_search('/jower/LIS/OUTPUT/EXPA46/postprocess/*.d01.gs4r')
ifile = file_search('/jower/sandbox/mcnally/fromKnot/EXP02/postprocess/*.d01.gs4r')
odir = '/jower/sandbox/mcnally/fromKnot/EXP02/daily/'
;parse out all of the variables into individual files
for i = 0,n_elements(ifile)-1 do begin
  close, /all
  openr,1, ifile[i]
  readu,1,data_in
  close,1
  
  date = strmid(ifile[i],50,8) & print, date ;this is new

  ECan = data_in[*,*,0]
  TVeg = data_in[*,*,1]
  ESol = data_in[*,*,2]


of0 = strcompress(odir+"ECan_" +date+".img",/remove_all) & print, of0
of1 = strcompress(odir+"TVeg_" +date+".img",/remove_all)
of2 = strcompress(odir+"ESol_" +date+".img",/remove_all)


close,/ALL

openw,1,of0
openw,2,of1
openw,3,of2

writeu,1,Ecan   
writeu,2,Tveg 
writeu,3,ESol 

  print,"wrote " + of1

  endfor
print, 'hold'
end  
;  ;test plot looks fine.....
;nx = 720
;ny = 350
;
;ingrid = fltarr(nx,ny)
;ifile = file_search('/jower/LIS/OUTPUT/EXPA46/daily/Sm*')
;SM = fltarr(nx,ny,n_elements(ifile))
;
;for i = 0, n_elements(ifile)-1 do begin &$
;  close, /all &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid &$
;  close,1 &$
; 
;  SM[*,*,i] = ingrid[*,*] &$
;endfor
;  
;temp = image(SM[*,*,0], rgb_table=4)
;temp = image(SM[*,*,1], rgb_table=4)
;temp = image(SM[*,*,2], rgb_table=4)
;temp = image(SM[*,*,3], rgb_table=4)
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07])
;;check out the time series for Niger
;xind = FLOOR((2.633 + 20.) / 0.10)
;yind = FLOOR((13.6454 + 5) / 0.10)
;
;p1 = plot(Root[xind,yind,*], thick = 3)
;p1 = plot(Tair[xind,yind,*], thick = 3)
