#!/bin/bash

#####################################################################################################
# Pré-processamento dos arquivos originais dos resultados de um modelo e de um experimento do CMIP5 #
# Ajeita os arquivos para ficarem com os tempos iguais                                              #
# Mudar o ROOTDIR e ao rodar a rotina selecionar o modelo e o experimento que está trabalhando      #
#Date: 28/10/2017 ---- OK
#Authors: Luciana
#####################################################################################################

ROOTDIR=/media/luciana/CMIP5/
cd $ROOTDIR

# echo "Modelo utilizado: (HadGEM2-ES/CM3/IPSL)"
#read modelo
modelo=HadGEM2-ES
cd $modelo

# echo "Experimento utilizado: (historical/rcp/decadal)"
#read experimento
experimento=historical
cd $experimento/ocean/raw

####seria mais o friver zos são iguais (um arquivo unico com todos os anos)
##friver so thetao so uo vo zos
for variavel in thetao so zos
    do
    echo "A variável a ser processada é a $variavel"

    # Pré processamento dos dados de SSH (variável zos)

    if [ "$variavel" == zos ]; then

    # 1) Selecionar os anos de interesse (de 1990 a 2005), para SSH (zos)

    cd $variavel

	  # for ens in $(seq 6 6)
      	    do
		echo "Selecionando anos de interesse para ensemble $ens"
    cdo selyear,1979/2005 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/zos/zos_Omon_HadGEM2-ES_historical_r2i1p1_195912-200511.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/zos_Omon_HadGEM2-ES_historical_r2i1p1_197901-200512.nc

		#cdo selyear,1979/2005 /media/leilane/Faggiani/Data/CMIP5/HadGEM2-ES/historical/ocean/raw/zos/zos_Omon_HadGEM2-ES_historical_r${ens}i1p1_185001-200512.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/zos_Omon_HadGEM2-ES_historical_r${ens}i1p1_197501-200512.nc
		#mv /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/*_197501-200512.nc $ROOTDIR/$modelo/$experimento/ocean/raw/pre_proc_leilane
	    done
	cd ..
    else

      # Pré processamento dos dados de ********** (variável friver)
      # 1) Selecionar os anos de interesse (de 1990 a 2005), para SSH (zos)

      cd $variavel

  	  # for ens in $(seq 6 6)
        	    do
  		echo "Selecionando anos de interesse para ensemble $ens"
      cdo selyear,1979/2005 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/friver/friver_Omon_HadGEM2-ES_historical_r2i1p1_195912-200511.nc  /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/friver_Omon_HadGEM2-ES_historical_r2i1p1_197912-200511.nc

  		#cdo selyear,1979/2005 /media/leilane/Faggiani/Data/CMIP5/HadGEM2-ES/historical/ocean/raw/zos/zos_Omon_HadGEM2-ES_historical_r${ens}i1p1_185001-200512.nc /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/zos_Omon_HadGEM2-ES_historical_r${ens}i1p1_197501-200512.nc
  		#mv /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/*_197501-200512.nc $ROOTDIR/$modelo/$experimento/ocean/raw/pre_proc_leilane
  	    done
  	cd ..
      else


    # Pré processamento das outras variáveis

    # 2) Juntando os dois arquivos para as outras quatro variáveis

    cd $variavel

	for ens in $(seq 6 6)
    	    do
		echo "Juntando arquivos da variável $variavel e ensemble $ens"
		cdo mergetime ${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_* /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/tt.nc
		cdo selyear,1975/2005 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp1.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc
		rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp1.nc
		    if [ "$variavel" == thetao ]; then
		    echo "Mudando de Kelvin para Celsius $variavel e ensemble $ens"
		    cdo subc,273.15 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc
		    rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc
		    ncatted -a units,thetao,m,c,"Celsius degree" /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc
		    rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/temp2.nc

		    elif [ "$variavel" == so ]; then
		    echo "Mudando unidade para salinidade $variavel e ensemble $ens"
		    cdo mulc,1000 /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/salt.nc
		    rm /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc
		    mv /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/salt.nc /media/luciana/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc/${variavel}_Omon_HadGEM2-ES_historical_r${ens}i1p1_197901-200512.nc
		    #rm /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/salt.nc

		    fi

		#mv /home/leilane/RESULTADOS/CMIP5/HadGEM2-ES/historical/ocean/raw/pre_proc_leilane/*_197501-200512.nc $ROOTDIR/$modelo/$experimento/ocean/raw/pre_proc_leilane
	    done
    cd ..

    fi

done
