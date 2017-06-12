pro pnt2roicheck
;the purpose of this script is to see if the ndvi that i extracted looks ok

fname=file_search('/jabber/sandbox/mcnally/ForKatNDVI/NDVI*')

indat=fltarr(14,400)
openu,1,fname[0]
readu,1,indat
close,1

indat2=fltarr(14,398)
openu,1,fname[1]
readu,1,indat2
close,1

;min/max coordinates:
;33.9774, 41.8838
;-4.66426; 4.68589
dat=[[indat],[indat2]]
x=reform(dat[1,good],796)
y=reform(dat[2,good],796)
z=reform(dat[3,good],796)

good=where(dat[1,*] gt 0.0003, count)
test=where(dat[2,*] lt 1 AND dat[1,*] , count) & count