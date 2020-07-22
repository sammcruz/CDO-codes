#!/bin/bash

#####################################################################################################
#Date: 28/10/2017
#Authors: Luciana  
#####################################################################################################

ROOTDIR=/media/luciana/CMIP5/
cd $ROOTDIR

echo "Modelo utilizado: (HadGEM2-ES/CM3/IPSL)"
#read modelo
modelo=HadGEM2-ES
cd $modelo

echo "Experimento utilizado: (historical/rcp/decadal)"
#read experimento
experimento= historical
cd $experimento/ocean/raw

# echo "ensemble: de 1 a 6"
# ens="6"
#read ens

#zos thetao so
# friver
for var in uo vo
    do

    echo "A variável a ser processada é a $var"

#1) Converter de grade curvilinear para grade regular

	echo "Convertendo grid curvilinear para regular: variável $var e ensemble $ens"
	cdo setgridtype,lonlat -remapycon,r360x180 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${var}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp1.nc

#2) Mudar a longitude de 0 a 360 para 180 a -180

	echo "Mudando a longitude: variável $var e ensemble $ens"
	cdo sellonlatbox,-180,180,-90,90 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp1.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc
	rm /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/temp1.nc

#3) Selecionar área de interesse

	echo "Recortando para o AS: variável $var e ensemble $ens"
	cdo sellonlatbox,-90,30,-80,30 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp3.nc
	rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc

#5) Mudar a data de referência

	echo "Mudando a data de referencia: variável $var e ensemble $ens"
	cdo setreftime,1900-01-01,00:00:00,days /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp3.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${var}_${modelo}_${experimento}_r${ens}i1p1_197901-200512.nc
	rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp3.nc

  # if [ "${var}" == uo ] || ["${var}" == vo ]; then
  #   cdo chname,lon,lonu,lat,latu /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/lala2.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/${var}_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc
  # else
  #   mv /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/lala2.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/${var}_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc
  # fi

# COMMENT
# parei aqui.. a partir daqui nao sei o que fazer!





mkdir merge

mv /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/${var}_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge

done

#6) Criar ubar e vbar de referência

cd merge

	# echo "Criando ubar a partir do ensemble $ens"
	# cdo vertmean uo_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc lalau.nc
	# cdo chname,uo,ubar lalau.nc ubar_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc
	# echo "Criando vbar a partir do ensemble $ens"
	# cdo vertmean vo_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc lalav.nc
	# cdo chname,vo,vbar lalav.nc vbar_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc
	# rm lala*

  # Calculo de UBAR ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  echo "Pega o grid já convertido para regular pelo FERRET"
  cp ~/ROTINAS/FERRET/bathy_U_regular_1grau.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/

  echo "Mudando a longitude do arquivo de batimetria de 0-360 para -180+180"
  cdo sellonlatbox,-180,180,-90,90 ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U_regular_1grau.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U_regular_1grau.nc

  echo "Recortando para o AS a batimetria"
  cdo sellonlatbox,-90,30,-80,30 ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc

  echo "Copia o arquivo de espessura dz do HadGEM2-ES para a pasta"
  cp /media/leilane/Faggiani/Data/CMIP5/HadGEM2-ES/historical/ocean/raw/uo/dz_HadGEM2-ES.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/

  echo "Adicionando a velocidade baroclínica uo ao arquivo de espessura de dz"
  ncks -A /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/uo_HadGEM2-ES_historical_r6i1p1_197501-200512.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc

  echo "Multiplicando uo por dz nas 60 camadas"
  ncap2 -s 'uodz = uo*dz' ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/uodz.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc

  echo "Calculando o somatório da velocidade barotrópica nas 60 camadas"
  ncap2 -s 'vertical_sum = uodz.total($lev)' ~/RESULTADOS/CMIP5/HadGEM2-ES/uodz.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/uodz.nc

  # echo "Renomeia dimensões do arquivo de grid para que fique igual as dimensões do arquivo de somatório"
  # ncrename -d lat,j -d .lon,i ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc

  echo "Adicionando a batimetrias nos pontos U da grade (Hu) ao arquivo de somatorio"
  ncks -A ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  # rm ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc

  echo "Divide o somatório pela profundidade em U (Hu)"
  ncap2 -s 'ubar = vertical_sum/bathymetry' ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  cdo -select,name=ubar ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/ubar_HadGEM2-ES_historical_r6i1p1_197501-200512.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc

  # Calculo de VBAR ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  # echo "Pega o grid já convertido para regular pelo FERRET"
  # cp ~/ROTINAS/FERRET/bathy_U_regular.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/
  #
  # echo "Mudando a longitude do arquivo de batimetria"
  # cdo sellonlatbox,-180,180,-90,90 ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U_regular.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc
  # rm ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U_regular.nc
  #
  # echo "Recortando para o AS a batimetria"
  # cdo sellonlatbox,-90,30,-80,30 ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc
  # rm ~/RESULTADOS/CMIP5/HadGEM2-ES/lala.nc

  echo "Copia dz HadGEM2-ES"
  cp /media/leilane/Faggiani/Data/CMIP5/HadGEM2-ES/historical/ocean/raw/uo/dz_HadGEM2-ES.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/

  echo "Adicionando vo ao arquivo de dz"
  ncks -A /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/vo_HadGEM2-ES_historical_r6i1p1_197501-200512.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc

  echo "Multiplicando vo por dz nas 60 camadas"
  ncap2 -s 'vodz = vo*dz' ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/vodz.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/dz_HadGEM2-ES.nc

  echo "Calculando o somatório da velocidade barotrópica nas 60 camadas"
  ncap2 -s 'vertical_sum = vodz.total($lev)' ~/RESULTADOS/CMIP5/HadGEM2-ES/vodz.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/vodz.nc

  echo "Adicionando Hu ao arquivo de somatorio"
  ncks -A ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/bathy_U.nc

  echo "Divide o somatório pela profundidade em U (Hu)"
  ncap2 -s 'vbar = vertical_sum/bathymetry' ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/somatorio.nc
  cdo -select,name=vbar ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/vbar_HadGEM2-ES_historical_r6i1p1_197501-200512.nc
  rm ~/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#7) Unindo os arquivos em um só, por ensemble

	cdo merge /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/*_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc
	echo "Unindo arquivo do ensemble $ens"

#8) Mudando nome das variáveis

	echo "Mudando nome das variáveis do ensemble $ens e alterando o nome de latlon das vel que são diferentes das outras variáveis"
  cdo chname,uo,u,vo,v /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala1.nc
  # cdo chname,zos,ssh,thetao,temp,so,salt,uo,u,vo,v /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala1.nc
	rm /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala.nc


#9) Mudar os missing values para NaN - DESCOMENTAR!!!!!

	echo "Mudando os missing values para NaN: variável $var e ensemble $ens"
	cdo setmissval,NaN /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala1.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512_UV.nc
#	cdo setmissval,NaN lala.nc ${var}_${modelo}_${experimento}_r${ens}i1p1_197501-200512.nc
	rm /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/lala1.nc

#10) Mudar o nome de lon e lat
  echo "Muda lonlat para lonu e latu"
  ncrename -O -v lon,lonu /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512_UV.nc
  ncrename -O -v lat,latu /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512_UV.nc
  ncrename -O -d lon,lonu /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512_UV.nc
  ncrename -O -d lat,latu /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512_UV.nc

# Essa parte é depois de finalizar
# #10) Separar em arquivos mensais
#
# 	for year in $(seq 1975 2005)
# 	do
# 	echo "Selecionando ano ${year}"
#
# 	cdo selyear,${year} /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_197501-200512.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_Y${year}M_all.nc
#
# 	for mon in $(seq 1 12)
# 	do
# 	echo "Selecionando ano ${year} e mes ${mon}"
#
# 	cdo selmon,${mon} /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/merge/${modelo}_${experimento}_Y${year}M_all.nc /media/leilane/Faggiani/Data/CMIP5/HadGEM2-ES/historical/ocean/ready_leilane/${modelo}_${experimento}_Y${year}M${mon}.nc
#
# 	done
# 	done
