;compare diego's WRSI and LIS-WRSI

;where is at actually a MAM season?
ifile = file_search('/home/mcnally/regionmask_hari/lgp_ee.bil')

nx = 445
ny = 579

ingrid = bytarr(nx,ny)
openr,1,ifile
readu,1,ingrid
close,1

;output for ENVI (in envi mutiply by 100)


p1=image(reverse(ingrid,2), rgb_table=4)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])
             
             
ifile2 = file_search('/home/mcnally/regionmask_hari/eew7*.bil')
ingrid2= bytarr(751,801)
openr,1,ifile2
readu,1,ingrid2
close,1

ingrid2(where(ingrid2 gt 15)) = 15

ifile3 = file_search('/home/mcnally/etw7*.bil')
ingrid3 = bytarr(751,801)
openr,1,ifile3
readu,1,ingrid3
close,1

temp = image(reverse(ingrid3,2)*100)
ingrid3(where(ingrid3 eq  60))=0


ofile = '/home/mcnally/regionmask_hari/SOS4envi.bil'
openw,1,ofile
writeu,1,ingrid2
close,1

p1=image(reverse(ingrid2,2), rgb_table=4, max_value=15)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20, range=[0,100])

ingrid(where(ingrid gt 8 and ingrid lt 13))=99


ifile = file_search('/raid/chg-shrad/DATA/Diego-WRSI/bil_format/chpsEast*WRSI_Index_EOS_????.bil')

nx = 587 
ny = 695 
ingrid = bytarr(nx,ny)
stack = bytarr(nx, ny, n_elements(ifile))

;for i = 0, n_elements(ifile)-1 do begin &$
;  openr,1,ifile[i] &$
;  readu,1,ingrid &$
;  close,1 &$
;  
;  stack[*,*,i] = ingrid &$
;endfor 


yr = indgen(32)+1981
ncolors = 256 ;this has to be set to 256 to get the pink no-start (253).

;for i = 0, n_elements(ifile)-1 do begin &$
 i=0 
  openr,1,ifile[i] &$
  readu,1,ingrid  &$
  close,1 &$
 
  heos = reverse(ingrid,2) &$
  ;heos(where(heos ge 253)) = !values.f_nan &$
  ;this ofile is for the OND that crosses yr 
  ;ofile = strcompress('/home/chg-mcnally/EAtiffs/MAM/EOS_WRSI.'+strmid(ifile[i],49,2)+strmid(ifile[i],54,2)+'.tif') &$
  ofile = strcompress('/home/chg-mcnally/EAtiffs/MAM/EOS_WRSI.'+string(yr[i])+'.tif', /remove_all) &$ 
  ;write_tiff, ofile, reverse(heos,2) ,geotiff=g_tags, /FLOAT &$
  print, 'wrote '+ofile &$

  ;make sigures that look like the EROS ones...
  ;w = WINDOW(DIMENSIONS=[500,500]) &$
  p1 = image(byte(heos), image_dimensions=[nx/10,ny/10], image_location=[23.2,-11.5],dimensions=[700,600], RGB_TABLE=make_wrsi_cmap(),  MIN_VALUE=0) &$
  p1.title = string(yr[i]) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,0] = [255,250,250] &$
  p1.rgb_table = rgbdump   &$

  c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, font_size=18)  &$
  ;what is shrad's domain again? -1.875 deg S to 7.875 deg N and 36.125 deg E and 49.625 deg E, what is the eros window?
  p1 = MAP('Geographic',LIMIT = [-11, 23, 20, 50], /overplot) &$
  p1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
  p1.mapgrid.color = [255, 250, 250] &$
  p1.mapgrid.label_position = 0 &$
  p1.mapgrid.label_color = 'black' &$
  p1.mapgrid.FONT_SIZE = 12 &$
  p1 = MAPCONTINENTS(/COUNTRIES, thick=2,  COLOR = [120, 120, 120]) &$
  ;************************************** 
  ofile = strcompress('/home/mcnally/MAM_wrsi_IMGS/Diego_EOS_WRSI'+string(yr[i])+'.jpg', /remove_all) &$
  p1.save,ofile ,RESOLUTION=200 &$
endfor





ifile = file_search('/raid/chg-shrad/DATA/Diego-WRSI/netcdf_format/chirpsEast_Africa_Mar-Nov_Onset_Rain_CUR_????.nc')


fileID = ncdf_open(ifile[10], /nowrite)
wrsiID = ncdf_varid(fileID,'Band1')

ncdf_varget,fileID,wrsiID,wrsi  

mve, wrsi


smdata(where(smdata gt 2000))=!values.f_nan