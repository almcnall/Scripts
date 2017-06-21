pro PON_MED4SSEB

;this script computes the median (2003-2014) and PON to make comparisons with the SSEBop
;;read in NOAH ET from readin_chirps_noah_et.pro (for EA, SA, WA), only read in 2003-2016!

;;2/10/17 save these outputs, since i do use the same median everytime...benefit was all three regions...

evapE = Evap
delvar, Evap
help,  evapE, evapS, evapw

params = get_domain01('EA')

eNX = params[0]
eNY = params[1]

;take the median for 2003-2013 (10yrs) for each month
;for monthly (not seasonal) analysis
;PON for NOAH
medEVAPe = MEDIAN(EvapE[*,*,*,0:9], dimension=4) & help, medEVAPe
medEVAPcubeE = REBIN(medEVAPe,eNX, eNY, NMOS, NYRS)
;then compute percent of this median for all yrs...
PONe = (Evape/MEDevapcubeE)*100
PONe(where(PONe gt 250)) = 250
delvar, medEvape, medEVAPcubeE

medEVAPs = MEDIAN(EvapS[*,*,*,0:9], dimension=4) & help, medEVAPs
medEVAPcubeS = REBIN(medEVAPs,sNX, sNY, NMOS, NYRS)
;then compute percent of this median for all yrs...
PONs = (EvapS/MEDevapcubeS)*100
PONs(where(PONs gt 250)) = 250
delvar, medEvapS, medEVAPcubeS

medEVAPw = MEDIAN(EvapW[*,*,*,0:9], dimension=4) & help, medEVAPw
medEVAPcubeW = REBIN(medEVAPw,wNX, wNY, NMOS, NYRS)
;then compute percent of this median for all yrs...
PONw = (EvapW/MEDevapcubeW)*100
PONw(where(PONw gt 250)) = 250
delvar, medEvapW, medEVAPcubeW


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