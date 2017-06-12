pro carveout_southmalawi  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this program is to generate maps of the LIS output variable
; specifically for Malawi. 
; The colorscheme needs to be changed depenging on the variable being plotted
; the area of interest (AOI) and range for the map_continents will need to be changed
; depending on the domain of interest.
; Also change the experiement code....
; AM 9/16/10
;*************************************************************************
device,decomposed=0

expdir = 'EXP027' 
  ;if expdir eq 'EXP027' then data='ubRFE2'
  
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/monthcubie/", /remove_all)
outdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/southmalawi/", /remove_all)
file_mkdir, outdir

cd, indir

file_w   = file_search('*{09,10,11,12,01,02,03,04}.img');no spaces! this had not been fixed when I started dinking...
;file_d  = file_search('*{05,06,07,08}.img')

vars = strarr(10); length = 9
vars= ['Qsub','airtem', 'evap', 'rain','runoff','soilm1', 'soilm2', 'soilm3','soilm4', 'PoET'] 

;vars = strarr(1); length = 9
;vars= ['PoET'] 
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]

nx     = 301.
ny     = 321.
outx   = 8.
outy   = 14.

nbands_w = 5. ;wet season
nbands_d = 4. ;dry season...I should run for full years for this reason alone

;allocate arrays
ingrid_w   = fltarr(nx,ny,nbands_w) ;initializes the array 
ingrid_d   = fltarr(nx,ny,nbands_d)
AOI        = fltarr(outx,outy,nbands_w)
all_aoi    = fltarr(n_elements(vars))
mean_SMal  = fltarr(nbands_w,8,n_elements(vars)); what is up with this 8?
ofile_SMal = strarr(n_elements(file_w))

;file names and dealing with different length variable names...next time make all strings same length.
for d=0, n_elements(file_w)-1 do begin;; this loop is for the months but is all the files in a year...
     
     if (strmid(file_w[d],0,4) eq 'evap') OR (strmid(file_w[d],0,4) eq 'Qsub') OR (strmid(file_w[d],0,4) eq 'rain') OR (strmid(file_w[d],0,4) eq 'PoET')then begin
     ofile_SMal(d) = Outdir+strmid(file_w[d],0,7)+"_SMal.img"
     endif else begin
     ofile_SMal(d) = Outdir+strmid(file_w[d],0,9)+"_SMal.img"
     endelse
     
end

count=0 ;counts 8 months (wet season) per variable 
z=0     ;after 8mo. varible changes and is writen as new dimension
FOR j = 0,n_elements(file_w)-1 do begin
  
  openr,1,indir+file_w[j]     ;opens the file
  readu,1,ingrid_w           ;reads it into ingrid  
  close,1
 
  ;mve,ingrid_w                 ;print out the max min mean and std deviation of var
  rgrid = reverse(ingrid_w,2)  ;IDL reads from bottom to top, this reverses rows (2) to plot
  AOI[*,*,*] = reverse(rgrid(216:223,92:105,*),2) ; I shouldn't have to do this twice but it works for now.
  openw,2,ofile_SMal[j] & writeu,2,AOI  
  close,2 
    
    for k=0,nbands_w-1 do begin
     
     mean_SMal[k,count,z]=mean(AOI[*,*,k],/NAN); still not sure what 8 is...
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

;get soil moisture to fix the soil moisture plots from Spring '11
 smcube=fltarr(3,5,5); 3 cols(depths), 5 rows(years), 4 pages(months)
 aetarray=fltarr(1,5,5)
;something is not right with my indexing....
for month=1,4 do begin ;for jan, feb, mar, apr
  ;month=i
  SM01=mean_SMal[*,month,5]
  SM02=mean_SMal[*,month,6]
  SM03=mean_SMal[*,month,7]
  AET=mean_SMal[*,month,2]
  AETarray[*,*,month]=AET
 smcube[*,*,month]=[transpose(SM01),transpose(SM02),transpose(SM03)]
endfor 

p1=plot(aetarray(0,*,1));aet, all years,jans
p1=plot(AETarray(0,0,1:4));Jan-Apr 2003
p1=plot(AETarray(0,1,1:4),color='cyan', /overplot);Jan-Apr 2004
p1=plot(AETarray(0,2,1:4),color='green', /overplot);Jan-Apr 2005
p1=plot(AETarray(0,3,1:4),color='blue', /overplot);Jan-Apr 2006
p1=plot(AETarray(0,4,1:4), /overplot);Jan-Apr 2006

 print, smcube(0,*,1:4); this gives me what I already have in excel - all years/depths for a given month
 print, smcube(0,0,*); this gives me all months for a given year..
 
print, 'hold here'
mos=['jan','feb','mar','apr']
;***************at 10cm*************************************switched to stacked bars in excel*****
p1=plot(smcube(0,0,1:4)/10, color='blue',symbol=4, sym_size=2, sym_filled=1, $
        thick=2,title='Modeled 10cm soil moisture, South Malawi 2003-2007');2003
p2=plot(smcube(0,1,1:4)/10,/overplot, color='magenta', symbol=4, sym_size=2, thick=3,sym_filled=1);2004
p3=plot(smcube(0,2,1:4)/10,/overplot, color='orange', symbol=4, sym_size=2, thick=3,sym_filled=1);2005
p4=plot(smcube(0,3,1:4)/10,/overplot, color='grey', symbol=4, sym_size=2, thick=3,sym_filled=1);2006
p5=plot(smcube(0,4,1:4)/10,/overplot, color='cyan', symbol=4, sym_size=2, thick=3,sym_filled=1, $
        xtickname=mos, XTICKFONT_SIZE=24, YTICKFONT_SIZE=18, YTITLE='soil moisture');2007

p1.name = '2003'
p2.name = '2004' 
p3.name = '2005' 
p4.name = '2006' 
p5.name = '2007'    
!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3]) ; not sure how this line works...

;***************at 40cm*************************************************************************
p1=plot(smcube(1,0,1:4)/30, color='blue',symbol=4, sym_size=2, sym_filled=1, $
        thick=2,title='Modeled 40cm soil moisture, South Malawi 2003-2007');2003
p2=plot(smcube(1,1,1:4)/30,/overplot, color='magenta', symbol=4, sym_size=2, thick=3,sym_filled=1);2004
p3=plot(smcube(1,2,1:4)/30,/overplot, color='orange', symbol=4, sym_size=2, thick=3,sym_filled=1);2005
p4=plot(smcube(1,3,1:4)/30,/overplot, color='grey', symbol=4, sym_size=2, thick=3,sym_filled=1);2006
p5=plot(smcube(1,4,1:4)/30,/overplot, color='cyan', symbol=4, sym_size=2, thick=3,sym_filled=1,$
        xtickname=mos,XTICKFONT_SIZE=24, YTICKFONT_SIZE=18);2007

p1.name = '2003'
p2.name = '2004' 
p3.name = '2005' 
p4.name = '2006' 
p5.name = '2007'    
!null = legend(target=[p1,p2,p3,p4,p5], position=[0.2,0.3]) ; not sure how this line works.
;***********************************************************************************************

precip=mean_SMal[*,month,3]
evapor=mean_SMal[*,month,2]
runof2=mean_SMal[*,month,0]
runof1=mean_SMal[*,month,4]

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
evapor=plot(mean_SMal[2,0:3,aet], /OVERPLOT)
;_________________________
years=strarr(nbands_w)
years=[2003,2004,2005,2006,2007]

v=0 ;v for variable!
;mean_SMal[years 2003-2007, month (jan-apr), variable
p1 = barplot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5])
p2 = barplot(years, mean_SMal[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p3 = barplot(years, mean_SMal[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p4 = barplot(years, mean_SMal[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)
;add a legend
p1.name = 'jans'
p2.name = 'febs' 
p3.name = 'mars' 
p4.name = 'aprs'    
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) ; not sure how this line works...
;____________________________________________________________
v=1 ;v1=airtemp
p5 = barplot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         fill_color='cyan', $
         thick=1, $
         view_title = vars[v], $
         ytitle = vars[v]+'(mm)',$
         xminor=0, $
         xrange=[2002.5, 2007.5], $
         yrange=[20, 25])
p6 = barplot(years, mean_SMal[*,1,v],index=1,nbars=4, fill_color='purple', /OVERPLOT)
p7 = barplot(years, mean_SMal[*,2,v],index=2,nbars=4, fill_color='grey', /OVERPLOT)
p8 = barplot(years, mean_SMal[*,3,v],index=3,nbars=4, fill_color='blue', /OVERPLOT)
;add a legend
p5.name = 'jans'
p6.name = 'febs' 
p7.name = 'mars' 
p8.name = 'aprs'    
!null = legend(target=[p5,p6,p7,p8], position=[0.2,0.3]) ; not sure how this line works...

;____________________________________________________________
v=2 ;v2=evap
p9 = plot(years,mean_SMal[*,0,v], $
         nbars=4, $
         index=0, $
         color='cyan', $
         thick=2, $
         view_title = vars[v], $
         ytitle = vars[v]+'[AET] (mm)',$
         xminor=0, $
         xrange=[2003, 2007])
p10 = plot(years, mean_SMal[*,1,v],index=1,nbars=4, color='purple', /OVERPLOT)
p11 = plot(years, mean_SMal[*,2,v],index=2,nbars=4, color='grey', /OVERPLOT)
p12 = plot(years, mean_SMal[*,3,v],index=3,nbars=4, color='blue', /OVERPLOT)
;add a legend
p9.name = 'jans'
p10.name = 'febs' 
p11.name = 'mars' 
p12.name = 'aprs'    
!null = legend(target=[p9,p10,p11,p12], position=[0.2,0.3]) ; not sure how this line works...
;*********************************************************************************************
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


end 
