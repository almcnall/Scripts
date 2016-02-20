cd('/gibber/lis_data/OUTPUT')

%% initialize the mapping stuff

%idl coordinates for RFE subset
NX = 301;
NY = 321;

ul_lat = 40.0;
ul_lon = -20.0;
lr_lat = -40.0;
lr_lon = 55.0;

lon = ul_lon:0.25:lr_lon;
lat = lr_lat:0.25:ul_lat;

countries=shaperead('/home/husak/Matlab/boundaries/africa_countries.shp');
coasts = shaperead('/home/husak/Matlab/boundaries/africa_coastlines.shp');
africa = shaperead('/home/husak/Matlab/boundaries/africa.shp');

m_proj('Equidistant Cylindrical','longitudes',[floor(min(lon)-2) ceil(max(lon)+2)], ...
  'latitudes',[floor(min(lat)-2) ceil(max(lat)+2)],'direction','vertical','aspect',0.5);



%% make graphic of number of dekads in LGP
infile = '/gibber/lis_data/OUTPUT/EXP021/NOAH/month_total_units/rain_200111_tot.img';
fid = fopen(infile,'r');
ndeks = fread(fid,[NX NY],'float32');
fclose(fid);

subplot(1,1,1);
tmp = ndeks;
%tmp(tmp == 0) = NaN;
%m_pcolor(lon',lat',flipud(tmp'));
contourcmap([0:25:400],'jet');
shading flat;
m_grid; colorbar;
title('Number of dekads in Growing Period');

for i=1:size(africa,1);
   m_line(africa(i).X,africa(i).Y,'color',[0 0 0]);
end

c = colormap;
c = flipdim(c,1);
colormap(c);
print -djpeg -r100 SA_LGP.jpg
