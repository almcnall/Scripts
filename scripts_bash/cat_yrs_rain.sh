#!/bin/bash

#******Oct 17, 2010********
#script to concatinate bin(.img) output from IDL precip reformating. I think that
# pete did monthly cum. but maybe i should do average daily rainfall per month (/days in month)
# to be consistant?
# This will also rename the files w.r.t. the precip type (e.g. TRMM) 
#current output has diffferent file names (e.g V6) and  different directories
# so maybe the rename isn"t necessary

#also chris may like his files in 'monthly' cubes? 
#*************************

#what exp are you working on and which dir?
precip=TRMMV6
OUTput=/gibber/lis_data/OUTPUT/TRMM_3B42/Africa_yearly
cd /jabber/Data/TRMM_3B42/Africa

#name the variables
vars=(2001 2002 2003 2004 2005 2006 2007 2008 2009 2010)

#use for loop to concatinate 12 months of the same variable
for (( i=0; i<${#vars[@]}; i++ )); do  #for all the variable names
  cat $( ls Africa.V6.${vars[i]}*.img ) > $OUTput/all_${vars[i]}_$precip.img  # cat and rename e.g. all_soilm1_exp006
done


