;3/26 the purpose of this script is to get the FAO WHC map that matches the geoWRSI
;format requirements
;I think that it uses global africa. what does it do for other countries?
;
;first check out the original file
ifile = file_search('/raid/ftp_out/people/mcnally/lis/regionmasks/whc3.bil')

nx = 751
ny = 801
ingrid = bytarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1

;the data go from 0 to 221 (what does this mean? mm I think)
temp = image(reverse(ingrid,2))
;first, make sure i can extract this from the data online...ewwww...
;;is the FAO porosity the same as the WHC? seems like it might be percent rather than mm. 

;but this only has one band! what is it???
;ny = 21600
;nx = 43200
;ifile = file_search('/raid2/sandbox/people/mcnally/hwsd.bil')
ifile = file_search('/raid2/sandbox/people/mcnally/hwsd_yemen.bil')
nx = 1440
ny = 840

ingrid = fltarr(nx,ny)

openr,1,ifile
readu,1,ingrid
close,1

 c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON,POSITION=[0.3,0.1,0.7,0.13], font_size=20, range=[0,100])

intxt = read_ascii('/home/chg-mcnally/yemen_awc.txt', delimiter= ' ')
whcmap = FLTARR(SIZE(ingrid,/DIMENSIONS)) * !VALUES.F_NAN

for i = 0, n_elements(intxt.field1[0,*])-1 do begin &$
  print, i &$
  index = where(ingrid eq intxt.field1[0,i]) &$
  WHCmap(index) = intxt.field1[1,i] &$
endfor 

;output needs to be upsidedown byte
;i forgot that it also needs to be at 0.1 degree...what dimensions are these?
;i should compare with the LGP map...which was 81 x 121
ofile = strcompress('/home/chg-mcnally/whc0ym.bil')
outwhc = congrid(whcmap,121,81)
openw,1,ofile
writeu,1,byte(outwhc)
close,1

ifile = file_search('/home/chg-mcnally/lgp_ym.bil')
ingrid = bytarr(121,81)
openr,1,ifile
readu,1,ingrid
close,1

;checking the plots for alignement
;i am going to say that they are good enough for now
;but i think we'll have to be more careful esp when dealing with 
;high resolution. 

ingrid = float(ingrid)
ingrid = congrid(ingrid, 1210, 810)
temp = image(ingrid, rgb_table=20, /overplot, transparency=60)

temp = image(reverse(whctest,2), rgb_table=16, min_value=0)
temp = image(rain, rgb_table=20, /overplot, transparency=80)




;got the ym_stck from lgp script
rain = mean(ym_stack, dimension=3, /nan)
rain = congrid(rain, 1210,810)

temp = image(rain)





