from mpl_toolkits.basemap import Basemap
from astropy.io import ascii
import matplotlib.pyplot as plt
import matplotlib
import sys 
from ncepy import corners_res, gem_color_list, ndate

# Read in output from verif_precip_grid2gauge.fd/grid2gauge.f, such as
#  g2g_st4_20161226.dat
# plot the difference anl-gauge (mm)
#
#   (e.g /com/verf/prod/precip.20161223)
# Then run with $day as argument:
#   python /meso/save/Ying.Lin/python/examples/09_plt_gauges.py yyyymmdd 
# output file to be found in /stmpp1/Ying.Lin/
# Read the precip data
infile=sys.argv[1]
#tbl = ascii.read("dat/09_good-usa-dlyprcp-20151213")
tbl = ascii.read(infile)
tbl.colnames  

# Set contour levels for precip    
#clevs = [0,0.1,2,5,10,15,20,25,35,50,75,100,125,150,175]
clevs = [ -20,-10, -5, -3, -1,-0.5, 0.5, 1, 3, 5, 10, 20 ]
#            1    2    3  4   5    6   7   8  9 10   11
# above line: how many colors are needed?  
#Use gempak color table for precipitation
gemlist=gem_color_list()
# Use gempak fline color levels from pcp verif page
pcplist=[8,14,2,17,19,31,21,22,23,25,28]
#Extract these colors to a new list for plotting
pcolors=[gemlist[i] for i in pcplist]

m = Basemap(llcrnrlon=-119,llcrnrlat=22,urcrnrlon=-64,urcrnrlat=49,
         resolution='l',projection='lcc',lat_1=33,lat_2=45,lon_0=-95)

m.drawcoastlines()
m.drawcountries()
m.drawstates()
m.drawmapboundary()

# col #1 is latitude, col #2 is longitude that have positive values that
# need to be made negative for west longitude. 

# Pull out the precip from the table and convert to mm
diff = tbl['col5'] - tbl['col4']

# Set up the colormap and normalize it so things look nice
mycmap=matplotlib.colors.ListedColormap(pcolors)
norm = matplotlib.colors.BoundaryNorm(clevs, mycmap.N)

# Set some options for circle size and circle line width
circle_size=12
circle_line_width=0.

# Make the scatter plot using the Basemap interface to matplotlib
sc=m.scatter(tbl['col3'],tbl['col2'],circle_size,
             diff,cmap=mycmap,norm=norm,latlon=True,lw=circle_line_width)

# plot the color bar
cbar = m.colorbar(sc,location='bottom',pad="5%",ticks=clevs,extend='both')
cbar.ax.tick_params(labelsize=8.5)
mycmap.set_under('hotpink')
mycmap.set_over('slateblue')
#plot the units label for the color bar
cbar.set_label('mm')
plt.title('anl-gauge diff:'+infile)
plt.savefig('diff.png',bbox_inches='tight')
plt.show()
