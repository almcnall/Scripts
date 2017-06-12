
;88888
spin2 = read_csv('/home/mcnally/evapS2.txt')
spin3 = read_csv('/home/mcnally/evapS3.txt')
spin4 = read_csv('/home/mcnally/evapS4.txt')


p1 = plot(spin2.field1[3:490], /overplot)
p2 = plot(spin3.field1, /overplot, 'b')

spin2 = read_csv('/home/mcnally/EA_OCTtest_soilS2.txt')
spin3 = read_csv('/home/mcnally/EA_OCTtest_soilS3.txt')

spin4 = read_csv('/home/mcnally/EA_OCTtest_SM1to4.S4.txt')
spin5 = read_csv('/home/mcnally/EA_OCTtest_SM1to4.S5.txt')



p1 = plot(spin2.field1)
p2 = plot(spin3.field1, /overplot, 'b')

p2 = plot(spin4.field1, /overplot, 'g')
p2 = plot(spin5.field1[35:n_elements(spin5.(0))-1], /overplot)

;;;;;;;;;;breaking up the soil layers;;;;;;;;;
ifile = file_search('/home/mcnally/SM_3.txt')
ifile4 = file_search('/home/mcnally/SM_4.txt')

soil = read_csv(ifile)
soil = float(soil.field1)

soil4 = read_csv(ifile4)
soil4 = float(soil4.field1)

onefour = [1,2,3,4]
counter = []

;rebin makes the 4 cols into a 4x2, then reform into an 1,4x2
;this does the same thing as the loop
;e.g print, reform(rebin(onefour,4,2),1,8)
counter = reform(rebin(onefour,4,n_elements(soil)/4),n_elements(soil))

soilarray = [transpose(counter), transpose(soil)]
soil01 = where(soilarray[0,*] eq 1, count)
soil02 = where(soilarray[0,*] eq 2, count)
soil03 = where(soilarray[0,*] eq 3, count)
soil04 = where(soilarray[0,*] eq 4, count)

layer01 = soil(soil01)
layer02 = soil(soil02)
layer03 = soil(soil03)
layer04 = soil(soil04)


soilarray4 = [transpose(counter), transpose(soil4)]
soil01 = where(soilarray4[0,*] eq 1, count)
soil02 = where(soilarray4[0,*] eq 2, count)
soil03 = where(soilarray4[0,*] eq 3, count)
soil04 = where(soilarray4[0,*] eq 4, count)

layer14 = soil4(soil01)
layer24 = soil4(soil02)
layer34 = soil4(soil03)
layer44 = soil4(soil04)

p1 = plot(layer01, /overplot)
p1 = plot(layer14,'c', /overplot)
