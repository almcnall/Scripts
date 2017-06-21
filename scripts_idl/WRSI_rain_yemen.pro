;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; greg wrote separate funtions (see WRSI_millet.pro), now this just has inputs.
; 1/30/2013: This is the file for the gridded inputs -- to be used with the compiled WRSI_millet_PR.pro
; 7/6/2012: updated to return SOS, AET, PAW and WRSI
; 10/4/2013 migrated to Rain
; 1/30/2014 thinking about re-running with the static SOS map to make the results for paper #2 more independant/stable
; 3/27/2014 figure out to calculate SOS for Yemen and make a climSOS map, also need climWRSI.
; This is the new version...
; 
;****get WHC*******
;try static WHC for sensitivity tests...
nx = 121
ny = 81
ifile = file_search('/home/chg-mcnally/whc0ym.bil')
whcgrid = bytarr(nx,ny)

openr,1,ifile
readu,1,whcgrid
close,1

whcgrid = reverse(whcgrid,2)
;******get LGP***********
ifile = file_search('/home/chg-mcnally/lgp_ym.bil')
lgpgrid = bytarr(nx,ny)
openr,1,ifile
readu,1,lgpgrid
close,1

;reverse to get it right-side up
lgpgrid = reverse(lgpgrid,2)

;****climatological SOS***********
;this is what I need to make. with which rainfall? does it matter?
;use the same rain as in the lgp script? yemen FCLIM?


;*****Gridded rainfall********
;this needs to be dekadal rainfall for the exact yemen domain at 0.1 degree...
;might as well use the kind of stuff that pete is producing -- see the link that he sent.
ifile = file_search('/raid2/sandbox/people/mcnally/CHIRPS-1.7/dekads/yemen/*.tif');these are 2001-2012

nx = 121
ny = 81
nz = n_elements(ifile);432 = 12*36

ingrid = fltarr(nx,ny)
rgrid = fltarr(nx,ny,nz)

;make a big stack and then reform...
for i = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  rgrid[*,*,i] = ingrid &$
endfor
rgrid(where(rgrid lt 0))=!values.f_nan 
;crop this down to just 2012 or add three dekads to round out 2013 (I'll do that...)
;I wonder how bad this chrips data is... eak!
temp =[  [[rgrid[*,*,*] ]], [[rgrid[*,*,1182:1184] ]]  ]
rainyrly = reform(temp,nx,ny,36,33) ;

;******station rainfall**********
;wfile = file_search('/raid/chg-mcnally/GTS.Niamey_Rainstation_dekad.csv')
;wrain = read_csv(wfile)
;wcube = float(reform(wrain.field1,36,11))
;wcube = [[wcube], [wcube(*,10)]] ;add a year for padding
;good = where(finite(wcube), complement=null)
;;why did i change NANs to zeros?
;wcube(null) = 0.

;*******EROS PET*****************
;crap i need dekadal yemen pet here, not monthly.
;ifile = file_search('/home/chg-mcnally/PETsahel.img') ;2001-2012
ifile = file_search('/home/sandbox/people/mcnally/PET_yemen.img')

nx = 121
ny = 81
ndk = 36
;nyr = 1

PETgrid = fltarr(nx,ny,ndk)

  openr,1,ifile 
  readu,1,PETgrid 
  close,1

;do i need to rep-mat this?
 EROSpet = Rebin(petgrid, 121,81, 36, 33)
;
;;add an extra yr to the petgrid so that it can run full 2012
;;and multiply by 10 to get the units correct
;temp = reform(petgrid,nx,ny,432)*10
;temp =[  [[temp[*,*,*] ]], [[temp[*,*,396:431] ]]  ] 
;EROSpet = reform(temp,nx,ny,36,13);x,y,dek,yr

;********************************
;find a place in yemen for spot checking like this
;Wankama 2006 - 2011 (13.6456,2.632 )
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)


;******initialize depending on station or whole sahel******
raingrd = rainyrly[*,*,*,*]
petgrd = EROSpet[*,*,*,*]; 
nyrs = n_elements(petgrd[0,0,0,*])
WRSIgrid = fltarr(nx,ny,nyrs);nx,ny,nyrs
PAWgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
AETgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
SOSout = fltarr(nx,ny,nyrs)
KCgrid = fltarr(nx,ny,max(lgpgrid)+1,nyrs)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
     ;x = nxind
     ;y = nyind
    ;loop/grid vs point
    if lgpgrid[x,y] le 1 then continue &$
    
    for yr = 0,n_elements(petgrd[0,0,0,*])-2 do begin &$ 
     rain = reform(raingrd[x,y,*,yr:yr+1],72) &$ 
     ;rain = wcube[*,yr] &$
     pet = reform(petgrd[x,y,*,yr:yr+1],72) &$ 
     ;pet = reform(petgrd[x,y,*,yr],36) &$
      whc = whcgrid[x,y] &$ 
     lgp = lgpgrid[x,y]  &$ 
     ;whc = 125 &$ 
     ;lgp = 10  &$ 
     ;comment/uncomment depending on static or dynamic SOS
     ;sos_ind = sosgrid[x,y]  &$
     ;new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp, sos_ind=sos_ind) &$
     new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp, pawout=tmppaw, aetout=tmpaet, sosout=tmpsos, kcout = tmpKC) &$
     ;new_wrsi = wrsi(rain, pet, whc=whc, lgp=lgp, pawout=tmppaw, aetout=tmpaet, sos_ind=sos_ind, kcout = tmpKC) &$
     
    ;IF outputing WRSI/SOS/LGP (scalar) 
     wrsigrid[x,y,yr] = new_wrsi &$ 
     SOSout[x,y,yr] = tmpsos &$
    ;this pads out the array so that different length of growing periods can be accomadiated.   
     pad = fltarr(max(lgpgrid)+1 -n_elements(tmppaw)) &$
     pad[*] = !values.f_nan &$
     PAWpad = [tmppaw,pad] &$
     AETpad = [tmpaet,pad] &$
     KCpad  = [tmpKC, pad] &$
     
     PAWgrid[x,y,*,yr] = PAWpad  &$
     AETgrid[x,y,*,yr] = AETpad  &$
     Kcgrid[x,y,*,yr]  = KCpad   &$
    endfor &$ ;yr 
 ;print, 'done'
  endfor &$ ;y
endfor &$
print, 'done'

test = sosout
test2 = wrsigrid
  ncolors = 15
  p1 = image(mean(test[*,*,0:31], dimension=3,/nan), rgb_table=20, image_dimensions=[12.0,8.0],$
               image_location=[42,12],dimensions=[120,80], max_value=15)
  c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13],$
              font_size=20, range=[0,100])           
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
 rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
 rgbdump[*,0] = [200,200,200]
  p1.rgb_table = rgbdump  ;
 
  p1 = MAP('Geographic',LIMIT = [12,42, 20, 54], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
  
  sosclim = mean(test[*,*,0:31], dimension=3, /nan)
  sosclim = byte(reverse(sosclim,2))
  wrsiclim = mean(test2[*,*,0:31], dimension=3,/nan)
  wrsiclim = byte(reverse(wrsiclim,2))

;uh-oh did i write out to the wrong filename?  
ofile = strcompress('/home/mcnally/SOSclim_yemen.bil')
openw,1,ofile
;writeu,1,sosclim
writeu,1,wrsiclim
close,1
;


ncolors=256
p1 = image(byte(wrsiclim),image_dimensions=[12.0,8.0],$
               image_location=[42,12],dimensions=[120,80], RGB_TABLE=make_wrsi_cmap()) &$ 

c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100]) 
rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
rgbdump[*,0] = [200,200,200]
p1.rgb_table = rgbdump  ; reassign the colorbar to the image

p1 = MAP('Geographic',LIMIT = [12,42, 20, 54], /overplot) &$
  p1.mapgrid.linestyle = 'dotted' &$
  p1.mapgrid.color = [150, 150, 150] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120], thick=2)
