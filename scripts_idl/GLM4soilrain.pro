pro GLM4soilrain

;the purpose of this program is to find b0 and b1 for the soil and raindfall

;there is no real reason to limit the output to just one rainfall values...
ifile='/jabber/Data/mcnally/AMMARain/rain4soil/GLM_soil_rain45.dat'

nx=18
ny=781

buffer=fltarr(nx,ny)

openr,1,ifile
readu,1,buffer
close,1

;prolly have to omit NANs first thing....
;y is the depenedent variavle - soil moisture
Y=buffer(1,*)
good=where(finite(y), count) & print, count
Y=reform(buffer(1,good),count)
;x is the indpendent variable - rainfall
X=reform(buffer(0,good),count)

;i guess i should check out my measurement errors....
result=regress(X,Y,chisq=chisq, const=const, correlation=correlation,ftest=ftest)
