

;
; Based on code from Greg Husak, this routine takes a time-series of value and translates them to  
; z-scores.  The gamma distribution is used, unless the data is very close to normal. Does not check for 
; missing values!
;

FUNCTION precip_2_spi_gh,ts, $
  MIN_POSOBS = MIN_POSOBS     ; set number of positive observations required to calculate SPI

;;;;;
; this function takes a vector of rainfall values and returns SPI values
; for the input data. 
;
; chris funk developed part of this based on some of my original code, and then 
; i reworked his stuff to handle when there are a large number of zeros 
; in the rainfall vector
;
; DEVELOPED BY: Greg Husak      April 30, 2009
; UPDATED BY: Greg Husak	January 12, 2012	; added MIN_POSOBS keyword
;
; ts = a vector of rainfall data.  ints or floats should all work the same
; 
; OPTIONAL ARGUMENTS
; MIN_POSOBS = integer for the minimum number of positive values required to calculate SPI
;
;;;;;

  normthresh    = 160.00   ; threshold for shape param
  if ~KEYWORD_SET(MIN_POSOBS) then $
    min_posobs    = 12       ; unless we get this many non-zero rain events, return all 0 spi vals
  
  zdim = n_elements(ts)
  ts   = double(reform(ts,zdim))

  pvals  = 0.0  ; number of positive values
  psum   = 0.0  ; sum of positive values
  logsum = 0.0
      
  pos_ids = where(ts gt 0.00)
  
  pvals   = float(n_elements(pos_ids))
  if pvals lt min_posobs then return,replicate(0,zdim) ; not enough non-zeros

  posave = mean(ts[pos_ids])
  logsum = total(alog(FLOAT(ts[pos_ids])))
  
  norain_prob = (float(zdim)- pvals) / float(zdim)  ; calculate the percent of no rain events in the pixel array

  bigA = alog(posave) - (logsum/pvals)
  shape = !VALUES.F_NAN		;   added by greg 2012.04.19
  scale = !VALUES.F_NAN		;   added by greg 2012.04.19
  if bigA gt 0 then begin
     shape = (1.0+sqrt((4.0*bigA/3.0)+1.0)) / (4.0*bigA)
     scale = posave / shape
  end
  
  ; if shape value is greater than 'normthresh' then calculate mean and std and use these for SPI

  zs    = fltarr(zdim)		;  added by pete 2012.04.19  if shape =NAN, then need a zs to return. 
  if shape gt normthresh then begin
    zs = (ts-mean(ts))/stdev(ts)
  end
  
  ; use gamma distribution to calculate the spi values
  if shape le normthresh AND pvals gt 1 then begin
       
     shape = double(shape)
     scale = double(scale)
     zs    = fltarr(zdim)
     
     for t=0,zdim-1 do begin
        xi  = double(ts[t])
        if xi gt 0 then begin 
           pxi = IGAMMA(shape,xi/scale)
        end else pxi=0.
         
        prob = norain_prob + ((1.0 - norain_prob) * pxi) ; this is the prob of this event
        
        if norain_prob gt 0.5 AND xi le 7.0 then prob = 0.5
        
        if TOTAL(prob ge 1.0) gt 0 then prob[WHERE(prob ge 1.0)] = 0.99999999
        zs[t] = gauss_cvf(1.0 - prob)        
     end
  end  
  
  return,zs
END
