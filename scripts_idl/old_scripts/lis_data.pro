pro lis_data
; this file was an attemp at reading the grib files before I was remined that they are grib, duh.

wdir = strcompress("/home/mcnally/Desktop/input/FORCING/GDAS/200210",/remove_all)
print,wdir
cd,wdir 

nx = 1000
ny = 1000
nz = 24

in_gdas = string('2002102818.gdas1.sfluxgrbf06.sg') 

openr,1,in_gdas        ; opens .sflux file for reading
forcing_data = fltarr(nx,ny,nz) ; this makes a lot of rows and cols and 23 values for each forcing var. 
temp = fltarr(24)

FOR i=0,999 DO BEGIN 
    FOR j = 0,999 DO BEGIN 
      READF,1,temp;read a line of data
      PRINT, temp    ; print the line
      forcing_data[i,j,*] = temp ;store it in forcing_data
    ENDFOR
ENDFOR

close,1
END
