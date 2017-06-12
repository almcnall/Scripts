pro arid_mask

;the purpose of this program is to make my own aridity mask from NDVI. 
;following the suggestion of Guerra et al. 2008 the mask will keep areas with ndvi gt 0.1 for two months in a row.


;read in ndvi file and add it all up.
idir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/month_clim/'

ifile = file_search(idir+'data.??.img')

nx = 751
ny = 801
buffer = fltarr(nx,ny)
ingrid = fltarr(nx,ny,2)
mask = intarr(nx,ny)
thresh = 0.25
;initialize the maske with the dec-jan map
openr,1,ifile[0]
readu,1,buffer
close,1
ingrid[*,*,0]=buffer

openr,1,ifile[11]
readu,1,buffer
close,1
ingrid[*,*,1]=buffer

tot2mo=total(ingrid,3)

wet = where(tot2mo gt thresh, complement=dry)
mask(wet) = 1
mask(dry) = 0

DJ=total(ingrid,3)
for i=1,n_elements(ifile)-1 do begin

  openr,1,ifile[i-1]
  readu,1,buffer
  close,1
  ingrid[*,*,0]=buffer

  openr,1,ifile[i]
  readu,1,buffer
  close,1
  ingrid[*,*,1]=buffer
  
  tot2mo=total(ingrid,3)
  wet = where(tot2mo gt thresh, complement=dry)
  buffer(wet) = 1
  buffer(dry) = 0
  
  mask(wet)=buffer(wet)+mask(wet)
  mask(dry)=buffer(dry)+mask(dry)
 
 endfor
 
 print, 'hold'
 
 mask(where(mask gt 0)) = 1
 temp=image(reverse(mask,2), rgb_table=4)
 
 ofile='/jabber/sandbox/mcnally/ndvi4luce/mask_ndvi025.img'
 ;ofile='/jabber/sandbox/mcnally/ndvi4luce/mask_ndvi020.img'
 
 openw,1,ofile
 writeu,1,mask
 close,1
 
 end
