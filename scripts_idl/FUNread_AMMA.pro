function FUNread_AMMA, fname ;names of vars coming in (ARGUMENTS)

;the purpose of this function is to read in data and return rainfall 
;data of interest, along with its lat lon, date, xycords
;not sure when here I am using this but it looked like a good idea.
;note on 4/9/2012
;this function would be fine if all the data collected the same type of rainfall BUT
;e.g. 143 collects hourly rainfall (in column X) and 132 collects 5min rainfall (in column Y)

valid= query_ascii(fname,info) ;checks compatability with read_ascii

myTemplate = ASCII_TEMPLATE(fname); go to line 100.
rain = read_ascii(fname, delimiter=';' ,template=myTemplate)

pramnt  = rain.FIELD11 ;make sure that this matches!
datetime  = rain.FIELD01 ; date i need to fill in this vector
  yr = fix(strmid(datetime,0,4))
  mo = fix(strmid(datetime,5,2))
  dy = fix(strmid(datetime,8,2))

lat = rain.FIELD02 ; latitude 
lon = rain.FIELD03 ; longitude

x = reform(lon+19.95)*10; becasue it is -29.95w and (2.5*20 = 50pixels) that is .05 off of 20 which should be the center of the pixel.
y = reform(lat+39.95)*10

data =[transpose(yr),transpose(mo), transpose(dy), transpose(lat), $
        transpose(lon), transpose(pramnt),transpose(x), transpose(y)]

return,data

end