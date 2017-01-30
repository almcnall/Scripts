
from osgeo import gdal, osr
from cartopy.crs import Orthographic, PlateCarree
from cartopy.feature import BORDERS, COASTLINE
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
from matplotlib import pyplot, colors, image
import numpy

AF_SOILSTORE_ANOM = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_SOILSTORE_ANOM_751x801_201504.tif'
AF_land_ocean = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_land_ocean_mask.tif'
LOGO_IMAGE = '/Users/icarroll/Downloads/nasa.png'

# read GeoTIFFs
gdal.UseExceptions()
ds = gdal.Open(AF_SOILSTORE_ANOM)
data = ds.ReadAsArray()
mask = gdal.Open(AF_land_ocean).ReadAsArray()

# set mask to nan for transparency
mask[mask == 0] = numpy.nan

# find data extent
ulx, xres, xskew, uly, yskew, yres = ds.GetGeoTransform()
lrx = ulx + (ds.RasterXSize * xres)
lry = uly + (ds.RasterYSize * yres)
ext = (ulx, lrx, lry, uly)

# confirm GEOGCS WGS 84
prj = ds.GetProjection()
srs = osr.SpatialReference(wkt=prj)
assert srs.GetAuthorityCode('geogcs') == '4326'
src_proj = PlateCarree()

# create geoaxes and color map
fig = pyplot.figure()
## proj = Orthographic(central_longitude=18.0)
proj = PlateCarree()
ax = fig.add_axes([0, 0, 1, 1], projection=proj)

# plot data and mask
src_kw = {
    'origin': 'upper',
    'extent': ext,
    'transform': src_proj,
}
art = ax.imshow(data, vmin=-20, vmax=20, cmap='BrBG', **src_kw)
cbar = pyplot.colorbar(art, shrink=0.9)
cbar.ax.tick_params(axis='both', which='both', length=0)

gl = ax.gridlines(crs=proj, draw_labels=True,
                  linewidth=1, color='gray', alpha=0.5, linestyle='--')
gl.xlabels_top = False
gl.ylabels_right = False
# gl.xlines = False
# gl.ylines = False
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER
gl.xlabel_style = {'size': 15, 'color': 'gray'}
gl.ylabel_style = {'size': 15, 'color': 'gray'}

# plot mask
cmap = colors.ListedColormap([[.616, .769, .965], [.835, .847, .863]])
ax.imshow(mask, cmap=cmap, **src_kw)

# add features
ax.add_feature(COASTLINE)
ax.add_feature(BORDERS)

# nasa logo
inset = fig.add_axes([0.1, 0.05, 0.25, 0.15])
inset.imshow(image.imread(LOGO_IMAGE))
pyplot.axis('off')

# safest to set extent last, adding stuff sometimes changes it
ax.set_extent(ext, proj)
pyplot.savefig('out.png', dpi=400, bbox_inches='tight')

