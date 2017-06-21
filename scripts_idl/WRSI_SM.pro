;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12
; ...so PAW is in mm on the same scale as rainfall. Is this what it looks like in Niger too?

; Define constants
WHC = 50 ; Water Holding Capacity how do i scale this appropriately.Keep this the same
;SWf = 0.45 ; fraction of WHC below which AETc is less than PETc
SWf = 0.4 ; fraction of WHC below which AETc is less than PETc (taken from Hari spreadsheet)

;K = [0,0.3,0.3,0.47,0.74,1,1.19,1.2,1.2,1.2,1.07,0.78,0.48] ; array with Kc [crop coefficient]
K = [0,0.30, 0.30,  0.53,  0.77,  1.00,  1.00,  1.00,  1.00,  1.00,  0.77,  0.53,  0.30] ;(taken from Hari spreadsheet)

;RD = [0,0.1,0.3,0.5,0.7,0.9,1,1,1,1,1,1,1] ; array with Root Depth
RD  = [0,0.1,0.3,0.5,0.7,0.9,1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

;PPT = [50,57,70,68,78,98,70,20,10,37,31,27,3,22] ; test values for precip [will be read in from file]
;PAW = [3,107,120,118,128,148,120,70,10,37,31,27,3];test values from soil moisture - how did he come up with these?
PAW = [10, 9, 9, 12,  48,  40,  58,  69,  54,  35,  26,  17,  14] ;not sure that i scaled this correctly...

;PET = [0,47,47,50,58,65,65,72,64,58,50,48,48] ; test values for PET [will be read in from file]
PET = [65, 61,  56,  60,  38,  39,  37,  45,  39,  35,  51,  41,  47];2007

AET = 0
AETf = 0
PETf = 0

; Read in inputs and perform calculations then output WRSI for each of 12 dekads
for n=0,n_elements(PET)-1 do begin
    
; Calculate components Soil Water Critical [SWC], Plant Available Water[PAW], Actual ET[AET], Soil Water Balance[SWB]
    SWC = RD[n] * WHC * SWf 
    PETc = [PET[n] * K[n]]
    ; set initial value for SWB -- do i have to calc SWB??
    ;if n eq 0 then SWB1 = PAW[0] $ ;should this be PAW[0] not sure this needs to be bere at all...
    ;else PAW = PPT[n] + SWB1
    ; Calculate AET per time period n
    if PAW[n] ge SWC then AET = PETc $
    else AET = [[PAW[n]/SWC]*PETc] & print, AET
    ; Calculate SWB per time period
;        zz = [PAW[n] - AET] ;not sure that this should be here....was this me or mark?
;        if zz gt 50 then SWB = 50 $
;        else begin
;         if zz le 0 then SWB = 0 else SWB = zz &$
;        endelse
;        SWB1 = SWB
        ; Calculate per dekad WRSI
        WRSI = [[AET/PETc]*100]
        ;print, "My vars are zz "+string(zz)+"  AET "+ string(AET) +"  SWB "+string(SWB)+"  PAW "+string(PAW[n])+"   WRSI"+string(WRSI)
         print, "  AET "+ string(AET) +"  PAW "+string(PAW[n])+"   WRSI"+string(WRSI)
        
        ;print, "My WRSI value is "+string(WRSI)+"."
    ; Calculate sum of AET and sum of PET for seasonal WRSI
    AETf = AETf + AET
    PETf = PETf + PETc
endfor
;Calculate seasonal WRSI
WRSIf = [AETf/PETf]*100
print, "My WRSI seasonal value is "+string(WRSIf)+"."

end