pro read_ubrfe2

;the purpose of this program is to read in the ubrfe2 data so I can compare
; it with the AMMA station spatial averages. It should be a bit higher. 

indir=strcompress('/jabber/LIS/Data/ubRFE2/', /remove_all)
cd, indir

fname=file_search('*200{5,6,7,8}*')
nx=751.
ny=801.
ingrid=fltarr(nx,ny)
rain=fltarr(nx,ny,n_elements(fname))

for i=0,n_elements(fname)-1 do begin
  openr,1,fname[i]
  readu,1,ingrid
  close,1
   byteorder,ingrid,/XDRTOF 
  rain[*,*,i]=reverse(ingrid,2)
  
endfor
rain=reverse(rain,2);this was already right side up in idl-land...
tvim, rain[224,535,234]

  lonmn = 2.55 &  lonmx = 2.85 & latmx = 13.65 &  latmn = 13.45
  ;lonmn = -15. &  lonmx = 10 & latmx = 15 &  latmn = -5
  xmax = (lonmx+19.95)*10
  xmin = (lonmn+19.95)*10
  
  ymax=(latmx+39.95)*10
  ymin=(latmn+39.95)*10
  
tvim,rain(xmin:xmax,ymin:ymax)

print,'hold here'

end
