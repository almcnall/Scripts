pro nve, Data


;	data = [1,2, !Values.F_NAN, 5.0, 7.3, !Values.F_NAN]  

zeroes   = 0.0 * data
goodex   = where(zeroes eq 0, good_cnt)
nogoodex = where(zeroes ne 0, nogood_cnt)

;	print, good_cnt, nogood_cnt




if(good_cnt gt 0)   then  mve,Data(where(zeroes eq 0))
if(nogood_cnt gt 0) then  print, 'Found  ',strcompress(string(nogood_cnt))," NAN's"


end
