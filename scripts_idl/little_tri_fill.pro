FUNCTION LITTLE_TRI_FILL,txvert,tyvert,tfrac, $
   TXCEN = TXCEN, $    ; provided x-coord of the triangle
   TYCEN = TYCEN, $    ; provided y-coord of the triangle
   TXFILL = TXFILL, $   ; output x's for the fill
   TYFILL = TYFILL      ; output y's for the fill

;;;;;
; this function takes the input coordinates of an outer triangle
; and draws a triangle within that depending on the fraction of
; fill set by tfrac
;
; DEVELOPED BY: Greg Husak      September 10, 2012
;
; REQUIRED ARGUMENTS
; txvert = the x-values of outer triangle vertices
; tyvert = the y-values of outer triangle vertices
; txcen = provided center of the triangle, allows flexibility with centroid or linear center
; tycen =
; tfrac = the fraction of the triangle to be filled [0,1]
;
; OPTIONAL ARGUMENTS
; TXFILL = the x-values of the fill triangle vertices
; TYFILL = the y-values of the fill triangle vertices
;;;;;

   ; if the centroids are not provided then calculate them
   if ~KEYWORD_SET(TXCEN) then txcen = MIN(txvert) + 0.5 * (MAX(txvert) - MIN(txvert))
   if ~KEYWORD_SET(TYCEN) then tycen = MIN(tyvert) + 0.5 * (MAX(tyvert) - MIN(tyvert))

   xfrac = txvert - txcen
   yfrac = tyvert - tycen
   xfrac = xfrac * tfrac
   yfrac = yfrac * tfrac

   txfill = xfrac + txcen
   tyfill = yfrac + tycen

   return,1
END