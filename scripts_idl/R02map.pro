pro R02map

;the purpose of this program is to read in the temperature and RO list and fill R0 values
;that correspond to temperatures. 
;;this program reads in the temperature and R) list and fills in the R0values on a grid.

;
;*****read in the africa only temperature data********
TRofile = file_search('/jabber/LIS/Data/worldclim/africa/ROatAfrTempRangev2.csv')
tmapfile = file_search('/jabber/LIS/Data/worldclim/africa/worldclim_africa/01degree/tmean_*img')
mfile = file_search('/jabber/sandbox/mcnally/ndvi4luce/mask_ndvi025.img')

mx = 751
my = 801

nx=751
ny=801

mask = intarr(mx,my)
openr,1,mfile
readu,1,mask
close,1

;change the mask to float and the zeros to NANs so that it works with the new scaling.
mask=float(reverse(mask,2))
;mask=congrid(mask,nx,ny)
nulls=where(mask eq 0.0, count, complement=Tmin)
mask(nulls)=!values.f_nan

;open the file with the list of temperatures and r0's 
buffer=read_csv(TRofile, dlimiter=",")
TandR0=[transpose(buffer.field2), transpose(buffer.field3)]
Topt = max(TandR0[1,*])
;read in the temperature map
mm=['01','02','03','04','05','06','07','08','09','10','11','12']
for i=0,n_elements(tmapfile)-1 do begin &$
  ingrid=intarr(nx,ny) &$
  openr,1,tmapfile[i] &$
  readu,1,ingrid &$
  close,1  &$

;**********write out maps of actual R0 values - not scaled***********
afro=fltarr(mx,my)   &$
afro[*,*]=!values.f_nan   &$
  for j=0,n_elements(TandR0[0,*])-1 do begin  &$
    if TandR0[0,j] lt 157. then continue  &$
    index=where(TandR0[0,j] eq ingrid, count)  &$;where the R0 temp = avg temp... 
    afro(index)=TandR0[1,j]    &$
  endfor  &$
  
  ;afro=afro*mask  &$
 ;write out each of the R0maps
;  ofile=strcompress('/jabber/LIS/Data/worldclim/africa/R0/R0_'+mm[i]+'.img', /remove_all)  &$
;  openw,1,ofile  &$
;  writeu,1,afro  &$
;  close,1   &$
;endfor 
;**********************************************************************  
;*****write out scaled R0 values [so that the color bar works]*********
  afro=fltarr(mx,my)
  afro[*,*]=-1*(Topt)
 
  for j=0,n_elements(TandR0[0,*])-1 do begin &$
    if TandR0[0,j] lt 157. then continue  &$
    index=where(TandR0[0,j] eq ingrid, count)  &$
    ;if TandR0[0,j] le 157. then afro(index) = 0-Topt ;maybe i can set all background values to 'low'
    if TandR0[0,j] gt 157. AND TandR0[0,j] le 252. then afro(index)=-1*(Topt-TandR0[1,j])  &$
    if TandR0[0,j] gt 252. AND TandR0[0,j] le 337. then afro(index)=(Topt-TandR0[1,j])    &$
    if TandR0[0,j] ge 338. then afro(index) = Topt   &$;maybe this doesn't belong either?   
  endfor  &$
;and write out the data....
  ofile=strcompress('/jabber/LIS/Data/worldclim/africa/scaled_R0/R0_'+mm[i]+'v3.img', /remove_all)
  afro=afro*mask
;  openw,1,ofile
;  writeu,1,afro*mask
;  close,1
  
  print, 'wrote' +ofile
  temp = image(afro*mask, rgb_table=4,title=string(i+1))
;   cbar = COLORBAR(ORIENTATION=1, $
;  POSITION=[0.90, 0.2, 0.95, 0.75])
endfor ;i
print, 'done'
  ;ingrid = congrid(ingrid,mx,my) &$
  ;change ingrid to float if you want nulls to be NANs
  
;  ofile = strcompress(strmid(tmapfile[i],0,59)+'.img', /remove_all) &$
;  openw,1,ofile &$
;  writeu,1,ingrid &$
;  close,1 &$
;endfor
end
