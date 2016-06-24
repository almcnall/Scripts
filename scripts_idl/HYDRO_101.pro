;the regional water balance

;1. agreggate by HYMAP basin
;read in the basin map to see if i can average over these areas instead of rando boxes.
ifile = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/lis_input_sa_elev_hymap_test.nc')
VOI = 'HYMAP_basin' &$ ;
basin = get_nc(VOI, ifile)

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

