FUNCTION make_wrsi_cmap
;;;;; 
; this function writes out the colormap for WRSI grids to match the 
; online colorscale.  
;
; no input arguments are required.
;
; DEVELOPED BY: Greg Husak	February 12, 2013
;
;;;;;

cmap = BYTARR(3,256)

; set the fail color
for i=0,49 do cmap[*,i] = [255,97,24]
; set the poor color
for i=50,59 do cmap[*,i] = [206,170,49]
; set the mediocre color
for i=60,79 do cmap[*,i] = [255,255,198]
; set the average color
for i=80,94 do cmap[*,i] = [189,255,41]
; set the good color
for i=95,99 do cmap[*,i] = [49,223,0]
; set the very good color
cmap[*,100] = [0,174,57]
; set the no start (late) color
cmap[*,253] = [255,166,206]
; set the yet to start color
cmap[*,254] = [123,255,247]
; set the N/A color
cmap[*,255] = [255,255,255]

;;; return the flipped version of cmap
return,cmap

END

