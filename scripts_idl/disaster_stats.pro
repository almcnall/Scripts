pro disaster_stats

;Jan 11, 2015 open disaster data from PreventionWeb and look at worst area/econ/mortality droughts in
; selected countries
;01 = cid
;02 = country_name
;03 = NAT_Disasters_Affected People_NUMPOP
;04 = NAT_Disasters_Affected People_DATE
;05 = NAT_Disasters_Affected People_DISASTER
;06 = NAT_Disasters_ECONDAMAGE_COST_USDX1000
;07 = NAT_Disasters_ECONDAMAGE_DATE
;08 = NAT_Disasters_ECONDAMAGE_DISASTER
;09 = NAT_Disasters_KilledPeople_DATE
;10 = NAT_Disasters_KilledPeople_DISASTER
;11 = NAT_Disasters_KilledPeople_NUMPOP

idir = '/home/sandbox/people/mcnally/'
ifile = idir+'top10_disaster_newheader.csv'

indat = read_csv(ifile, header=hdr)

;lets make a Kenya example
KYr_aff = indat.field07(where(indat.field02 eq 'Kenya'))
;does the Kenya SM anomaly time series hit the droughts?
;Does the hit rate improve when we mask high population areas?



