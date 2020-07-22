
# Area de interesse
xmin=(-44)
xmax=(-28)
ymin=(-18)
ymax=(-24)

# pasta de destino do download
dest=(/home/samanthalof/Downloads/SODA)

for i in soda3.3.2_5dy_ocean_or*
    do
    
    ano=$(echo $i | cut -c24-33)
    echo -e "Cutting $i into ->> SODA_${ano} \n"
    cdo sellonlatbox,-44,-28,-24,-18 $i SODA_${ano}.nc
    mv SODA_${ano}.nc Cortados
    mv $i SODA_global_5d

done
exit








# pasta de destino do download
dest=(/media/samantha/OCEAN/Pesquisa/MODELOS/SODA)

# Intervalo de interesse
inicio=(2002-11-08) # data inicial
fim=(2019-01-03)    # data final

#---------------------------------------------------------------
seguinte=`date +%Y-%m-%d --date=""${inicio}" 12:00:00 5 day"`

cd /media/samantha/OCEAN/Pesquisa/MODELOS/SODA
for ((yi=1;yi<=10231; yi+=5))
    do
    	iniciof=`date +%Y_%m_%d --date="${inicio}"`

	echo -e "Baixando arquivo SODA de ${iniciof} \n"
	#echo "wget http://dsrs.atmos.umd.edu/DATA/soda3.3.2/ORIGINAL/ocean/soda3.3.2_5dy_ocean_or_${inicio}.nc"
	wget "http://dsrs.atmos.umd.edu/DATA/soda3.3.2/ORIGINAL/ocean/soda3.3.2_5dy_ocean_or_${iniciof}.nc"

if [ -s $dest/soda3.3.2_5dy_ocean_or_${iniciof}.nc ]; then #verifica se o arquivo se encontra na pasta destino
	cd /media/samantha/OCEAN/Pesquisa/MODELOS/SODA
	cdo sellonlatbox,${xmin},${xmax},${ymax},${ymin} soda3.3.2_5dy_ocean_or_${iniciof}.nc SODA_${inicio}.nc
	if [ -s $dest/SODA_${inicio}.nc ]; then
		rm soda3.3.2_5dy_ocean_or_${iniciof}.nc
		mv SODA_${inicio}.nc $dest/Cortados
	fi
	inicio="${seguinte}"
	seguinte=`date +%Y-%m-%d --date=""${inicio}" 12:00:00 5 day"`
fi


done


wget "http://dsrs.atmos.umd.edu/DATA/soda3.3.2/ORIGINAL/ocean/soda3.3.2_5dy_ocean_or_2003_09_24.nc" && wget "http://dsrs.atmos.umd.edu/DATA/soda3.3.2/ORIGINAL/ocean/soda3.3.2_5dy_ocean_or_2003_09_29.nc"



