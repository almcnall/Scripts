pro Triple-colocation

;read in Noah ET PON
;read in SSEB PON
;read in NDVI PON (after generating MODIS NDVI files with LVT)

;or 
;read in Noah SM
;read in CCI-SM (see ECV_eval_paper for readin file)
;read in NDVI or SSEB

;usual set up...
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

startyr = 2003 ;start with 1982 since no data in 1981
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;params = get_domain25('WA')

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('SA')

sNX = params[0]
sNY = params[1]
smap_ulx = params[2]
smap_lrx = params[3]
smap_uly = params[4]
smap_lry = params[5]

params = get_domain01('EA')

eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

params = get_domain01('WA')

wNX = params[0]
wNY = params[1]
wmap_ulx = params[2]
wmap_lrx = params[3]
wmap_uly = params[4]
wmap_lry = params[5]

;;;;;;
indir = '/discover/nobackup/projects/fame/Validation/SSEB/ETA_AFRICA/'

ETAe = bytarr(eNX,eNY,12,(endyr-startyr)+1)
ETAs = bytarr(sNX,sNY,12,(endyr-startyr)+1)
ETAw = bytarr(wNX,wNY,12,(endyr-startyr)+1)

openr,1,indir+'ETA_EA_294_348_12_14_byte.bin'
readu,1,ETAe
close,1

openr,1,indir+'ETA_SA_486_443_12_14_byte.bin'
readu,1,ETAs
close,1

openr,1,indir+'ETA_WA_446_124_12_14_byte.bin'
readu,1,ETAw
close,1

;;;;;;;;;;get NOAH PON values from PON_MED4SSEB.pro;;;;;;;;;;;;;;
help, ETAe, ETAs, ETAw
help, PONe  ;, PONs, PONw\\

;;get NDVI PON values...where do i read in MODIS NDVI? can I get this from LVT?
;;i think i also have them from AVHRR, from the JAG paper. Where is that data?
