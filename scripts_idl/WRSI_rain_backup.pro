;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
;moved over to IDL 12/28/12

; Define constants
WHC = 50 ; Water Holding Capacity
;SWf = 0.45 ; fraction of WHC below which AETc is less than PETc
SWf = 0.4
;K = [0,0.3,0.3,0.47,0.74,1,1.19,1.2,1.2,1.2,1.07,0.78,0.48] ; array with Kc [crop coefficient] (maize, what about millet?)
K = [0,0.30, 0.30,  0.53,  0.77,  1.00,  1.00,  1.00,  1.00,  1.00,  0.77,  0.53,  0.30]

;RD = [0,0.1,0.3,0.5,0.7,0.9,1,1,1,1,1,1,1] ; array with Root Depth
RD  = [0,0.1,0.3,0.5,0.7,0.9,1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

;from mark carroll (illinois?)
;PPT = [50,57,70,68,78,98,70,20,10,37,31,27,3,22] ; test values for precip [will be read in from file]

;from Niger_2005_2008.xls
;PPT = [57.81, 23.9859, 38.3085,75.1978, 40.8481, 32.3063, 25.4238, 64.9827, 39.5417, 31.8092, 15.7485, 36.6288, 25.3576]

;rounded to integer
;PPT = [58, 24, 38,75, 41, 32, 25, 65, 40, 32, 16, 37, 25];2005
PPT = [14,  17,  17,  62,  58,  62,  51,  87,  74,  43,  6, 0, 1];2007


;PET = [0,47,47,50,58,65,65,72,64,58,50,48,48] ; test values for PET [will be read in from file]
;PET = [58,  51,  48,  48,  44,  41,  37,  34,  34,  45,  47,  39,  44] ;from Niger.xls 2005
PET = [65, 61,  56,  60,  38,  39,  37,  45,  39,  35,  51,  41,  47];2007

AET = 0
AETf = 0
PETf = 0
PAW = 0
; Read in inputs and perform calculations then output WRSI for each of 12 dekads
for n=0,n_elements(PET)-1 do begin
    
; Calculate components Soil Water Critical [SWC], Plant Available Water[PAW], Actual ET[AET], Soil Water Balance[SWB]
    SWC = RD[n] * WHC * SWf
    PETc = [PET[n] * K[n]]
    ; set initial value for SWB
    if n eq 0 then SWB1 = PPT[n] $
    ; Calculate PAW per time period n
    else PAW = PPT[n] + SWB1
    ; Calculate AET per time period n
    if PAW ge SWC then AET = PETc $
    else AET = [[PAW/SWC]*PETc] &
    ;print, [AET, PETc]
    ; Calculate SWB per time period
        zz = [[SWB1 + PPT[n]] - AET]
        if zz gt 50 then SWB = 50 $
        else begin
         if zz le 0 then SWB = 0 else SWB = zz &$
        endelse
                SWB1 = SWB
        ; Calculate per dekad WRSI
        WRSI = [[AET/PETc]*100]
       ; print,"My vars are zz "+string(zz)+" AET "+ string(AET) +" SWB "+string(SWB)+" PAW "+string(PAW)+" WRSI "+string(WRSI)
       print, "  AET "+ string(AET) +"  PETc "+string(PETc)+"  PAW "+string(PAW)+"   WRSI"+string(WRSI)
       
        ;print, "My WRSI value is "+string(WRSI)+"."
    ; Calculate sum of AET and sum of PET for seasonal WRSI
    AETf = AETf + AET
    PETf = PETf + PETc
endfor
;Calculate seasonal WRSI
WRSIf = [AETf/PETf]*100
print, "My WRSI seasonal value is "+string(WRSIf)+"."

end