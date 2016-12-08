PRO sunset_colors, N_COLORS = colnum

; Set colour table.
; Default, without keyword, is 254 sunset colours running smoothly from
; blue (1) to red (254), plus black (0) and white (255). The number of
; colours excluding black and white can be reduced with keyword N_COLORS
; set to a value in the range 1 to 11. This colour scheme is
; colour-blind friendly and suitable for printing.

; Written by: P.J.J. Tol, SRON, November 2009
; Improved palette, 17 January 2010


IF KEYWORD_SET(colnum) THEN BEGIN
   colnum = ROUND(colnum)
   IF (colnum LT 1 OR colnum GT 11) AND (colnum NE 254) THEN BEGIN
      MESSAGE, 'Number of colors is 1..11 or 254, set to 254.', /INFORMATIONAL
      colnum = 254
   ENDIF
ENDIF ELSE BEGIN
   colnum = 254
ENDELSE

; colour coordinates
IF colnum EQ 254 THEN x = INDGEN(colnum)/(colnum-1.) ELSE BEGIN xarr = $
  [[10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
   [10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
   [10, 7, 4, 0, 0, 0, 0, 0, 0, 0, 0], $
   [13, 9, 5, 1, 0, 0, 0, 0, 0, 0, 0], $
   [13, 9, 7, 5, 1, 0, 0, 0, 0, 0, 0], $
   [12, 10, 8, 6, 4, 2, 0, 0, 0, 0, 0], $
   [12, 10, 8, 7, 6, 4, 2, 0, 0, 0, 0], $
   [12, 11, 9, 8, 6, 5, 3, 2, 0, 0, 0], $
   [12, 11, 9, 8, 7, 6, 5, 3, 2, 0, 0], $
   [14, 12, 11, 9, 8, 6, 5, 3, 2, 0, 0], $
   [14, 12, 11, 9, 8, 7, 6, 5, 3, 2, 0]]
   x = xarr[0:colnum-1,colnum-1]
ENDELSE

; colour set
IF colnum NE 254 THEN BEGIN
   sunsetred = [174, 208, 210, 237, 245, 249, 255, 255, 230, 180, 153, 119, 58, 0, 61]
   sunsetgreen = [28, 50, 77, 135, 162, 189, 227, 250, 245, 221, 199, 183, 137, 139, 82]
   sunsetblue = [62, 50, 62, 94, 117, 126, 170, 210, 254, 247, 236, 229, 201, 206, 161]
   red = sunsetred[[x]]
   green = sunsetgreen[[x]]
   blue = sunsetblue[[x]]
ENDIF ELSE BEGIN
   red = ROUND(255.*(0.237-2.13*x+26.92*x^2-65.5*x^3+63.5*x^4-22.36*x^5))
   green = ROUND(255.*(0.572+1.524*x-1.811*x^2)^2/(1-0.291*x+0.1574*x^2)^2)
   blue = ROUND(255./(1.579-4.03*x+12.92*x^2-31.4*x^3+48.6*x^4-23.36*x^5))
ENDELSE

; colour indices
IF colnum EQ 254 THEN ci = INDGEN(colnum) ELSE $
   ci = [ROUND(INDGEN(253)*colnum/253.+0.5), colnum] - 1

R = [0, red[[ci]], 255]
G = [0, green[[ci]], 255]
B = [0, blue[[ci]], 255]

TVLCT, R, G, B

END
