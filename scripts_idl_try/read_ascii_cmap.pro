pro read_ascii_cmap
;
;this script reads the monthly cmap data that is in ascii txt. 
;Each file is 12 months, from 88.75N-S and 1.25E-W
;output files are binary, float 144x72x12, reversed (to open in envi) and shifted to 180E-180
;AM 5/10/2011
;
;description of the data from CMAP_monthlyReadme.txt

;    1)  content:
;        kyr    ==  year  ( 79 - 99 - 00 - 09 )
;        kmn    ==  month (1 - 12)
;        rlat   ==  latitude  (-88.75 --> 88.75)
;        rlon   ==  longitude (eastward from 1.25 E)
;        rain1  ==  monthly precipitation by merging
;                   gauge, 5 kinds of satellite estimates
;                   (GPI,OPI,SSM/I scattering, SSM/I emission and
;                    MSU) and numerical model predictions
;                    (mm/day)
;        error1 ==  estimates of relative error for
;                   rain1 (%)
;        rain2  ==  monthly precipitation by merging
;                   gauge and the 5  kinds of satellite estimates
;                   (mm/day)
;        error2 ==  estimates of relative error for
;                   rain2 (%)
;
;    2)  coverage:
;        -88.75S -- 88.75N; 1.25E -> Eastward -> 1.25W
;        cmap_mon_v0411_yy.txt --> January  - December of the year 19yy
;
;    3)  resolution:
;        2.5 deg lat x 2.5 deg lon
;        monthly
;
;    4)  missing values
;        -999.0
;___________________________________________________________________________________________________

indir=strcompress('/jabber/LIS/Data/CPCOriginalCMAP/', /remove_all)
odir=strcompress('/jabber/LIS/Data/reshapeCMAP/', /remove_all)
file_mkdir, odir

cd, indir
y = ['00','01', '02', '03', '04', '05', '06', '07', '08', '09','10']
mo= ['jan','feb','mar','apr','may','jun','jul','aug','spt','oct','nov','dec']
;declare variable arrays

nx=144.
ny=72.
bands=12.
globe=fltarr(nx,ny,bands)

ff=file_search('cmap_mon*.txt')

  for i=0,n_elements(y)-1 do begin ;file/year loop
    ;ff=file_search(strcompress('*'+y[i]+'.txt')) ;file name/yr
    
    valid = query_ascii(ff[i],info) ;checks compatability with read_ascii
    line = info.lines ;I think that this check n_elements in array
  
    yrs=intarr(line)   &   mos=intarr(line)   &   lats=fltarr(line)   &   lons = fltarr(line)
    rain1s = fltarr(line)   &   error1s=fltarr(line)   &   rain2s=fltarr(line)  &   error2s=fltarr(line)
  
    openr,1,ff[i]
    ;intialize varaibles
     yr=0 & mo=0 & lat=0. & lon=0. & rain1=0. & rain2=0.
  
    for k=0,line[0]-1 do begin
      readf,1,yr, mo, lat, lon, rain1, error1, rain2, error2
      yrs(k) = yr   &   mos(k)= mo   &   lats(k) = lat   &   lons(k) = lon   &   rain1s(k)=rain1   &   rain2s(k)=rain2
    endfor ;k
    close,1
  
    rain1_array=reform(rain1s,nx,ny,bands)
    rain2_array=reform(rain2s,nx,ny,bands)
  
    globe1=[rain1_array(72:143,0:71,*),rain1_array(0:71,0:71,*)] ;shift to 180E-180W, not 0E-0W
    ;globe1[*,*,*] = REVERSE(globe1[*,*,*],2) ;flip so I can open in envi
  
    globe2=[rain2_array(72:143,0:71,*),rain2_array(0:71,0:71,*)] ;shift to 180E-180W, not 0E-0W
    ;globe2[*,*,*] = REVERSE(globe2[*,*,*],2) ;flip so I can open in envi

  
  outfile1=strcompress(odir+strmid(ff[i],0,17)+'_R1.img', /remove_all)
  outfile2=strcompress(odir+strmid(ff[i],0,17)+'_R2.img', /remove_all)
  
  ;write rain1 -- satellite, gauge and model rainfall estiamte (mm/day)
  openw,2,outfile1
  writeu,2,globe1
  close,2
  
  ;write rain2 -- satellite and gauge rainfall estimte (mm/day)
  openw,3,outfile2
  writeu,3,globe2
  close,3
  
  
endfor;i
  
end
