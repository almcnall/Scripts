;this script is just scraps that helped me check the post processing for EXA40
;this is just the spinup run but since it is now daily outputs we are elimating
;a whole silly step of agregating from three hourly. 
;now I think that all the main post processing can be done with the (1) bash script that generates the "run_daily_EXP" and then the flip-af_gs4r_sahel.pro i clip off the two bad bytes, swap the byte order and make sure the orientation is happy - for IDL not ENVI
;there will have to be a second script for parsing out the variables of interest, and 
;getting the units nice (and then aggregating them to dekads or whatever. 
ifile = file_search('/jabber/LIS/OUTPUT/EXPA40/RootMoist.txt')
root = read_csv(ifile)
root = float(root.field1)
temp = plot(root)

ifile = file_search('/jabber/LIS/OUTPUT/EXPA41/RootMoist.txt')
root = read_csv(ifile)
root = float(root.field1)
temp = plot(root, /overplot,'b')

ifile = file_search('/jabber/LIS/OUTPUT/EXPA42/RootMoist.txt')
root = read_csv(ifile)
root = float(root.field1)
temp = plot(root,/overplot,'c')

ifile = file_search('/jabber/LIS/OUTPUT/EXPA43/RootMoist.txt')
root = read_csv(ifile)
root = float(root.field1)
temp = plot(root,/overplot,'m')

ifile = file_search('/jabber/LIS/OUTPUT/EXPA44/RootMoist.txt')
root2 = read_csv(ifile)
root2 = float(root2.field1)
temp = plot(root2,'g')

ifile = file_search('/jabber/LIS/OUTPUT/EXPA4b/RootMoist.txt')
root = read_csv(ifile)
root = float(root.field1)
temp = plot(root,/overplot,'black')




ifile = file_search('/jabber/LIS/OUTPUT/EXPA40/NOAH271/2001/20011229/200112290000.d01.gs4r')

direction = 2 ;files are upsidedown
nx     = long(720)
ny     = long(350)
nyuk   = 2.
nbands = 3

data_in  = fltarr((nx*ny)+nyuk,nbands) ;one long vector for each variable.
data_out = fltarr(nx   ,ny    ,nbands)

  i = 0
  ; open up file and read unformatted into 'data_in'
  openr,1, ifile
  readu,1,data_in
  close,1
  byteorder,data_in,/XDRTOF
  
  ; start J FOR loop to cycle through bands and flip them upside down
  for j=0,nbands-1 do begin &$
    ;tmp = data_in[0:(nx*ny)-1,j]
    tmp = data_in[1:(nx*ny),j] &$ ;this changed on 3/8/12...I hope that this works!
    
    tmp = reform(tmp,nx,ny) &$ 
    data_out[*,*,j] = tmp &$ 
    ;data_out[*,*,j] = REVERSE(data_out[*,*,j],direction) &$ 
  endfor ; close J FOR loop
  
  ;test plot
nx = 720
ny = 350

ingrid = fltarr(nx,ny,3)
ifile = file_search('/jabber/LIS/OUTPUT/EXPA40/postprocess/2001*')
Tair = fltarr(nx,ny,n_elements(ifile))
Root = fltarr(nx,ny,n_elements(ifile))

for i = 0, n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
 
  Tair[*,*,i] = ingrid[*,*,0] &$
  Root[*,*,i] = ingrid[*,*,2] &$
endfor
  
temp = image(Tair[*,*,0], rgb_table=4)
temp = image(Root[*,*,0], rgb_table=4)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
;check out the time series for Niger
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

p1 = plot(Root[xind,yind,*], thick = 3)
p1 = plot(Tair[xind,yind,*], thick = 3)
