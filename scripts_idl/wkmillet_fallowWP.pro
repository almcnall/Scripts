pro wkmillet_fallowWP

;this script reads the volumetric water content of the millet and fallow files and calculated the water potenital
;using the campbell equation and coefficents described in manyame et al. 2007.
;
;afterthought...read the files back in,include water potenital and writeback out to the same file with 
;an additional column. I didn;t include a date column but i think that it is pretty obvious that it is 
;72 dekads from 2005-2006. for some reason this was not working inside another file so i pulled it out.

ifile=file_search('/jabber/Data/mcnally/AMMASOIL/WK110/*VWC*cm.dat')
VWC=fltarr(72)

for i=0,n_elements(ifile)-1 do begin &$
  ;read in the volumetric water content
  openr,1,ifile[i] &$
  readu,1,VWC &$
  close,1 &$
  ;look at the file name to determine the depth and which Campbel coeff to use. 
  if strmid(ifile[i],53,3) eq '100' then begin &$
  ;psie=0.9, b=2.83, thetaS=0.4 >60cm
  WP=0.9*(VWC/0.4)^(-2.83) &$
  endif
  if strmid(ifile[i],53,3) eq '50c' then begin  &$
  ;30-60cm: ψe=0.78, b=2.71, Өs=0.42 
  WP=0.78*(VWC/0.42)^(-2.71)
  endif
  if strmid(ifile[i],53,3) eq '10c' then begin  &$
  ;0-30cm: ψe=0.69, b=2.17, Өs=0.42 
  WP=0.69*(VWC/0.42)^(-2.17)  &$
  endif   &$
  
  ofile=strcompress(strmid(ifile[i],0,58)+'WP.csv', /remove_all)  &$
  write_csv, ofile,[transpose(VWC),transpose(WP)]   &$
endfor
print, 'hold'
end