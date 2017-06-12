;read in shahriar's tifs
;
indir = '/discover/nobackup/projects/fame/RS_DATA1/GIMMS_MODIS/NDVI_SM_ET_corr/Noah/'

;;;;;;SM01;;;;;;RANK CORR ;;;;;
ifile = file_search(indir+'noah1lyrsm_ndvi_rcor_lag0.tif')
NSM01RK_L0 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah1lyrsm_ndvi_rcor_lag1.tif')
NSM01RK_L1 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah1lyrsm_ndvi_rcor_lag2.tif')
NSM01RK_L2 = read_tiff(ifile, GEOTIFF = g_tags)

;;;;;;SM01;;;;;;RAW CORR LIKE OTHERS;;;;; Don't exist
;ifile = file_search(indir+'noah1lyrsm_ndvi_rawcor_lag0.tif')
;NSM01RC_L0 = read_tiff(ifile, GEOTIFF = g_tags)
;
;ifile = file_search(indir+'noah1lyrsm_ndvi_rawcor_lag1.tif')
;NSM01RC_L1 = read_tiff(ifile, GEOTIFF = g_tags)
;
;ifile = file_search(indir+'noah1lyrsm_ndvi_rawcor_lag2.tif')
;NSM01RC_L2 = read_tiff(ifile, GEOTIFF = g_tags)

;;;;;SM03;;;;;;
ifile = file_search(indir+'noah3lyrsm_ndvi_rawcor_lag0.tif')
NSM03RC_L0 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah3lyrsm_ndvi_rawcor_lag1.tif')
NSM03RC_L1 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah3lyrsm_ndvi_rawcor_lag2.tif')
NSM03RC_L2 = read_tiff(ifile, GEOTIFF = g_tags)

;;;;;SM04;;;;;;
ifile = file_search(indir+'noah4lyrsm_ndvi_rawcor_lag0.tif')
NSM04RC_L0 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah4lyrsm_ndvi_rawcor_lag1.tif')
NSM04RC_L1 = read_tiff(ifile, GEOTIFF = g_tags)

ifile = file_search(indir+'noah4lyrsm_ndvi_rawcor_lag2.tif')
NSM04RC_L2 = read_tiff(ifile, GEOTIFF = g_tags)

;;;Pvalue, not sure what this file is showing
;ifile = file_search(indir+'noah1lyrsm_ndvi_rcorpval_lag0.tif')
;pval = read_tiff(ifile, GEOTIFF = g_tags)

indir = '/discover/nobackup/projects/fame/RS_DATA1/GIMMS_MODIS/NDVI_SM_ET_corr/VIC/'
ifile = file_search(indir+'vic3lyrsm_ndvi_rcor_lag0.tif')
VSM03_L0 = read_tiff(ifile, GEOTIFF = g_tags)


indir = '/discover/nobackup/projects/fame/RS_DATA1/GIMMS_MODIS/NDVI_SM_ET_corr/VIC/'
ifile = file_search(indir+'vic2lyrsm_ndvi_rcor_lag0.tif')
VSM02_L0 = read_tiff(ifile, GEOTIFF = g_tags)