pro veg_map  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; I am trying to look at my vegetation files that don't seem to be opening in properly in envi. wtf?
; they open properly here in idl....
; 
; .compile /jower/dews/idl_user_contrib/esrg/tvim.pro
; .compile /jower/dews/idl_user_contrib/esrg/mve.pro
;*************************************************************************
device,decomposed=0

indir = strcompress("/home/mcnally/input/UMD-25KM",/remove_all)
cd, indir

vegtype = strarr(13); length = 9
vegtype= ['EvNeedle', 'EvBroad', 'DecNeedle', 'DecBroad', 'MixedCov', 'Wood', 'WoodGrass', 'closedShrub', 'openShrub','Grass', 'Crop', 'Bare', 'Urban'] 

nx     = 1440.
ny     = 600.
nbands = 13                    

file=file_search('UMD_veg0.25.1gd4r')

ingrid  = fltarr(nx,ny,nbands) ;initializes the array 

 openr,1,file             ;opens the file
 readu,1,ingrid           ;reads it into ingrid  
 close,1
 byteorder,ingrid,/XDRTOF
 
 mve,ingrid                 ;print out the max min mean and std deviation of var
 rgrid=ingrid
 ;rgrid = reverse(ingrid,2)  ;IDL reads from bottom to top, needs to be reversed to plot
   
  FOR k= 0,nbands-5 DO BEGIN ; just do the rainy months
      ;k=1
      window,k,xsize=nx+100, ysize=ny+100
      pos1 = [.05,.05,.91,.95] ;for full window

; tvim Display an image with provisions for color,plot and axis titles, oplot capability
; scaling for colors, dealing w/ invalid data, displays true color images

      ;if the viariable is blue high, red low (rainfall, runoff)
      loadct,12,rgb_table=tmpct ;34 is rainbow, 3 is red scale
      tmpct = reverse(tmpct,1)
      tvlct,tmpct                 
       
       ;map_set, 0,0,/cont,/cyl ;limit=[-19.5,30,-8,42.75],/noerase, /noborder,pos=pos1, mlinethick=1,color=125
       ;map_continents, /countries, color=125,   mlinethick=2
       tvim,rgrid(*,*,k),title=vegtype[k],range=[0,800,100], /scale,lcharsize=1.8, /noframe, pos = pos1
       
     
   
   endfor ;k-each band 


end ;end program


 
;
