wkdir='/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/ESPvanilla'
cd wkdir
for START_YR in {1982..2015};do
  END_YR=$[$START_YR+1]
  #rm lis.config_MERRA2_CHIRPS_EA_20150930_$START_YR
  cp lis.config_MERRA2_CHIRPS_EA_template lis.config_MERRA2_CHIRPS_EA_20150930_$START_YR
  find lis.config_MERRA2_CHIRPS_EA_20150930_$START_YR -type f | xargs perl -pi -e 's|START_YEAR|'$START_YR'|g'
  find lis.config_MERRA2_CHIRPS_EA_20150930_$START_YR -type f | xargs perl -pi -e 's|END_YEAR|'$END_YR'|g'
  find lis.config_MERRA2_CHIRPS_EA_20150930_$START_YR -type f | xargs perl -pi -e 's|STATE_DATE|20150930|g'
  
  cp slurm_merra2_chirp2_ea_day_template.job slurm_merra2_chirp2_ea_day_$START_YR.job
  find slurm_merra2_chirp2_ea_day_$START_YR.job -type f | xargs perl -pi -e 's|START_YEAR|'$START_YR'|g'
done

for i in $(ls slurm_merra2_chirp2_ea_day_*);do sbatch $i;done
