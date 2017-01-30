#!/usr/bin/env python

import numpy as np
import cartopy
import matplotlib.pyplot as plt            # pyplot module import
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER # Fancy formatting
import cartopy.crs as ccrs # Coordinate reference systems


#-------------------
# Read a binary file
#-------------------
#fileName = "/gpfsm/dnb02/projects/p63/AFRICA_plots/AFRICA_VIS/data/HYPERWALL/AF_SOILSTORE_ANOM_751x801_201501.bin"
filename='Jossy_test.bin'
A = np.fromfile(filename, dtype='<f')

lat_min = -40.0
lat_max =  40.0
lon_min = -20.0
lon_max =  60.0

nlon = 751
nlat = 800

lats = np.zeros(nlat)
lat_del = (lat_max - lat_min) / (nlat-1)
for i in range(nlat):
    lats[i] = lat_min + i*lat_del

lons = np.zeros(nlon)
lon_del = (lon_max - lon_min) / nlon
for i in range(nlon):
    lons[i] = lon_min + i*lon_del

print "lon: ", lons.shape
print "lat: ", lats.shape

data = A.reshape(nlat,nlon)
#print type(data), data.shape

#-----------------------------------#
#------------- PLOTTING ------------#
#-----------------------------------#

#--------------------
# Create bounding box
#--------------------
bbox = [lon_min, lon_max, lat_min, lat_max]

#----------------------------------------------------
# Define figure of size (15,8) and 
# an axis 'inside' with an equirectangular projection
#----------------------------------------------------
fig, ax = plt.subplots(figsize=(15,8), subplot_kw=dict(projection=ccrs.PlateCarree()))

#------------------------------------------------
# Set the map extent using the bbox defined above
#------------------------------------------------
ax.set_extent(bbox, ccrs.PlateCarree()) 

#------------------------------------------------------
# Draw coast line with the highest resolution available 
# (unless you use a different source)
#------------------------------------------------------
ax.coastlines('10m')

#ax.add_feature(cartopy.feature.LAND)
#ax.add_feature(cartopy.feature.OCEAN)
#ax.add_feature(cartopy.feature.COASTLINE)
ax.add_feature(cartopy.feature.BORDERS, linestyle=':')
#ax.add_feature(cartopy.feature.LAKES, alpha=0.5)
#ax.add_feature(cartopy.feature.RIVERS)

#----------------------------------
# Add latitude/kongitude grid lines
#----------------------------------
gl = ax.gridlines(crs=ccrs.PlateCarree(), # using the same projection
                  draw_labels=True,       # add labels
                  linewidth=1, 
                  color='gray', 
                  alpha=0.25, 
                  linestyle='--'         # grid line specs
                 )
# Remove labels above and on the right of the map 
# (note that Python allows the double equality)
gl.xlabels_top = gl.ylabels_right = False
# Format the labels ufig, ax = plt.subplots(figsize=(15,8), subplot_kw=dict(projection=ccrs.PlateCarree()))
sing the formatters imported from cartopy
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER


#-----------------------
# Contour plot with fill
#-----------------------
cp = ax.contourf(lons, lats, data, 
                 6,                             # number of color levels
                 transform=ccrs.PlateCarree(),
                 cmap=plt.cm.RdBu_r,            # A standard diverging colormap, from Blue to Red
                 extend='both'                  # To make pointy colorbar
               )

#------------------
# Create a colorbar
#------------------
cb = plt.colorbar(cp,                        # connect it to the contour plot
                  ax=ax,                     # put it in the same axis
                  orientation='horizontal',
                  shrink=0.25,               # shrink its size by 4
                  pad = 0.05                 # shift it up
                 )

#------------------
# Title of the plot
#------------------
ax.set_title('AF_SOILSTORE_ANOM', fontsize=14)

plt.show()

