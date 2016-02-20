pro luce_GHCN_CAMS
;the purpose of this script is to read in the temp data (montly clim) for the malaria stuff
;and extract the relevant time series. I could extract the whole time series for each point, and then just average over the
;relevant months. Maybe I should use the condensed list of lat/lons?
;I would like to use this new dataset but maybe I should just stay consistant for this round of analysis...

indir='/home/mcnally/luce_sites/'
cd, indir

ifile=file_search('data*')

nx=150
ny=160
nbands=12
itemp=fltarr(nx,ny,nbands)

openr,1,ifile
readu,1,itemp
itemp = swap_endian(itemp)
close,1

temp=image(reverse(itemp[*,*,*]),2)
temp=image(itemp[*,*,1]) ;looks fine




