PRO clipAfrica_veg

; this program subsets the global veg data to the Africa domain
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      300 x 320  pixels

indir = strcompress("/home/mcnally/input/UMD-25KM",/remove_all)
;outdir = strcompress('/home/mcnally/input/AfricaUMD-25KM' , /remove_all)

;file_mkdir,outdir

cd, indir
file=file_search('UMD_veg0.25.1gd4r')
infile  = n_elements(infile)

inx  =  1440.
iny  =  600.
ibands= 13
outx =  300.
outy =  320.
obands= 13

globe = fltarr(inx,iny,ibands)
afr   = fltarr(outx,outy,obands)

vegtype = strarr(13); 
vegtype= ['EvNeedle', 'EvBroad', 'DecNeedle', 'DecBroad', 'MixedCov', 'Wood', 'WoodGrass', 'closedShrub', 'openShrub','Grass', 'Crop', 'Bare', 'Urban'] 

;for i=0,n_elements(infile)-1 do begin
   ;i=0
   openu,1,file
   readu,1,globe                                ;persiann data starting at 0.125 deg chopping africa
   byteorder,globe,/XDRTOF
   afr = globe(640:940,140:440,*)
   close,1   
  
  FOR k= 0,ibands-1 DO BEGIN ; just do the rainy months
      ;k=1
      window,k,xsize=outx, ysize=outy
      pos1 = [.05,.05,.91,.95] ;for full window

; tvim Display an image with provisions for color,plot and axis titles, oplot capability
; scaling for colors, dealing w/ invalid data, displays true color images

      ;if the viariable is blue high, red low (rainfall, runoff)
      loadct,12,rgb_table=tmpct ;34 is rainbow, 3 is red scale
      tmpct = reverse(tmpct,1)
      tvlct,tmpct                 
       
      tvim,afr(*,*,k),title=vegtype[k],range=[0,800,100], /scale,lcharsize=1.8, /noframe, pos = pos1
      map_set, 0,0,/cont,/cyl,limit=[-27,-22,50,62],/noerase, /noborder,pos=pos2, mlinethick=1,color=100, /grid
      ;map_set limits [latmin,lonmin,latmax,lonmax]
      map_continents, /countries, color=black,   mlinethick=2
  endfor ;k-each band 
  
end


   

