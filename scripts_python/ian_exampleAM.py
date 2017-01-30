from qgis.core import *

QgsApplication.setPrefixPath('/usr/local/other/SSSO_Ana-PyD/4.2.0_py2.7_gcc-5.3-sp3')

qgs = QgsApplication([], False)

qgs.initQgis()


from PyQt4.QtCore import QFileInfo
rasterFile = '../../WaterStressPercentNorm_01mon_EA201607.tif'
fileInfo = QFileInfo(rasterFile)
baseName = fileInfo.baseName()

rlayer = QgsRasterLayer(rasterFile, baseName)
print rlayer.isValid()

vectorfile = '/discover/nobackup/almcnall/SHPfiles/tl_2016_us_state.shp'
layer = QgsVectorLayer(vectorfile, 'state')
if not layer.isValid():
  print "Layer failed to load!"




qgs.exitQgis()
