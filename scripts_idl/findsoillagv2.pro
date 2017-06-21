pro findsoillagv2

;the purpose of this script is to find what lag works best for the different VOLUME 
;soil moisture values found in the 110files. Use the 90 day table for each of the different days. 
;[version 1 is for the neutron probe measurements].
;since these are both almost continuous i could probably do a cross correlation...I would have to fillin missing dates.

;dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_millet_110dates.dat') ;millet site
dfile=file_search('/jabber/Data/mcnally/AMMASOIL/wankama_fallow_110dates.dat')

;sdate=intarr(4,469); (millet)yr.m.day,doy 
sdate=intarr(4,493);(fallow)yr.m.day,doy

;2005 is 0:165
openr,1,dfile
readu,1,sdate ;ops looks like I am missing 2005-12-31...
close,1

;find SM files 
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/*_cube110.dat')
i=0; for fallow and i=1 for millet

nx=6 ; I think that there are 6 for both millet110 and fallow110
ny=469; (469 millet)n depths when SM was recorded

sbuffer=fltarr(nx,ny)
;for i=0,n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,sbuffer
  close,1

;***************check out the soil data*************************
;what are my depths?
mdepths=[-10,-50,-100,-150,-200,-250]
slope=(sbuffer[0,*]-sbuffer[1,*])/(50-10)
y=intarr(n_elements(slope))
;silly plots
test=plot(slope[0:165])
test=plot(y[0:165], /overplot, thick=6, title='Fallow 2005:surface (10cm) vs depth wetness (50cm)', ytitle='slope', xtitle='day 0=june 16,2005')

;begining/end of wet/dry spells for fallow2005
d=[13,35,39,40,48,49,59,69,77,86,87,95,130]

p1=plot(sbuffer[*,d[0]], mdepths, 'r');july 4
p2=plot(sbuffer[*,d[1]], mdepths, 'orange', /overplot);july 26
p3=plot(sbuffer[*,d[2]], mdepths, 'green', /overplot);july 30
p4=plot(sbuffer[*,d[3]], mdepths, 'b', /overplot);aug1
p5=plot(sbuffer[*,d[4]], mdepths, 'c', /overplot);aug9
p6=plot(sbuffer[*,d[5]], mdepths, 'm', /overplot);aug12
p7=plot(sbuffer[*,d[6]], mdepths, 'b', /overplot);aug22
p8=plot(sbuffer[*,d[7]], mdepths, 'black', /overplot);sept2
;skip rains sept2-4, dry 5-7, wet 8-10
p9=plot(sbuffer[*,d[8]], mdepths, '.-r', /overplot);sept10
p10=plot(sbuffer[*,d[9]], mdepths, 'orange', linestyle=2, /overplot);sept19
p11=plot(sbuffer[*,d[10]], mdepths, 'green', linestyle=2, /overplot);sept20 
p12=plot(sbuffer[*,d[11]], mdepths, 'blue', linestyle=2, /overplot);sept28 last rain
p13=plot(sbuffer[*,d[12]], mdepths, 'm', linestyle=2, /overplot, $
         title='begining/end of wet/dry spells Fallow 2005', xtitle='soil moisture (mm)',$
         ytitle='depth(cm)');sept28 last rain
p1.name = strcompress(strjoin(sdate[0:2,d[0]]))
p2.name = strcompress(strjoin(sdate[0:2,d[1]]))
p3.name = strcompress(strjoin(sdate[0:2,d[2]]))
p4.name = strcompress(strjoin(sdate[0:2,d[3]]))
p5.name = strcompress(strjoin(sdate[0:2,d[4]]))
p6.name = strcompress(strjoin(sdate[0:2,d[5]]))
p7.name = strcompress(strjoin(sdate[0:2,d[6]]))
p8.name = strcompress(strjoin(sdate[0:2,d[7]]))
p9.name = strcompress(strjoin(sdate[0:2,d[8]]))
p10.name = strcompress(strjoin(sdate[0:2,d[9]]))
p11.name = strcompress(strjoin(sdate[0:2,d[10]]))
p12.name = strcompress(strjoin(sdate[0:2,d[11]]))
p13.name = strcompress(strjoin(sdate[0:2,d[12]]))

!null = legend(target=[p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13], position=[0.2,0.3]) 
;**********************************************
;what is the size of my rainarray?
xr=90;x-rain (cols)
yr=ny ;y-rain (rows)

rbuffer=fltarr(xr,yr)
;open the 90 x 71/68 rainfall array
;ifile=file_search('/jabber/Data/mcnally/AMMARain/rain4soil/raincum4soil_fallow110.dat')
ifile=file_search('/jabber/Data/mcnally/AMMARain/rain4soil/raincum4soil_millet110.dat')
openr,1,ifile
readu,1,rbuffer
close, 1

;site=4
corr=fltarr(n_elements(mdepths),n_elements(rbuffer[*,0]))
;just checking out one site and one depth at all different cummulative times.
  for d=0,n_elements(mdepths)-1 do begin &$
    for l=0,n_elements(rbuffer[*,0])-1 do begin &$;for each nlag from 0 to 90
      table=[reform(sbuffer[d,*],1,yr), rbuffer[89-l,*] ] &$
      good=where(finite(table[0,*]), count) &$
      table=table[*,good] &$
      corr[d,l]=correlate(table[0,*], table[1,*]) &$
    endfor &$
  endfor


maxcorr=intarr(n_elements(mdepths))
;check out where the actual peak is. I am not sure if this will do what I want it to do...
  for i=0,n_elements(corr[*,0])-1 do begin &$
   maxcorr[i]= where(corr[i,*] eq max(corr[i,*])) &$
  endfor

print, 'hold here'


;*****************plots***************************
;****too many too look at for each site (10)******

;p1=plot(corr[0,*], 'red')
;p2=plot(corr[1,*], 'orange', /overplot)
;p3=plot(corr[2,*], 'green', /overplot)
;p4=plot(corr[3,*], 'blue', /overplot)
;p5=plot(corr[4,*], 'purple', /overplot)
;p6=plot(corr[5,*], 'black', /overplot, title='soil moisture and cumulative precip at millet site', $
;        xtitle='n days cumulative precip', ytitle='correlation')
;
;p1.name = string(mdepths[0]) + ' cm '
;p2.name = string(mdepths[1]) + ' cm '
;p3.name = string(mdepths[2]) + ' cm '
;p4.name = string(mdepths[3]) + ' cm '
;p5.name = string(mdepths[4]) + ' cm '
;p6.name = string(mdepths[5]) + ' cm '
;
;!null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3]) 

end
