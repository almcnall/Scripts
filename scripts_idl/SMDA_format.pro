pro SMDA_format
;the purpose of this script is to make the soil moisture timeseries reable by the lis.
;that means making the values daily and writing them out as a grid the same size as the run domain
;and one file per day with the title e.g. 200401311200.d01.gs4r

;****rebin the 10day soil moisture data into a daily timeseries...
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/VWCWWK1_avg70.csv')
vwc10=read_csv(ifile)
vwcdaily=interpol(vwc10,1461)
;ofile='/jabber/Data/mcnally/AMMASOIL/VWCWWK1_avg70_daily.csv'
;write_csv,ofile,vwcdaily

;create the filenames
startyr = 2005
endyr = 2008
dperm = [31,28,31,30,31,30,31,31,30,31,30,31]
ldperm = [31,29,31,30,31,30,31,31,30,31,30,31]
cnt=0

ofiles=strarr((4*365)+1)
for y=startyr,endyr do begin &$
   for m=1,12 do begin &$
     if y eq endyr then dperm=ldperm &$
      for d=1,dperm[m-1] do begin &$
         ofiles[cnt]=strcompress(string(y)+ STRING(format='(I2.2)', m)+ STRING(format='(I2.2)', d)+'1200.d01.gs4r', /remove_all)  &$
         cnt++  &$
      endfor  &$;d
   endfor  &$;m
endfor;y 
  
;what is the size of the run domain? 13 to 14N, 1.5 to 3E @10km +1 pixel for good luck?
nx=16
ny=11
outarray=fltarr(nx,ny)

for i=0,n_elements(vwcdaily)-1 do begin  &$
  outarray[*,*]=vwcdaily[i]  &$
  byteorder,outarray,/XDRTOF   &$
  ofile=ofiles[i]  &$
  ;are the units correct? kg/m2/s?
  
  openw,1,'/jabber/Data/mcnally/AMMASOIL/DAWK1/'+ofile  &$
  writeu,1,outarray  &$
  close,1  &$
endfor

;how does my estimated compare to the daily?
;is is off by 0.4cm which looks like a lot on the plot, but might not be that bad...(my estimates are low bias)
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/WK1_2/WK2_field108_70cm_completeTS.dat')
;FLOAT = Array[5, 70080]
idat=fltarr(7,70080)
openr,1,ifile
readu,1,idat
close,1

VWC=-0.0663-0.0063*idat[6,*]+0.0007*idat[6,*]^2
VWC=congrid(VWC,n_elements(vwcdaily))

;check out the lis test case example:
;looks like the units mm are ok.
;tfile=file_search('/jabber/sandbox/mcnally/input/dainput/SynSM/*gs4r')
;X=50
;Y=21
;buffer=fltarr(X,Y)
;
;openr,1,tfile[0]
;readu,1,buffer
;close,1
;byteorder,buffer,/XDRTOF
;byteorder,outarray,/XDRTOF
;
;good=where(buffer gt -1.0, count)


  
