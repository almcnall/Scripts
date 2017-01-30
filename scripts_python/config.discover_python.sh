#!/bin/sh
#------------------------------------------------------------------------------
# DESCRIPTION:                                                                 
# Sample config file for running LIS batch scripts on NASA GSFC Discover
# supercomputer for FEWS-NET ASIA.
# Jossy P. Jacob (Sept 2015)
#------------------------------------------------------------------------------

# We completely purge the module environment variables and LD_LIBRARY_PATH 
# before loading only those specific variables that we need.
module purge

#unset LD_LIBRARY_PATH

module load comp/intel-13.1.1.163
module load lib/mkl-9.1.023
module load other/comp/gcc-4.5-sp1 
module load other/SIVO-PyD/spd_1.7.0_gcc-4.5-sp1

