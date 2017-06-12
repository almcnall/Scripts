function mal_postprocess
; the purpose of this program is to deal with all of soni's output
; however, when I changed from umd to dyn crop something in the processing
; got whacked. 

;exp = 'RFE2_StaticRoot'
;out = 'RFE2StaticRoot'
;expdir = 'EXPORS'

;exp = 'RFE2_UMDVeg'
;out = 'RFE2UMDVeg'
;expdir = 'EXPORU'

exp = 'RFE2_DynCrop'
out = 'RFE2DynCrop'
expdir = 'EXPORC'

indir = strcompress('/gibber/lis_data/'+exp+'/output/'+expdir+'/NOAH32/monthcube_'+exp, /remove_all)
;odir = strcompress('/gibber/lis_data/'+exp+'/output/'+expdir+'/NOAH32/postprocess/', /remove_all)
                    ;/gibber/lis_data/RFE2_DynCrop/output/EXPORC/NOAH32/postprocess
;file_mkdir, odir

var = ['sm01', 'sm02', 'sm03', 'sm04', 'tair', 'root', 'rain', 'PoET', 'evap']
yr = [2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008]
dmo = ['05','06','07','08']

nx     = 31.
ny     = 77.
nbands = n_elements(yr) ; 8 yrs of jan and (which?), 7 yrs of others (which?)

short = fltarr(nx,ny,nbands-1)
pad = fltarr(nx,ny,1)
pad[*,*,*] = !VALUES.F_NAN
idata = fltarr(nx,ny,nbands)

;be sure to change these depending on experiment
;allStroot = fltarr(nx,ny,nbands,12,n_elements(var));
;allStroot[*,*,*,*,*] = !VALUES.F_NAN

;allumdveg = fltarr(nx,ny,nbands,12,n_elements(var));
;allumdveg[*,*,*,*,*] = !VALUES.F_NAN

alldyncrp = fltarr(nx,ny,nbands,12,n_elements(var));
alldyncrp[*,*,*,*,*] = !VALUES.F_NAN

cd, indir
shortfile = file_search('????{05,06,07,08,09,10,11,12}*.img')

;;******************************************
;for i=0,n_elements(shortfile)-1 do begin
;  openu,1,shortfile[i]
;  readu,1,short
;  close, 1
;  
;  fixed = [ [[short]], [[pad]] ] ; ;add and extra band so that there are 8.
;  
;  openw,2,shortfile[i] ;re-write instead of overwrite?
;  writeu,2,fixed 
;  close,2
;endfor
;*****************************************
;put all the data into one cube so I can use one var for all plots
;cd, odir

for i= 0, n_elements(var)-1 do begin
  ;i=0
  ifile = file_search(var[i]+'*.img')
  for j=0,n_elements(ifile)-1 do begin ;is this a var for every yr or every month
    openu,1, ifile[j]
    readu,1,idata
    close,1
    ;be sure to change this for each experiment...
;    allStroot[*,*,*,j,i] = idata
    ;allumdveg[*,*,*,j,i] = idata
    alldyncrp[*,*,*,j,i] = idata
  endfor; j
endfor;i

;return, allStroot
;return, allumdveg
return, alldyncrp
END
