PRO distinct_colors, N_COLORS = colnum, GRAY_BACKGROUND = gray, SCREEN = screen

; Set colour table.
; Default, without keyword, is black (0), white (255) and 9 colours
; that are as distinct as possible in both normal and colour-blind
; vision, but also match well together. They stay distinct when printed
; on paper. Optimized preselections are available with keyword N_COLORS
; set to a value in the range 1 to 12.

; Keyword GRAY_BACKGROUND sets colours 0, 255 and up to 4 main colours
; as used in SRON presentations.

; Keyword SCREEN reverses colours 0 and 255. Then the screen shows what
; PostScript output will look like without this keyword.

; Written by: P.J.J. Tol, SRON, August 2009
; Added GRAY_BACKGROUND and SCREEN, 23 November 2009
; Improved palette, 17 January 2010
; Changed 8-colour set, 14 August 2010


IF KEYWORD_SET(colnum) THEN BEGIN
   colnum = ROUND(colnum)
   IF KEYWORD_SET(gray) THEN BEGIN
      IF (colnum LT 1 OR colnum GT 4) THEN BEGIN
         MESSAGE, 'Number of colors for a gray background is 1..4, set to 4.', /INFORMATIONAL
         colnum = 4
      ENDIF
   ENDIF ELSE BEGIN
      IF (colnum LT 1 OR colnum GT 12) THEN BEGIN
         MESSAGE, 'Number of colors is 1..12, set to 9.', /INFORMATIONAL
         colnum = 9
      ENDIF
   ENDELSE
ENDIF ELSE BEGIN
   IF KEYWORD_SET(gray) THEN colnum = 4 ELSE colnum = 9
ENDELSE

; colour coordinates
xarr = $
   [[12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [12, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [12, 6, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0], $
    [12, 6, 5, 3, 0, 0, 0, 0, 0, 0, 0, 0], $
    [0, 1, 3, 5, 6, 0, 0, 0, 0, 0, 0, 0], $
    [0, 1, 3, 5, 6, 8, 0, 0, 0, 0, 0, 0], $
    [0, 1, 2, 3, 5, 6, 8, 0, 0, 0, 0, 0], $
    [0, 1, 2, 3, 4, 5, 6, 8, 0, 0, 0, 0], $
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0], $
    [0, 1, 2, 3, 4, 5, 9, 6, 7, 8, 0, 0], $
    [0, 10, 1, 2, 3, 4, 5, 9, 6, 7, 8, 0], $
    [0, 10, 1, 2, 3, 4, 5, 9, 6, 11, 7, 8]]
x = xarr[0:colnum-1,colnum-1]

; colour set
IF KEYWORD_SET(gray) THEN BEGIN
   red = [128,255,255,100]
   green = [155,102,204,194]
   blue = [200,102,102,4]
   red = red[0:colnum-1]
   green = green[0:colnum-1]
   blue = blue[0:colnum-1]
ENDIF ELSE BEGIN
   red = [51, 136, 68, 17, 153, 221, 204, 136, 170, 102, 102, 170, 68]
   green = [34, 204, 170, 119, 153, 204, 102, 34, 68, 17, 153, 68, 119]
   blue = [136, 238, 153, 51, 51, 119, 119, 85, 153, 0, 204, 102, 170]
   red = red[[x]]
   green = green[[x]]
   blue = blue[[x]]
ENDELSE

IF KEYWORD_SET(gray) THEN scrclr = [[255,255,204],[66,66,66]] $
   ELSE scrclr = [[0,0,0],[255,255,255]]
IF KEYWORD_SET(screen) THEN scrclr = REVERSE(scrclr, 2)

R = [scrclr[0,0], red, INTARR(255 - N_ELEMENTS(x)) + scrclr[0,1]]
G = [scrclr[1,0], green, INTARR(255 - N_ELEMENTS(x)) + scrclr[1,1]]
B = [scrclr[2,0], blue, INTARR(255 - N_ELEMENTS(x)) + scrclr[2,1]]

TVLCT, R, G, B

END
