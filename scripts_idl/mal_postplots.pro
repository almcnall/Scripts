PRO mal_postplots
;this script is the sequence of commands that plot my data.
;the .run trick seems to hang up in idl8 (although it works in idl7)
;soo...it works to compile the 'procedure' then use the break points....
;
;run the data processing function
;allStroot = mal_postprocess() 
;allumdveg = mal_postprocess()
alldyncrp = mal_postprocess()
;call the plotting procedure
;this should accept the arguments from mal_postprocess and plot them.

;**********plot stuff*************
;map
;tv,alldata[*,*,0,0]
;********************************
x1=1 & y1=1
var = ['sm01', 'sm02', 'sm03', 'sm04', 'tair', 'root', 'rain', 'PoET', 'evap']
yr =[2001,2002,2003,2004,2005,2006,2007,2008]
mo =['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']

spaceavg = fltarr(n_elements(var),n_elements(yr),n_elements(mo))
yravg = fltarr(n_elements(var),n_elements(mo))
stmm = fltarr(n_elements(var), n_elements(mo))
anom = fltarr(n_elements(var),n_elements(yr),n_elements(mo))

for v=0,n_elements(var)-1 do begin
  for t=0,n_elements(yr)-1 do begin
    for m=0,n_elements(mo)-1 do begin
    ;eak change this too with experiment anme
      ;spaceavg[v,t,m]= mean(allStroot(*,*,t,m,v), /nan)
      ;spaceavg[v,t,m]= mean(allumdveg(*,*,t,m,v), /nan)
      spaceavg[v,t,m]= mean(alldyncrp(*,*,t,m,v), /nan)
    endfor;m
  endfor;t
endfor ;v
;**********************************************************************
;for vv=0,n_elements(var)-1 do begin
;  for mm=0,n_elements(mo)-1 do begin
;     yravg[vv,mm]= mean(allrfe2umd(*,*,*,mm,vv), /nan)
;    endfor;m
;endfor ;vv
;
;or, same thing ops
;;short term monthly mean so that I can show anamolies
for a =0, n_elements(var)-1 do begin
  for b=0,n_elements(mo)-1 do begin
    stmm[a,b] = mean(spaceavg[a,*,b], /nan)
  endfor;b 
endfor;a

;************************************************************************
for a=0, n_elements(var)-1 do begin
; a=6
;  ;for b=0,n_elements(mo)-1 do begin
;  ;p1 = plot(yr,spaceavg[a,*,0], view_title = 'static root time series by month '+var[a], ytitle=var[a])
;  p1 = plot(yr,spaceavg[a,*,0], view_title = 'umdveg time series by month '+var[a], ytitle=var[a])
;  
;  p2 = plot(yr, spaceavg[a,*,1],color='purple', /overplot)
;  p3 = plot(yr, spaceavg[a,*,2],color='green', /overplot)
;  p4 = plot(yr, spaceavg[a,*,3],color='red', /overplot)
;  p5 = plot(yr, spaceavg[a,*,4],color='cyan', /overplot)
;
;;;add a legend
;  p1.name = mo[0]
;  p2.name = mo[1]
;  p3.name = mo[2]
;  p4.name = mo[3]
;  p5.name = mo[4] 
;  ;p12.name = 'aprs'    
;  !null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3]) ; how do i move this up?

;shows the annual time series...var,year,month
;how do I shift these so that the peak is January?

;p6 = plot(spaceavg[a,0,*], view_title = 'time series- static root', ytitle=var[a], xtickname=mo)
;p7 = plot(spaceavg[a,1,*],color='purple', /overplot)
;p8 = plot(spaceavg[a,2,*],color='green', /overplot)
;p9 = plot(spaceavg[a,3,*],color='red', /overplot)
;p10 = plot(spaceavg[a,4,*],color='cyan', /overplot)
;p11 = plot(spaceavg[a,5,*],color='orange', /overplot)
;p12 = plot(spaceavg[a,6,*],color='yellow', /overplot)

;p6.name = '2001' ;0
;p7.name = '2002' ;1
;p8.name = '2003' ;2
;p9.name = '2004' ;3
;p10.name = '2005' ;4
;p11.name = '2006' ;5
;p12.name = '2007' ;6
    
;!null = legend(target=[p6,p7,p8,p9,p10,p11,p12], position=[0.2,0.5]

;this is for the annual plots of just a bad, good and average(?) year
;a=8
;p9 = plot( [ [[spaceavg[a,3,6:11]]], [[spaceavg[a,4,0:5]]] ], view_title = 'time series- static root', color='orange', $ 
;             ytitle=var[a], xtickname=[mo(6:11), mo(0:5)])
p9 = plot( [ [[spaceavg[a,3,6:11]]], [[spaceavg[a,4,0:5]]] ], view_title = 'time series- dyncrp', color='orange', $ 
             ytitle=var[a], xtickname=[mo(6:11), mo(0:5)])
p10 = plot( [ [[spaceavg[a,4,6:11]]], [[spaceavg[a,5,0:5]]] ], color='blue', /overplot,xtickname=[mo(6:11), mo(0:5)])
p11 = plot( [ [[spaceavg[a,5,6:11]]], [[spaceavg[a,6,0:5]]] ], color='grey', /overplot,xtickname=[mo(6:11), mo(0:5)])

p9.name = '2004-05' ;3
p10.name = '2005-06' ;4
p11.name = '2006-07' ;5

!null = legend(target=[p9,p10,p11], position=[0.2,0.55]) 

endfor
;********************************************************
;I think that this one would be better as anomolies, to get rid of seasonal cycle...
; if space average is var,year,month I want a 9,1,12 array that is the average 
; but then I have to say for each year subtract the vector....

for a=0,n_elements(vars)-1 do begin
  for c=0,n_elements(yr)-1 do begin
   anom= spaceavg[a,c,*]-stmm[a,*]
  endfor
endfor

  
;null = legend(target=[p9,p10,p11,p12], position=[0.2,0.3]) ; not sure how this line works...
END

