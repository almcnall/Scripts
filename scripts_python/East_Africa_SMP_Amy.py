#!/usr/bin/env python
#
# Python plotting software to plot Soil Moisture Percentile
##Jossy Jacob Jan 2016###
##
## How to run: ./East_Africa_SMP.py 201511 201512 
## It plots 2 months LIS run data for NOAH, VIC for
## 2 experiments with forcings: MERRA+CHIRPS, RFE+GDAS
##
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import glob
from netCDF4 import Dataset
from numpy import *
from datetime import date
import datetime
import string
import time
import sys
import math
from Tkinter import *
import array
import matplotlib.font_manager as font_manager

#from scipy.stats.stats import nanmean
from mpl_toolkits.basemap import Basemap
def make_N_colors(cmap_name, N):
    cmap = cm.get_cmap(cmap_name, N)
fontj = {'family' : 'serif',
         'color'  : 'b',
         'weight' : 'bold',
         'size'   :12,
         }

mydate=sys.argv[1]
mydate1=sys.argv[2]
#my_cmap_r = reverse_colourmap(cm.jet)
#my_cmap_r = cm.bwr_r
my_cmap_r = cm.jet_r
#exp1=sys.argv[2]
#mydate='201510'
#mydate1='201511'
exp1='NOAH_MC'
year1=mydate[0:4]
mymonth=mydate[4:6]
#print year1, year2, mydate, mydate2
#dir1=MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_RFE_GDAS_ea_dailyV2/post
#filename FLDAS_NOAH01_A_EA_M.A201511.001.nc
expname1='NOAH01 - RFE & GDAS'
dir1 = '../data/NOAH_RG/'
file1 = dir1 + 'FLDAS_NOAH01_A_EA_M.A'+mydate+'.001.nc'
#dir2=MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA_EA_fix/post
#filename FLDAS_NOAH01_B_EA_M.A201510.001.nc
expname2='NOAH01 - CHIRPS & MERRA2'
dir2 = '../data/NOAH_MC/'
file2 = dir2 + 'FLDAS_NOAH01_C_EA_M.A'+mydate+'.001.nc'
#dir3=MODEL_RUNS/VIC_OUTPUT/OUTPUT_RG71_EAv2/post
#filename FLDAS_VIC025_A_EA_M.A201511.001.nc
expname3='VIC025 - RFE & GDAS'
dir3 = '../data/VIC_RG/'
file3 = dir3 + 'FLDAS_VIC025_A_EA_M.A'+mydate+'.001.nc'
#dir4=MODEL_RUNS/VIC_OUTPUT/OUTPUT_MC71_EAv3/post
#filename FLDAS_VIC025_B_EA_M.A201510.001.nc
expname4='VIC025 - CHIRPS & MERRA2'
dir4 = '../data/VIC_MC/'
file4 = dir4 + 'FLDAS_VIC025_C_EA_M.A'+mydate+'.001.nc'
#	Y = 443 ;
#	X = 486 ;

ds1       = Dataset(file1, 'r', format='NETCDF4')
ds2       = Dataset(file2, 'r', format='NETCDF4')
ds3       = Dataset(file3, 'r', format='NETCDF4')
ds4       = Dataset(file4, 'r', format='NETCDF4')
#SM01_Percentile
SM1=ds1.variables['SM01_Percentile'][:,:]
SM2=ds2.variables['SM01_Percentile'][:,:]
SM3=ds3.variables['SM01_Percentile'][:,:]
SM4=ds4.variables['SM01_Percentile'][:,:]
cen_lat = 38.5
cen_lon = 65.0
truelat1 = 21.
truelat2 = 56.0
standlon = 65.0
X=ds1.variables['X'][:]
Y=ds1.variables['Y'][:]

# x_dim and y_dim are the x and y dimensions of the model
# domain in gridpoints
#x_dim = len(ds.dimensions['east_west'])
#y_dim = len(ds.dimensions['north_south'])
x_dim = len(ds1.dimensions['X'])
y_dim = len(ds1.dimensions['Y'])

# Get the grid spacing
dx = float(ds1.DX)
dy = float(ds1.DY)
nx=x_dim
ny=y_dim
x1, y1 = np.meshgrid(X,Y);
width_meters = dx * (x_dim - 1)
height_meters = dy * (y_dim - 1)  
lon=X
lon_1 = X[0]
lon_2 = X[nx-1]
lat=Y
lat_01 = Y[0]
lat_02= Y[ny-1]
cen_lat = (lat_01 + lat_02)/2.
cen_lon = (lon_2 + lon_1)/2.
truelat1 = lat_01
truelat2 = lat_02 
# x_dim and y_dim are the x and y dimensions of the model
# domain in gridpo

smcolors=('#990000', '#ff3300',  '#e67300', '#ffcc66','#ffff00','#ffffff','#aaff80','#66ff33','#009900','#006600','#003399')

fig = plt.figure(num=None, figsize=(10,6), facecolor='w') 
text1='Soil Moisture Percentile:' + mydate
fig.text(0.3, 0.92, text1,color='b', fontsize=20)#,horizontalalignment='Left')
plt.subplot(121)

#cxcoord  = [0.05, 0.05, 0.7, 0.025]
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=lon_1,llcrnrlat=lat_01,urcrnrlon=lon_2,urcrnrlat=lat_02,\
    lat_0=cen_lat,lon_0=cen_lon,lat_1=truelat1,lat_2=truelat2)  
#ff1=np.squeeze(SST[:,:])
ff1=np.squeeze(SM1[:,:])*100.
Tmax=100
Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
clev=[0,2,5,10,20,30,70,80,90,95,98,100]

#m.drawcoastlines(color='grey')
#m.drawcountries(color='grey')
m.drawcoastlines(color='k',linewidth=1.25)
m.drawcountries(color='k',linewidth=1.25)

parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
cs = plt.contourf(x1,y1,ff1,clev,colors=smcolors)
#cs = plt.contourf(x1,y1,ff1,clev,cmap=my_cmap_r,extend="both")
tit_text=expname1
plt.title(tit_text)
# add colorbar.
#cx  = fig.add_axes(cxcoord1)
#cbar=plt.colorbar(cs,cax=cx,orientation='vertical',extend='both')
#cbar.ax.set_yticklabels(['<-10','-2','6','14','22','30','>35']) 
#cbar.set_label('%')
#plt.show()

plt.subplot(122)
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=lon_1,llcrnrlat=lat_01,urcrnrlon=lon_2,urcrnrlat=lat_02,\
    lat_0=cen_lat,lon_0=cen_lon,lat_1=truelat1,lat_2=truelat2)  
#ff1=np.squeeze(SST[:,:])
ff1=np.squeeze(SM2[:,:])*100.
#Tmax=100
#Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
#m.drawcoastlines(color='k')
#m.drawcountries(color='k')
m.drawcoastlines(color='k',linewidth=1.25)
m.drawcountries(color='k',linewidth=1.25)

parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
#cs = plt.contourf(x1,y1,ff1,clev,cmap=my_cmap_r,extend="both")
cs = plt.contourf(x1,y1,ff1,clev,colors=smcolors)
tit_text=expname2 
plt.title(tit_text)
# add colorbar.
cxcoord2  = [0.92, 0.2, 0.025, 0.6]
cx  = fig.add_axes(cxcoord2)
cbar=plt.colorbar(cs,cax=cx,orientation='vertical',spacing='uniform')
cbar.set_ticks(clev)
cbar.ax.set_yticklabels(clev) 
cbar.set_label('percentile')
figname = '../plots/EA_NOAH_SMP_'+mydate+'.png'
print figname
plt.savefig(figname) 
#plt.show()
#
# VIC Plot
#
X2=ds3.variables['X'][:]
Y2=ds3.variables['Y'][:]

# x_dim and y_dim are the x and y dimensions of the model
# domain in gridpoints
x_dim2 = len(ds3.dimensions['X'])
y_dim2 = len(ds3.dimensions['Y'])
# Get the grid spacing
dx2 = float(ds3.DX)
dy2 = float(ds3.DY)
nx2=x_dim2
ny2=y_dim2
x2, y2 = np.meshgrid(X2,Y2);
width_meters2 = dx2 * (x_dim2 - 1)
height_meters2 = dy2 * (y_dim2 - 1)  
lon2=X2
vlon_1 = X2[0]
vlon_2 = X2[nx2-1]
vlat=Y2
vlat_01 = Y2[0]
vlat_02= Y2[ny2-1]
vcen_lat = (vlat_01 + vlat_02)/2.
vcen_lon = (vlon_2 + vlon_1)/2.
vtruelat1 = vlat_01
vtruelat2 = vlat_02 

fig = plt.figure(num=None, figsize=(10,6), facecolor='w') 
text1='Soil Moisture Percentile:' + mydate
fig.text(0.3, 0.92, text1,color='b', fontsize=20)#,horizontalalignment='Left')
plt.subplot(121)

#cxcoord  = [0.05, 0.05, 0.7, 0.025]
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=vlon_1,llcrnrlat=vlat_01,urcrnrlon=vlon_2,urcrnrlat=vlat_02,\
    lat_0=vcen_lat,lon_0=vcen_lon,lat_1=vtruelat1,lat_2=vtruelat2)  
#ff1=np.squeeze(SST[:,:])
ff2=np.squeeze(SM3[:,:])*100.
#Tmax=100
#Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
m.drawcoastlines(color='k',linewidth=1.25)
m.drawcountries(color='k',linewidth=1.25)
parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
#cs = plt.contourf(x2,y2,ff2,clev,cmap=my_cmap_r,extend="both")
cs = plt.contourf(x2,y2,ff2,clev,colors=smcolors)
tit_text=expname3
plt.title(tit_text)
#
#
plt.subplot(122)
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=vlon_1,llcrnrlat=vlat_01,urcrnrlon=vlon_2,urcrnrlat=vlat_02,\
    lat_0=vcen_lat,lon_0=vcen_lon,lat_1=vtruelat1,lat_2=vtruelat2)  
#ff1=np.squeeze(SST[:,:])
ff2=np.squeeze(SM4[:,:])*100.
#Tmax=100
#Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
m.drawcoastlines(color='k',)
m.drawcountries(color='k')
parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
#cs = plt.contourf(x2,y2,ff2,clev,cmap=my_cmap_r,extend="both")
cs = plt.contourf(x2,y2,ff2,clev,colors=smcolors)
tit_text=expname4 
plt.title(tit_text)
# add colorbar.
cxcoord2  = [0.92, 0.2, 0.025, 0.6]
cx  = fig.add_axes(cxcoord2)
cbar=plt.colorbar(cs,cax=cx,orientation='vertical',spacing='uniform')
cbar.set_ticks(clev)
cbar.ax.set_yticklabels(clev) 
cbar.set_label('percentile')
figname = '../plots/EA_VIC_SMP_'+mydate+'.png'
print figname
plt.savefig(figname) 
#plt.show()
#
#
# Plot the RFE+GDAS for next month
#
expname11='NOAH01 - RFE & GDAS'
file11 = dir1 + 'FLDAS_NOAH01_A_EA_M.A'+mydate1+'.001.nc'
#dir2=MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA_SA_fix/post
#filename FLDAS_NOAH01_B_SA_M.A201510.001.nc
#dir3=MODEL_RUNS/VIC_OUTPUT/OUTPUT_RG71_SAv2/post
#filename FLDAS_VIC025_A_SA_M.A201511.001.nc
expname33='VIC025 - RFE & GDAS'
dir3 = '../data/VIC_RG/'
file33 = dir3 + 'FLDAS_VIC025_A_EA_M.A'+mydate1+'.001.nc'
ds11       = Dataset(file11, 'r', format='NETCDF4')
ds33       = Dataset(file33, 'r', format='NETCDF4')
#SM01_Percentile
SM11=ds11.variables['SM01_Percentile'][:,:]
SM33=ds33.variables['SM01_Percentile'][:,:]

fig = plt.figure(num=None, figsize=(10,6), facecolor='w') 
text1='Soil Moisture Percentile:' + mydate1
fig.text(0.3, 0.92, text1,color='b', fontsize=20)#,horizontalalignment='Left')
plt.subplot(121)

#cxcoord  = [0.05, 0.05, 0.7, 0.025]
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=lon_1,llcrnrlat=lat_01,urcrnrlon=lon_2,urcrnrlat=lat_02,\
    lat_0=cen_lat,lon_0=cen_lon,lat_1=truelat1,lat_2=truelat2)  
#ff1=np.squeeze(SST[:,:])
ff1=np.squeeze(SM11[:,:])*100.
#Tmax=100
#Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
m.drawcoastlines(color='k',linewidth=1.25)
m.drawcountries(color='k',linewidth=1.25)
parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
#cs = plt.contourf(x1,y1,ff1,clev,cmap=my_cmap_r,extend="both")
cs = plt.contourf(x1,y1,ff1,clev,colors=smcolors)
tit_text=expname11
plt.title(tit_text)
# add colorbar.
#cx  = fig.add_axes(cxcoord1)
#cbar=plt.colorbar(cs,cax=cx,orientation='vertical',extend='both')
#cbar.ax.set_yticklabels(['<-10','-2','6','14','22','30','>35']) 
#cbar.set_label('%')
#plt.show()

plt.subplot(122)
m = Basemap(resolution='i',projection='cyl',\
    llcrnrlon=lon_1,llcrnrlat=lat_01,urcrnrlon=lon_2,urcrnrlat=lat_02,\
    lat_0=cen_lat,lon_0=cen_lon,lat_1=truelat1,lat_2=truelat2)  
#ff1=np.squeeze(SST[:,:])
ff2=np.squeeze(SM33[:,:])*100.
#Tmax=100
#Tmin=2
#clev=np.arange(Tmin,Tmax,4) 
m.drawcoastlines(color='k',linewidth=1.25)
m.drawcountries(color='k',linewidth=1.25)
parallels = np.arange(-60,90,10.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
## draw meridians
meridians = np.arange(0.,110.,10.)
m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)
#cs = plt.contourf(x,y,ff1,clev,cmap=cm.jet)
#colormap_r = ListedColormap(colormap.colors[::-1])
cs = plt.contourf(x2,y2,ff2,clev,cmap=my_cmap_r,extend="both")
cs = plt.contourf(x2,y2,ff2,clev,colors=smcolors)
tit_text=expname33 
plt.title(tit_text)
# add colorbar.
cxcoord2  = [0.92, 0.2, 0.025, 0.6]
cx  = fig.add_axes(cxcoord2)
cbar=plt.colorbar(cs,cax=cx,orientation='vertical',spacing='uniform')
cbar.set_ticks(clev)
#cbar.set_yticklabels(['0','2','5','10','20','30','70','80','90','95','98']) 
cbar.ax.set_yticklabels(clev) 
cbar.set_label('percentile')
figname = '../plots/EA_NOAH_VIC_SMP_'+mydate1+'.png'
print figname
plt.savefig(figname) 
#plt.show()


