pro readin_GHS_POP_GPW4

;12/5/16 readin narcisa's pop data and try to get it on the same grid as NOAH 294x348
;08/02/17 revisit to get the orignal GPW4 2000-2017 data. Did I already do this?

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

;readin the 1975 population file and see whats up 331x350
data_dir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/netcdf_popfiles/'

ifile = file_search(data_dir+'noah_1975pop_0.nc')
VOI = 'Band1' &$ ;Qsb_tavg
pop75 = get_nc(VOI, ifile)
pop75(where(pop75 lt 0)) = !values.f_nan


ifile = file_search(data_dir+'noah_1990pop_0.nc')
VOI = 'Band1' &$ ;Qsb_tavg
pop90 = get_nc(VOI, ifile)
pop90(where(pop90 lt 0)) = !values.f_nan

ifile = file_search(data_dir+'noah_2000pop_0.nc')
VOI = 'Band1' &$ ;Qsb_tavg
pop00 = get_nc(VOI, ifile)
pop00(where(pop00 lt 0)) = !values.f_nan

ifile = file_search(data_dir+'noah_2015pop_0.nc')
VOI = 'Band1' &$ ;Qsb_tavg
pop15 = get_nc(VOI, ifile)
pop15(where(pop15 lt 0)) = !values.f_nan
  
;readin a noah file so i can see how they overlay
y = 2015
m = 1
data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/HYMAP/OUTPUT_EA1981/post/'
ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_H_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m))
VOI = 'RiverStor_tavg'
Qs = get_nc(VOI, ifile)

;;10-11 seems to get the populatiuon right up to the lake/ocean edges. then 2 pixels clipped from north end.
;p1 = image(qs,max_value=10, rgb_table=16)
;temp = image(pop75[10:303,0:347], rgb_table=64, max_value=0.005, transparency=50, /overplot)

;so that is 321x350 when i want 294x348

;write out the pop to the FLDAS grid
pop75FG = pop75[10:303,0:347] & help, pop75FG
pop90FG = pop90[10:303,0:347] & help, pop90FG
pop00FG = pop00[10:303,0:347] & help, pop00FG
pop15FG = pop15[10:303,0:347] & help, pop15FG

;now that everything is on the same grid i can use the EA plot parameters
domain = string('Noah33_CHIRPS_MERRA2_EA')
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]


;what is the best way to interpoloate?
;first stack the data
POPstack = [ [[pop75FG]], [[pop90FG]], [[pop00FG]], [[pop15FG]] ] & help, popstack

delvar, pop75, pop90, pop00, pop15

