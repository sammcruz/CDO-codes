#!/bin/bash

#####################################################################################################
#
# Lê os arquivos quinquenais do HadGEM2-ES e os separa anualmente para cada variável
#
# authors: Luciana/Leilane
# date: 26/10/2017
#####################################################################################################

ROOTDIR=/media/luciana/OCEAN_HD/
cd $ROOTDIR

#echo "Modelo utilizado: (HadGEM2-ES/CM3/IPSL)"
#read modelo
modelo=HadGEM2-ES
cd $modelo

#echo "Experimento utilizado: (historical/rcp/decadal)"
#read experimento
experimento=historical
cd $experimento/atm/raw

# echo "Variável a ser processada: pr (precipitation)
# 			  ps (surface air pressure)
# 			  tas (air temperature)
# 			  huss (specific humidity)
# 			  rlds (down LW solar radiation)
# 			  swrad (net SW radiation)
# 			  uas (u-wind in 10m)
# 			  vas (v-wind in 10m)"
# read variavel
# cd $variavel
# pr

# tas huss  uas vas rlds rsds rsus

  for ((year=1985;year<=2005; year+=5))
    do
      for variavel in huss uas vas rlds rsds rsus
        do
            if [ "$variavel" == rsds ] || [ "$variavel" == rsus ]; then
              cd swrad
          		echo "Juntanto os arquivos variavel $variavel"
            	cdo	mergetime ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_*.nc temp1.nc
              echo "Separando anualmente a variável $variavel"
              cdo splityear temp1.nc ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_
              rm temp1.nc
              cd ../../
            else
              cd $variavel
          		echo "Juntanto os arquivos variavel $variavel"
          		cdo mergetime *.nc temp1.nc
              echo "Separando anualmente a variável $variavel"
              cdo splityear temp1.nc ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_
              rm temp1.nc
              cd ../
            fi

  done

done


# Processando a variável PS
