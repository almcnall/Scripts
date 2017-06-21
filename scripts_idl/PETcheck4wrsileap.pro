ifile2 = file_search('/home/mcnally/etXX0228.bil')

nx = 360
ny = 181
ingrid2 = uintarr(nx,ny)

openr,1,ifile2
readu,1,ingrid2
close,1

ingrid2 = reverse(ingrid2/100,2)

afr2=ingrid2[160:234,50:130]

temp = image(congrid(afr2,750,801),layout = [2,1,2], rgb_table=4, min_value=100, max_value=600, /CURRENT)
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
  

temp.title = string(ifile2)
nve, afr2



ifile = file_search('/home/mcnally/etXX0229.bil')
for i=0,n_elements(ifile)-1 do begin &$
print, ifile &$

nx = 360 &$
ny = 181 &$
ingrid = uintarr(nx,ny) &$
openr,1,ifile &$
readu,1,ingrid &$
close,1 &$

ingrid = reverse(ingrid/100,2) &$
afr=ingrid[160:234,50:130] &$


;temp = image(congrid(afr,750,801),layout = [2,1,1], rgb_table=4, min_value=100, max_value=600, /CURRENT) &$
  
  horn = ingrid[160:234,80:120] & help, horn
temp = image(congrid(horn,750,400),layout = [2,1,1], rgb_table=4, min_value=100, max_value=600)
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)  

temp.title = string(ifile) &$
nve, horn &$

endfor

ifile3 = file_search('/home/mcnally/etXX0305.bil')

nx = 360
ny = 181
ingrid2 = uintarr(nx,ny)

openr,1,ifile3
readu,1,ingrid2
close,1

ingrid2 = reverse(ingrid2/100,2)

afr2=ingrid2[160:234,50:130]
horn = ingrid2[160:234,80:120] & help, horn

;temp = image(congrid(afr2,750,801),layout = [2,1,2], rgb_table=4, min_value=100, max_value=600, /CURRENT)
;c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
;             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
             
temp = image(congrid(horn,750,400),layout = [2,1,2], rgb_table=4, min_value=100, max_value=600, /CURRENT)
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=24)
 
temp.title = string(ifile3)
nve, afr2
nve, horn


