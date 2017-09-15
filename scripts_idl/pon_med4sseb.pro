pro PON_MED4SSEB

;this script computes the median (2003-2014) and PON to make comparisons with the SSEBop
;;read in NOAH ET from readin_chirps_noah_et.pro (for EA, SA, WA), only read in 2003-2016!

; 2/10/17 save these outputs, since i do use the same median everytime...benefit was all three regions...
; 08/30/17 -add lines for multi-month median AND add in ESP outlook capabilities

;;;;;;;;for multimonth...sum first if only read in spp. months;;;
help, evap, et
evap = total(evap,3)
et = total(et,3)

evap_median = rebin(median(evap[*,*,0:11],dimension=3), nx, ny, nyrs) & help, evap_median
et_median = rebin(median(et[*,*,0:11],dimension=3),nx,ny,nyrs) & help, et_median

PON_evap = (evap/evap_median)*100 & help, pon_evap
PON_ET = (et/et_median)*100 & help, pon_et
PON_ET(where(PON_ET ge 250)) = 250
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;for multimonth outlooks;;;;;;;;;;;
help, evap
evap = total(evap,3)
evap_median = rebin(median(evap[*,*,0:11],dimension=3), nx, ny, nyrs) & help, evap_median

;;introduce the esp-estimate here....
help, espmedian ;just 2017
esp_may2sept = total(espmedian[*,*,4:8], 3)
PON_evap = (esp_may2sept/evap_median)*100 & help, pon_evap
PON_evap(where(PON_evap ge 250)) = 250
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

help, evap, et
evapE = Evap
delvar, Evap
help, evapE, et
;help,  evapE, evapS, evapw

params = get_domain01('EA')

eNX = params[0]
eNY = params[1]

;take the median 2003-2015 (now 12 yrs), was 2003-2013 (10yrs)
;for monthly (not seasonal) analysis
;PON for NOAH
medEVAPe = MEDIAN(EvapE[*,*,*,0:11], dimension=4) & help, medEVAPe
medEVAPcubeE = REBIN(medEVAPe,eNX, eNY, NMOS, NYRS)
;then compute percent of this median for all yrs...
PONe = (Evape/MEDevapcubeE)*100
PONe(where(PONe gt 250)) = 250
delvar, medEvape, medEVAPcubeE

;medEVAPs = MEDIAN(EvapS[*,*,*,0:9], dimension=4) & help, medEVAPs
;medEVAPcubeS = REBIN(medEVAPs,sNX, sNY, NMOS, NYRS)
;;then compute percent of this median for all yrs...
;PONs = (EvapS/MEDevapcubeS)*100
;PONs(where(PONs gt 250)) = 250
;delvar, medEvapS, medEVAPcubeS
;
;medEVAPw = MEDIAN(EvapW[*,*,*,0:9], dimension=4) & help, medEVAPw
;medEVAPcubeW = REBIN(medEVAPw,wNX, wNY, NMOS, NYRS)
;;then compute percent of this median for all yrs...
;PONw = (EvapW/MEDevapcubeW)*100
;PONw(where(PONw gt 250)) = 250
;delvar, medEvapW, medEVAPcubeW

;reading in SSEBv4
NMOS = n_elements(ET[0,0,*,0]) & print, nmos
NYRS = n_elements(ET[0,0,0,*]) & print, nyrs

medETe = MEDIAN(ET[*,*,*,0:9], dimension=4) & help, medETe
medETcubeE = REBIN(medETe,NX, NY, NMOS, NYRS)
;then compute percent of this median for all yrs...
PONe_SSEB = (ET/medETcubeE)*100
PONe_SSEB(where(PONe_SSEB gt 250)) = 250
delvar, medEvapE, medEVAPcubeE


;;similar for VIC
;NX=172
;NY = 52
;medEVAPV = MEDIAN(ET_CHIRPS25[*,*,*,0:9], dimension=4) & help, medEVAPV
;medEVAPcubeV = REBIN(medevapv,NX, NY, NMOS, NYRS)
;
;PONV = (ET_CHIRPS25/MEDevapCUBEV)*100
;PONV(where(PONV gt 250)) = 250
;
;;make an ETA for VIC
;ETA_V = congrid(reform(eta,446,124,12*14),172,52,168)
;
