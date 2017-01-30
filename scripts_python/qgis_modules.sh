module purge

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/other/SSSO_Ana-PyD/4.2.0_py2.7_gcc-5.3-sp3/lib
export GDAL_DATA=/usr/local/other/SSSO_Ana-PyD/4.2.0_py2.7_gcc-5.3-sp3/share/gdal
export PYTHONPATH=/usr/local/other/SSSO_Ana-PyD/4.2.0_py2.7_gcc-5.3-sp3/share/qgis/python
module load other/comp/gcc-5.3-sp3
module load other/SSSO_Ana-PyD/SApd_4.2.0_py2.7_gcc-5.3-sp3
