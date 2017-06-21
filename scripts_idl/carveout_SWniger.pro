pro carveout_SWniger  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this program is to generate maps of the LIS output variable
; specifically for south west niger to match up with my hyperion scenes. 
; the area of interest (AOI) and range for the map_continents will need to be changed
; depending on the domain of interest.
; I don't think that the code got finished... AM 3/21/11
; Also change the experiement code....
; AM 9/16/10
;*************************************************************************
device,decomposed=0

expdir = 'EXP027' 
  ;if expdir eq 'EXP027' then data='ubRFE2'
  
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/monthcubie/", /remove_all)
outdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/SWniger/", /remove_all)
file_mkdir,outdir

cd, indir

;file_w   = file_search('*{09,10,11,12,01,02,03,04}.img');no spaces! this had not been fixed when I started dinking...
;file_d  = file_search('*{05,06,07,08}.img') ; so I think I might have to have these separate because the file sizes are different.
file = file_search('*.img')

vars = strarr(10); length = 9
vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4', 'PoET'] 

;vars = strarr(1); length = 9
;vars= ['PoET'] 
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]

nx     = 301.
ny     = 321.
outx   = 2.
outy   = 4.

nbands = 5. ;wet season
;nbands_d = 4. ;dry season...I should run for full years for this reason alone, maybe the last one can just be empty...

;allocate arrays
ingrid      = fltarr(nx,ny,nbands) ;initializes the array 
;ingrid_d    = fltarr(nx,ny,nbands_d)
AOI         = fltarr(outx,outy,nbands)
all_aoi     = fltarr(n_elements(vars))
mean_SWNig  = fltarr(nbands,8,n_elements(vars))
ofile_SWNig = strarr(n_elements(file))

;file names and dealing with different length variable names...next time make all strings same length.
for d=0, n_elements(file)-1 do begin;; this loop is for the months but is all the files in a year...
     
     if (strmid(file[d],0,4) eq 'evap') OR (strmid(file[d],0,4) eq 'Qsub') OR (strmid(file[d],0,4) eq 'rain') OR (strmid(file[d],0,4) eq 'PoET')then begin
     ofile_SWNig(d) = Outdir+strmid(file[d],0,7)+"_SWNig.img"
     endif else begin
     ofile_SWNig(d) = Outdir+strmid(file[d],0,9)+"_SWNig.img"
     endelse
     
end

count=0 ;counts 8 months (wet season) per variable 
z=0     ;after 8mo. varible changes and is writen as new dimension
FOR j = 0,n_elements(file)-1 do begin
  
  openr,1,indir+file[j]     ;opens the file
  readu,1,ingrid           ;reads it into ingrid  
  close,1
 
  ;mve,ingrid_w                 ;print out the max min mean and std deviation of var
  rgrid = reverse(ingrid,2)  ;IDL reads from bottom to top, this reverses rows (2) to plot
  AOI[*,*,*] = reverse(rgrid(87:88,109:112,*),2) ; I shouldn't have to do this twice but it works for now.
  openw,2,ofile_SWNig[j] & writeu,2,AOI  
  close,2 
    
    for k=0,nbands-1 do begin
     
     mean_SWNig[k,count,z]=mean(AOI[*,*,k],/NAN); 
     ;all_aoi[k,j]=mean_SMal   
    endfor;k
  count=count+1
  if count eq 8 then z=z+1
  if count eq 8 then count=0 
  if z lt 9 then print, 'variable ='+vars[z] ;allows for graceful exit
 endfor;j 

;-----------------plots------------------------
;data defined above
;use xtickname=['jan','feb','mar'] for named catagories. 
;
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4']
;water balance = P-evap-Qsub-runoff+soilm1+soilm2
month=3
precip=mean_SWNig[*,month,3]
evapor=mean_SWNig[*,month,2]
runof2=mean_SWNig[*,month,0]
runof1=mean_SWNig[*,month,4]

balance = precip-evapor-runof1-runof2
print, balance

;_________________________
rain=3
aet=2
;mean_SMal[years 2003-2007, month (jan-apr), variable
months=['jan','feb','mar','apr']
p05 = barplot(mean_SMal[2,0:3,rain], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xtitle = '2005', $
         xminor=0, $
         xrange=[0, 4])
evapor=plot(mean_SWNig[2,0:3,aet], /OVERPLOT)
;_________________________
years=strarr(nbands)
years=[2003,2004,2005,2006,2007]

v=0 ;v for variable!
;mean_SMal[years 2003-2007, month (jan-apr), variable
p1 = barplot(years,mean_SWNig[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5])
p2 = barplot(years, mean_SWNig[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p3 = barplot(years, mean_SWNig[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p4 = barplot(years, mean_SWNig[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)
;add a legend
p1.name = 'jans'
p2.name = 'febs' 
p3.name = 'mars' 
p4.name = 'aprs'    
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) ; not sure how this line works...
;____________________________________________________________
v=1 ;v1=airtemp
p5 = barplot(years,mean_SWNig[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5], $
         yrange=[20, 25])
p6 = barplot(years, mean_SWNig[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p7 = barplot(years, mean_SWNig[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p8 = barplot(years, mean_SWNig[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)
;add a legend
p5.name = 'jans'
p6.name = 'febs' 
p7.name = 'mars' 
p8.name = 'aprs'    
!null = legend(target=[p5,p6,p7,p8], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
v=2 ;v2=evap
p9 = plot(years,mean_SWNig[*,0,v], $
         nbars=4, $
         index=0, $
         color='cyan', $
         thick=2, $
         view_title = vars[v], $
         ytitle = vars[v]+'[AET] (mm)',$
         xminor=0, $
         xrange=[2003, 2007])
p10 = plot(years, mean_SWNig[*,1,v],index=1,nbars=4, color='purple', /OVERPLOT)
p11 = plot(years, mean_SWNig[*,2,v],index=2,nbars=4, color='grey', /OVERPLOT)
p12 = plot(years, mean_SWNig[*,3,v],index=3,nbars=4, color='blue', /OVERPLOT)
;add a legend
p9.name = 'jans'
p10.name = 'febs' 
p11.name = 'mars' 
p12.name = 'aprs'    
!null = legend(target=[p9,p10,p11,p12], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4']
v=3 ;v3=rain
p13 = barplot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5])
p14 = barplot(years, mean_SMal[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p15 = barplot(years, mean_SMal[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p16 = barplot(years, mean_SMal[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)
;add a legend
p13.name = 'jans'
p14.name = 'febs' 
p15.name = 'mars' 
p16.name = 'aprs'    
!null = legend(target=[p13,p14,p15,p16], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
;bar plot of PET....I am concerned that it is lower in 2005...why has this changed from EXP025?
;;has it changed or was I just looking at Mike Marshall's?
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4', 'PoET']
v=9 ;v9=PoET
p29 = barplot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         yrange=[200,400],$
         xminor=0, $
         xrange=[2002.5, 2007.5])
p30 = barplot(years, mean_SMal[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p31 = barplot(years, mean_SMal[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p32 = barplot(years, mean_SMal[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)

;add a legend
p29.name = 'jans'
p30.name = 'febs' 
p31.name = 'mars' 
p32.name = 'aprs'    
!null = legend(target=[p29,p30,p31,p32], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
;I am trying to get all the soil moisture on one plot.
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4', 'PoET']
v=5 ;v9=PoET
p29 = plot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         color='blue', $
         thick=1, $
         view_title = 'soil mositure layers 1-3', $
         ytitle = 'Soil moisture(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5])
p30 = plot(years, mean_SMal[*,1,v],index=1,nbars=4, color='green', /OVERPLOT)
p31 = plot(years, mean_SMal[*,2,v],index=2,nbars=4, color='yellow', /OVERPLOT)
p32 = plot(years, mean_SMal[*,3,v],index=3,nbars=4, color='maroon', /OVERPLOT)

v2=6 ;v9=PoET
p1 = plot(years, mean_SMal[*,0,v2],index=1,nbars=4, color='blue', /OVERPLOT)
p2 = plot(years, mean_SMal[*,1,v2],index=1,nbars=4, color='green', /OVERPLOT)
p3 = plot(years, mean_SMal[*,2,v2],index=2,nbars=4, color='yellow', /OVERPLOT)
p4 = plot(years, mean_SMal[*,3,v2],index=3,nbars=4, color='maroon', /OVERPLOT)

v3=7 ;v9=PoET
p12 = plot(years, mean_SMal[*,0,v3],index=1,nbars=4, color='blue', /OVERPLOT)
p12 = plot(years, mean_SMal[*,1,v3],index=1,nbars=4, color='green', /OVERPLOT)
p13 = plot(years, mean_SMal[*,2,v3],index=2,nbars=4, color='yellow', /OVERPLOT)
p14 = plot(years, mean_SMal[*,3,v3],index=3,nbars=4, color='maroon', /OVERPLOT)

;v4=8 ;v9=PoET
;p22 = plot(years, mean_SMal[*,0,v4],index=1,nbars=4, color='cyan', /OVERPLOT)
;p22 = plot(years, mean_SMal[*,1,v4],index=1,nbars=4, color='purple', /OVERPLOT)
;p23 = plot(years, mean_SMal[*,2,v4],index=2,nbars=4, color='grey', /OVERPLOT)
;p24 = plot(years, mean_SMal[*,3,v4],index=3,nbars=4, color='blue', /OVERPLOT)

;add a legend
p29.name = 'jans'
p30.name = 'febs' 
p31.name = 'mars' 
p32.name = 'aprs'    
!null = legend(target=[p29,p30,p31,p32], position=[0.2,0.3]) ; not sure how this line works...
;____________________________________________________________
;runoff as a line/scatter plot
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4']
v=4 ;v4=runoff
p17 = plot(mean_SMal[*,0,v], $
         color='blue', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xtitle = 'years 03-07')
p18 = plot(mean_SMal[*,1,v],color='green', /OVERPLOT)
p19 = plot(mean_SMal[*,2,v],color='black', /OVERPLOT)
p20 = plot(mean_SMal[*,3,v],color='orange', /OVERPLOT)
;add a legend
p17.name = 'jans'
p18.name = 'febs' 
p19.name = 'mars' 
p20.name = 'aprs'    
!null = legend(target=[p17,p18,p19,p20], position=[0.2,0.3]) ; not sure how this line works...
;____________________________________________________________
;trying to plot aet and pet on the same graph.....

v=9 ;v2=PET
p9 = plot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         color='cyan', $
         thick=2, $
         view_title = vars[v], $
         ytitle = vars[v]+'[PET] (mm)',$
         yrange = [280,400], $
         xminor=0, $
         xrange=[2003, 2007])
p10 = plot(years, mean_SMal[*,1,v],index=1,nbars=4, color='purple', /OVERPLOT)
p11 = plot(years, mean_SMal[*,2,v],index=2,nbars=4, color='grey', /OVERPLOT)
p12 = plot(years, mean_SMal[*,3,v],index=3,nbars=4, color='blue', /OVERPLOT)
;p0 = plot(years, mean_SMal[*,1,2],index=1,nbars=4, color='orange', /OVERPLOT)
;p1 = plot(years, mean_SMal[*,2,2],index=2,nbars=4, color='grey', /OVERPLOT)
;p2 = plot(years, mean_SMal[*,3,2],index=3,nbars=4, color='blue', /OVERPLOT)
;add a legend
;add a legend
p9.name = 'jans'
p10.name = 'febs' 
p11.name = 'mars' 
p12.name = 'aprs'    
!null = legend(target=[p9,p10,p11,p12], position=[0.2,0.3]) ; not sure how this line works...
;____________________________________________________________
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4']
v=5 ;v5=sm1
p21 = plot(mean_SMal[*,0,v], $
         color='blue', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xtitle = 'years 03-07')
p22 = plot(mean_SMal[*,1,v],color='green', /OVERPLOT)
p23 = plot(mean_SMal[*,2,v],color='black', /OVERPLOT)
p24 = plot(mean_SMal[*,3,v],color='orange', /OVERPLOT)
;add a legend
p21.name = 'jans'
p22.name = 'febs' 
p23.name = 'mars' 
p24.name = 'aprs'    
!null = legend(target=[p21,p22,p23,p24], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
;vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4']
v=6 ;v5=sm2
p25 = plot(mean_SMal[*,0,v], $
         color='blue', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xtitle = 'years 03-07')
p26 = plot(mean_SMal[*,1,v],color='green', /OVERPLOT)
p27 = plot(mean_SMal[*,2,v],color='black', /OVERPLOT)
p28 = plot(mean_SMal[*,3,v],color='orange', /OVERPLOT)
;add a legend
p25.name = 'jans'
p26.name = 'febs' 
p27.name = 'mars' 
p28.name = 'aprs'    
!null = legend(target=[p25,p26,p27,p28], position=[0.2,0.3]) ; not sure how this line works...

end 


 
;      window,2,xsize=825, ysize=750
;      pos1 = [.05,.05,.91,.95] ;for full window
;
;      ;if the variable is temperature (or other red, high variable)
;      ;loadct,3,rgb_table=tmpct   ;displays color table
;      ;tmpct = reverse(tmpct,1)
;      ;tvlct,tmpct
;
;      ;if the viariable is blue high, red low (rainfall, runoff)
;      ;fileps=strcompress('/home/mcnally/testmap_'+data+vars[j]+"_"+months[k]+'.eps', /remove_all)
;      loadct,1,rgb_table=tmpct ;34 is rainbow
;      tmpct = reverse(tmpct,1)
;      tvlct,tmpct                 
;      
;      ;toggle,file=fileps;file=fileps[count] ; this isn't quite working but I am tierd of it 9/17/10
;        tvim,AOI, title='Southern Africa ', range=[0,2,0.25], /scale, lcharsize=1.8, /noframe, pos = pos1
;        map_set, 0,0,/cont,/cyl,limit=[-19.5,30,-8,42.75],/noerase, /noborder,pos=pos1, mlinethick=1,color=125
;        map_continents, /countries, color=125,   mlinethick=2
;      ;toggle     
;   
;   ;ENDFOR ;k-each band 
;
;
; ; ENDFOR ;j- each file
;
;end ;end program
