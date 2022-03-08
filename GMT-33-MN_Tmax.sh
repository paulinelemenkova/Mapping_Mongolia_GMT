#!/bin/sh
# #!/bin/sh
# Purpose: Climate datasets https://climate.northwestknowledge.net/TERRACLIMATE/index_directDownloads.php (here: Mongolia)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract subset of img file in Mercator or Geographic format
gmt grdcut TerraClimate_tmax_2019.nc -R87.5/120/41.5/52.5 -Gmn_tmax.nc
gdalinfo -stats mn_tmax.nc
# Minimum=-32.100, Maximum=1.000, Mean=-15.443, StdDev=4.977
#gmt makecpt -Chaxby -T-234/393/1 > colors.cpt
gmt makecpt -Cwysiwyg -T-33/1/0.5 > pauline.cpt
# gmt makecpt --help


#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R87.5/120/41.5/52.5 -JPoly/6.5i -Dh -M -EMN > Mongolia.txt
#####################################################################

ps=MN_tmax.ps
# Make background transparent image
gmt grdimage mn_tmax.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JPoly/6.5i -I+a15+ne0.75 -t100 -Xc -P -K > $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R87.5/120/41.5/52.5 -JPoly/6.5i Mongolia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mn_tmax.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JPoly/6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mn_tmax.nc -R -J -C2 -A2+f7p,0,black+gwhite@60 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg87.6/38.9+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg4f0.2a2+l"Colormap: 'wysiwyg': 20 well-separated RGB colors [C=RGB] -33/-4/0.5)" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_GRID_PEN_PRIMARY=thinner,grey \
    --MAP_GRID_PEN_SECONDARY=thinnest,grey \
    -Bpxg10f5a5 -Bpyg10f2.5a2.5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.1c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Tmax (maximum temperature) in Mongolia (2019)" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-2.3c+c10+w1000k+l"American polyconic projection. Scale (km)"+f \
    -UBL/0p/-60p -O -K >> $ps

# Texts
# Hydrology
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB -Gwhite@60 >> $ps << EOF
92.3 50.1 Uvs Nuur
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB >> $ps << EOF
93.3 48.1 Khyargas
93.3 47.7 Nuur
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-340 -Gwhite@60 >> $ps << EOF
103.5 49.63 Selenga
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-335 -Gwhite@60 >> $ps << EOF
110.3 47.4 Kherlen
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-330 -Gwhite@60 >> $ps << EOF
110.5 48.7 Onon
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-45 -Gwhite@60 >> $ps << EOF
93.06 49.47 Tes
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,white+jLB+a-280 >> $ps << EOF
100.1 50.0 Khövsgöl
EOF
#
# Mts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,black+jLB+a-40 -Gwhite@50  >> $ps << EOF
89.0 48.6  A  l  t  a  i   M  t  s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,black+jLB+a-10 -Gwhite@50 >> $ps << EOF
96.3 47.2 Khangai Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,black+jLB+a-315 -Gwhite@50 >> $ps << EOF
107.3 47.3 Khentii Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB+a-330  >> $ps << EOF
105.1 42.0 G o b i  D e s e r t
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@30 >> $ps << EOF
103.70 48.20 Ulaanbaatar
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
106.92 47.92 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
104.20 49.10 Erdenet
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
104.04 49.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
106.10 49.50 Darkhan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
105.95 49.46 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
112.70 47.63 Choibalsan
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
114.53 48.07 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
99.30 49.25 Mörön
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
100.15 49.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
91.40 48.15 Khovd
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
91.64 48.00 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
90.20 49.00 Ölgii
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
89.97 48.96 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
100.90 45.80 Bayankhongor
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
100.72 46.19 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
102.93 46.36 Arvaikheer
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
102.77 46.26 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@30 >> $ps << EOF
89.15 50.10 Ulaangom
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
92.06 49.98 0.20c
EOF

# Add GMT logo
gmt logo -Dx7.0/-2.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.7c -N -O \
    -F+f10p,21,black+jLB >> $ps << EOF
2.1 9.0 Dataset: TerraClimate. Input Data WorldClim, CRUTS4.0. Spatial resolution: 4 km (1/24\232)
EOF

# Convert to image file using GhostScript
gmt psconvert MN_tmax.ps -A0.5c -E720 -Tj -Z
