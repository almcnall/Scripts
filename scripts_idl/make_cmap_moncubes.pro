pro make_cmap_moncubes  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this script is to cat the monthly total/averge for a specific variable into a monthly cube.
; I don't think that this is a real script AM 5/11/11
;;*************************************************************************
  
indir = strcompress("/jabber/LIS/Data/reshapeCMAP/R1/",/remove_all)
outdir = strcompress("/jabber/LIS/Data/reshapeCMAP/moncube/", /remove_all)

file_mkdir, outdir
cd, indir

ifile1=file_search('*_R1.img')

nx = 144
ny = 72
nbands = 12

yrs    = ['00','01', '02', '03', '04', '05', '06', '07', '08', '09']
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]

buffer=fltarr(nx,ny,n_elements(months))
datain=fltarr(nx,ny,n_elements(yrs))


for i=0,n_elements(months)-1 do begin
 for j=0, n_elements(yrs)-1 do begin
    openr,1,ifile1[j]
    readu,1,buffer
    datain[*,*,j]=buffer[*,*,i]
    close,/all
  endfor
  
  ofile=strcompress(outdir+'cmap'+months[i]+'.img')
  openw,2,ofile
  writeu,2,datain
  close,2
endfor

end
