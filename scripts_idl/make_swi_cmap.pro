FUNCTION make_swi_cmap
;;;;; 
; this function writes out the colormap for WRSI grids to match the 
; online colorscale.  
;
; no input arguments are required.
;
; DEVELOPED BY: Greg Husak	February 12, 2013
; modified by amy to for the SWI color scheme
;;;;;

cmap = BYTARR(3,256)

; set the fail color
for i=10,50 do cmap[*,i] = [229,204,255]
; set the poor color
for i=50,90 do cmap[*,i] = [204,153,255]
; set the mediocre color
for i=90,100 do cmap[*,i] = [76,0,153]
; set the no start (late) color
cmap[*,253] = [204,0,204]
; set the yet to start color
cmap[*,254] = [123,255,247]
; set the N/A color
cmap[*,255] = [255,255,255]

;;; return the flipped version of cmap
return,cmap

END

