;SOS check

indir = '/home/sandbox/people/mcnally/SOS_GW2_YR/'
indir = '/home/sandbox/people/mcnally/GPM_SOS4Dalia/'


;ifile1 = file_search(indir+'/SOS_SA_chirpnc/SOS_current_2006.d01.bil') & print, ifile1
;ifile2 = file_search(indir+'/SOS_SA_longrun/SOS_current_2006.d01.bil') & print, ifile2
;ifile3 = file_search(indir+'/SOS_SA_rfechirp/SOS_current_2006.d01.bil') & print, ifile3
ifile3 = file_search(indir+'/RFE2_SOS_current_2016.d01.bil') & print, ifile3

NX = 486
NY = 443

ingrid1 = ulonarr(NX,NY)
ingrid2 = ulonarr(NX,NY)
ingrid3 = ulonarr(NX,NY)

openr,1,ifile1
openr,2,ifile2
openr,3,ifile3

readu,1,ingrid1
readu,2,ingrid2
readu,3,ingrid3

close,1
close,2
close,3

;ingrid3 and 2 appear to be identicle - good i guess since they are both rfechirp.
temp = image(reverse(ingrid1,2),min_value=0, max_value=60, rgb_table=4, layout=[3,1,1])
temp = image(reverse(ingrid2,2),min_value=0, max_value=60, rgb_table=4, layout=[3,1,2], /current)
temp = image(reverse(ingrid3,2),min_value=0, max_value=60, rgb_table=4, layout=[3,1,3], /current)