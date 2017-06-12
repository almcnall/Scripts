pro clip_FTIP2Africa

;this program clips out the global ftip to the 1501x1601 africa window.

fx=7200
fy=2000
frain=fltarr(fx,fy)
stack=fltarr(fx,fy)
; Global FTIP-RT from 2005.02 to 2012.01
ftip=file_search('/jabber/gibber/Products/FTIP_Global/FTIP_daily/2012.01.18-RT/*.tif')

for i=0,n_elements(ftip) do begin &$
  openr,1,ftip[i] &$
  readu,1,frain &$
  close,1 &$

  frain=reverse(frain,2)
  AfFTIP=frain[3200:4700,200:1800]

  ofile='/jower/LIS/data/AF_FTIP/'+strmid(ftip[i],61)
  openw,1,ofile
  writeu,1,AfFTIP
  close, 1
;stack=frain+stack &$
endfor

print, 'hold here'

end