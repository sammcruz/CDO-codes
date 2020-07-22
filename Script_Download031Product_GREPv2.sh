#!/bin/bash

#==============================================================
# Script para download dos resultados do produto GREP Physics Analysis and Forecast updated Daily;
# Faz o download de um arquivo mensal das variáveis ssh (zos), salinidade (so), temperatura (to), u (uo) e v (vo), da profundidade
# mínima à máxima para área e período de interesses. Além disso, avalia se o arquivo do dia pretendido ao longo do loop foi baixado
# para a pasta de destino, se sim, segue para o próximo download, caso contrário (devido algum erro), tenta baixa-lo novamente.
# Autor: Samantha Cruz - 18 de janeiro de 2020
#==============================================================

#--------------------------------------------------------------
# Parametros do usuario
user=(username) # login no CMEMS
pass=(psswd)   # CMEMS password

# directory where your motu-client.py is located
motu=(/home/samantha/.local/lib/python3.6/site-packages/motuclient.pyc)
# destiny folder
dest=(/home/samantha/Documents)

# subsetting box
xmin=(-56)
xmax=(21)
ymin=(-36)
ymax=(-2)

# depth limits
zmin=(0.5056)
zmax=(5902.058300000001)

# All period you want to download
inicio=(1993-01-01) # start
fim=(2017-12-31)    # end
#---------------------------------------------------------------

fim=`date +%F --date=""${fim}" 00:00:00 1 year"`
seguinte=`date +%Y-%m-%d --date=""${inicio}" 00:00:00 1 month"`

seguinte=$(date -d "$seguinte -1 days" +"%Y-%m-%d")

while [ "$inicio" != "$fim" ]; do

echo "Downloading $inicio to $seguinte"

if [ -s $dest/GREP_$inicio.nc ]; # CHECK IF THE FILE YOU WANT TO DOWNLOAD IS ALREADY N THE FOLDER
	inicio=`date +%Y-%m-%d --date=""${inicio}" 00:00:00 1 month"`
	seguinte=`date +%Y-%m-%d --date=""${inicio}" 00:00:00 1 month"`
	seguinte=$(date -d "$seguinte -1 days" +"%Y-%m-%d")
fi

echo "Downloading $inicio to $seguinte"

python3.6 -m motuclient --motu http://my.cmems-du.eu/motu-web/Motu --service-id GLOBAL_REANALYSIS_PHY_001_031-TDS --product-id global-reanalysis-phy-001-031-grepv2-daily --longitude-min -44 --longitude-max -28 --latitude-min -24 --latitude-max -18 --date-min "${inicio} 00:00:00" --date-max "${seguinte} 00:00:00" --depth-min ${zmin} --depth-max ${zmax} --variable uo_foam --variable vo_foam --variable thetao_foam --variable so_foam --variable zos_foam --variable uo_oras --variable vo_oras  --variable thetao_oras --variable so_oras --variable zos_oras --out-dir ${dest} --out-name GREP_${inicio}.nc --user ${user} --pwd ${pass}


# All Vars:
# --variable uo_glor --variable vo_glor --variable thetao_glor --variable so_glor --variable zos_glor
# --variable uo_cglo --variable vo_cglo  --variable thetao_cglo --variable so_cglo --variable zos_cglo 
# --variable uo_foam --variable vo_foam --variable thetao_foam --variable so_foam --variable zos_foam
# --variable uo_oras --variable vo_oras  --variable thetao_oras --variable so_oras --variable zos_oras


done





























