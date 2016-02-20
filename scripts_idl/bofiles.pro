;the purpose of this program is to look at bo's files and see if I actually need to convert them.

ifile=file_search('/raid/sandbox/mcnally/BoFiles4cubes/krmm_20??_01*bil')
nx=400 ;50N:50S
ny=1440
buffer=fltarr(ny,nx)
openr,1,ifile[0]
readu,1,buffer
close,1

p1=image(reverse(buffer,2))
