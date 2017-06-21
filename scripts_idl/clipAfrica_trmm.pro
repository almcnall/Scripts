PRO clipAfrica_trmm

; this program subsets the trmmv6 data to the Africa domain. Global TRMM 0-360 (lon), 50S-50N (lat)
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees, 301 x 321  pixels @ 0.25 deg, 751 x 801 @ 0.1 degree
; 

indir  = strcompress('/jower/LIS/data/TRMM_amy/',/remove_all)
outdir = strcompress('/jabber/LIS/Data/ubTrmm_Afr/', /remove_all)

file_mkdir, outdir
cd, indir

file=file_search('20*')

inx    = 1440. ;global fclim at 0.05 degree
iny    = 400.
ibands = 1.
outx   = 301.   ;africa domain at 0.1 degree (to match RFE2)
outy   = 321.
obands = 1.

globe   = fltarr(inx,iny,ibands)
afr     = fltarr(outx,outy,obands)

for d=0,n_elements(file)-1 do begin
   cd, file[d]
   v6=file_search('3B42V6.*')
    file_mkdir, outdir+strmid(v6[d],7,6)
    
   ;subset Africa and make cubes of the FClim
  for i=0,n_elements(v6)-1 do begin
     openu,1,v6[i]
     readu,1,globe                                   
     afr[*,*] = globe(640:940,40:360) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      
     close,1
     
     ofile= strcompress(outdir+strmid(v6[d],7,6)+'/'+v6[i], /remove_all)
    
     openw,2,ofile
     writeu,2,afr
     close, 2 
  endfor ; i 
   ; come back up one level
  cd,'..'
 endfor ;d
   
 

; tvim Display an image with provisions for color,plot and axis titles, oplot capability
; scaling for colors, dealing w/ invalid data, displays true color images

      ;if the viariable is blue high, red low (rainfall, runoff)
     ; loadct,12,rgb_table=tmpct ;34 is rainbow, 3 is red scale
     ; tmpct = reverse(tmpct,1)
     ; tvlct,tmpct                 
      
      ;tvim, reverse(globe,2), range=[0,100]
      ;tvim,reverse(buffer,2),title='fclim',range=[0,100];, /scale,lcharsize=1.8, /noframe, pos = pos1
      ;map_set, 0,0,/cont,/cyl,limit=[-27,-22,50,62],/noerase, /noborder,pos=pos2, mlinethick=1,color=100, /grid
      ;map_set limits [latmin,lonmin,latmax,lonmax]
      ;map_continents, /countries, color=black,   mlinethick=2

end


   

