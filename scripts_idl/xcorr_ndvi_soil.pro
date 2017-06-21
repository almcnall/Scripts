;the purpose of this file is to cross correlate the growing season
;NDVI and soil moisture anomalies.
;make a mask so that I look at only summer months (deks 16:30)

;where are my soil moisture and NDVI anomalies?
ifile1 = file_search('/jabber/Data/mcnally/AMMASOIL/add_anomsWK12TK.csv')
ifile2 = file_search('/jabber/Data/mcnally/AMMAVeg/NDVIadd_anomsWK12TK.csv')

sanom = read_csv(ifile1)
nanom = read_csv(ifile2)

wk140 = transpose([[sanom.field1], [nanom.field1]])

;make summer mask
ifile = file_search('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.csv')
ndvi = read_csv(ifile)
ncube = reform(nanom.field1,36,4)
scube = float(sanom.field1)
scube = reform(scube,36,4)

;cube[0:12,*] = !values.f_nan
;cube[13:30,*] = 1
;cube[31:35,*] = !values.f_nan
;mask = reform(cube,144)
;ofile = '/jabber/Data/mcnally/sahel_summer_TSmask.csv'
;write_csv,ofile,mask

summer = where(finite(mask))

;what if I just take the average of all of the sites...
lag = [-5,-4,-3,-2,-1,0,1,2,3,4,5]
result = c_correlate(ncube[15:30,0],scube[13:30,0],lag) & print, result