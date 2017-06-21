pro noahSM

;the purpose of this program is to make the noah soil moisture module more accessable - maybe add in the improvements mentioned
;in Decharme et al. (2009). 
;! ----------------------------------------------------------------------
;! SUBROUTINE SFLX - VERSION 2.7 - June 2nd 2003 - 
;the soil model is described in Pan and Mahrt (1984;1987)
;soil hydrology is medeled in this subroutine with the prognostisc equation for nondimensional soil water content
;where are D and K specified? maybe in SUBROUTINE WDFCND that calculates D and K as functions of water content and then
;plugs them into equation 24 at some point
;
;;****************
;do I need to include the infiltration threshold equation, probably? depends when Edir is subtracted and how '
;I represent that...what are my inputs going to look like P-Edir? the I-Edir, or go from P to I (throughfall-runoff)
; then I-Edir...?
;*****************
;! ----------------------------------------------------------------------
;! SUB-DRIVER FOR "NOAH/OSU LSM" FAMILY OF PHYSICS SUBROUTINES FOR A
;! SOIL/VEG/SNOWPACK LAND-SURFACE MODEL TO UPDATE SOIL MOISTURE, SOIL
;! ICE, SOIL TEMPERATURE, SKIN TEMPERATURE, SNOWPACK WATER CONTENT,
;! SNOWDEPTH, AND ALL TERMS OF THE SURFACE ENERGY BALANCE AND SURFACE
;! WATER BALANCE (EXCLUDING INPUT ATMOSPHERIC FORCINGS OF DOWNWARD
;! RADIATION AND PRECIP)

;parameters
  FREEZ = 273.15
  LVH2O = 2.501E+6
  LSUBS = 2.83E+6
  R = 287.04
  CP = 1004.5
  CFACTR = 0.5    ; CANOPY WATER PARAMETER
  MCMAX = 0.5E-3  ; CANOPY WATER PARAMETER
  RSMAX = 5000.0  ; MAX. STOMATAL RESISTANCE
  TOPT = 298.0    ; OPTIMUM TRANSPIR AIR TEMP
  SBETA = -2.0    ; TO CALC VEG EFFECT ON SHFLX

  FRZK=0.15       ; Ice content threshold in soil
  REFDK = 2.0E-6  ; Reference ...what?
  REFKDT = 3.0    ;reference for surface infiltration parameter
  FXEXP = 2.0     ; BARE SOIL EVAP EXP USED IN DEVAP
  CSOIL = 2.00E+6 ; SOIL HEAT CAPACITY [J M-3 K-1]

  ;-- SPECIFY DEPTH[M] OF LOWER BOUNDARY SOIL TEMPERATURE.
  ZBOT = -8.0
  ;--  PARAMETER USED TO CALCULATE ROUGHNESS LENGTH OF HEAT.
  CZIL = 0.1
  
; ----------------------------------------------------------------------
;   INITIALIZATION
; ----------------------------------------------------------------------
      RUNOFF1 = 0.0
      RUNOFF2 = 0.0
      RUNOFF3 = 0.0
      SNOMLT = 0.0
      EMISSI = 1.0
      ETA_KINEMATIC = -9999.0

; ----------------------------------------------------------------------
; CALCULATE DEPTH (NEGATIVE) BELOW GROUND FROM TOP SKIN SFC TO BOTTOM OF
; EACH SOIL LAYER.  NOTE:  SIGN OF ZSOIL IS NEGATIVE (DENOTING BELOW
; GROUND), SLDPTH = thickness of each soil layer, NSOIL= number of layers, ZSOIL= depth below ground
;still have to idl-ify this.
; ----------------------------------------------------------------------
        ZSOIL(1) = -SLDPTH(1) ;not sure how I'll index this
        DO KZ = 2,NSOIL ;for each layer of soil 
          ZSOIL(KZ) = -SLDPTH(KZ)+ZSOIL(KZ-1) ;calc the soil depth by adding ones above
        END DO

; ----------------------------------------------------------------------
; CALCULATE Root didstribution (RTDIS). Jesse 20050406
; NROOT is the number of root layers as a function of vegetation type
; ----------------------------------------------------------------------
        DO KZ = 1, NROOT ;for each root layer (how does it know what this is?)
           RTDIS(KZ) = -SLDPTH(KZ)/ZSOIL(NROOT); proportion of depth out of total e.g. 10/100,30/100,60,100
        END DO


 ; ----------------------------------------------------------------------
; NEXT IS CRUCIAL CALL TO SET THE LAND-SURFACE PARAMETERS, INCLUDING
; SOIL-TYPE AND VEG-TYPE DEPENDENT PARAMETERS.
; ----------------------------------------------------------------------
;      CALL REDPRM (VEGTYP,SOILTYP,SLOPETYP,
;     +            CFACTR,CMCMAX,RSMAX,TOPT,REFKDT,KDT,SBETA,
;     O            SHDFAC,RSMIN,RGL,HS,ZBOT,FRZX,PSISAT,SLOPE,
;     +            SNUP,SALP,BEXP,DKSAT,DWSAT,SMCMAX,SMCWLT,SMCREF,
;     O            SMCDRY,F1,QUARTZ,FXEXP,RTDIS,SLDPTH,ZSOIL,
;     +            NROOT,NSOIL,Z0,CZIL,XLAI,CSOIL,PTU)

; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; PRECIP IS LIQUID (RAIN), HENCE SAVE IN THE PRECIP VARIABLE THAT
; LATER CAN WHOLELY OR PARTIALLY INFILTRATE THE SOIL (ALONG WITH 
; ANY CANOPY "DRIP" ADDED TO THIS LATER)
; skip all the specifications that deal with snow.
; ----------------------------------------------------------------------
        PRCP1 = PRCP

; ----------------------------------------------------------------------
; NEXT CALCULATE THE SUBSURFACE HEAT FLUX...I will try to skip this part and stick to the water balance 
; ----------------------------------------------------------------------
;  CONVERT RUNOFF3 (INTERNAL LAYER RUNOFF FROM SUPERSAT) FROM M TO M S-1
;  AND ADD TO SUBSURFACE RUNOFF/DRAINAGE/BASEFLOW
; ----------------------------------------------------------------------
      RUNOFF3 = RUNOFF3/DT ;DT is the time step, change in time, duh
      RUNOFF2 = RUNOFF2+RUNOFF3 ;not totally sure what is happenin' here.

; ----------------------------------------------------------------------
; TOTAL COLUMN SOIL MOISTURE IN METERS (SOILM) AND ROOT-ZONE 
; SOIL MOISTURE AVAILABILITY (FRACTION) RELATIVE TO POROSITY/SATURATION
; SOILM = total soil mositure content
; ----------------------------------------------------------------------
      SOILM = -1.0*SMC(1)*ZSOIL(1) ;make soil depth positive * moisture content. 
      DO K = 2,NSOIL
        SOILM = SOILM+SMC(K)*(ZSOIL(K-1)-ZSOIL(K)); accumulate the amount of soil moisture found at each layer for tot SMC
      END DO

; ----------------------------------------------------------------------
; ROOT-ZONE SOIL MOISTURE AVAILABILITY (FRACTION) RELATIVE
; TO POROSITY/SATURATION (SOILW; aka, MSTAVRZ)
; ----------------------------------------------------------------------
      SOILWM = -1.0*(SMCMAX-SMCWLT)*ZSOIL(1);max avail water*layer depth 
      SOILWW = -1.0*(SMC(1)-SMCWLT)*ZSOIL(1);actual avail water * layer depth
      DO K = 2,NROOT
        SOILWM = SOILWM+(SMCMAX-SMCWLT)*(ZSOIL(K-1)-ZSOIL(K));accumulate potenital amount for all root layers
        SOILWW = SOILWW+(SMC(K)-SMCWLT)*(ZSOIL(K-1)-ZSOIL(K)); accumulate actual amount for all root layers. 
      END DO
      SOILW = SOILWW/SOILWM ;find the ratio of actual to potential

;----------------------------------------------------------------------
; TOTAL COL SOIL MOISTURE AVAIL RELATIVE TO POROSITY/SATURATION (SOILT) 
;  (aka, MSTAVTOT), similar calculation to the one above but for all layers, not just the rooted ones. 
;----------------------------------------------------------------------
      SOILTM = -1.0*(SMCMAX-SMCWLT)*ZSOIL(1)
      SOILTW = -1.0*(SMC(1)-SMCWLT)*ZSOIL(1)
      DO K = 2,NSOIL
        SOILTM = SOILTM+(SMCMAX-SMCWLT)*(ZSOIL(K-1)-ZSOIL(K))
        SOILTW = SOILTW+(SMC(K)-SMCWLT)*(ZSOIL(K-1)-ZSOIL(K))
      END DO
      SOILT = SOILTW/SOILTM     
;! ----------------------------------------------------------------------
;! END SUBROUTINE SFLX
;! ----------------------------------------------------------------------
      
;! ----------------------------------------------------------------------
;! DIRECT EVAP A FUNCTION OF RELATIVE SOIL MOISTURE AVAILABILITY, LINEAR
;! WHEN FXEXP=1.
;! FX > 1 REPRESENTS DEMAND CONTROL
;! FX < 1 REPRESENTS FLUX CONTROL
;SMCDRY dry soil moisture threashold where evap from top layer ends
;SMCMAX=porosity, FXEXP=2
;! ----------------------------------------------------------------------
      SRATIO = (SMC - SMCDRY) / (SMCMAX - SMCDRY);available SM/potential SM
      IF (SRATIO .GT. 0.) THEN ;if there is some SM
        FX = SRATIO**FXEXP ;FXEXP=2
        FX = MAX ( MIN ( FX, 1. ) ,0. ); FX =1,0 or fraction flux or demand control
      ELSE
        FX = 0.
      ENDIF

;! ----------------------------------------------------------------------
;! ALLOW FOR THE DIRECT-EVAP-REDUCING EFFECT OF SHADE
;shade fraction: area fractional coverage of green vegetation, where does it come from?
;! ----------------------------------------------------------------------
;!      DEVAP = FX * ( 1.0 - SHDFAC ) * ETP1
      EDIR1 = FX * ( 1.0 - SHDFAC ) * ETP1 ;PET greater than zero
;     
;! ----------------------------------------------------------------------
;! SUBROUTINE EVAPO
;! ----------------------------------------------------------------------
;! CALCULATE SOIL MOISTURE FLUX.  THE SOIL MOISTURE CONTENT (SMC - A PER
;! UNIT VOLUME MEASUREMENT) IS A DEPENDENT VARIABLE THAT IS UPDATED WITH
;! PROGNOSTIC EQNS. THE CANOPY MOISTURE CONTENT (CMC) IS ALSO UPDATED.
;! FROZEN GROUND VERSION:  NEW STATES ADDED: SH2O, AND FROZEN GROUND
;! CORRECTION FACTOR, FRZFACT AND PARAMETER SLOPE.
;! ----------------------------------------------------------------------
;! ----------------------------------------------------------------------
;! executable code begins here if the potential evapotranspiration is
;! greater than zero.
;! ----------------------------------------------------------------------
;this about how these values can be replaced with a time series so 
;that I don't actually have to solve for them..all evaps (direct/dry/wet get rolled into one)
;! ----------------------------------------------------------------------
;! TOTAL UP EVAP AND TRANSP TYPES TO OBTAIN ACTUAL EVAPOTRANSP
;;this is where my AET would go in....
;! ----------------------------------------------------------------------
      ETA1 = EDIR1 + ETT1 + EC1

;! ----------------------------------------------------------------------
;! SUBROUTINE SMFLX
;! ----------------------------------------------------------------------
;! CALCULATE SOIL MOISTURE FLUX.  THE SOIL MOISTURE CONTENT (SMC - A PER
;! UNIT VOLUME MEASUREMENT) IS A DEPENDENT VARIABLE THAT IS UPDATED WITH
;! PROGNOSTIC EQNS. THE CANOPY MOISTURE CONTENT (CMC) IS ALSO UPDATED.
;! FROZEN GROUND VERSION:  NEW STATES ADDED: SH2O, AND FROZEN GROUND
;! CORRECTION FACTOR, FRZFACT AND PARAMETER SLOPE.
;! ----------------------------------------------------------------------
;! ----------------------------------------------------------------------
;! PCPDRP IS THE COMBINED PRCP1 AND DRIP (FROM CMC) THAT GOES INTO THE
;! SOIL
;this is where all the rainfall comes in , maybe I can do a rainfall-ET
;! ----------------------------------------------------------------------
      PCPDRP = (1. - SHDFAC) * PRCP1 + DRIP / DT ;precip+drip is not shade*rain+drip/time
;! ----------------------------------------------------------------------
;! CALL SUBROUTINES SRT AND SSTEP TO SOLVE THE SOIL MOISTURE
;! TENDENCY EQUATIONS. 
;!
;! IF THE INFILTRATING PRECIP RATE IS NONTRIVIAL,
;!   (WE CONSIDER NONTRIVIAL TO BE A PRECIP TOTAL OVER THE TIME STEP 
;!    EXCEEDING ONE ONE-THOUSANDTH OF THE WATER HOLDING CAPACITY OF 
;!    THE FIRST SOIL LAYER)
;! THEN CALL THE SRT/SSTEP SUBROUTINE PAIR TWICE IN THE MANNER OF 
;!   TIME SCHEME "F" (IMPLICIT STATE, AVERAGED COEFFICIENT)
;!   OF SECTION 2 OF KALNAY AND KANAMITSU (1988, MWR, VOL 116, 
;!   PAGES 1945-1958) MINIMIZE 2-DELTA-T OSCILLATIONS IN THE 
;!   SOIL MOISTURE VALUE OF THE TOP SOIL LAYER THAT CAN ARISE BECAUSE
;!   OF THE EXTREME NONLINEAR DEPENDENCE OF THE SOIL HYDRAULIC 
;!   DIFFUSIVITY COEFFICIENT AND THE HYDRAULIC CONDUCTIVITY ON THE
;!   SOIL MOISTURE STATE
;! OTHERWISE CALL THE SRT/SSTEP SUBROUTINE PAIR ONCE IN THE MANNER OF
;!   TIME SCHEME "D" (IMPLICIT STATE, EXPLICIT COEFFICIENT) 
;!   OF SECTION 2 OF KALNAY AND KANAMITSU
;! PCPDRP IS UNITS OF KG/M**2/S OR MM/S, ZSOIL IS NEGATIVE DEPTH IN M 
;! ----------------------------------------------------------------------
!     IF ( PCPDRP .GT. 0.0 ) THEN
      IF ( (PCPDRP*DT) .GT. (0.001*1000.0*(-ZSOIL(1))*SMCMAX) ) THEN
;if rainfall is more than trace then call srt, and sstep
;! ----------------------------------------------------------------------
;! ----------------------------------------------------------------------
;! CALL SUBROUTINES SRT AND SSTEP TO SOLVE THE SOIL MOISTURE
;! TENDENCY EQUATIONS. 
;!
;! IF THE INFILTRATING PRECIP RATE IS NONTRIVIAL,
;!   (WE CONSIDER NONTRIVIAL TO BE A PRECIP TOTAL OVER THE TIME STEP 
;!    EXCEEDING ONE ONE-THOUSANDTH OF THE WATER HOLDING CAPACITY OF 
;!    THE FIRST SOIL LAYER)
;! THEN CALL THE SRT/SSTEP SUBROUTINE PAIR TWICE IN THE MANNER OF 
;!   TIME SCHEME "F" (IMPLICIT STATE, AVERAGED COEFFICIENT)
;!   OF SECTION 2 OF KALNAY AND KANAMITSU (1988, MWR, VOL 116, 
;!   PAGES 1945-1958)TO MINIMIZE 2-DELTA-T OSCILLATIONS IN THE 
;!   SOIL MOISTURE VALUE OF THE TOP SOIL LAYER THAT CAN ARISE BECAUSE
;!   OF THE EXTREME NONLINEAR DEPENDENCE OF THE SOIL HYDRAULIC 
;!   DIFFUSIVITY COEFFICIENT AND THE HYDRAULIC CONDUCTIVITY ON THE
;!   SOIL MOISTURE STATE
;! OTHERWISE CALL THE SRT/SSTEP SUBROUTINE PAIR ONCE IN THE MANNER OF
;!   TIME SCHEME "D" (IMPLICIT STATE, EXPLICIT COEFFICIENT) 
;!   OF SECTION 2 OF KALNAY AND KANAMITSU
;! PCPDRP IS UNITS OF KG/M**2/S OR MM/S, ZSOIL IS NEGATIVE DEPTH IN M 
;
;! SUBROUTINE SRT
;! ----------------------------------------------------------------------
;! CALCULATE THE RIGHT HAND SIDE OF THE TIME TENDENCY TERM OF THE SOIL
;! WATER DIFFUSION EQUATION.  ALSO TO COMPUTE ( PREPARE ) THE MATRIX
;! COEFFICIENTS FOR THE TRI-DIAGONAL MATRIX OF THE IMPLICIT TIME SCHEME.
;! ----------------------------------------------------------------------
;! ----------------------------------------------------------------------
;! FROZEN GROUND VERSION REFERENCE FROZEN GROUND PARAMETER, CVFRZ
! ----------------------------------------------------------------------
;! DETERMINE RAINFALL INFILTRATION RATE AND RUNOFF.  INCLUDE THE
;! INFILTRATION FORMULE FROM SCHAAKE AND KOREN MODEL.
;! MODIFIED BY Q DUAN
;! ----------------------------------------------------------------------
      IOHINF=1 ;what is this??

;! ----------------------------------------------------------------------
;! DETERMINE RAINFALL INFILTRATION RATE AND RUNOFF
;! ----------------------------------------------------------------------
      PDDUM = PCPDRP ;I calculate precip and drip earlier
      RUNOFF1 = 0.0
      IF (PCPDRP .NE. 0.0) THEN
        DT1 = DT/86400. ;time step in m/s
        SMCAV = SMCMAX - SMCWLT ;max available soil moisture = poroisit - wilting point
        DMAX(1)=-ZSOIL(1)*SMCAV ;use max avail soil water to compute max diffusivity
;! ----------------------------------------------------------------------
;! VAL = (1.-EXP(-KDT*SQRT(DT1)))
;! IN BELOW, REMOVE THE SQRT IN ABOVE
;more on KDT: refkdt=scalar surface runoff parameter, 
;refdk= a reference value for kdt
; KDT = REFKDT * DKSAT/REFDK
; RFEKDT defined module_sf_noah271lsm.F90:!      PARAMETER(REFKDT = 3.0)
; DKSAT saturated hydraulic conductivity
; REFDK defined in noah271_main.F90 and module_sf_noah271lsm.F90:
; REFDK=2.E-6 IS THE SAT. 
;; ! ----------------------------------------------------------------------
;! from :  noah271_main.F90 
;  KDT IS DEFINED BY REFERENCE REFKDT AND DKSAT; REFDK=2.E-6 IS THE SAT.
;! DK. VALUE FOR THE SOIL TYPE 2
;! ----------------------------------------------------------------------
;     REFDK=2.0E-6
;     REFKDT=3.0
;     KDT = REFKDT * DKSAT/REFDK

;! ----------------------------------------------------------------------
        VAL = (1.-EXP(-KDT*DT1));is this like 1-e^kt?
        DDT = DD*VAL
        PX = PCPDRP*DT ;precip *time step
        IF (PX .LT. 0.0) PX = 0.0
        INFMAX = (PX*(DDT/(PX+DDT)))/DT 
        ;max infiltration = precip rate* change in diff/rainrate+diff change w/ time)/change time
        ;looking at schaake et al. (1996). 



;! ----------------------------------------------------------------------
;! SUBROUTINE WDFCND
;! ----------------------------------------------------------------------
;! CALCULATE SOIL WATER DIFFUSIVITY AND SOIL HYDRAULIC CONDUCTIVITY.
;! ----------------------------------------------------------------------
;! ----------------------------------------------------------------------
;!     CALC THE RATIO OF THE ACTUAL TO THE MAX PSBL(possible) SOIL H2O CONTENT
;! ----------------------------------------------------------------------
      SMC = SMC ;stored as as history/state variable along withn temp, moisture content, snow, albedo, exchange coff
      SMCMAX = SMCMAX ; a parameter (porosity)
      FACTR1 = 0.2 / SMCMAX ;what does this do?
      FACTR2 = SMC / SMCMAX ;ratio of actual to potential soil moisture

;! ----------------------------------------------------------------------
;PREP AN EXPNTL COEF AND CALC THE SOIL WATER DIFFUSIVITY
;BEXP - soil parameter - b parameter in hydraulic functions (better explantion pls)
;DWSAT - saturated soil diffusivity, specified for each of 9 soil types
;WDF = water diffusivity
;! ----------------------------------------------------------------------
      EXPON = BEXP + 2.0 ;
      WDF = DWSAT * FACTR2 ** EXPON ;factor2 includes actual smc
;! ----------------------------------------------------------------------
;! RESET THE EXPNTL COEF AND CALC THE HYDRAULIC CONDUCTIVITY
;WCND=water conductivity?
;! ----------------------------------------------------------------------
      EXPON = (2.0 * BEXP) + 3.0
      WCND = DKSAT * FACTR2 ** EXPON ;factor2 includes actual smc


