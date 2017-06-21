PRO clipAfrica

; this program subsets the FCLIM data to the Africa domain
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees, 301 x 321  pixels @ 0.25 deg, 751 x 801 @ 0.1 degree
; don't concatinate geoTiffs, stupid.

indir  = strcompress('/gibber/Products/FTIP_Global/idl_saves/binaryFCLIM/',/remove_all)
outdir = strcompress('/jabber/LIS/Data/FCLIM_Afr/', /remove_all)
file_mkdir, outdir

cd, indir
ifile=file_search('*.bin')

nx    = 7200 ;global fclim at 0.05 degree
ny    = 2000

onx = 1501
ony = 1601
nbands = 12

globe   = lonarr(nx,ny)
buffer  = lonarr(onx,ony,nbands)

;subset Africa and make cubes of the FClim
for i=0,n_elements(ifile)-1 do begin
   openr,1,ifile[i]
   readu,1,globe
   ;temp=image(reverse(globe[3200:4700,200:1800],2))
   buffer[*,*,i] = globe(3200:4700,200:1800) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      
   close,1   
endfor  

print, 'hold here'
;write to file   
   ofile=outdir+'Fclim_Afr_cube.img'   
   openw, 2,ofile
   writeu,2,buffer
   
   close, 2

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


   

