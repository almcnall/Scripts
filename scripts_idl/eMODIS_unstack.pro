pro eMODIS_unstack

;the purpose of this script is to unstack the yearly emodis dat back into individual dekad files (so that i don't kill the computer again)
namedir='/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/'
cd, namedir
onames=file_search('data.{2002,2003,2004,2005,2006,2007,2008}*')

wkdir='/jabber/sandbox/mcnally/west_africa_emodis/'
cd, wkdir
ifile=file_search('WA????.img')

nx = 19271
ny = 7874
ibands = 36
obands = 1

buffer=fltarr(nx,ny,ibands)
count=0
for i=0, n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,buffer
  close,1
  for j=0, ibands-1 do begin
    odata=buffer[*,*,j]
    ofile='WA'+onames[count]+'.img'
    openw,2,ofile
    writeu,2,odata
    close,2
    odata=0 ;free the odata variable
    count++ ;this was in the wrong spot before and f'd up my filenames...2001-2008
  endfor;j
endfor;i 

end