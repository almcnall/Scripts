; this function takes and input timeseries and returns the ranks of the values in the 
; timeseries as a floating point array.  it can only handle 1-D arrays as either a 
; single n-point array, or a [1xn] array.
;
; this function is taken from DSI work
; developed  by Greg Husak at UC Santa Barbara
; Date: April 8, 2013


FUNCTION Get_Ranks,ts
   ; returns an array with the same dimensions as ts, with the associated ranks of ts
   ts = REFORM(ts)
   nvals = N_ELEMENTS(ts) 
   output = FINDGEN(nvals)  ; make output that is the index array

   tmpts = [[FLOAT(ts)], [output]]
   tmpts = tmpts[SORT(tmpts[*,0]),*]
   tmpts = [[tmpts], [RANKS(tmpts[*,0])]]
   tmpts = tmpts[SORT(tmpts[*,1]),*]

   return,tmpts[*,2]

END

