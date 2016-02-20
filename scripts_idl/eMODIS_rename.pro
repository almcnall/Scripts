pro eMODIS_rename

;the purpose of this script is to rename the emodis dekads that i had f'd up
namedir='/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/'
cd, namedir
onames=file_search('data.*')

wkdir='/jabber/sandbox/mcnally/west_africa_emodis/'
cd, wkdir
ifile=file_search('WA*.img')

nx = 19271
ny = 7874
buffer=fltarr(nx,ny)

for i=0, n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,buffer
  close,1
  
  ofile='WA'+strmid(onames[i],0,14)+'img'
  openw,2,ofile
  writeu,2,buffer
  close,2
endfor;i 

end