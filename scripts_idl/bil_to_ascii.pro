pro bil_to_ascii
;not sure where this script came from but I'll try to modify it to convert .bil to .img
;I think this was a crappy attempt back when I thought I had to convert .bil to ascii for soni

year    = string(2009); don't think that this is right...
month   = string(11)
day     = string(11)
file_yr = strmid(year,1,3,/reverse_offset) ;extracts the two digit yr.

nx = 360
ny = 181

wdir = strcompress("/jower/LIS/Data/PET.BIL/pet_"+year+month+"/",/remove_all)
print,wdir
cd,wdir 

in_bil    = strcompress("et"+file_yr+month+day+".bil",/remove_all)
out_ascii = strcompress("et"+file_yr+month+day+".csv",/remove_all)

RefPET = uintarr(nx,ny) ; EROS RefET are unsigned positive integer

openr,1,in_bil        ; opens .bil file for reading
readu,1,RefPET        ; reads .bil file to variable
close,1

file_mkdir,"/jower/LIS/Data/PET.BIL/pet.ascii"
cd, '../pet.ascii'
openw, 2, out_ascii ; 
printf,2, RefPET

close,2
end





