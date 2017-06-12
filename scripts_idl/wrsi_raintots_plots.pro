
test1 = where(lgpgrid gt 8 AND lgpgrid lt 11)
test2 = where(lgpgrid ge 7 AND lgpgrid le 13 AND sosgrid ge 16 AND sosgrid lt 36);northern pastoral 

test2a = where(lgpgrid ge 7 AND lgpgrid le 9 AND sosgrid ge 22 AND sosgrid lt 36);northern pastoral 
test2b = where(lgpgrid ge 10 AND lgpgrid le 13 AND sosgrid ge 16 AND sosgrid lt 21);northern pastoral 
test3 = where(lgpgrid ge 14 AND lgpgrid le 16 AND sosgrid ge 11 AND sosgrid le 16);sahel crops
test4 = where(lgpgrid ge 17 AND lgpgrid le 20 AND sosgrid ge 5 AND sosgrid le 11);northern pastoral 
 

raintot = total(raingrd, 3)
ref= long(720)*long(350)*12
rain1 = reform(raintot,ref)
wrsi1 = reform(wrsigrid, ref)

p1 = plot(rain1(test1),wrsi1(test1),'*')
p1 = plot(rain1(test2a), wrsi1(test2a), '*',title = 'WRSI vs rainfall totals in cropping area (7<lgpgrid<9, 22<sos<36)')
p1 = plot(rain1(test2b), wrsi1(test2b), '*',title = 'WRSI vs rainfall totals in cropping area (10<lgpgrid<13, 16<sos<21)')

p1 = plot(rain1(test3), wrsi1(test3), '*')
p1 = plot(rain1(test4), wrsi1(test4), '*')


temp = image(lgpgrid, rgb_table=4, min_value=0, max_value=21, title = 'LGP')
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
             
p1 = image(sosgrid[*,0:249], image_dimensions=[72.0,25.1], image_location=[-20,-5], dimensions=[nx/100,251/100], $
           rgb_table =4, title = 'SOS', font_size=18, min_value=5,max_value=29)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)
p1 = MAP('Geographic',LIMIT = [-5, -20, 18, 52], /overplot)
p1.mapgrid.linestyle = 'dotted'
p1.mapgrid.color = [150, 150, 150]
p1.mapgrid.label_position = 0
p1.mapgrid.label_color = 'black'
p1.mapgrid.FONT_SIZE = 12
p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
             
             
             
temp = image(sosgrid, rgb_table=4, min_value=0, max_value=21)
c = COLORBAR(target=temp,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], font_size=20)