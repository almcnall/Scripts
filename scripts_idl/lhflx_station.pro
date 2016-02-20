 pro lhflx_station
 
 ;this script reads in available station data and finds the monthly average
 
;ifile = file_search('/home/mcnally/ETfromMMarshall/west_africa_flux/HBe_Don_actinruf2005.csv')
;ben = read_csv(ifile) ; not really sure if there is flux data in here or not...
;ifile = file_search('/home/mcnally/ETfromMMarshall/west_africa_flux/HMa_Kel_actinruf2005.csv')
;kel = read_csv(ifile); uh, i can't tell where the LH is...

ifile = file_search('/home/mcnally/ETfromMMarshall/west_africa_flux/Fallow2006.csv')
;fal = read_ascii(ifile, delimiter=';')
valid= qup1ery_ascii(ifile,info) ;checks compatability with read_ascii

myTemplate = ASCII_TEMPLATE(ifile); go to line 100.
fal = read_ascii(ifile, delimiter=';' ,template=myTemplate)
;Time;Le;Rg;Rn;Rh;Th
LHfal = fal.field2
LHfal(where(LHfal lt 0))=!values.f_nan

;compare the models to Wankama 2006
month = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
m = strmid(fal.field1,3,2)
buffer=fltarr(n_elements(month))
help, smooth(LHfal,30,/nan)
for i = 0,n_elements(month)-1 do begin &$
  buffer[i]=mean(LHfal(where(m eq month[i])), /nan) &$
endfor

;compare the models to Mali 2007: Kelma (-15.2237;-1.5002) and Agoufou(-15.3432;-1.4807)
ifile = file_search('/jabber/chg-mcnally/AMMAlhflx/239-AE.H2OFlux_G.csv')
myTemplate = ASCII_TEMPLATE(ifile); go to line 100.
ag = read_ascii(ifile, delimiter=';' ,template=myTemplate)
yr = strmid(ag.field1,0,4) & print, yr
mo = strmid(ag.field1,5,2) & print, mo

LHagkm = ag.field6
LHagkm(where(LHagkm lt 0))=!values.F_NAN
LHag = LHagkm(where(ag.field2 eq -15.3432));Agoufou(-15.3432;-1.4807)
LHkm = LHagkm(where(ag.field2 eq -15.2237));Kelma (-15.2237;-1.5002)

year = ['2007', '2008']
ag1=fltarr(2,12) ; 2 sites, 2 years, 12 months
km=fltarr(2,12)
for y = 0,n_elements(year)-1 do begin &$
  for i = 0,n_elements(month)-1 do begin &$
    ag1[y,i]=mean(LHag(where(mo eq month[i] AND yr eq year[y])), /nan) &$
    km[y,i]=mean(LHkm(where(mo eq month[i] AND yr eq year[y])), /nan) &$   
  endfor &$
endfor
agout = [ [ag1[0,*]],[ag1[1,*]] ] & p1 = plot(agout)
kmout = [ [km[0,*]],[km[1,*]] ] & p1 = plot(kmout)

ofile = '/jabber/chg-mcnally/LHFLX_Agoufou_monthly_2007_2008.csv'
write_csv,ofile,agout

ofile = '/jabber/chg-mcnally/LHFLX_Kelma_monthly_2007_2008.csv'
write_csv,ofile,kmout

ofile = '/jabber/chg-mcnally/LHFLX_WankFal_monthly_2006.csv'
write_csv,ofile,buffer

