pro rotate4diego

;the purpose of this program is to rotate pete's trmm data (but the funtion is reverse!)
; so that Diego can easily read it into ACRmap - 1. rotate files w/ idl 2. make headers w/ bash script

indir = strcompress(" /jabber/Data/TRMM_3B42/WHem/pentads/", /remove_all)
outdir = strcompress("/jabber/Data/mcnally/trmm4diego/", /remove_all)

cd, indir
nx=364.
ny=400.

file=file_search('WHem*.img')
buffer=dblarr(nx,ny)
for i=0,n_elements(file)-1 do begin
  openr,1,file[i]
  readu,1,buffer
  buffer=reverse(buffer,2)
  close,1
  openw,1,outdir+file[i]
  writeu,1,buffer
  close,1
endfor

end