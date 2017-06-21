;write out stations
;;OMG THIS IS A MESS.
;11/10/14 write out the station data into CSV files from BB, YW and F96 for comparison with grids

;;;;;;;;;; Hajjah;;;;;;;;;;;;;;;;;;ugh, what is the best way to do this?
   hallah  = [ 12,  21,  36,  110, 39,  26,  45,  101, 38,  0, 11,  29]; BB
   YW = fltarr(12)-999
   lonx = fltarr(12)+ 43.600
   laty = fltarr(12)+  15.683 
   elev = fltarr(12)+ 1300
   name = strarr(12)+'hallah'
   header = ['name','lonx', 'laty', 'elev', 'BB','YW']
   ofile = '/home/sandbox/people/mcnally/HAJJAH_monthly_avg_BB.csv'
   write_csv, ofile, name,lonx, laty, elev, hallah, YW, HEADER=header


;;;;;;;;;;MARIB BB=1, CG=2, YM=3;;;;;;;;;;;;;;;;;

;Marib  15.483  45.317
mxind = FLOOR((45.317 + 20.) / 0.25)
myind = FLOOR((15.483 + 40) / 0.25)

marib1 = [0.000, 7.000, 15.000,  41.000,  1.000, 1.000, 2.000, 2.000, 2.000, 0.000, 0.000, 0.000]; BB
;marib2 = [0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000]
marib3 = [0.000, 7.400, 14.900,  40.500,  1.300, 0.800, 1.700, 1.900, 1.500, 0.000, 0.000, 0.300];YW

lonx = fltarr(12)+45.317
laty = fltarr(12)+15.483
elev = fltarr(12)+1100
name = strarr(12)+'marib'
header = ['name','lonx', 'laty', 'elev', 'BB',  'YW']
ofile = '/home/sandbox/people/mcnally/MARIB_monthly_avg_BB_YM.csv'
write_csv, ofile, name,lonx, laty, elev, marib1, marib3, HEADER=header


;;;;;;;;;;;;DAHI;;;;;;;;;;;;;;;;;;
Dahi = [  1, 5, 2, 13,  14,  1, 7, 36,  37,  17,  1, 4]
   YW = fltarr(12)-999
lonx = fltarr(12)+ 43.050
laty = fltarr(12)+  15.217
elev = fltarr(12)+ 70
name = strarr(12)+'dahi'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/DAHI_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, DAHI,YW, HEADER=header

;;;Hoedeidah;;;;;;;;;
hxind = FLOOR((44.183 + 20.) / 0.25)
hyind = FLOOR((14.75 + 40) / 0.25)

;Al Hodeydah A.P.
hoedBB = [18,  15,  12,  33,  3, 0, 5, 12,  4, 3, 0, 2]
hoedYW =[ 18.4, 15.7,  12.3,  32.8,  2.6, 0 , 5.34,  11.9,  3.8, 3, 0, 2.4]
lonx = fltarr(12)+ 44.183
laty = fltarr(12)+  14.75
elev = fltarr(12)+ 10
name = strarr(12)+'Hodeydah'
header = ['name','lonx', 'laty', 'elev', 'BB', 'YW']
ofile = '/home/sandbox/people/mcnally/HODEYDAH_monthly_avg_BB_YW.csv'
write_csv, ofile, name,lonx, laty, elev, hoedBB, hoedYW, HEADER=header

;;;;Riyan;;;;;;;;;;;;;;;;;
;Riyan
rxind = FLOOR((49.367 + 20.) / 0.25)
ryind = FLOOR((14.65 + 40) / 0.25)

Riyan = [ 2, 17,  11,  25,  2, 1, 1, 1, 2, 5, 6, 4]
   YW = fltarr(12)-999
lonx = fltarr(12)+ 49.383
laty = fltarr(12)+  14.650
elev = fltarr(12)+ 25
name = strarr(12)+'Riyan'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/RIYAN_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, Riyan,YW, HEADER=header

;;;;;;;;;;;YARIM;;;;;;;;;;;;;;;;;;;;
Yarim = [11,  33,  86,  89,  97,  42,  105, 183, 45,  14,  8, 7]
YW = fltarr(12)-999
lonx = fltarr(12)+ 44.383
laty = fltarr(12)+   14.300
elev = fltarr(12)+ 2400
name = strarr(12)+'Yarim'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/YARIM_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, Yarim,YW, HEADER=header

;;;;;;;;;;;;;;;;RIHAB;;;;;;;;;;;;;;;;;;;
Rihab = [13,  14 , 34 , 75 , 95 , 46 , 74 , 103, 60 , 26,  14,  2]
   YW = fltarr(12)-999
 lonx = fltarr(12)+  44.183
 laty = fltarr(12)+   14.217
 elev = fltarr(12)+ 1500
 name = strarr(12)+'Rihab'
 header = ['name','lonx', 'laty', 'elev', 'BB','YW']
 ofile = '/home/sandbox/people/mcnally/RIHAB_monthly_avg_BB.csv'
 write_csv, ofile, name,lonx, laty, elev, Rihab,YW, HEADER=header
 
 ;;;ZABID;;;;;;Gerba
; zabidYW = [4.3, 14.4,  11.5,  18.3,  43.9,  5, 39.3,  64.8,  95.6,  44.9,  3.9, 1.9]
 ZabidBB = [4, 14 , 12  ,18 , 44 , 5 ,39,  65,  96,  45 , 4 ,2]
 ZabidYW = [ 4.3, 14.4,  11.5,  18.3 , 43.9,  5, 39.3 , 64.8,  95.6,  44.9,  3.9 ,1.9]
 zabid96 = [5, 12,  12,  20,  46,  5, 39,  71,  99,  48,  4, 2]

 lonx = fltarr(12)+ 43.600
 laty = fltarr(12)+ 14.150
 elev = fltarr(12)+ 1300
 name = strarr(12)+'Zabid'
 header = ['name','lonx', 'laty', 'elev', 'BB', 'YW','F96']
 ofile = '/home/sandbox/people/mcnally/ZABID_monthly_avg_BB_YW_F96.csv'
 write_csv, ofile, name,lonx, laty, elev, ZabidBB, ZabidYW, Zabid96,HEADER=header

;;;;IBB;;;;;;
IbbBB =  [16,  32,  99,  148, 243, 252, 322, 333, 245, 85 , 42 , 17]
IBBTDA = [15.7 , 31.6,  98.7,  147.9, 243.4, 252.2 ,322.4 ,333 ,244.5 ,85.12 ,42.3 , 16.8 ]
ibbMOA = [8.2, 21.1,  45.3,  78.6 , 107.1 ,134.6, 183.3 ,170.7 ,119.5 ,17.3 , 14.9 , 4]

lonx = fltarr(12)+ 44.183
laty = fltarr(12)+ 13.983
elev = fltarr(12)+ 1800
name = strarr(12)+'Ibb'
header = ['name','lonx', 'laty', 'elev', 'BB', 'YW1','YW2']
ofile = '/home/sandbox/people/mcnally/IBB_monthly_avg_BB_YW1_YW2.csv'
write_csv, ofile, name,lonx, laty, elev, IbbBB, IbbTDA,IbbMOA, HEADER=header

;;;;EL BARH;;;;;;;
ElBarh  = [ 13,  3, 19,  36,  53,  25,  28,  27 , 83,  33,  6 ,3]
   YW = fltarr(12)-999
lonx = fltarr(12)+ 43.700
laty = fltarr(12)+ 13.450
elev = fltarr(12)+ 600
name = strarr(12)+'Barh'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/BARH_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, ElBarh,YW, HEADER=header

;;;;AL MOKAH;;;;;could also be at 13.25 43.283
AlMokhaBB = [0, 4 ,9 ,1, 0, 0, 0, 0, 0, 2, 0, 5]
AlMokhaYW = [ 0, 4.1, 9.2, 1.1, 0, 0, 0, 0, 0, 1.7, 0, 5.3]
 lonx = fltarr(12)+ 43.250
 laty = fltarr(12)+ 13.317
 elev = fltarr(12)+ 5
 name = strarr(12)+'AlMokha'
 header = ['name','lonx', 'laty', 'elev', 'BB','YW']
 ofile = '/home/sandbox/people/mcnally/MOKHA_monthly_avg_BB_YW.csv'
 write_csv, ofile, name,lonx, laty, elev, AlMokhaBB,AlMokhaYW, HEADER=header

;;;AlKhod;;;;;;;;;
AlKhod = [5, 8, 8, 3, 4, 2, 2, 7, 15,  8, 1, 3]
   YW = fltarr(12)-999

lonx = fltarr(12)+ 45.333
laty = fltarr(12)+ 13.083
elev = fltarr(12)+ 5
name = strarr(12)+'AlKhod'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/KHOD_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, AlKhod,YW, HEADER=header

;;;;Aden KhKhormaksar;;;;;;;;
AdenK=[ 6, 7, 5, 5, 5, 0, 2, 3, 6, 3, 2, 6 ]
aden96 = [ 8, 4, 8, 6, 4, 1, 1, 3, 5, 3, 2, 3]

lonx = fltarr(12)+ 45.017
laty = fltarr(12)+ 12.833
elev = fltarr(12)+ 7
name = strarr(12)+'AdenKhormaksar'
header = ['name','lonx', 'laty', 'elev', 'BB', 'F96']
ofile = '/home/sandbox/people/mcnally/ADENKhormaksar_monthly_avg_BB_F96.csv'
write_csv, ofile, name,lonx, laty, elev, Adenk,aden96,HEADER=header

;;;barim island;;;;;
Barim=[ 5, 3, 5, 3, 2, 2, 3, 5, 13,  3, 3, 3]
   YW = fltarr(12)-999
lonx = fltarr(12)+ 43.400
laty = fltarr(12)+  12.650
elev = fltarr(12)+ 27
name = strarr(12)+'BarimIsland'
header = ['name','lonx', 'laty', 'elev', 'BB','YW']
ofile = '/home/sandbox/people/mcnally/BARIMIsland_monthly_avg_BB.csv'
write_csv, ofile, name,lonx, laty, elev, barim, YW, HEADER=header

;;;;;;;;;;;bani Uwair 43.68333333 16.76666667 = 187mm;;;;;;;;;;;;;
bxind = FLOOR((43.683 + 20.) / 0.25)
byind = FLOOR((16.7667 + 40) / 0.25)

BU_F96 = [  7, 14,  23,  45, 16,  5, 18,  37,  3, 2, 0, 4]
BU_YW = [  6.5, 14.1,  20.3,  42.9, 15.9,  4.5, 15.6,  34.1,  1.9, 1.6, 0, 3]
lonx = fltarr(12)+43.683
laty = fltarr(12)+16.7667
elev = fltarr(12)+2100
name = strarr(12)+'BANIUWAIR'
header = ['name','lonx', 'laty', 'elev', 'BU_F96', 'BU_YW']
ofile = '/home/sandbox/people/mcnally/BANIUWAIR_monthly_avg_F96_YM.csv'
write_csv, ofile, name,lonx, laty, elev, BU_F96, BU_YW, HEADER=header

;;;;TAIZ;;;;;;;;;;;;;;;;;;;;;;
   
T96 = [  9, 12,  37,  68,  89,  73,  60,  89,  110, 91,  17,  5] ;high rainfall near ibb
TYW = [8.6, 11.7 ,40.9, 77.8, 95.7, 76.5, 58, 88.8, 104.3, 80.3, 10.8, 5.5]
lonx = fltarr(12)+44.02
laty = fltarr(12)+13.58
elev = fltarr(12)+1380
name = strarr(12)+'TAIZ'
header = ['name','lonx', 'laty', 'elev', 'F96', 'YW']
ofile = '/home/sandbox/people/mcnally/TAIZ_monthly_avg_F96_YM.csv'
write_csv, ofile, name,lonx, laty, elev, T96, TYW, HEADER=header

;;;;DHALLA;;;;;;
dhalla96 = [ 6, 6, 24, 28, 48, 22, 93, 106, 42,  7, 3, 4]
   YW = fltarr(12)-999
lonx = fltarr(12) + 44.730
laty = fltarr(12) + 13.700 
elev = fltarr(12) + !values.f_nan
name = strarr(12) + 'Dhalla'
header = ['name','lonx', 'laty', 'elev', 'F96','YW']
ofile = '/home/sandbox/people/mcnally/DHALLA_monthly_avg_F96.csv'
write_csv, ofile, name,lonx, laty, elev, dhalla96, YW, HEADER=header

;;;;;seiyun;;;;;;;;;;;;;
seiyun96 = [ 5, 2, 9, 11,  3, 0, 6, 17,  1, 4, 1, 0]
   YW = fltarr(12)-999

lonx = fltarr(12) + 48.820 
laty = fltarr(12) + 15.950
elev = fltarr(12) + 580
name = strarr(12) + 'Seiyun'
header = ['name','lonx', 'laty', 'elev', 'F96','YW']
ofile = '/home/sandbox/people/mcnally/SEIYUN_monthly_avg_F96.csv'
write_csv, ofile, name,lonx, laty, elev, seiyun96,YW, HEADER=header

;;;Dhmar;;;;;;44.417  14.580
YW1 = [0.5, 25.2 , 36.1,  71.4 , 54.1 , 3.4 ,37.2 , 84.9 , 15.5 , 4 ,0, 5.6]
YW2 = [1.8, 16.9,  44.9 , 65.7  ,52.9 , 6, 58,  110, 14.8,  10.6,  6.8, 3.4]
YW3 = [2.5, 7.2, 59.5,  83.9,  39.9,  1.9, 29.1,  60.3,  6.7, 7, 4.6, 4.9]

lonx = fltarr(12) + 44.417
laty = fltarr(12) + 14.580
elev = fltarr(12) + !values.f_nan
name = strarr(12) + 'Dhmar'
header = ['name','lonx', 'laty', 'elev', 'YW.1','YW.2','YW.3']
ofile = '/home/sandbox/people/mcnally/DHMAR_monthly_avg_YW3.csv'
write_csv, ofile, name,lonx, laty, elev, YW1,YW2,YW3, HEADER=header

;;;;Mahwit;;;;
YM1 = [ 13.8,  9.5, 17.5,  115.3, 82.5,  66.1 , 101 ,173.7, 67.8,  5, 12.7,  8.5]
YW2 =  [1.4, 12.6,  4.9, 99.6 , 16.3,  46.6 , 69.5 , 103 ,56.1,  22 , 0.4 ,8.4]
   
lonx = fltarr(12) + 43.5 
laty = fltarr(12) + 15.5
elev = fltarr(12) + !values.f_nan
name = strarr(12) + 'Mahwit'
header = ['name','lonx', 'laty', 'elev', 'YW.1','YW.2']
ofile = '/home/sandbox/people/mcnally/MAHWIT_monthly_avg_YW2.csv'
write_csv, ofile, name,lonx, laty, elev, YW1,YW2, HEADER=header

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sana_airport96 = [ 3, 7, 36,  53,  28,  4, 25,  38,  2, 13,  3, 1]
sana_airportFW = [ 5.9, 12.5, 18.7,  39.6,  17.8,  5.7, 25.4,  36.9,  5.3, 8.5,  3.5, 3.3]

;mean station data from paper
;I think making a 4 pannel plot for each station allows you to see how they covary
;bani_uwair = [  7, 14,  23,  45, 16,  5, 18,  37,  3, 2, 0, 4]
;sana_airport = [ 3, 7, 36,  53,  28,  4, 25,  38,  2, 13,  3, 1]
;zabid = [5, 12,  12,  20,  46,  5, 39,  71,  99,  48,  4, 2]
;taiz = [  9, 12,  37,  68,  89,  73,  60,  89,  110, 91,  17,  5] ;high rainfall near ibb
;TAIZ2 = [8.6, 11.7 ,40.9, 77.8, 95.7, 76.5, 58, 88.8, 104.3, 80.3, 10.8, 5.5];from the scanned pdf
;dhalla = [ 6, 6, 24,  28,  48,  22,  93,  106, 42,  7, 3, 4]
;aden = [ 8, 4, 8, 6, 4, 1, 1, 3, 5, 3, 2, 3]
;seiyun = [ 5, 2, 9, 11,  3, 0, 6, 17,  1, 4, 1, 0]


;al_mahwit
amxind = FLOOR((43.5 + 20.) / 0.25)
amyind = FLOOR((15.5 + 40) / 0.25)

;Marib  15.483  45.317
mxind = FLOOR((45.317 + 20.) / 0.25)
myind = FLOOR((15.483 + 40) / 0.25)




;IBB
ixind = FLOOR((44.333 + 20.) / 0.25)
iyind = FLOOR((14.00 + 40) / 0.25)

;mokha
mkxind = FLOOR((43.283 + 20.) / 0.25)
mkyind = FLOOR((13.25 + 40) / 0.25)


;


;sana airport 44.21666667 15.46666667=574mm,
saxind = FLOOR((44.2166 + 20.) / 0.25)
sayind = FLOOR((15.466 + 40) / 0.25)

;zabid 43.43333333 14.15=182mm
zxind = FLOOR((43.433 + 20.) / 0.25)
zyind = FLOOR((14.15 + 40) / 0.25)

;taiz 44.01666667 13.58333333=415mm
txind = FLOOR((44.0166 + 20.) / 0.25)
tyind = FLOOR((13.5833 + 40) / 0.25)

;dhalla 44.73333333 13.7=280mm
dxind = FLOOR((44.733 + 20.) / 0.25)
dyind = FLOOR((13.7 + 40) / 0.25)

;aden  45.03333333 12.8333333=59mm
axind = FLOOR((45.033 + 20.) / 0.25)
ayind = FLOOR((12.833 + 40) / 0.25)

;seiyun 48.81666667 15.95=88mm
sxind = FLOOR((48.8166 + 20.) / 0.25)
syind = FLOOR((15.95 + 40) / 0.25)

;;;;;;;;;and for the world clim data..;;;;;;;
map_ulx = 30.05  & map_lrx = 49.95
map_uly = 20.15  & map_lry = 5.15

;taiz 44.01666667 13.58333333=415mm, worldclim = 424.8
;wtxind = FLOOR((44.0166 - map_ulx) / 0.1)
;wtyind = FLOOR((13.5833 - map_lry) / 0.1)


;al_mahwit
wamxind = FLOOR((43.5  - map_ulx) / 0.1)
wamyind = FLOOR((15.5 - map_lry) / 0.1)

;Marib  15.483  45.317
wmxind = FLOOR((45.317  - map_ulx) / 0.1)
wmyind = FLOOR((15.483- map_lry) / 0.1)

;Riyan
wrxind = FLOOR((49.367  - map_ulx) / 0.1)
wryind = FLOOR((14.65 - map_lry) / 0.1)

;IBB
wixind = FLOOR((44.333  - map_ulx) / 0.1)
wiyind = FLOOR((14.00 - map_lry) / 0.1)

;mokha
wmkxind = FLOOR((43.283  - map_ulx) / 0.1)
wmkyind = FLOOR((13.25 - map_lry) / 0.1)

;Hoedeidah
whxind = FLOOR((44.183  - map_ulx) / 0.1)
whyind = FLOOR((14.75 - map_lry) / 0.1)
;
;bani 43.68333333 16.76666667 = 187mm
wbxind = FLOOR((43.683  - map_ulx) / 0.1)
wbyind = FLOOR((16.7667 - map_lry) / 0.1)

;sana airport 44.21666667 15.46666667=574mm,
wsaxind = FLOOR((44.2166  - map_ulx) / 0.1)
wsayind = FLOOR((15.466 - map_lry) / 0.1)

;zabid 43.43333333 14.15=182mm
wzxind = FLOOR((43.433  - map_ulx) / 0.1)
wzyind = FLOOR((14.15 - map_lry) / 0.1)

;taiz 44.01666667 13.58333333=415mm
wtxind = FLOOR((44.0166  - map_ulx) / 0.1)
wtyind = FLOOR((13.5833 - map_lry) / 0.1)

;dhalla 44.73333333 13.7=280mm
wdxind = FLOOR((44.733  - map_ulx) / 0.1)
wdyind = FLOOR((13.7 - map_lry) / 0.1)

;aden  45.03333333 12.8333333=59mmw
waxind = FLOOR((45.033  - map_ulx) / 0.1)
wayind = FLOOR((12.833 - map_lry) / 0.1)

;seiyun 48.81666667 15.95=88mm
wsxind = FLOOR((48.8166  - map_ulx) / 0.1)
wsyind = FLOOR((15.95 - map_lry) / 0.1)