#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Mongolia)
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

# Extract a subset of ETOPO1m for the study area
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R87.5/120/41.5/52.5 -Gmn_relief.nc
gmt grdcut GEBCO_2019.nc -R87.5/120/41.5/52.5 -Gmn_relief.nc
gdalinfo -stats mn_relief.nc
# Minimum=-155.000, Maximum=4848.000, Mean=1319.129, StdDev=571.535

# Make color palette
#gmt makecpt -Cdem3.cpt -V -T-155/4848 > pauline.cpt
#gmt makecpt -Cwiki-schwarzwald-d020 -V -T500/4848 > pauline.cpt
gmt makecpt -Cwiki-schwarzwald-d050 -V -T500/4400 > pauline.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief

#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R87.5/120/41.5/52.5 -JPoly/6.5i  -Dh -M -EMN > Mongolia.txt
#gmt pscoast -Dh -M -ELB > Malawi.txt
#####################################################################

ps=Topo_MN.ps
# Make background transparent image
gmt grdimage mn_relief.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JPoly/6.5i  -I+a15+ne0.75 -t100 -Xc -P -K > $ps
    
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R87.5/120/41.5/52.5 -JPoly/6.5i  Mongolia.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage mn_relief.nc -Cpauline.cpt -R87.5/120/41.5/52.5 -JPoly/6.5i  -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour mn_relief.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
#gmt pscoast -R -J \
    -Ia/thinner,blue -Na -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
    
# Add color legend
gmt psscale -Dg87.2/38.9+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'wiki-schwarzwald-d050' elevation scale by Wikimedia Commons free media repository [R=0/4906 C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
#scheme for maps of North Rhine–Westphalia by Wikipedia contributor TUBS.
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_GRID_PEN_PRIMARY=thinner,grey \
    --MAP_GRID_PEN_SECONDARY=thinnest,grey \
    -Bpxg10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Topographic map of Mongolia" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx14.0c/-2.0c+c10+w1000k+l"American polyconic projection. Scale (km)"+f \
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
-F+jTL+f10p,26,blue2+jLB+a-340 -Gwhite@60 >> $ps << EOF
103.5 49.63 Selenga
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-335 -Gwhite@60 >> $ps << EOF
110.3 47.4 Kherlen
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-330 -Gwhite@60 >> $ps << EOF
110.5 48.7 Onon
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-45 -Gwhite@60 >> $ps << EOF
93.06 49.47 Tes
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,white+jLB+a-280 >> $ps << EOF
100.1 50.0 Khövsgöl
EOF
#
# Mts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB+a-55  >> $ps << EOF
89.0 48.6  A  l  t  a  i   M  t  s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,white+jLB+a-30 >> $ps << EOF
96.3 48.0 Khangai Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,white+jLB+a-315 >> $ps << EOF
107.3 47.3 Khentii Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,26,black+jLB+a-330  >> $ps << EOF
105.1 42.0 G o b i  D e s e r t
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
103.70 48.20 Ulaanbaatar
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
106.92 47.92 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@40 >> $ps << EOF
104.20 49.10 Erdenet
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
104.04 49.02 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,0,black+jLB -Gwhite@40 >> $ps << EOF
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
-F+f9p,0,yellow+jLB >> $ps << EOF
99.30 49.15 Mörön
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
100.15 49.63 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,yellow+jLB >> $ps << EOF
91.40 48.15 Khovd
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
91.64 48.00 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,yellow+jLB >> $ps << EOF
90.20 49.00 Ölgii
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
89.97 48.96 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,yellow+jLB >> $ps << EOF
100.90 45.80 Bayankhongor
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
100.72 46.19 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,yellow+jLB >> $ps << EOF
102.93 46.36 Arvaikheer
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
102.77 46.26 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
89.15 50.10 Ulaangom
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
92.06 49.98 0.20c
EOF

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w2.8c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,grey -Rg -JG102/5N/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -EMN+gred -Sdodgerblue -O -K -X$x0 -Y$y0 >> $ps
#gmt pscoast -Rg -JG12/5N/$w -Da -Gbrown -A5000 -Bg -Wfaint -ECM+gbisque -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

# Add GMT logo
gmt logo -Dx7.0/-2.7+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X1.0c -Y2.5c -N -O \
    -F+f10p,21,black+jLB >> $ps << EOF
2.4 9.0 Digital elevation data: SRTM/GEBCO, 15 arc sec (ca. 450 m) resolution grid
EOF

# Convert to image file using GhostScript
gmt psconvert Topo_MN.ps -A0.5c -E720 -Tj -Z
