pro paper2_plotsv2

;updated on 8/27/13 to deal with paths moving from /jabber to /jower and to address some of joel's comments.
;locations of the study sites
;five months later...12/26/13: revisit and see what figures need to be made for this paper.
;12/31/13 (g'bye 2013) this code runs...now what?
;1/17/14 so maybe i want to do this with FLDAS soil moisture rather than  the NSM since the reviewers don't like that yet
;1/27/14 going back and looking at the microwave data
;2/03/14 remake crop area plot.
;2/19/14 try the spatial correlation in Hain et al. 2011
;2/25/14 make mutipanel plots
;6/17/14 back for revisions
;7/24/14 more revisions. 

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

;suggested figure 1 - sahel region with land cover and isohytes******

;*****************figure 1,2,3 SOIL MOISTURE CORRELATIONS**********************************
;do I want to use the raw data or the scaled data?
rfile = file_search('/home/chg-mcnally/sahel_ubRFE_PAW36_2001-2012_LGP_WHC_PET.img')
mofile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img'); this needs to be divided by 10,000 for VWC (or 100 for %)
;nofile = file_search('/home/chg-mcnally/sahel_NSM_microwave.img');what are the dims here?

lfile2 = file_search('/home/chg-mcnally/SM0X2_scaled4WRSI.img') 
;lfile3 = file_search('/home/chg-mcnally/SM0X3_scaled4WRSI.img') 
;nfile =  file_search('/home/chg-mcnally/NWET_scaled4WRSI.img');I mapped this, looks very similar to RFE-WRSI
mfile =  file_search('/home/chg-mcnally/ECV_MW_scaled4WRSI.img')

nx = 720
ny = 350
nz = 396

npawgrid = fltarr(nx,ny,nz)
rpawgrid = fltarr(nx,ny,432)
mpawgrid = fltarr(nx,ny,nz)
lpawgrid2 = fltarr(nx,ny,nz)
lpawgrid3 = fltarr(nx,ny,nz)


mocube = fltarr(nx,350,36,10);
nogrid = fltarr(nx,350,396)

openr,1,rfile
readu,1,rpawgrid
close,1
rpawgrid(where(rpawgrid eq 0))=!values.f_nan
rpawgrid(where(rpawgrid gt 400))=400

rpawcube = reform(rpawgrid,nx,350,36,12)


openr,1,mfile
readu,1,mpawgrid
close,1
mpawgrid(where(mpawgrid eq 0))=!values.f_nan
mpawcube = reform(mpawgrid,nx,ny,36,11)


openr,1,mofile
readu,1,mocube
close,1
mocube(where(mocube eq 0))=!values.f_nan
mogrid = reform(mocube,nx,350,360)

openr,1,nfile
readu,1,npawgrid
close,1
npawcube = reform(npawgrid, 720,ny,36,11)

openr,1,lfile2
readu,1,lpawgrid2
close,1
lpaw2cube = reform(lpawgrid2,nx,ny,36,11)

openr,1,lfile3
readu,1,lpawgrid3
close,1
lpaw3cube = reform(lpawgrid3,nx,ny,36,11)


openr,1,nofile
readu,1,nogrid
close,1
nocube = reform(nogrid, 720,350,36,11)

;Wankama 2006 - 2011 (13.6456,2.632 )
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;Belefoungou-Top 9.79506     1.71450  
bxind = FLOOR((1.7145 + 20.) / 0.10)
byind = FLOOR((9.79506 + 5) / 0.10)

out_rl2 = fltarr(720,250)
out_rl3 = fltarr(720,250)
out_rm  = fltarr(720,250)
out_rn  = fltarr(720,250)
out_l2m = fltarr(720,250)
out_l2n = fltarr(720,250)
out_l3m = fltarr(720,250)
out_l3n = fltarr(720,250)
out_mn  = fltarr(720,250)
out_rno = fltarr(720,250)
out_l2no = fltarr(720,250)
out_l3no = fltarr(720,250)
out_rmo  = fltarr(720,250)
out_l2mo = fltarr(720,250)
out_l3mo = fltarr(720,250)
out_mom  = fltarr(720,250)
aout_rl2 = fltarr(720,250)



;I masked out the dry season ahead of time
for x = 0, 720-1 do begin &$
  for y = 0, 250-1 do begin &$
    r = total(rpawcube[x,y,*,0:10],3,/nan) &$
    l2 = total(lpaw2cube[x,y,*,*],3,/nan) &$
    l3 = total(lpaw3cube[x,y,*,*],3,/nan) &$
    m = total(mpawcube[x,y,*,*],3,/nan) &$
    n = total(npawcube[x,y,*,*],3,/nan) &$
    no = total(nocube[x,y,*,*],3,/nan) &$
   ; mo = total(mocube[x,y,*,*],3,/nan) &$
    
    rr = r(where(finite(r)))  &$
    ll2 = l2(where(finite(l2))) &$
    ll3 = l3(where(finite(l3))) &$
    mm = m(where(finite(m))) &$
    nn = n(where(finite(n))) &$
    nno = no(where(finite(no))) &$
    ;mmo = no(where(finite(mo))) &$
     
    out_rl2[x,y] = correlate(rr,ll2) &$
    out_rl3[x,y] = correlate(rr,ll3) &$
    out_rm[x,y] = correlate(rr,mm) &$
    out_rn[x,y] = correlate(rr,nn) &$
    out_rno[x,y] = correlate(rr,nno) &$
       
    out_l2m[x,y] = correlate(ll2,mm) &$
    out_l2n[x,y] = correlate(ll2,nn) &$
    out_l2no[x,y] = correlate(ll2,nno) &$  
    
    out_l3m[x,y] = correlate(ll3,mm) &$
    out_l3n[x,y] = correlate(ll3,nn) &$
    out_l3no[x,y] = correlate(ll3,nno) &$   
    
    out_mn[x,y] = correlate(mm,nn) &$
      
    ;anomalies
     aout_rl2[x,y] = correlate(rr-mean(rr),ll2-mean(ll2)) &$
    
        
  endfor &$
endfor

;*********try hain's spatial correlations*******
;;1. average the dekadal SM map for each year (720x250x11)
;s1 = mean(lpaw2cube,dimension=3, /nan)
;;2.map the standardized seasonal anomaly
;mu = mean(s1,dimension=3, /nan)
;sigsq = variance(s1,dimension=3,/nan)
;
;s1mw = mean(mpawcube,dimension=3, /nan)
;muMW = mean(s1mw,dimension=3, /nan)
;
;s1b = mean(rpawcube,dimension=3, /nan)
;muB = mean(s1b,dimension=3, /nan)
;
;;can the whole maps be correlated?
;goodMW = where(finite(muMW))
;;anomaly maps for 2004, 2005, 2006
;ncolors=20
; p1 = image(s1b[*,0:249,5]-muB,image_dimensions=[75.0,25.0], image_location=[-20,-5],dimensions=[nx,450], $
;             RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), min_value=-40, max_value=40) &$ 
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])
; rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
; rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
; rgbdump[*,0] = [200,200,200]
;  p1.rgb_table = rgbdump  ; reassign the colorbar to the image
;  p1.title = '"bucket" 2006 anomaly'
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
;*********************************************************************

;anomalies look the same cause its correlation too....
;make this mutipanel. layout=ncol, nrow, index

ncolors=20
p1 = image(out_rl2,layout=[1,5,1],margin=0.1,image_dimensions=[75.0,25.0], image_location=[-20,-5],dimensions=[nx,750], $
             RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1) &$ 
t = TEXT(target=p1, -18, 1, '$\it a) Bucket/Noah$',/DATA, FONT_SIZE=18)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
p1 = image(out_rm,layout=[1,5,2],margin = 0.1, image_dimensions=[75.0,25.0], image_location=[-20,-5], $
             RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current) &$ 
t = TEXT(target=p1, -18, 1, '$\it b) Bucket/ECV$',/DATA, FONT_SIZE=18)
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
p1 = image(out_l2m,layout=[1,5,3],margin=0.1, image_dimensions=[75.0,25.0], image_location=[-20,-5], $
             RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current) &$ 
t = TEXT(target=p1, -18, 1, '$\it c) Noah/ECV$',/DATA, FONT_SIZE=18) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.label_show = 0
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
p1 = image(out_rl2-out_rm,layout=[1,5,4],margin= 0.1,image_dimensions=[75.0,25.0], image_location=[-20,-5], $
             RGB_TABLE=reverse(CONGRID(make_cmap(ncolors),3,256),2), min_value=-1, max_value=1, /current) &$ 
t = TEXT(target=p1, -19, 1, '$\it d) difference Noah, ECV$',/DATA, FONT_SIZE=16) 
cb = COLORBAR(TARGET=p1,ORIENTATION=0, title = 'correlation', font_size=16, textpos=0)
 rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
 rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
 rgbdump[*,0] = [200,200,200]
  p1.rgb_table = rgbdump  ; reassign the colorbar to the image
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 6 &$
  p1.mapgrid.label_show = 0
  ;p1.mapgrid.color = [150, 150, 150] &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
;*********************WRSI FIGURES*********************
;***plot the N-WRSI, R-WRSI for Wankama and Agoufou****
rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') ;EOS_WRSI_NDVI2001_2012vPETv2.img
rfileS = file_search('EOS_WRSI_ubRFE2001_2012_staticSOS.img')
;lfile1 = file_search('/home/chg-mcnally/EOS_WRSI_SM01_2001_2012.img')
l2file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')
l3file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X3_2001_2010_staticSOS.img')
nfile = file_search('/home/chg-mcnally/EOS_WRSI_NWET_2001_2010_staticSOS.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010_staticSOS.img')

nx = 720
ny = 350
nz = 11

l2grid = fltarr(nx,ny,nz)
l3grid = fltarr(nx,ny,nz)

mgrid = fltarr(nx,ny,nz)
rgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nz)

openr,1,rfile
readu,1,rgrid
close,1
 
openr,1,nfile
readu,1,ngrid
close,1

openr,1,l2file
readu,1,l2grid
close,1

openr,1,l3file
readu,1,l3grid
close,1

openr,1,mfile
readu,1,mgrid
close,1

;******EROS-like WRSI (0-100) maps********** 
;**********WRSI FIGURE PANEL***********
ncolors=256
p1 = image(byte(rgrid[*,0:249,3]),layout=[1,4,1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
              dimensions=[nx,750], RGB_TABLE=make_wrsi_cmap()) &$ 
t = TEXT(target=p1, -18, 1, '$\it a) Original (bucket) WRSI$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

p1 = image(byte(l2grid[*,0:249,3]),layout=[1,4,2], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
           RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$ 
t = TEXT(target=p1, -18, 1, '$\it b) Noah (0-40cm) WRSI$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)


p1 = image(byte(mgrid[*,0:249,3]),layout=[1,4,3], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
           RGB_TABLE=make_wrsi_cmap(), /CURRENT) &$ 
t = TEXT(target=p1, -18, 1, '$\it c) ECV microwave WRSI$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

;***************************************************
;***Percent of average map***********
ncolors=200
p1 = image(byte(rgrid[*,0:249,3]/mean(rgrid[*,0:249,0:9], dimension=3, /nan)*100),layout=[1,4,1], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
              dimensions=[nx,750], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50) &$ 
t = TEXT(target=p1, -18, 1, '$\it a) Original WRSI % of normal$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

p1 = image(byte(l2grid[*,0:249,3]/mean(l2grid[*,0:249,0:9], dimension=3, /nan)*100),layout=[1,4,2], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50, /CURRENT) &$ 
t = TEXT(target=p1, -18, 1, '$\it b) Noah WRSI % of normal$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

p1 = image(byte(mgrid[*,0:249,3]/mean(mgrid[*,0:249,0:9], dimension=3, /nan)*100),layout=[1,4,3], image_dimensions=[72.0,25.0], image_location=[-20,-5], $ 
           RGB_TABLE=CONGRID(make_cmap(ncolors),3,256), max_value=150, min_value=50, /CURRENT) &$ 
t = TEXT(target=p1, -18, 1, '$\it c) ECV WRSI % of normal$',/DATA, FONT_SIZE=18) 
;c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
cb = COLORBAR(TARGET=p1,ORIENTATION=0, title = '2004 % of normal', font_size=16, textpos=0)

rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image
p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
p1.mapgrid.linestyle = 6 &$
p1.mapgrid.color = [150, 150, 150] &$
p1.mapgrid.label_show = 0 &$
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)

 

;*********************WRSI FIGURES*********************
;1/31/2014 redid these with the FAO production data. 
;***plot the N-WRSI, R-WRSI for Wankama and Agoufou****
;rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') ;
;lfile = file_search('/jabber/chg-mcnally/EOS_WRSI_SM01_2001_2012.img')
;nfile = file_search('/home/chg-mcnally/EOS_WRSI_NWET_2001_2012.img')
mkfile = file_search('/home/chg-mcnally/WRSI_compare_mask.img')
cfile = file_search('/home/chg-mcnally/cz_mask_sahel.img')
rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012_staticSOS.img')
mfile = file_search('/home/chg-mcnally/EOS_WRSI_MW_2001_2010_staticSOS.img')   
l2file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X2_2001_2010_staticSOS.img')
l3file = file_search('/home/chg-mcnally/EOS_WRSI_SM0X3_2001_2010_staticSOS.img')
nfile = file_search('/home/chg-mcnally/EOS_WRSI_NWET_2001_2010_staticSOS.img')  

nx = 720
ny = 350
nz = 10

cgrid = fltarr(nx,ny)
mkgrid = fltarr(nx,ny)

rgrid = fltarr(nx,ny,nz)
mgrid = fltarr(nx,ny,nz)
lgrid2 = fltarr(nx,ny,nz)
lgrid3 = fltarr(nx,ny,nz)

ngrid = fltarr(nx,ny,nz)

openr,1,cfile
readu,1,cgrid
close,1
;mask out the wet part of chad
cgrid[*,0:150]=!values.f_nan


openr,1,mkfile
readu,1,mkgrid
close,1

openr,1,mfile
readu,1,mgrid
close,1

openr,1,rfile
readu,1,rgrid
close,1
 
openr,1,nfile
readu,1,ngrid
close,1

openr,1,l2file
readu,1,lgrid2
close,1

openr,1,l3file
readu,1,lgrid3
close,1
;
;show the cropped areas by country
  p1 = image(cgrid,image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx,ny],title = 'crop zones', rgb_table=27) &$ 
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;****************looking at countries**6/11/2013, revisit 2/03/2014**************************
;read in yields data 2001-2011 anomalies
;yfile = file_search('/jabber/chg-mcnally/millet_yields_6_11_2013.csv'); these are anomalies.
;see old data in the excel Niger_2005_2008file 

;production stats from FAO:
BF=[1009044.00,  994661.00, 1184283.00 , 937630.00, 1196253.00,  1175040.00,  966016.00,  1255189.00,   970927.00, 1147894.00]
CH=[397608.00,   357425.00, 516341.00 ,  297529.00, 578303.00,   589754.00 ,  495486.00,   523162.00,   550000.00, 600000.00]
MA=[792548.00,   795146.00, 1260498.00 , 974673.00, 1157810.00,  1128773.00, 1175107.00,  1413908.00,  1390410.00,  1373342.00]
NG=[2414394.00,  2504000.00, 2744900.00, 2037700.00,2652400.00, 3008584.00 , 2781928.00,  3521727.00,  2677855.00,  3843351.00]
SG=[556655.00,   414820.00, 628426.00,   323752.00, 608551.00,  494345.00,   318822.00,   678171.00,    810121.00, 813294.98]

;remove trend from yield data...from Greg's code:
yield_mat = transpose([[bf],[ch], [ma],[ng],[sg]]) & help, yield_mat

trend = fltarr(n_elements(yield_mat[*,0]))
yld2 = FLTARR(SIZE(yield_mat,/DIMENSIONS)) * !VALUES.F_NAN

;use the detrended yields instead....detrended & mean zero-ish
for i=0,n_elements(trend)-1 do begin &$
  yrind = WHERE(FINITE(yield_mat[i,*]),count) &$
  trend[i] = REGRESS(yrind,REFORM(yield_mat[i,yrind],count),yfit = tmp_est) &$
  yld2[i,yrind] = yield_mat[i,yrind] - tmp_est &$
endfor

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count

;sudan = where(cgrid eq 1005, count) & print, count
;southsudan = where(cgrid eq 1006, count) & print, count ;oops did i not rerun this? ignore sudan for now.
;I just use the 10 years of data...will this change my means?
NigerWRSI   = fltarr(5,10)
SenegalWRSI = fltarr(5,10)
MaliWRSI    = fltarr(5,10)
BurkinaWRSI = fltarr(5,10)
ChadWRSI    = fltarr(5,10)
;rain-WRSI  then NDVI-WRSI
for i = 0,n_elements(nigerWRSI[0,*])-1 do begin &$
    ryrgrid = rgrid[*,*,i] &$
    myrgrid = mgrid[*,*,i] &$    
    l2yrgrid = lgrid2[*,*,i] &$
    l3yrgrid = lgrid3[*,*,i] &$
    nyrgrid = ngrid[*,*,i] &$
    
    NigerWRSI[*,i]   =  [mean(ryrgrid(niger), /nan)  ,mean(myrgrid(niger), /nan)  ,mean(l2yrgrid(niger), /nan)  ,mean(l3yrgrid(niger), /nan)  ,mean(nyrgrid(niger),/nan)  ] &$
    SenegalWRSI[*,i] =  [mean(ryrgrid(senegal), /nan),mean(myrgrid(senegal), /nan),mean(l2yrgrid(senegal), /nan),mean(l3yrgrid(senegal), /nan),mean(nyrgrid(senegal), /nan)] &$
    MaliWRSI[*,i]    =  [mean(ryrgrid(mali), /nan)   ,mean(myrgrid(mali), /nan)   ,mean(l2yrgrid(mali), /nan)   ,mean(l3yrgrid(mali), /nan)   ,mean(nyrgrid(mali), /nan)] &$
    BurkinaWRSI[*,i] =  [mean(ryrgrid(burkina), /nan),mean(myrgrid(burkina), /nan),mean(l2yrgrid(burkina), /nan),mean(l3yrgrid(burkina), /nan),mean(nyrgrid(burkina), /nan)] &$
    ChadWRSI[*,i]    =  [mean(ryrgrid(chad), /nan)   ,mean(myrgrid(chad), /nan)   ,mean(l2yrgrid(chad), /nan)   ,mean(l3yrgrid(chad), /nan)   ,mean(nyrgrid(chad), /nan)] &$   
endfor;i
;**************burkina faso*************************************

bYIELDanom = yld2[0,*]
bWRSIanom = [BurkinaWRSI[0,*]-mean(BurkinaWRSI[0,*]),  BurkinaWRSI[1,*]-mean(BurkinaWRSI[1,*]), BurkinaWRSI[2,*]-mean(BurkinaWRSI[2,*]),$
         BurkinaWRSI[3,*]-mean(BurkinaWRSI[3,*]), BurkinaWRSI[4,*]-mean(BurkinaWRSI[4,*]) ]

print, r_correlate(bYIELDanom,bWRSIanom[0,*])
print, r_correlate(bYIELDanom,bWRSIanom[1,*])
print, r_correlate(bYIELDanom,bWRSIanom[2,*])
print, r_correlate(bYIELDanom,bWRSIanom[3,*])
print, r_correlate(bYIELDanom,bWRSIanom[4,*])

;***chad*****
cYIELDanom = yld2[1,*]
cWRSIanom = [ChadWRSI[0,*]-mean(ChadWRSI[0,*]),  ChadWRSI[1,*]-mean(ChadWRSI[1,*]), ChadWRSI[2,*]-mean(ChadWRSI[2,*]),$
         ChadWRSI[3,*]-mean(ChadWRSI[3,*]), ChadWRSI[4,*]-mean(ChadWRSI[4,*]) ]


print, r_correlate(cYIELDanom,cWRSIanom[0,*])
print, r_correlate(cYIELDanom,cWRSIanom[1,*])
print, r_correlate(cYIELDanom,cWRSIanom[2,*])
print, r_correlate(cYIELDanom,cWRSIanom[3,*])
print, r_correlate(cYIELDanom,cWRSIanom[4,*])

;***MALI*****
mYIELDanom = yld2[2,*]
mWRSIanom = [MaliWRSI[0,*]-mean(MaliWRSI[0,*]),  MaliWRSI[1,*]-mean(MaliWRSI[1,*]), MaliWRSI[2,*]-mean(MaliWRSI[2,*]),$
         MaliWRSI[3,*]-mean(MaliWRSI[3,*]), MaliWRSI[4,*]-mean(MaliWRSI[4,*]) ]

print, r_correlate(mYIELDanom,mWRSIanom[0,*])
print, r_correlate(mYIELDanom,mWRSIanom[1,*])
print, r_correlate(mYIELDanom,mWRSIanom[2,*])
print, r_correlate(mYIELDanom,mWRSIanom[3,*])
print, r_correlate(mYIELDanom,mWRSIanom[4,*])


;****NIGER*******
nYIELDanom = yld2[3,*]
nWRSIanom = [NigerWRSI[0,*]-mean(NigerWRSI[0,*]),  NigerWRSI[1,*]-mean(NigerWRSI[1,*]), NigerWRSI[2,*]-mean(NigerWRSI[2,*]),$
         NigerWRSI[3,*]-mean(NigerWRSI[3,*]), NigerWRSI[4,*]-mean(NigerWRSI[4,*]) ]


print, r_correlate(nYIELDanom,nWRSIanom[0,*])
print, r_correlate(nYIELDanom,nWRSIanom[1,*])
print, r_correlate(nYIELDanom,nWRSIanom[2,*])
print, r_correlate(nYIELDanom,nWRSIanom[3,*])
print, r_correlate(nYIELDanom,nWRSIanom[4,*])

;****SENEGAL******
sYIELDanom = yld2[4,*]
sWRSIanom = [SenegalWRSI[0,*]-mean(SenegalWRSI[0,*]),  SenegalWRSI[1,*]-mean(SenegalWRSI[1,*]), SenegalWRSI[2,*]-mean(SenegalWRSI[2,*]),$
         SenegalWRSI[3,*]-mean(SenegalWRSI[3,*]), SenegalWRSI[4,*]-mean(SenegalWRSI[4,*]) ]


print, r_correlate(sYIELDanom,sWRSIanom[0,*])
print, r_correlate(sYIELDanom,sWRSIanom[1,*])
print, r_correlate(sYIELDanom,sWRSIanom[2,*])
print, r_correlate(sYIELDanom,sWRSIanom[3,*])
print, r_correlate(sYIELDanom,sWRSIanom[4,*])

print, correlate(sYIELDanom,sWRSIanom[0,*])
print, correlate(sYIELDanom,sWRSIanom[1,*])
print, correlate(sYIELDanom,sWRSIanom[2,*])
print, correlate(sYIELDanom,sWRSIanom[3,*])
print, correlate(sYIELDanom,sWRSIanom[4,*])

;*****************************************************
WRSIanom = sWRSIanom
YIELDanom = sYIELDanom
;labels=['01','02','03','04','05', '06','07','08','09','10']
p1 = plot(WRSIanom[0,*],YIELDanom/stdev(YIELDanom),'o',sym_size=2, name = '  R-WRSI');
p2 = plot(WRSIanom[1,*],YIELDanom/stdev(YIELDanom),'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='  MW-WRSI')
p3 = plot(WRSIanom[2,*],YIELDanom/stdev(YIELDanom),'co',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='  NOAH02-WRSI')     
p4 = plot(WRSIanom[3,*],YIELDanom/stdev(YIELDanom),'bo',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='  NOAH03-WRSI') 
p5 = plot(WRSIanom[4,*],YIELDanom/stdev(YIELDanom),'mo',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name=' NDVI-WRSI')      
;p2.xrange=[-10,10]
;p2.yrange=[-3,3]
p1.title = 'Niger'
p1.font_size = 18
!NULL = LEGEND(TARGET=[P1,P2,P3,P4,P5], POSITION=[0.2,0.3], FONT_SIZE=14, SAMPLE_WIDTH=0,shadow=0,linestyle=6) ;

p3=plot([0,0],[-10,10],/overplot)
p3=plot([-10,10],[0,0],/overplot)




;;*******FIGUREs 4-6 How well does station rainfall & microwave compare to observations**********
;
;Agoufou, Mali 2005-2008 add these to the MW and NWET plot (might need to normalize?)
sfile = file_search('/home/chg-mcnally/AMMA2013/dekads/Agoufou*{0.3,0.4,0.6}*csv')
;rfile = file_search('/home/chg-mcnally/AGPAW36_2005_2008_SOS.20.18.19.20_LGP7_WHC125_PET.csv')

nx = 720
ny = 350
;soil moisture observations
A103 = read_csv(sfile[0])
A203 = read_csv(sfile[1])
A304 = read_csv(sfile[2])
A106 = read_csv(sfile[3])
A206 = read_csv(sfile[4])

A103 = float(A103.field1); go with this one!
A203 = float(A203.field1)
A304 = float(A304.field1); go with this one!
A106 = float(A106.field1); go with this one!
A206 = float(A206.field1)

;pad these out to match the 12 yr time series. 2001-2012
early = fltarr(144)
early[*] = !values.f_nan
late = fltarr(144)
late[*] = !values.f_nan

A103p = reform([early, A103, late],36,12)
A203p = reform([early, A203, late],36,12)
A304p = reform([early, A304, late],36,12)
A106p = reform([early, A106, late],36,12)
A206p = reform([early, A206, late],36,12)


agavg = mean([transpose(a103),transpose(a106),transpose(a304),transpose(a203),transpose(a206)], dimension=1, /nan)


;FIGURE 1.NWET vs OBS
;
;reform these so i can restrict to the growing season for each location. dek12-31 (apr21-Nov1)
;FIGURE 2.NWET vs MW -- so for these RS comparisons we don't need to be restricted to the sites
;I can do a much larger spatial area (map) corrleation at each point for the differnet years.  

;I want the data plotted over this one. I'll need some correlation coeffients here....
p1 = plot(npawgrid[axind,ayind,12:31,*]*0.0001,mpawgrid[axind,ayind,12:31,*]*0.0001, 'r*', /overplot, name='Agoufou, Mali')

p1 = plot(reform(npawgrid[axind,ayind,12:31,0:9]*0.0001, 20*10),reform(mpawgrid[axind,ayind,12:31,*]*0.0001,20*10), 'r*', /overplot, name='ECV MW estimate')
p1 = plot(reform(npawgrid[axind,ayind,12:31,*]*0.0001, 20*12),reform(mpawgrid[axind,ayind,12:31,*]*0.0001,20*10), '*', /overplot, name='ECV MW estimate')

p4 = plot(reform(npawgrid[axind,ayind,12:31,*],20*12 )*0.0001, reform(a103p[12:31,*],20*12), '*', /overplot, name='in situ observation')
p4 = plot(reform(npawgrid[axind,ayind,12:31,*],20*12 )*0.0001, reform(a203p[12:31,*],20*12), '*', /overplot)
p4 = plot(reform(npawgrid[axind,ayind,12:31,*],20*12 )*0.0001, reform(a304p[12:31,*],20*12), '*', /overplot)
p4 = plot(reform(npawgrid[axind,ayind,12:31,*],20*12 )*0.0001, reform(a106p[12:31,*],20*12), '*', /overplot)
p4 = plot(reform(npawgrid[axind,ayind,12:31,*],20*12 )*0.0001, reform(a206p[12:31,*],20*12), '*', /overplot)
p4.name = 'in situ obs'
!null = legend(target=[p1,p4], position=[0.2,0.3], font_size=14, sample_width=0) ;
p4.xtitle='NDVI-MW soil mositure estimate'
p4.ytitle='in situ and microwave observation'
p4.title = 'May-October soil mositure Agoufou, Mali'

p5 = plot(reform(mpawgrid[axind,ayind,12:31,*],20*10 )*0.0001, reform(a103p[12:31,*],20*12), '*')
p5 = plot(reform(mpawgrid[axind,ayind,12:31,*],20*10 )*0.0001, reform(a203p[12:31,*],20*12), '*', /overplot)
p5 = plot(reform(mpawgrid[axind,ayind,12:31,*],20*10 )*0.0001, reform(a304p[12:31,*],20*12), '*', /overplot)
p5 = plot(reform(mpawgrid[axind,ayind,12:31,*],20*10 )*0.0001, reform(a106p[12:31,*],20*12), '*', /overplot)
p5 = plot(reform(mpawgrid[axind,ayind,12:31,*],20*10 )*0.0001, reform(a206p[12:31,*],20*12), '*', /overplot)

p4.xrange=[0,0.25]
p4.yrange=[0,0.25]

;***********************wankama scatter plots*******
;2006-2011
ifile = file_search('/home/chg-mcnally/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')
;use mwgrid for the microwave....

WK14 = read_csv(ifile[0])
WK47 = read_csv(ifile[1])
WK71 = read_csv(ifile[2])

wk14 = float(wk14.field1)
wk47 = float(wk47.field1)
wk71 = float(wk71.field1)


;pad these out to match the 12 yr time series. 2001-2012
;try to match with TK instead. there are some weak years here...
early = fltarr(180)
early[*] = !values.f_nan
late = fltarr(36)
late[*] = !values.f_nan

wk14p = reform([early, wk14, late],36,12)
wk47p = reform([early, wk47, late],36,12)
wk71p = reform([early, wk71, late],36,12)

p2 = plot(npawgrid[wxind,wyind,12:31,*]*0.0001,mpawgrid[wxind,wyind,12:31,*]*0.0001, 'r*', /overplot, name='ECV MW')
p4 = plot(reform(npawgrid[wxind,wyind,12:31,*],20*12 )*0.0001, reform(wk14p[12:31,*],20*12), '*', /overplot, name='in situ observation')
p4 = plot(reform(npawgrid[wxind,wyind,12:31,*],20*12 )*0.0001, reform(wk47p[12:31,*],20*12), '*', /overplot, name='in situ observation')
p4 = plot(reform(npawgrid[wxind,wyind,12:31,*],20*12 )*0.0001, reform(wk71p[12:31,*],20*12), '*', /overplot, name='in situ observation')
p4.name = 'in situ obs'
!null = legend(target=[p1,p4], position=[0.2,0.3], font_size=14, sample_width=0) ;
p4.xtitle='NDVI-MW soil mositure estimate'
p4.ytitle='in situ and microwave observation'
p4.title = 'May-October soil mositure Wankama, Niger'

;a = mean(ndvi,dimension=3,/nan)
;********remake the NWET vs ECV_SM scatter********************
;I think that i should restrict this to the growing season (12/29/13)
;why does this look like i am comparing wrsi and nwet?
p1=plot(npawgrid[bxind,byind,*]*0.0001,mpawgrid[bxind,byind,*]*0.0001, 'r*')
p1.xrange=[0.05,0.25]
p1.yrange=[0.05,0.25]
p1.ytitle = 'microwave sm (m3/m3)'
p1.xtitle = 'ndvi derived sm (m3/m3)'
p1.title = 'Belefougou, Benin Soil moisture 2001-2010'



;*************************************************************
;********************do I need this? it was lost on /jabber... 8/27/13
ifile = file_search('/home/MODIS/eMODIS/01degree/sahel/data.{2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012}*img')

nx = 720
ny = 350
nz = n_elements(ifile)
;nz = 36

ingrid = fltarr(nx,ny)
ndvi = fltarr(nx,ny,nz)

for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
  ndvi[*,*,f] = ingrid &$
endfor 

ndvi36 = reform(ndvi,nx,ny,36,12)
npaw36 = reform(npawgrid,nx,ny,36,12)
rpaw36 = reform(rpawgrid,nx,ny,36,10)

aveg = mean(ndvi36[axind,ayind,*,*], dimension=4,/nan)
wveg = mean(ndvi36[wxind,wyind,*,*], dimension=4,/nan)
bveg = mean(ndvi36[bxind,byind,*,*], dimension=4,/nan)

arpaw = mean(rpaw36[axind,ayind,*,*], dimension=4,/nan)
wrpaw = mean(rpaw36[wxind,wyind,*,*], dimension=4,/nan)
brpaw = mean(rpaw36[bxind,byind,*,*], dimension=4,/nan)

anpaw = mean(npaw36[axind,ayind,*,*], dimension=4,/nan)
wnpaw = mean(npaw36[wxind,wyind,*,*], dimension=4,/nan)
bnpaw = mean(npaw36[bxind,byind,*,*], dimension=4,/nan)

;does this look ok?
p1 = image(total(nswb,3, /nan), rgb_table=20)
 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])

;********************AG,MALI***************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(aveg, thick = 3, 'black', name = 'AG NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(anpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(arpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname
;*******************WK, NIGER*************************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(wveg, thick = 3, 'black', name = 'WK NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(wnpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(wrpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname
;*******************BT, BENIN*************************************************
xtickvalues=[0, 5, 10, 15, 20, 25, 30, 35]+2
xtickname = ['11-Jan' , '1-Mar', '21-Apr', '11-Jun','1-Aug', '21-Sep',  '11-Nov', '1-Jan']
p2 = plot(bveg, thick = 3, 'black', name = 'BB NDVI', /overplot, $
         xtickvalues = xtickvalues, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0)
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(bnpaw*0.0001, thick = 3, 'light grey', name = 'N-WET', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         YTITLE='soil wetness m3/m3',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
p3 = plot(brpaw*0.0001, thick = 2, 'orange', name = 'ECV_SM', /overplot)
!null = legend(target=[p1,p2,p3], position=[0.2,0.3], font_size=14) ;
p3.xtickname=xtickname

;**************************************************************************************************
;;*******FIGUREs 4-6 How well does station rainfall & microwave compare to observations**********
;Agoufou, Mali
sfile = file_search('/home/chg-mcnally/AMMA2013/dekads/Agoufou*{0.3,0.4,0.6}*csv')
rfile = file_search('/home/chg-mcnally/AGPAW36_2005_2008_SOS.20.18.19.20_LGP7_WHC125_PET.csv')
mfile = file_search('/home/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img')
nfile = file_search('/home/chg-mcnally/sahel_NSM_microwave.720.350.432_2001_2012.img')

nx = 720
ny = 350
mwgrid = fltarr(nx,ny,360)
nwetgrid = fltarr(nx,ny,432)

;soil moisture observations
A103 = read_csv(sfile[0])
A203 = read_csv(sfile[1])
A304 = read_csv(sfile[2])
A106 = read_csv(sfile[3])
A206 = read_csv(sfile[4])

A103 = float(A103.field1); go with this one!
A106 = float(A106.field1); go with this one!
A304 = float(A304.field1); go with this one!
A203 = float(A203.field1)
A206 = float(A206.field1)

agavg = mean([transpose(a103),transpose(a106),transpose(a304),transpose(a203),transpose(a206)], dimension=1, /nan)

;read in the 2005-2008 AG rpaw data
sta_paw = read_csv(rfile)

;read in the microwave data
openr,1,mfile
readu,1,mwgrid
close,1
mwgrid = mwgrid*0.01

;read in NWET 
openr,1,nfile
readu,1,nwetgrid
close,1

;extract microwave 2005-2008 for AG****
agmw  = mwgrid[axind,ayind,*]
agmwcube = reform(agmw,36,10)
ag0508 = reform(agmwcube[*,4:7],36*4)
ag0508(where(ag0508 lt 0))=0

;extract NWT for 2005-2008
agnwet = nwetgrid[axind,ayind,*]
agnwetcube = reform(agnwet,36,12)
agnwet0508 =reform(agnwetcube[*,4:7],36*4)

;*****which one do I plot? maybe just make a correlation table...
wet = where(finite(sta_paw.field1))
mw = where(finite(ag0508), complement=dry)
all_wet = where(finite(ag0508) AND finite(sta_paw.field1))


wet = where(finite(float(sta_paw.field1)))
print, correlate(ag0508(wet),agavg(wet));0.57 MW v station
print, correlate(ag0508(all_wet),float(sta_paw.field1(all_wet)));0.24 ;MW v WRSI
print, correlate(agavg(wet),float(sta_paw.field1(wet)));0.41  ;station v WRSI?
print, correlate(agnwet0508(wet),agavg(wet));0.52 ;NWET v station

;subtract out the means so that i can calculate the bias and error...nope, need to transform into same units.
nve, ag0508(wet)
nve, agavg(wet)*100

;p1=plot(ag0508(wet),agavg(wet)*100, 'bo', sym_size=2, xtitle = 'ECV_SM ', $
;        ytitle = 'AG obs, wet season (%VWC)' , font_size=20, /sym_filled)
;p1=plot(float(sta_paw.field1(wet)),A206(wet)*100, 'co', sym_size=2, xtitle = 'sta_PAW', $
;        ytitle = 'AG obs, wet season (%VWC)' , font_size=20, /sym_filled)
;        p1.xrange = [0,24]
;        p1.yrange = [15,24]
;p2=plot([-2.5,2.5],[-2.5,2.5], /overplot,xrange=[-2.5,2.5], yrange=[-2.5,2.5])

;*****************the figure *******************************

xticks = ['Jun-05','Jun-06','Jun-07','Jun-08']
xtickvalues = [ 18, 54, 90, 126 ]
p2 = plot(float(sta_paw.field1), thick = 3, 'black', name = 'station-PAW', /overplot, $)
         xtickvalues = xtickvalues, $
         xtickname = xticks,$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,143])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station-PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
p1 = plot(agavg*100, thick = 2, 'light grey', name = 'avg obs SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvalues, font_name='times',$
         xtickname = xticks,$
         YTITLE='SM (VWC%)',AXIS_STYLE=1,/CURRENT, xrange=[0,143],font_size=20)
p3 = plot(ag0508, /overplot, thick =2, 'orange', name='ECV_MW_SM')
p4 = plot(agnwet0508*0.01, /overplot, thick =1,linestyle=2, 'orange', name='NDVI_SM')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) ;

;*************************Wankama****************************
ifile = file_search('/home/chg-mcnally/AMMA2013/dekads/Wankama_sm_0.{1,4,7}*.csv')
rfile = file_search('/home/chg-mcnally/WKPAW36_2005_2008_SOS.16.18.18.14_LGP10_WHC140_PET.csv')
;use mwgrid for the microwave....

WK14 = read_csv(ifile[0])
WK47 = read_csv(ifile[1])
WK71 = read_csv(ifile[2])

sarray = transpose([[float(wk14.field1)],[float(wk47.field1)],[float(wk71.field1)]]) & help, sarray
wkavg = mean(sarray[*,0:107], dimension=1, /nan)

sta_paw = read_csv(rfile)
sta_paw0608 = float(sta_paw.field1[36:143])
;extract microwave 2006-2008 for AG****
wkmw  = mwgrid[wxind,wyind,*]
wkmwcube = reform(wkmw,36,10)
wk0608 = reform(wkmwcube[*,5:7],36*3)
;why do i have negative values? wtf?
;****this makes the correlation not work, but 
;wk0608(where(wk0608 lt 0))= 0

;extract NWT for 2006-2008
wknwet = nwetgrid[wxind,wyind,*]
wknwetcube = reform(wknwet,36,12)
wknwet0608 =reform(wknwetcube[*,5:7],36*3)

;*****which one do I plot? maybe just make a correlation table...
wet = where(finite(sta_paw0608))
mw = where(finite(wk0608), complement=dry)
all_wet = where(finite(wk0608) AND finite(sta_paw0608))
print, correlate(wk0608(mw),wkavg(mw));MW-station=0.56
;print, correlate(wk0608(all_wet),sta_paw0608(all_wet));MW-RPAW = 0.74
print, correlate(wkavg(wet),sta_paw0608(wet));0.83
print, correlate(wknwet0608(mw),wkavg(mw));NWET-station=0.60

;for the mean/std MW/station comparison
nve, wk0608(wet)
nve, wkavg(wet)*100
nwetplot = wknwet0608*0.01
nwetplot(dry)=!values.f_nan

 xtickname = ['Jun-06', 'Jun-07','Jun-08']
 xtickvals = [0,36,72]+18
p2 = plot(sta_paw0608, thick = 3, 'black', name = 'station PAW', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,107])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0)
p1 = plot(wkavg*100, thick = 3, 'light grey', name = 'avg observed SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, font_name='times',$
         xtickname = xtickname,$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT, xrange=[0,107])
p3 = plot(wk0608, /overplot,thick =2, 'orange', name='ECV_MW_SM')
p4 = plot(nwetplot, /overplot,thick =1,linestyle=2, 'orange', name='NDVI_SM')

lgr2 = LEGEND(TARGET=[p1, p2,p3,p4], font_size=16, font_name='times')
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p1.ytitle='soil moisture (%VWC)'
p1.font_name='times'

;**********Belefougou, Benin******************
ifile = file_search('/home/chg-mcnally/AMMA2013/dekads/Belefoungou-Top_sm_{0.2,0.4,0.6}*.csv')
rfile = file_search('/home/chg-mcnally/BBPAW36_2005_2008_SOS.12.10.09_LGP18_WHC119_PET.csv')

BB20 = read_csv(ifile[0])
BB40 = read_csv(ifile[1])
BB60 = read_csv(ifile[2])

sarray = transpose([[float(bb20.field1)],[float(bb40.field1)],[float(bb60.field1)]]) & help, sarray
bbavg = mean(sarray[*,0:107], dimension=1, /nan)*100

sta_paw = read_csv(rfile) 
sta_paw0608 = float(sta_paw.field1[0:107])
;extract microwave 2006-2008 for BB****
bbmw  = mwgrid[bxind,byind,*]
bbmwcube = reform(bbmw,36,10)
bb0608 = reform(bbmwcube[*,5:7],36*3)
bb0608(where(bb0608 lt 0))=0

;extract NWT for 2006-2008
bbnwet = nwetgrid[bxind,byind,*]
bbnwetcube = reform(bbnwet,36,12)
bbnwet0608 =reform(bbnwetcube[*,5:7],36*3)

;*****which one do I plot? maybe just make a correlation table...
wet = where(finite(sta_paw0608))
print, correlate(bb0608(wet),bbavg(wet));0.84
print, correlate(bb0608(wet),sta_paw0608(wet));0.85
print, correlate(bbavg(wet),sta_paw0608(wet));0.79
print, correlate(bbnwet0608(wet),bbavg(wet));0.37 - doh! the clouds!

nve, bb0608
nve, bbavg

 xtickname = ['Jun-06', 'Jun-07','Jun-08']
 xtickvals = [0,36,72]+18
p2 = plot(sta_paw0608, thick = 3, 'black', name = 'station PAW', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,107])
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='station PAW (mm)', $
       TEXTPOS=1,tickfont_size=20, minor = 0)
p1 = plot(sarray[0,0:107]*100, thick = 3, 'light grey', name = 'observed SM@ 20cm', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, font_name='times',$
         xtickname = xtickname,$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT, xrange=[0,107])
p3 = plot(bb0608, /overplot,thick =2, 'orange', name='ECV_MW_SM')
p4 = plot(bbnwet0608*0.01, /overplot,thick =2, 'orange', name='NDVI_SM', linestyle=2)

lgr2 = LEGEND(TARGET=[p1, p2,p3,p4], font_size=16, font_name='times')
p1.xtickfont_size = 20
p1.ytickfont_size = 20
p1.ytitle='soil moisture (%VWC)'
p1.font_name='times'


;******compare Monthly soil moisture anomalies between NPAW, RPAW, microwave for the different countries****
;I should re-do these anomalies, for just the 10 years. 

mfile = file_search('/home/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img')
rfile = file_search('/home/chg-mcnally/rpaw_monthly.img')
nfile = file_search('/home/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img')

nx=720
ny=350

rpawcube = fltarr(nx,ny,12,12)*!values.f_nan
nwetcube = fltarr(nx,ny,12,12)*!values.f_nan

openr,1,nfile
readu,1,nwetcube
close,1

openr,1,rfile
readu,1,rpawcube
close,1

mingrid = fltarr(nx,ny)
mbuffer = fltarr(nx,ny,n_elements(mfile))

for i = 0,n_elements(mfile)-1 do begin &$
  openr,1,mfile[i] &$
  readu,1,mingrid &$
  close,1 &$
  mbuffer[*,*,i] = mingrid &$
endfor
;pad these out....
pad = fltarr(nx,ny,24)*!values.f_nan
mwgrid = [ [[mbuffer]],[[pad]]]

smMWcube = reform(mwgrid,nx,350,12,12)

;changed to just the 10 year series...
Rstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      w0R = rpawcube[x,y,m,0:9] &$
      test = where(finite(w0R), count) &$
      if count le 1 then continue &$
      Rstdanom[x,y,m,*] = (w0R-mean(w0R,/nan))/stdev(w0R(where(finite(w0R)))) &$
    endfor &$
  endfor &$
endfor


Mstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      wMW = smMWcube[x,y,m,0:9] &$
      test = where(finite(wMW), count) &$
      if count le 1 then continue &$
      Mstdanom[x,y,m,*] = (wMW-mean(wMW,/nan))/stdev(wMW(where(finite(wMW)))) &$
    endfor &$
  endfor &$
endfor

NWstdanom=fltarr(nx,250,12,10);x,y,month,year
for x = 0,nx-1 do begin &$
  for y = 0,250-1 do begin &$
    for m=0,11 do begin &$
      Nwet = nwetcube[x,y,m,0:9] &$
      test = where(finite(nwet), count) &$
      if count le 1 then continue &$
      NWstdanom[x,y,m,*] = (nwet-mean(nwet,/nan))/stdev(nwet(where(finite(nwet)))) &$
    endfor &$
  endfor &$
endfor

;check out the anomalie maps for 2001, 2004, 2009
;NWstdanom[x,y,m,*]
;Rstdanom[x,y,m,*]
;Mstdanom[x,y,m,*]
;
;ncolors=256   
;
;  p1 = image(mean(Rstdanom[*,*,6:7,8], dimension=3, /nan)*cmask, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),$
;             image_dimensions=[72.0,25.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], min_value=-2, max_value=2) &$ 
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
;  p1.title = 'RPAW crop zones 2008'
;  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  
;*****************correlation maps added later (8/10/13)**********************************
;******************read in monthly SM data (RPAW, MW, LIS)********************************
;nfile = file_search('/jower/chg-mcnally/fromKnot/EXP01/monthly/Sm01*.img');132
;mfile = file_search('/jower/chg-mcnally/ECV_soil_moisture/monthly/sahel/*.img');120
;wfile = file_search('/jower/chg-mcnally/rpaw_monthly.img')
;ifile7 = file_search('/jower/chg-mcnally/sahel_NSM_microwave_monthly_12yrs.img');this is NWET?
;
;nx = 720
;ny = 350
;
;buffern = fltarr(nx,250)
;bufferm = fltarr(nx,350)
;
;sm01grid = fltarr(nx,250,n_elements(mfile))
;mwgrid = fltarr(nx,350,n_elements(mfile))
;rpawcube = fltarr(nx,350,12,12)*!values.f_nan
;nwetcube = fltarr(nx,ny,12,12)*!values.f_nan
;
;openr,1, wfile
;readu,1,rpawcube
;close,1
;
;openr,1,ifile7
;readu,1,nwetcube
;close,1
;
;for i = 0,n_elements(mfile)-1 do begin &$
;  openr,1,nfile[i] &$
;  openr,2,mfile[i] &$
;  
;  readu,1,buffern &$
;  readu,2,bufferm &$
;  
;  close,1 &$
;  close,2 &$
; 
;  sm01grid[*,*,i] = buffern &$
;  mwgrid[*,*,i] = bufferm &$
;endfor 
;
;mw_cube = reform(mwgrid,nx,350,12,10)
;sm01_cube = reform(sm01grid,nx,250,12,10)
;
;mo = [1,2,3,4,5,6,7,8,9,10,11,12]
;corgrid = fltarr(nx,ny,n_elements(mo))
;corgrid[*,*,*]=!values.f_nan
;
;;***correlation map for nwet and mw
;for m = 0,n_elements(mo)-1 do begin &$
;  for x = 0,nx-1 do begin &$
;    for y = 0,250-1 do begin &$
;     test = where(finite(rpawcube[x,y,mo[m]-1,*]),complement=null) &$
;     if n_elements(null) eq 12 then continue &$
;     corgrid[x,y,m]=correlate(mw_cube[x,y,mo[m]-1,*],nwetcube[x,y,mo[m]-1,0:9]) &$
;    endfor  &$
;  endfor  &$
;  print,x,y &$
;endfor 
;
;p1 = image(corgrid[*,*,6], image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
;           RGB_TABLE=4, max_value=1,title = 'NWET-MW Correlation: July')
;  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
;p1 = MAP('Geographic',LIMIT = [0, -20, 18, 25], /overplot) &$
;  p1.mapgrid.linestyle = 'dotted' &$
;  p1.mapgrid.color = [150, 150, 150] &$
;  p1.mapgrid.label_position = 0 &$
;  p1.mapgrid.label_color = 'black' &$
;  p1.mapgrid.FONT_SIZE = 12 &$
;  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) 
 
;***compare standardized soil mositure by crop zones***********************
cfile = file_search('/home/chg-mcnally/cz_mask_sahel.img')

nx = 720
ny = 350
nz = 12

cgrid = fltarr(nx,ny)

openr,1,cfile
readu,1,cgrid
close,1

cgrid = cgrid[*,0:249]

burkina = where(cgrid eq 1, count) & print, count
chad = where(cgrid eq 2, count) & print, count
mali = where(cgrid eq 3, count) & print, count
niger = where(cgrid eq 4, count) & print, count
senegal = where(cgrid eq 5, count) & print, count

;mask out the crop zones of interest
cmask=cgrid
cmask(where(cmask ge 1 AND cgrid le 5, complement=null))=1
cmask(null)=!values.f_nan

;get the RPAW, NPAW, SM01, SM02, and SMMW for each country (averged over? J,A,S?)
;rain  then NDVI
;******************************************** 
;where were these standardized?

NigerSM = fltarr(3,12,10)
SenegalSM = fltarr(3,12,10)
MaliSM = fltarr(3,12,10)
BurkinaSM = fltarr(3,12,10)
ChadSM = fltarr(3,12,10)

for m = 0,n_elements(mstdanom[0,0,*,0])-1 do begin &$
  for y = 0,n_elements(mstdanom[0,0,0,*])-1 do begin &$
    rpaw = rstdanom[*,*,m,y] &$
    smMW = mstdanom[*,*,m,y] &$
    nwet = nwstdanom[*,*,m,y] &$
    
    NigerSM[*,m,y] =  [mean(rpaw(niger),/nan)    ,mean(smMW(niger),/nan)  ,mean(nwet(niger),/nan)] &$
    SenegalSM[*,m,y] =  [mean(rpaw(senegal),/nan),mean(smMW(senegal),/nan),mean(nwet(senegal),/nan)] &$
    MaliSM[*,m,y] =  [mean(rpaw(mali),/nan)      ,mean(smMW(mali),/nan)   ,mean(nwet(mali),/nan)] &$
    BurkinaSM[*,m,y] =  [mean(rpaw(burkina),/nan),mean(smMW(burkina),/nan),mean(nwet(burkina),/nan)] &$
    ChadSM[*,m,y] =  [mean(rpaw(chad), /nan)     ,mean(smMW(chad),/nan)   ,mean(nwet(chad),/nan)] &$
    
  endfor &$    
endfor;i

;take the july-aug mean
BJA = mean(BurkinaSM[*,6,*], dimension=2, /nan) 
CJA = mean(ChadSM[*,6,*], dimension=2, /nan)
MJA = mean(MaliSM[*,6,*], dimension=2, /nan)
NJA = mean(NigerSM[*,6,*], dimension=2, /nan)
SJA = mean(SenegalSM[*,6,*], dimension=2, /nan)

;*****out for google*****
garray =[[bja[0,*]],[bja[1,*]],[bja[2,*]] ] & print, garray
;******************
WAarray = [ [[BJA]],[[CJA]], [[MJA]],[[NJA]],[[SJA]] ] & help, WAarray
sahelavg = mean(waarray, dimension=3, /nan) & help, sahelavg
colors = ['blue', 'orange', 'green']
nbars = 3

 xticks = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010']
 xtickvalues = [0,1,2,3,4,5,6,7,8,9]
;plot all three products for each year in Burkina
 b1 = barplot(sahelavg[0,*], nbars=nbars, fill_color=colors[0],index=0, /overplot, name = 'R-PAW')
 b2 = barplot(sahelavg[1,*], nbars=nbars, fill_color=colors[1],index=1, /overplot, name = 'ECV_MW')
 b3 = barplot(sahelavg[2,*], nbars=nbars, fill_color=colors[2],index=2, /overplot, name = 'N-PAW')
 b2.yrange = [-0.75,0.75]
 b2.ytitle = 'standardized anomaly'
   b2.xminor = 0 &$
   b2.yminor = 0 &$
   b2.xtickvalues = xtickvalues &$
   b2.xtickname = xticks &$
   b2.font_name='times' &$
   b2.font_size=16 &$
   ax = b2.axes
   ax[2].HIDE = 1 
   ax[3].HIDE = 1 
  !null = legend(target=[b1,b2,b3], position=[0.2,0.3], font_size=14) ;
   



name = ['R-SM', 'MW-SM','N-SM']

  index = 0
  xticks = ['July', 'Aug', 'Sept']
  xtickvalues = [0,1,2]

for y =1,4 do begin &$
  for p=0,n_elements(NigerSM[*,0,0])-1 do begin &$
    y=1 &$
    b2 = barplot(burkinasm[p,6:8,y], nbars=nbars, fill_color=colors[p],index=p, name = name[p], /overplot) &$
   
   b2.yrange=[-2,2] &$
   b2.xminor = 0 &$
   b2.yminor = 0 &$
   b2.xtickvalues = xtickvalues &$
   b2.xtickname = xticks &$
   b2.font_name='times' &$
   b2.font_size=16 &$
   b2.title = 'chad et standardized anomalies '+strcompress('200'+string(y+1), /remove_all) &$
   ax = b2.axes &$
   ax[2].hide = 1  &$
   ax[3].hide = 1  &$
   if p lt 3 then continue &$
   !null = legend(target=[b1], position=[0.2,0.3], font_size=14) &$
  endfor &$
  w=window() &$
endfor


p1 = plot(brwanom,yield_mat[0,*]/stdev(yield_mat[0,*]),'o',sym_size=2, name='R-WRSI')
p2 = plot(bsWanom,yield_mat[0,*]/stdev(yield_mat[0,*]),'go',/overplot, sym_size=2,/SYM_FILLED,$
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name = 'N-WRSI')
p2.xrange=[-8,8]
p2.yrange=[-2.5,2.5]
p1.title = 'Burkina Faso: R-WRSI (0.53*), N-WRSI (0.72**)'
p1.font_size = 18
p3=plot([0,0],[-8,8],/overplot)
p3=plot([-8,8],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14) ;


;p2 = plot(byanom, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0, yrange = [-1500,1500])
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(brwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.51', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(bnwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.45', /overplot,yrange=[-10,10])
!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks

;****CHAD**WOWY**************
;cyanom = cyield[1:11]-mean(cyield[1:11])
crwanom = ChadWRSI[0,*]-mean(ChadWRSI[0,*])
cnwanom = ChadWRSI[1,*]-mean(ChadWRSI[1,*])

print, r_correlate(yield_mat[1,*],crwanom);48*
print, r_correlate(yield_mat[1,*],cnwanom);59

;maybe don't standardize them? that isn't want the correlation is anyway...
;p1 = plot(crwanom/stdev(crwanom),yld2[1,1:11]/stdev(yld2[1,1:11]),'o',sym_size=2, name = 'R-WRSI');
p1 = plot(crwanom,yield_mat[1,*]/stdev(yield_mat[1,*]),'o',sym_size=2, name = 'R-WRSI');
p2 = plot(cnwanom,yield_mat[1,*]/stdev(yield_mat[1,*]),'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='N-WRIS')
p2.xrange=[-10,10]
p2.yrange=[-3,3]
p1.title = 'Chad: R-WRSI (0.48*), N-WRSI (0.59*)'
p1.font_size = 18
p3=plot([0,0],[-10,10],/overplot)
p3=plot([-10,10],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14, line_thick=0) ;


;p2 = plot(cyanom, thick = 3, 'black', name = 'Yield anom', /overplot, $
;         xtickvalues = xtickvalues, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         AXIS_STYLE=0, yminor = 0)
;yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='Yield anomaly (Hg/Ha)', $
;       TEXTPOS=1,tickfont_size=20, minor = 0, tickfont_name='times')
;p1 = plot(crwanom, thick = 3, 'light grey', name = 'R-WRSI anom, r=0.45', xminor = 0, yminor = 0, $
;         MARGIN = [0.15,0.2,0.15,0.1], $
;         xtickvalues = xtickvalues, font_name='times',$
;         YTITLE='WRSI anomaly',AXIS_STYLE=1,/CURRENT, xrange=[0,MAX(p2.xrange)],font_size=20)
;p3 = plot(cnwanom, thick = 2, 'green', name = 'N-WRSI anom, r=0.85', /overplot, yrange=[-15,15])
;!null = legend(target=[p1,p3,p2], position=[0.2,0.3], font_size=14) ;
;p3.xtickname=xticks



;*******WHOOT -- Mali************
;myanom = myield[1:11]-mean(myield[1:11])
mrwanom = MaliWRSI[0,*]-mean(MaliWRSI[0,*])
mnwanom = MaliWRSI[1,*]-mean(MaliWRSI[1,*])

;i dunno why these numbers are changing....except maybe when i added an extra year?
print, r_correlate(yield_mat[2,*],mrwanom);0.65**, 0.63, 0.3
print, r_correlate(yield_mat[2,*],mnwanom);0.73**, 0.60, 0.5*

p1 = plot(mrwanom,yield_mat[2,*]/stdev(yield_mat[2,*]),'o',sym_size=2, name = 'R-WRSI')
p2 = plot(mnwanom,yield_mat[2,*]/stdev(yield_mat[2,*]),'go',/overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0,font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name = 'N-WRSI')
          
p2.xrange=[-10,10]
p2.yrange=[-3,3]
p1.title = 'Mali: R-WRSI (0.3), N-WRSI (0.5*)'
p1.font_size = 20
p3=plot([0,0],[-10,10],/overplot)
p3=plot([-10,10],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14, sample_width=0) ;

  
  ;*******************NIGER************************** 
;b=0,c=1,m=2,n=3,s=4
;nyanom = nyield[1:11]-mean(nyield[1:11])
nrwanom = NigerWRSI[0,*]-mean(NigerWRSI[0,*])
nnwanom = NigerWRSI[1,*]-mean(NigerWRSI[1,*])

print, r_correlate(yield_mat[3,*],nrwanom);0.47; 0.51
print, r_correlate(yield_mat[3,*],nnwanom);0.62;0.60**

;and chris's scatterplot
p1 = plot(nrwanom,yield_mat[3,*]/stdev(yield_mat[3,*]),'o',sym_size=2, name = 'R-WRSI')
p2 = plot(nnwanom,yield_mat[3,*]/stdev(yield_mat[3,*]),'go', /overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0, font_size=20, font_name='times', ytitle='yield anomaly',$ 
          xtitle = 'WRSI anomaly', name='N-WRSI')          
p2.xrange=[-15,15]
p2.yrange=[-2,2]
p1.title = 'Niger: R-WRSI (0.4), N-WRSI (0.62*)'
p1.font_size = 20
p3=plot([0,0],[-15,15],/overplot)
p3=plot([-15,15],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=14) ;

;***********************************************
;WHOOT --Senegal
;syanom = syield[1:11]-mean(syield[1:11])
srwanom = SenegalWRSI[0,*]-mean(SenegalWRSI[0,*])
snwanom = SenegalWRSI[1,*]-mean(SenegalWRSI[1,*])

print, r_correlate(yield_mat[4,*],srwanom);0.73 (0.011); 0.
print, r_correlate(yield_mat[4,*],snwanom);0.9  (0.00);0.86

;and chris's scatterplot
p1 = plot(srwanom,yield_mat[4,*]/stdev(yield_mat[4,*]),'o',sym_size=2, name='R-WRSI')
p2 = plot(snwanom,yield_mat[4,*]/stdev(yield_mat[4,*]),'go', /overplot, sym_size=2,/SYM_FILLED, $
          yminor=0, xminor=0, font_size=20, font_name='times', ytitle='yield anomaly standardized',$ 
          xtitle = 'WRSI anomaly', name='N-WRSI')

p2.xrange=[-30,30]
p2.yrange=[-2,2]
p1.title = 'Senegal: R-WRSI (0.69*), N-WRSI (0.79**)'
p1.font_size = 20
p3=plot([0,0],[-30,30],/overplot)
p3=plot([-30,30],[0,0],/overplot)
!null = legend(target=[p1,p2], position=[0.2,0.3], font_size=12) ;





;checkum out, still not toatally sure why i lose a whole yr of NDVI. 
mmngrid = mean(mngrid[*,*,0:9],dimension=3,/nan)
mmngrid(where(mmngrid lt 50))=!values.f_nan

mmrgrid = mean(mrgrid[*,*,0:9],dimension=3,/nan)
mmrgrid(where(mmrgrid lt 50))=!values.f_nan

mdiff = mmngrid-mmrgrid
mdiff(where(mdiff gt 20 OR mdiff lt -20))=!values.f_nan
;****for the nice WRSI looking map*******************
p1 = image(byte(mmngrid), image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
            RGB_TABLE=make_wrsi_cmap(), title = 'mean (2001-2011) N-WRSI')
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;***************for the difference map, use the cmap color table*****************
ncolors=256   

  p1 = image(mdiff, RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             dimensions=[nx/100,ny/100],title = 'mean diff', min_value = -20, max_value=20) &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])

;**********************************************************************************
;***********************start checking out the anomalies year by year**************
;**********************************************************************************
rfile = file_search('/home/chg-mcnally/EOS_WRSI_ubRFE2001_2012vPETv2.img') 
nfile = file_search('/home/chg-mcnally/EOS_WRSI_NDVI2001_2012vPETv2.img')

nx = 720
ny = 350
nz = 12

rgrid = fltarr(nx,ny,nz)
ngrid = fltarr(nx,ny,nz)

openr,1,rfile
readu,1,rgrid
close,1

openr,1,nfile
readu,1,ngrid
close,1

nanom = fltarr(nx,ny,11)
nm=fltarr(11)
rm=fltarr(11)
for i = 0,9 do begin &$
  nanom[*,*,i] = mngrid[*,*,i]-mean(mngrid[*,*,0:9], dimension=3,/nan) &$
  nm[i] = mean(nanom[*,*,i],/nan) &$
endfor  

ranom = fltarr(nx,ny,11)
;apparenetly i lost a year at the end of mrgrid is this right?
for i = 0,9 do begin &$
  ranom[*,*,i] = mrgrid[*,*,i]-mean(mrgrid[*,*,0:9], dimension=3,/nan) &$
   rm[i] = mean(ranom[*,*,i],/nan) &$
endfor  
;***make a nice barplot, not in excel :) ********
nbars = 2
colors = ['blue', 'green']
data = [[rm],[nm]]

  index = 0
  xticks = ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011']
  xtickvalues = [0,1,2,3,4,5,6,7,8,9,10]
   b1 = barplot(rm/stdev(rm), nbars=nbars, index=0,fill_color=colors[0], name = 'R-WRSI');blue = rain
   b2 = barplot(nm/stdev(nm), nbars=nbars, index=1,fill_color=colors[1],/overplot, yrange = [-2,2], name = 'N-WRSI')
   b2.xminor = 0
   b2.yminor = 0
   b2.xtickvalues = xtickvalues
   b2.xtickname = xticks
   b2.font_name='times'
   b2.font_size=16
   
   ax = b2.axes
   ax[2].HIDE = 1 
   ax[3].HIDE = 1 
  !null = legend(target=[b1,b2], position=[0.2,0.3], font_size=14) ;
  
   
;*********************************************************************  
NCOLORS=256
;wet=2003,2005 dry = 2004,2002
i=6
good = where(finite(nanom), complement=null)
nanom(null) = 0

good = where(finite(ranom), complement=null)
ranom(null) = 0

  p1 = image(nanom[*,*,i], RGB_TABLE=CONGRID(make_cmap(ncolors),3,256),image_dimensions=[72.0,35.0], image_location=[-20,-5], $ 
             min_value=-20, max_value=20, $ 
             dimensions=[nx/100,ny/100], title = strcompress('N-WRSI_ANOMALY_200'+string(i+1),/remove_all )) &$ 
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20) &$
  p1 = MAP('Geographic',LIMIT = [0, -20, 18, 52], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120]) &$
 ; p1.Save, strcompress("/home/mcnally/N_anom_data"+string(i)+".png", /remove_all), BORDER=10, RESOLUTION=300, /TRANSPARENT   &$ 


;check out the wet/dry years
meangrid = fltarr(11)
for i =0,10 do begin &$
 meangrid[i] = mean(ranom[*,*,i], /nan) &$
endfor

;incase i mess up 1/29/14
;for x = 0, 720-1 do begin &$
;  for y = 0, 250-1 do begin &$
;    r = rpawgrid[x,y,*] &$
;    l = lpawgrid3[x,y,*] &$
;    m = mpawgrid[x,y,*] &$
;    n = npawgrid[x,y,*] &$
;    no = nogrid[x,y,*] &$
;    mo = mogrid[x,y,*] &$
;    
;    rr = r(where(finite(r)))  &$
;    ll = l(where(finite(l))) &$
;    mm = m(where(finite(m))) &$
;    nn = n(where(finite(n))) &$
;    nno = no(where(finite(no))) &$
;    mmo = no(where(finite(mo))) &$
;    
;  
;    out_rl[x,y] = correlate(rr,ll) &$
;    out_rm[x,y] = correlate(rr,mm) &$
;    out_rn[x,y] = correlate(rr,nn) &$
;    out_rno[x,y] = correlate(rr,nno) &$
;    out_rmo[x,y] = correlate(rr,mmo) &$
;    
;    
;    
;    out_lm[x,y] = correlate(ll,mm) &$
;    out_ln[x,y] = correlate(ll,nn) &$
;    out_lno[x,y] = correlate(ll,nno) &$    
;    out_lmo[x,y] = correlate(ll,mmo) &$
;    out_mom[x,y] = correlate(mmo,mm) &$
;    
;    
;    out_mn[x,y] = correlate(mm,nn) &$
;        
;  endfor &$
;endfor
