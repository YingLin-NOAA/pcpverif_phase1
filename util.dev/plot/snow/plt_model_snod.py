# Plots precipitation analysis
#
# From Jacob Carley's NAMRR 'plot hourly QPF' code
import matplotlib
matplotlib.use('Agg')   #Necessary to generate figs when not running an Xserver (e.g. via PBS)
import ncepy
from ncepy import corners_res, gem_color_list, ndate
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pygrib, datetime
import sys 
# model name (e.g. fv3gfs)
# infile1: fcst range 1 (e.g. 12h fcst)
# infile2: fcst range 2 (e.g. 36h fcst)
model=sys.argv[1]
infile1=sys.argv[2]
infile2=sys.argv[3]

grbfin = pygrib.open(infile1)
snod1 = grbfin.select(name='Snow depth')[0]

grbfin = pygrib.open(infile2)
snod2 = grbfin.select(name='Snow depth')[0]

fhr1=snod1['stepRange']  # output would be '0', '24', etc.
#print fhr1
fhr2=snod2['stepRange']
#print fhr2

# Compute valid time:
cychrmm=snod2.dataTime #Cycle (e.g. 1200 UTC)
cycpdy=snod2.dataDate #PDY

cycyr= int(str(cycpdy)[0:4])
cycmn= int(str(cycpdy)[4:6])
cycdy= int(str(cycpdy)[6:8])
cychr= int(str(cychrmm)[0:2])

print 'cycyr,cycmn,cycdy,cychr=', cycyr,cycmn,cycdy,cychr
cycletime = datetime.datetime(cycyr,cycmn,cycdy,cychr,0)
validtime = cycletime + datetime.timedelta(hours=int(fhr2))
# validtime looks like this: 2019-02-23 12:00:00
# For the title/file name, we want '2019022312':
vdate = str(validtime)[0:4]+str(validtime)[5:7]+str(validtime)[8:10]+str(validtime)[11:13]
print vdate

# Convert SNOD from meter to inches:
vals = (snod2.values-snod1.values)*39.3701
grbfin.close()

# Get the lats and lons
lats, lons = snod1.latlons()

# Set contour levels for precip    
clevs = [ 0.0, 0.1, 1, 2, 4, 6, 8, 12, 18, 24, 30, 36 ]
 
#Use gempak color table for precipitation
gemlist=gem_color_list()
# Use gempak fline color levels from pcp verif page
pcplist=[31,28,25,21,23,19,20,11,12,2,14,30,1]
#Extract these colors to a new list for plotting
pcolors=[gemlist[i] for i in pcplist]

# Set up the colormap and normalize it so things look nice
mycmap=matplotlib.colors.ListedColormap(pcolors)
norm = matplotlib.colors.BoundaryNorm(clevs, mycmap.N)

fig = plt.figure(figsize=(8,8))
m = Basemap(llcrnrlon=-119,llcrnrlat=22,urcrnrlon=-64,urcrnrlat=49,
         resolution='l',projection='lcc',lat_1=33,lat_2=45,lon_0=-95)
m.drawcoastlines(linewidth=0.5)
m.drawcountries(linewidth=0.5)
m.drawstates(linewidth=0.5)

#cf = m.contourf(lons,lats,vals,clevs,latlon=True,colors=pcolors,extend='max')
cf = m.contourf(lons,lats,vals,clevs,cmap=mycmap,norm=norm,latlon=True,extend='max')
cf.set_clim(0,36) 
plt.title(model+' SNOD '+fhr1+'-'+fhr2+'h fcst valid at '+vdate)
# add colorbar.
cbar = m.colorbar(cf,location='bottom',pad="5%",ticks=clevs,format='%.1f')
cbar.ax.tick_params(labelsize=8.5)    
cbar.set_label('inches')

plt.savefig('snod_'+model+'.'+vdate+'.'+fhr2+'h.png',bbox_inches='tight')

