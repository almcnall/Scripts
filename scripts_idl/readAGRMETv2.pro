PRO readAgGRMETv2

;the purpose of this program is to read the agrmet radiation files. Ideally into daily averages....

FOR yr = 2000, 2009 DO BEGIN 
   if yr MOD 4 ne 0 then days = 365 $
   else days = 366
  for d = 1, days
     