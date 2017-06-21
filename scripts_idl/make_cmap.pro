FUNCTION make_cmap,ncolors
;;;;; 
; this function takes the number of colors and creates a colormap
; variable that goes from blue-white-red.  this is the colormap that
; should be used to show anomalies or differences.
;
; this function requires a numerical value of ncolors that defines the
; number of colors to be included in the output colormap.  ncolors
; should be an even number
;
; DEVELOPED BY: Greg Husak	March 26, 2012
;
; ncolors = an integer of the number of colors to be included in the LUT
;           (ncolors must be >= 8)
;           
;**the original version is in /jower/Data/dews/idl_user_contrib/pending...
;I copied it into my source dir so that I could make changes...AM 5/19/12
;
;;;;;

cmap = BYTARR(3,ncolors)
halfcol = FLOOR((ncolors+1)/2)-1	; index of the mid-point of the LUT

;;; start with the lower half of the colorscale

; deal with the blue
fullblue = CEIL((halfcol+1.0)/3.0)-1 	; index where the RGB should be [0, 0, 255]
for i=fullblue-1,0,-1 do cmap[2,i] = BYTE(255b - BYTE(255.0 * ((fullblue)-i) / (fullblue+1) ))
cmap[2,fullblue:halfcol] = 255b;

; deal with the green
fullcyan = fullblue + FIX((halfcol - fullblue) / 2.0) 
for i=fullblue+1,fullcyan do cmap[1,i] = BYTE(255.0 * (i-fullblue) / (fullcyan - fullblue))
cmap[1,fullcyan:halfcol] = 255b;

; deal with the red
for i = fullcyan+1,halfcol do cmap[0,i] = BYTE( 255.0 * (i- fullcyan) / FLOAT(halfcol - fullcyan))

;;; now reverse the colorscale for the bottom half

cmap(*,(ncolors-1)-halfcol:ncolors-1) = REVERSE(REVERSE(cmap[*,0:halfcol],2),1)

;;; return the flipped version of cmap
return,REVERSE(cmap,2)

END

