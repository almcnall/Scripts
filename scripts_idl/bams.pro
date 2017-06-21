pro BAMS

;this script generates figs for the BAMS-FLDAS paper
;
;Figure 1. FEWS NET/FLDAS regions of interest
;Figure 2. Anomaly correlation for CCI-SM and Noah soil moisture.

;open file for greg
;y=2010
;m=1
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/NOAH_RFE2_GDAS_EA/'
;fileID = ncdf_open(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_A_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m), /nowrite) &$
;SoilID = ncdf_varid(fileID,'SoilMoist_tavg') &$
;ncdf_varget,fileID, SoilID, SM01
;sm01(where(sm01 lt 0)) = !values.f_nan
