pro daily_total_EXPA46
;this script parses out the variables of interest with my new output scheme
;adjusted on 6/15/2013 for newest experiment
nx     = long(720)
ny     = long(250);this is new
nbands = 29;this is new

data_in = fltarr(nx,ny,nbands)

;ifile = file_search('/jower/LIS/OUTPUT/EXPA46/postprocess/*.d01.gs4r')
ifile = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/postprocess/*.d01.gs4r')
odir = '/jower/sandbox/mcnally/fromKnot/EXP01/daily/'
;parse out all of the variables into individual files
for i = 0,n_elements(ifile)-1 do begin
  close, /all
  openr,1, ifile[i]
  readu,1,data_in
  close,1
  
  date = strmid(ifile[i],50,8) & print, date ;this is new

  SWnt = data_in[*,*,0]
  LWnt = data_in[*,*,1]
  Qlhx = data_in[*,*,2] 
  Qshx = data_in[*,*,3]
  Qghx = data_in[*,*,4]
  Rain = data_in[*,*,5]
  Evap = data_in[*,*,6]
  Qsuf = data_in[*,*,7]
  Qsub = data_in[*,*,8]
  SurT = data_in[*,*,9]  
  Albd = data_in[*,*,10]
  Sm01 = data_in[*,*,11]
  Sm02 = data_in[*,*,12]
  Sm03 = data_in[*,*,13]
  Sm04 = data_in[*,*,14]
  St01 = data_in[*,*,15]
  St02 = data_in[*,*,16] 
  St03 = data_in[*,*,17]
  St04 = data_in[*,*,18]
  PoET = data_in[*,*,19]
  Wind = data_in[*,*,20]
  Rainf = data_in[*,*,21]
  Tairf = data_in[*,*,22]
  Qairf = data_in[*,*,23]
  Psurf = data_in[*,*,24]
  SWdnf = data_in[*,*,25]
  LWdnf = data_in[*,*,26]
  Grns = data_in[*,*,27]
  Emisf = data_in[*,*,28]
  
;  ECan = data_in[*,*,20]
;  TVeg = data_in[*,*,21]
;  ESol = data_in[*,*,22]
;  Root = data_in[*,*,23]

of0 = strcompress(odir+"SWnt_" +date+".img",/remove_all)
of1 = strcompress(odir+"LWnt_" +date+".img",/remove_all)
of2 = strcompress(odir+"Qlhx_" +date+".img",/remove_all)
of3 = strcompress(odir+"Qshx_" +date+".img",/remove_all)
of4 = strcompress(odir+"Qghx_" +date+".img",/remove_all)
of5 = strcompress(odir+"Rain_" +date+".img",/remove_all)
of6 = strcompress(odir+"Evap_" +date+".img",/remove_all)
of7 = strcompress(odir+"Qsuf_" +date+".img",/remove_all)
of8 = strcompress(odir+"Qsub_" +date+".img",/remove_all)
of9 = strcompress(odir+"Tsuf_" +date+".img",/remove_all)
of10 = strcompress(odir+"Albd_" +date+".img",/remove_all)
of11 = strcompress(odir+"Sm01_" +date+".img",/remove_all)
of12 = strcompress(odir+"Sm02_" +date+".img",/remove_all)
of13 = strcompress(odir+"Sm03_" +date+".img",/remove_all)
of14 = strcompress(odir+"Sm04_" +date+".img",/remove_all)
of15 = strcompress(odir+"St01_" +date+".img",/remove_all)
of16 = strcompress(odir+"St02_" +date+".img",/remove_all)
of17 = strcompress(odir+"St03_" +date+".img",/remove_all)
of18 = strcompress(odir+"St04_" +date+".img",/remove_all)
of19 = strcompress(odir+"PoET_" +date+".img",/remove_all)
of20 = strcompress(odir+"Wind_" +date+".img",/remove_all)
of21 = strcompress(odir+"Rainf_" +date+".img",/remove_all) 
of22 = strcompress(odir+"Tairf_" +date+".img",/remove_all) 
of23 = strcompress(odir+"Qairf_" +date+".img",/remove_all) 
of24 = strcompress(odir+"Psurf_" +date+".img",/remove_all)
of25 = strcompress(odir+"SWdnf_" +date+".img",/remove_all) 
of26 = strcompress(odir+"LWdnf_" +date+".img",/remove_all)
of27 = strcompress(odir+"Grns_" +date+".img",/remove_all) 
of28 = strcompress(odir+"Emisf_" +date+".img",/remove_all)

;of20 = strcompress(odir+"Ecan_" +date+".img",/remove_all)
;of21 = strcompress(odir+"TVeg_" +date+".img",/remove_all)
;of22 = strcompress(odir+"ESol_" +date+".img",/remove_all)
;of23 = strcompress(odir+"Root_" +date+".img",/remove_all)

close,/ALL

openw,1,of0
openw,2,of1
openw,3,of2
openw,4,of3
openw,5,of4
openw,6,of5
openw,7,of6
openw,8,of7
openw,9,of8
openw,10,of9
openw,11,of10
openw,12,of11
openw,13,of12
openw,14,of13
openw,15,of14
openw,16,of15
openw,17,of16
openw,18,of17
openw,19,of18
openw,20,of19
openw,21,of20
openw,22,of21
openw,23,of22
openw,24,of23
openw,25,of24
openw,26,of25
openw,27,of26
openw,28,of27
openw,29,of28

writeu,1,SWnt 
writeu,2,LWnt
writeu,3,Qlhx 
writeu,4,Qshx
writeu,5,Qghx
writeu,6,Rain
writeu,7,Evap
writeu,8,Qsuf
writeu,9,Qsub
writeu,10,SurT
writeu,11,Albd
writeu,12,Sm01
writeu,13,Sm02 
writeu,14,Sm03  
writeu,15,Sm04
writeu,16,St01
writeu,17,St02 
writeu,18,St03  
writeu,19,St04
writeu,20,PoET
writeu,21,Wind 
writeu,22,Rainf 
writeu,23,Tairf 
writeu,24,Qairf 
writeu,25,Psurf 
writeu,26,SWdnf 
writeu,27,LWdnf
writeu,28,Grns 
writeu,29,Emisf

;writeu,21,Ecan   
;writeu,22,Tveg 
;writeu,23,ESol 
;writeu,24,Root 


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
