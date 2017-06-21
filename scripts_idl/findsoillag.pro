pro findsoillag

;the purpose of this script is to find what lag works best for the different soil moisture values. Use the 90 day table for
;each of the different days. Different days should show different depths.open up the datefile so that I know 
;where/when I can in the 0-70 array of dates 2005-2008

;dfile=file_search('/jabber/Data/mcnally/AMMASOIL/smdates4rainlag.dat') ;millet site
dfile=file_search('/jabber/Data/mcnally/AMMASOIL/smdates4rainlag_fallow.dat')

;sdate=intarr(5,71);yr.m.day.hr,doy for millet
sdate=intarr(5,68);yr.m.day.hr,doy for fallow

openr,1,dfile
readu,1,sdate
close,1

;find SM files 
ifile=file_search('/jabber/Data/mcnally/AMMASOIL/*_cube.dat')
i=0; for fallow and i=1 for millet

nx=10 ;(11 millet)n sites where SM was recorded
ny=29; (17 millet)n depths when SM was recorded
nz=68; (71 millet)n dates where SM was recorded

;nx=11 ;(11 millet)n sites where SM was recorded
;ny=17; (17 millet)n depths when SM was recorded
;nz=71; (71 millet)n dates where SM was recorded

;are there actually 29 depths for the fallow sites??
sbuffer=fltarr(nx,ny,nz)

;for i=0,n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,sbuffer
  close,1

xr=90 ;x-rain (cols)
yr=68 ;y-rain (rows)

rbuffer=fltarr(xr,yr)
;open the 90 x 71/68 rainfall array
ifile=file_search('/jabber/Data/mcnally/AMMARain/rain4soil/raincum4soil_fallow.dat')
openr,1,ifile
readu,1,rbuffer
close, 1

;ok, i have dates and rainfall values and soil values
;what is the relationship between soil moisture at 40cm and previous 30 day rainfall at site1?

;lets just cut this off at 2.4 meters shall we?
mdepths=[-40, -65, -90, -140,  -190,  -240];,  -340,  -440,  -540,  -640,  -740,  -840,  -940,  -1030, -1040, -1115, -1140]

;site=4
corr=fltarr(nx,n_elements(mdepths),n_elements(rbuffer[*,0]))
;just checking out one site and one depth at all different cummulative times.
for s=0,nx-1 do begin ;this is the number of sites...there are 11 for millet and 10 for fallow. 
  for d=0,n_elements(mdepths)-1 do begin &$
    for l=0,n_elements(rbuffer[*,0])-1 do begin &$;for each nlag from 0 to 90
      table=[reform(sbuffer[s,d,*],1,yr), rbuffer[89-l,*] ] &$
      good=where(finite(table[0,*]), count) &$
      table=table[*,good] &$
      corr[s,d,l]=correlate(table[0,*], table[1,*]) &$
    endfor &$
  endfor
endfor

maxcorr=intarr(nx,n_elements(mdepths))
;check out where the actual peak is. I am not sure if this will do what I want it to do...
for s=0,nx-1 do begin
  for i=0,n_elements(corr[0,*,0])-1 do begin &$
   maxcorr[s,i,*]= where(corr[s,i,*] eq max(corr[s,i,*])) &$
  endfor
endfor 

;*****************plots***************************
;****too many too look at for each site (10)******
s=0
p1=plot(corr[s,0,*], 'red')
p2=plot(corr[s,1,*], 'orange', /overplot)
p3=plot(corr[s,2,*], 'green', /overplot)
p4=plot(corr[s,3,*], 'blue', /overplot)
p5=plot(corr[s,4,*], 'purple', /overplot)
p6=plot(corr[s,5,*], 'black', /overplot, title='soil moisture and cumulative precip at site'+string(s), $
        xtitle='n days cumulative precip', ytitle='correlation')

p1.name = string(mdepths[0]) + ' cm '
p2.name = string(mdepths[1]) + ' cm '
p3.name = string(mdepths[2]) + ' cm '
p4.name = string(mdepths[3]) + ' cm '
p5.name = string(mdepths[4]) + ' cm '
p6.name = string(mdepths[5]) + ' cm '

!null = legend(target=[p1,p2,p3,p4,p5,p6], position=[0.2,0.3]) 



print, 'hold here'
end
