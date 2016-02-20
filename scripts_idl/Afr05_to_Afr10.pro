FUNCTION Afr05_to_Afr10,indat 
   ; this function reads in a global 0.05-degree file [-180:180E, -50:50N] with 
   ; dimensions (7200x2000) and returns the africa window at 0.1-degree 
   ; [-20.05:55.05E, -40.05:40.05N] with dimensions (751x801).
   ; 
   ; infile = filename of global file
   ;
   ; Created by: Greg Husak, October 22, 2013
      

   INX = 1500
   INY = 1600

   OUTX = 751
   OUTY = 801

   outdat = FLTARR(OUTX,OUTY)

   indat2 = FLTARR(INX+2,INY+2)
   indat2[1:-2,1:-2] = indat

   for x=0,OUTX-1 do begin
      lox = 2*x
      hix = lox+1
      for y=0,801-1 do begin
         loy = 2*y
         hiy = loy+1
         tmparr = indat2(lox:hix,loy:hiy)       ; 2x2 grid at original resolution convert to 0.1 resolution
         blug = where(tmparr ge 0, cnt)
         if(cnt gt 0) then outdat(x,y) = mean(tmparr(blug))
      endfor
   endfor

   return,outdat

END


