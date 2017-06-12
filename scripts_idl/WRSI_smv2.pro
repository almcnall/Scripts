;# Development script to take Earth Observed precipitation and soil moisture and get crop yield
;# Written by Mark Carroll
;# Initial date 02/15/2012
;# Updated 02/23/2012
;# Added values for testing Indiana 03/21/2012
; moved over to IDL 12/28/12 values for WRSI are taken from Hari's spreadsheet WRSI.

y = 0;2=2007,3=2008
; Define constants
ifile = file_search('/home/mcnally/regionmasks/whc3.bil')
whcgrid = bytarr(751,801)
openr,1,ifile
readu,1,whcgrid
close,1

whcgrid = reverse(whcgrid,2)
;temp = image(whcgrid,rgb_table=4)

;get WHC for a given lat/lon
;Wankama Niger (prolly should double check this...)
xind = FLOOR((2.633 + 20.05) * 10.0)
yind = FLOOR((13.6454 + 40.05) * 10.0)

WHC = whcgrid(xind,yind)& print,whcgrid(xind,yind)
;WHC = 50 ; default WRSI
;WHC = 105 ; recommended by yamaguchi 2002 -- might make my estimates looks more like WRSI 
;or at least this might be the source of bias. FAO WHC = 140

ifile = file_search('/home/mcnally/regionmasks/lgp_ws_sahelwindow.img')
lgpgrid = fltarr(720,350)
openr,1,ifile
readu,1,lgpgrid
close,1

;Wankama Niger
xind = FLOOR((2.6496 + 20.) / 0.10)
yind = FLOOR((13.6496 + 5) / 0.10)
LGP = lgpgrid(xind,yind) & print, LGP ; 105 day or so millet? that is short!

;where do these values come from?
SWf = 0.4 ; fraction of WHC below which AETc is less than PETc (taken from Hari spreadsheet)
K = [0, 0.30, 0.30,  0.53,  0.77,  1.00,  1.00,  1.00,  1.00,  1.00,  0.77,  0.53,  0.30] ;(taken from Hari spreadsheet)
RD  = [0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

;read in the SM probe data
ifile = file_search('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
soil = read_csv(ifile)
wk240 = reform(float(soil.field3),36,4)
wk270 = reform(float(soil.field4),36,4)

FC = 0.09
WP = 0.03
scale = WHC/(FC-WP)
;y = 1;0=2005, 1=2006, ...3=2008
;this is scaled...subtract the wilting point (0.03) and make FC (0.09) the max...or that 0.06 (available water) = 50mm
;PAW = (wk240[15:27,y]-WP)* scale ;& print, transpose(PAW)
PAW = (wk240[14:26,y]-WP)* scale ;& print, transpose(PAW)

;PAW = [10, 9, 9, 12,  48,  40,  58,  69,  54,  35,  26,  17,  14] ;seems reasonable....

;EROS PET
ifile = file_search('/jabber/chg-mcnally/EROSPET/wankama_dekadPET_2005_2008.csv')
potevp = read_csv(ifile)
potevp = reform(potevp.field1,36,4)

PET = potevp(15:27,0)*10
;PET = [65, 61,  56,  60,  38,  39,  37,  45,  39,  35,  51,  41,  47];2007
;extract PET values from EROS data
;Extract rainfall values from RFE, ubRFE and station (that file may exsist and may have PET with it)

;I will want to do the computation from 2001 to present....make sure all the data is there :)

AET  = 0
AETf = 0
PETf = 0

outarray = fltarr(5,n_elements(PET))
; Read in inputs and perform calculations then output WRSI for each of 12 dekads
for n=0,n_elements(PET)-1 do begin
    
; Calculate components Soil Water Critical [SWC], Plant Available Water[PAW], Actual ET[AET], Soil Water Balance[SWB]
    SWC = RD[n] * WHC * SWf 
    PETc = [PET[n] * K[n]]
   ;there is no change in results when i force PAW to be zero at n=0.
   ;if n eq 0 then PAW[n] = 0
    ; Calculate AET per time period n
    if PAW[n] ge SWC then AET = PETc $
    else AET = [[PAW[n]/SWC]*PETc] 
     ; Calculate per dekad WRSI
    WRSI = [[AET/PETc]*100]
    ;print, "  AET "+ string(AET) +"  PETc "+string(PETc)+"  PAW "+string(PAW[n])+"   WRSI"+string(WRSI)
     outarray[*,n]= [AET, PETc, SWC, PAW[n], WRSI]
        
    ; Calculate sum of AET and sum of PET for seasonal WRSI
    AETf = AETf + AET
    PETf = PETf + PETc
endfor
;Calculate seasonal WRSI
WRSIf = [AETf/PETf]*100
print, outarray
print, "My WRSI seasonal value is "+string(WRSIf)+"."

end