FUNCTION make_sos_cmap
;;;;; 
; this function writes out the colormap for WRSI SOS grids to match the 
; online colorscale.  
;
; no input arguments are required.
;
; DEVELOPED BY: Will Turner	July 27, 2015
;
;;;;;

cmap = BYTARR(3,256)

;;;set colors for respective SOS
;
; <= Apr 1
for i=1,10 do cmap[*,i] = [163,0,194]
; Apr 2
cmap[*,11] = [191,79,224]
; Apr 3
cmap[*,12] = [227,173,245]
; May 1
cmap[*,13] = [0,148,173]
; May 2
cmap[*,14] = [33,214,255]
; May 3
cmap[*,15] = [140,242,255]
; Jun 1
cmap[*,16] = [0,189,46]
; Jun 2
cmap[*,17] = [61,255,150]
; Jun 3
cmap[*,18] = [163,255,204]
; Jul 1
cmap[*,19] = [240,117,0]
; Jul 2
cmap[*,20] = [255,145,38]
; Jul 3
cmap[*,21] = [255,184,171]
; Aug 1
cmap[*,22] = [247,232,204]
; Aug 2
cmap[*,23] = [230,204,150]
; Aug 3
cmap[*,24] = [207,168,54]
; >= Sep 1
for i=25,36 do cmap[*,i] = [150,99,0]
; set the N/A color
cmap[*,0] = [255,255,255]
; set the NO START color
cmap[*,60] = [255,247,125]

;;; return the flipped version of cmap
return,cmap

END

