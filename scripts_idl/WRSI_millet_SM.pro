; this file will contain a bunch of functions which will allow for the 
; creation of the WRSI from input rainfall and PET with options for 
; controlling a lot of other factors

FUNCTION GET_DEKAD_WEIGHTS,in_lgp
   ; this function is designed to take a number of dekads specifying the length
   ; of the growing season and return a 1-d array of weights for each 
   ; dekad.  these are the average crop coefficient for each dekad.
   ;
   ; in_lgp = integer corresponding to the LGP

   ndays = in_lgp * 10.0		; number of days in season
   day_frac = (FINDGEN(ndays) +1)/ndays      ; fraction of the season at each day
   kc = FLTARR(ndays)             ; crop coefficient
   dek_wts = FLTARR(in_lgp)

   ; set time periods of growing season when kc changes
   iv = 0.14       ; fraction of season from initial to vegetative
   vr = 0.38       ; fraction of season from initial to reproductive
   rr = 0.76       ; fraction of season from initial to ripening
   eos = 1.0       ; fraction of season at end

   ; set kc values
   init_kc = 0.3   ; kc at initial stage
   repro_kc = 1.0  ; kc at reproductive stage
   end_kc = 0.30   ; kc at end of season

   ; set kc values for each day of the growing season

    ; initial stage
   kc(where(day_frac le iv)) = init_kc 
    ; vegetative stage
   kc(where(day_frac gt iv AND day_frac le vr)) = $
      init_kc + ((repro_kc - init_kc) / (vr - iv)) * (day_frac(where(day_frac gt iv AND day_frac le vr)) - iv) 
    ;reproductive stage
   kc(where(day_frac gt vr AND day_frac le rr)) = repro_kc
    ; ripening stage
   kc(where(day_frac gt rr)) = repro_kc + ((end_kc - repro_kc) / (eos - rr)) * (day_frac(where(day_frac gt rr)) - rr)

   ;  get dekadal average of the Kc for each dekad

   for i=0,in_lgp-1 do $
      dek_wts(i) = mean(kc(i*10:(i*10)+9))

   return,dek_wts

END

FUNCTION SOS_1d,rain_arr
   ; this function takes a 1-dimensional rainfall timeseries and returns the value
   ; of the SOS position
   ; 
   ; rain_arr = 1-d array of rainfall values

   vals = N_ELEMENTS(rain_arr)
   SOS = 60	; default is no start

   ; check timeseries for start of season
   for i=0,vals-3 do begin
      if rain_arr(i) ge 25 AND TOTAL(rain_arr(i+1:i+2)) ge 20 then begin
         SOS = i
	 BREAK 		; break loop if we set SOS
      endif
   endfor
   ; check second to last date for SOS
   if SOS eq 60 then begin
      if rain_arr(vals-2) ge 25 AND rain_arr(vals-1) ge 20 then SOS = vals-2
   endif

   return, SOS

END

FUNCTION GET_RD_FRACTION,in_lgp,max_eff_rd
   ; this function is designed to take a number of dekads specifying the length
   ; of the growing season and return a 1-d array of root-depth-fraction for 
   ; each dekad. 
   ;
   ; in_lgp = integer corresponding to the LGP
   ; max_eff_rd = maximum effective root depth

   ndays = in_lgp * 10.0                ; number of days in season
   day_frac = (FINDGEN(ndays))/ndays      ; fraction of the season at each day
   erd = FLTARR(ndays)             ; effective root depth
   rdf = FLTARR(ndays)		   ; root depth fraction
   dek_rdf = FLTARR(in_lgp)

   ; set some timing variables
   erd_max_frac = 0.44       ; fraction of season of maximum root depth
   eos = 1.0       ; fraction of season at end

   init_erd = 0.1   ; erd at initial stage

   ; set erd values for each day of the growing season

    ; initial growth stage
   erd(where(day_frac lt erd_max_frac)) = $
      init_erd + ((max_eff_rd - init_erd) / erd_max_frac) * (day_frac(where(day_frac lt erd_max_frac))) 
   erd(where(day_frac ge erd_max_frac)) = max_eff_rd
  
   ; conver erd to rdf
   rdf = erd / max_eff_rd
 
   ;  get dekadal average of the Kc for each dekad
   for i=0,in_lgp-1 do $
      dek_rdf(i) = mean(rdf(i*10:(i*10)+9))

   return,dek_rdf

END


FUNCTION WRSI,soil,pet, $
  LGP = LGP, $		  ; set length of growing period (default is 12 dekads)
  WHC = WHC, $		  ; set the water holding capacity (default is 50mm)
  SWf = SWf, $ 		  ; soil water fraction (default is 0.45 for maize)
  rmean = rmean, $  ; the rainfall PAW climatology
  nmean = nmean, $  ; the NDVI PAW climatology
  SOS_ind = SOS_ind, $ ; use climatological start of season (default is calculated sos)
  pawout = pawout, $   ;set this var to write out the pawout
  sosout = sosout, $   ;set this var to write out the calculated SOS 
  aetout = aetout     ;set this var to write out the dekadal AET
  ;KCout = KCout      ;set this var to write out the Kc

  if ~KEYWORD_SET(LGP) then $
    LGP = 12		; default LGP is 12 dekads unless specified
  if ~KEYWORD_SET(WHC) then $
    WHC = 50		; default WHC is 50mm unless specified
  if ~KEYWORD_SET(SWf) then $
    SWf = 0.4		; default SWf is 0.45 (maize) unless specified
  if ~KEYWORD_SET(SOS_ind) then $
      SOS_ind = 60 ;why is this set to 60 rather than the calculated one? i guess to avoid that function?
      
  WRSI = FLTARR(LGP)
  Kc = get_dekad_weights(LGP)	; get the crop coefficients
  ;SOS_ind = SOS_1d(ppt)	; the index of the SOS based on ppt

  ; set the root depth fraction
  RD_max = 0.9
  RDf = GET_RD_FRACTION(LGP,RD_max)

  ; set some of the array variables
  SWC = RDf * FLOAT(WHC) * SWf			; set the critical soil water level
  if SOS_ind lt 37 then $
    PETc = pet[SOS_ind:SOS_ind+(LGP-1)] * kc	$; set the crop water requirement
  else PETc = !values.f_nan
 
 	; set initial antecedent SWB conditions
  AETs = 0.		; seasonal cumulative AET
  PETs = 0.		; seasonal cumulative PET
  outarr = FLTARR(5,LGP)
  pawout = FLTARR(LGP)
  aetout = FLTARR(LGP)
  KCout = FLTARR(LGP)

  ; loop through for all dekads of the growing season
  PAW = soil
  ;adjust the PAW to the WRSI_rainclimatology (but first I need to know the PAW climatology...)
  ;read in the PAWclim map....
  ;PAW = (SOIL-nmean)+rmean
  
  for i=SOS_ind,SOS_ind+LGP-1 do begin  &$
     if SOS_ind gt 37 then continue
    
    ; Calculate potential available water (PAW) for time period i
     ; Calculate AET per time period n
    if PAW[i] ge SWC[i-SOS_ind] then AET = PETc[i-SOS_ind] $ 
    else AET = ((PAW[i]/SWC[i-SOS_ind])*PETc[i-SOS_ind])  &$
    
;  ; Calculate resulting SWB at i -ah, so i get to skip this part...no max for the N-PAW I guess? 
;    it is just calibrated near the max.
;    tmp = ((SWBa + PPT[i]) - AET) &$
;    if tmp gt 50 then SWBa = 50 $ 
;      else begin &$
;        if tmp le 0 then SWBa = 0 else SWBa = tmp  &$   
;      endelse &$
    
    ; Calculate per dekad WRSI
      WRSI[i-SOS_ind] = ((AET/PETc[i-SOS_ind])*100.) &$
     outarr[*,i-SOS_ind]= [AET, PETc[i-SOS_ind], PAW[i], WRSI[i-SOS_ind], SWC[i-SOS_ind]] &$
    ; Calculate sum of AET and sum of PET for seasonal WRSI
    check = where(finite(AET), count)
    if count lt 1 then continue &$
    AETs = AETs + AET &$
    PETs = PETs + PETc[i-SOS_ind] &$
    pawout[i-SOS_ind] = paw[i] ; i guess if i output this it'll be in the same format as the rpaw.
    aetout[i-SOS_ind] = AET
    ;KCout = Kc
  endfor

  ;Calculate seasonal WRSI
  WRSIf = (AETs/PETs)*100
  sosout = SOS_ind
  ;print, WRSIf
  return,WRSIf
END  
  

