#!/usr/bin/env python

import numpy as np
import cartopy
import matplotlib.pyplot as plt            # pyplot module import
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER # Fancy formatting
import cartopy.crs as ccrs # Coordinate reference systems
import array

#-------------------
# Read a binary file
#-------------------
#fileName = "/gpfsm/dnb02/projects/p63/AFRICA_plots/AFRICA_VIS/data/HYPERWALL/AF_SOILSTORE_ANOM_751x801_201501.bin"
#A = np.fromfile(fileName, dtype='<f4')

dx = 0.1
dy = 0.1
nx=751
ny=800
lon_1=-20.05
lon_2= lon_1+nx*dx
lat_1=-39.95
lat_2=lat_1+ny*dy
lat=np.arange(lat_1,lat_2,dx)
lon=np.arange(lon_1,lon_2,dy)
x1,y1=np.meshgrid(lon,lat)
file2='Jossy_test.bin'
f=open(file2,'rb')
s=f.read()
a=array.array('f',s)
array2 = np.reshape(a, [nx, ny], order='F')

data = array2

lat_min = lat_1
lat_max =  lat_2
lon_min = lon_1
lon_max =  lon_2
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
fig, ax = plt.subplots(figsize=(7,8), subplot_kw=dict(projection=ccrs.PlateCarree()))

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
ax.add_feature(cartopy.feature.OCEAN)
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
# Format the labels using the formatters imported from cartopy
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER


#-----------------------
# Contour plot with fill
#-----------------------
#lon1, lat1 = np.meshgrid(lons,lats)

l1=np.transpose(x1)
l2=np.transpose(y1)
#cp = ax.contourf(lons, lats, data, 
cp = ax.contourf(l1, l2, data, 
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
                  shrink=0.75,               # shrink its size by 4
                  pad = 0.07                 # shift it up
                 )

#------------------
# Title of the plot
#------------------
ax.set_title('AF_SOILSTORE_ANOM', fontsize=14)
plt.savefig('Jossy_test_cartopy.png')
#plt.show()

