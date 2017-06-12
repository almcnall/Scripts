PRO clipAfrica_malawi

; this program subsets the Africa FCLIM data to the Malawi domain
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees, 301 x 321  pixels @ 0.25 deg, 751 x 801 @ 0.1 degree
; don't concatinate geoTiffs, stupid.

indir  = strcompress('/jabber/LIS/Data/FCLIMv4_0.1_bin/',/remove_all)
outdir = strcompress('/jabber/LIS/Data/FCLIM_Malawi/', /remove_all)
file_mkdir, outdir

cd, indir
file=file_search('*.bin')

inx  = 751 ;global fclim at 0.1 degree
iny  = 801
x   = 31   ;malawi domain at 0.1 degree (to match RFE2)
y   = 77


afr   = fltarr(inx,iny)
buffer  = fltarr(x,y)
fltgrid = fltarr(x,y)

;subset Africa and make cubes of the FClim
for i=0,n_elements(file)-1 do begin
   openr, 1, indir+file[i] 
   readu, 1, afr                          
   buffer= afr(527:558,229:306) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      
   close,1 
   ofile=strmid(file[i],0,2)+'malawi.bin'
   outgrid= strcompress(outdir+ofile,/remove_all)
   
   openw, 2,outgrid
   writeu,2,buffer
   
   close, 2                                   ;Malawi   32.75 - 35.85 E, -17.05 - -9.35S  
endfor  

;regrid to 0.1 degree and change to float
   ;regrid=congrid(buffer,outx,outy,12) ;regrids the 0.1 degree to 0.25
   ;fltgrid=float(regrid)
   ;fltgrid[WHERE(fltgrid lt 0.)] = !VALUES.F_NAN

;write to file   
   

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


   

