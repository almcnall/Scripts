
; This program takes an input grid and maps it with country boundaries. 
; It is designed to handle the default africa RFE window, but will
; hopefully allow more input arguments later to be more flexible.
;

PRO map_afr_rfe,ingrid,CTVALUE=CTVALUE

;  CTVALUE = colortable value to be used, if not set then revert to default value

   DEFAULT_CT = 2	; set default colortable if not set elsewhere
   
   if KEYWORD_SET(CTVALUE) then begin
      if CTVALUE ge 0 AND CTVALUE le 40 then $
         loadct,CTVALUE,/SILENT $
      else loadct,DEFAULT_CT
   endif else begin
      loadct,DEFAULT_CT,/SILENT
   endelse

   xdim = 751
   ydim = 801

   lonmin = -19.95
   lonmax = 55.05
   latmin = -39.95
   latmax = 40.05

   loncen = (lonmin + lonmax) / 2.0
   latcen = (latmin + latmax) / 2.0

   device, decomposed=0, /bypass_translation
   window,xsize=xdim,ysize=ydim

   MAP_SET,$
     ; latcen, loncen, 0, $
     /mercator, $
     limit=[latmin,lonmin,latmax,lonmax]
     ; XMARGIN = [0,0], $
     ; YMARGIN = [0,0]

   warpedimage = map_image(ingrid,startx,starty, COMPRESS=1, $
     LATMIN=latmin,LATMAX=latmax,LONMIN=lonmin,LONMAX=lonmax)

;   print,startx,starty

   tvscl,warpedimage,startx,starty

   MAP_CONTINENTS, /COASTS, /COUNTRIES, MLINETHICK=2, color=200
   MAP_GRID, /LABEL, /HORIZON, color=100, $
     londel=10, latdel=10,lonlab=-40,latlab=-20,latalign=0,lonalign=0

END
