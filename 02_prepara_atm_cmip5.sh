#!/bin/bash

#####################################################################################################
#bla bla bla
#necessário ter instalado o CDO e o NCO!!!
#####################################################################################################

ROOTDIR=/media/luciana/CMIP5/
cd $ROOTDIR

#echo "Modelo utilizado: (HadGEM2-ES/CM3/IPSL)"
#read modelo
modelo=HadGEM2-ES
cd $modelo

#echo "Experimento utilizado: (historical/rcp/decadal)"
#read experimento
experimento=historical
cd $experimento/atm/raw

# pr tas huss rlds swrad uas vas ps

for variavel in pr
    do
		echo "Variável a ser processada: $variavel"
		cd $variavel

		for year in $(seq 1985 2005)
    do
      echo "Estou processando o ano: $year"
		    # Vento
		    if [ "$variavel" == uas ] || [ "$variavel" == vas ]; then

			    echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
			    cdo sellonlatbox,-90,30,-80,30 ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
          echo "Selecionando a cada 6 horas a variavel ${variavel} do ano $year"
				  cdo seltime,00:00:00,06:00:00,12:00:00,18:00:00 luciana/temp1.nc luciana/temp2.nc
				  rm luciana/temp1.nc

					if [ "$variavel" == uas ]; then
					echo "Mudando nome da variavel $variavel e ano $year"
					cdo chname,uas,Uwind luciana/temp2.nc luciana/$modelo-$variavel-$year.nc
					rm luciana/temp2.nc
					fi

					if [ "$variavel" == vas ]; then
					echo "Mudando nome da variavel $variavel e ano $year"
					cdo chname,vas,Vwind luciana/temp2.nc luciana/$modelo-$variavel-$year.nc
					rm luciana/temp2.nc
					fi

		    # Net SW radiation
		    elif [ "$variavel" == swrad ]; then
				  echo "Selecionando horas variavel rsds e ano $year"
				  cdo seltime,01:30:00,07:30:00,13:30:00,19:30:00 rsds_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/rsds_${year}.nc
				  echo "Selecionando horas variavel rsus e ano $year"
				  cdo seltime,01:30:00,07:30:00,13:30:00,19:30:00 rsus_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/rsus_${year}.nc

				  echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
				  cdo sellonlatbox,-90,30,-80,30 luciana/rsds_${year}.nc luciana/temp_down.nc
				  cdo sellonlatbox,-90,30,-80,30 luciana/rsus_${year}.nc luciana/temp_up.nc
				  rm luciana/rsds_${year}.nc luciana/rsus_${year}.nc

				  echo "Calculando o net radiation para SW ano $year"
				  cdo sub luciana/temp_down.nc luciana/temp_up.nc luciana/temp1.nc
				  rm luciana/temp_*

				  echo "Mudando nome das variaveis para $variavel e ano $year"
				  cdo chname,rsds,swrad luciana/temp1.nc luciana/temp2.nc
				  rm luciana/temp1.nc

				  echo "Mudando metadado variavel $variavel e ano $year"
				  ncatted -a standard_name,swrad,m,c,"surface_net_sw_radiation" luciana/temp2.nc luciana/temp3.nc
				  ncatted -a long_name,swrad,m,c,"Surface Net Shortwave Radiation" luciana/temp3.nc luciana/$modelo-$variavel-$year.nc
          rm luciana/temp2.nc luciana/temp3.nc
		    else


				# Temperatura
				if [ "$variavel" == tas ]; then
          echo "Selecionando horas variavel $variavel e ano $year"
          cdo seltime,00:00:00,06:00:00,12:00:00,18:00:00 ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
          echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
  		    cdo sellonlatbox,-90,30,-80,30 luciana/temp1.nc luciana/temp2.nc
  		    rm luciana/temp1.nc
  				echo "Convertendo de Kelvin para Celsius ano $year"
  				cdo subc,273.15 luciana/temp2.nc luciana/temp3.nc
  				rm luciana/temp2.nc
  				echo "Mudando nome da variavel $variavel e ano $year"
  				cdo chname,tas,Tair luciana/temp3.nc luciana/temp4.nc
  				rm luciana/temp3.nc
  				echo "Mudando metadado variavel $variavel e ano $year"
  				ncatted -a units,Tair,m,c,"Celsius degree" luciana/temp4.nc luciana/$modelo-$variavel-$year.nc
  				rm luciana/temp4.nc
				fi

				# Precipitacao
				if [ "$variavel" == pr ]; then
          echo "Selecionando horas variavel $variavel e ano $year"
          cdo seltime,01:30:00,07:30:00,13:30:00,19:30:00 ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
          echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
  		    cdo sellonlatbox,-90,30,-80,30 luciana/temp1.nc luciana/temp2.nc
  		    # rm luciana/temp1.nc
  				echo "Mudando nome da variavel $variavel e ano $year"
  				cdo chname,pr,rain luciana/temp2.nc luciana/$modelo-$variavel-$year.nc
  				# rm luciana/temp2.nc
				fi

				# Umidade - está em kg/kg - no CFSR esta em g/kg
				if [ "$variavel" == huss ]; then
          echo "Selecionando horas variavel $variavel e ano $year"
          cdo seltime,00:00:00,06:00:00,12:00:00,18:00:00 ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
          echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
  		    cdo sellonlatbox,-90,30,-80,30 luciana/temp1.nc luciana/temp2.nc
  		    rm luciana/temp1.nc
  				echo "Mudando nome da variavel $variavel e ano $year"
  				cdo mulc,1000 luciana/temp2.nc luciana/temp3.nc
          rm luciana/temp2.nc
  				cdo chname,huss,Qair luciana/temp3.nc luciana/$modelo-$variavel-$year.nc
  				rm luciana/temp3.nc
				fi

				# Pressao
				if [ "$variavel" == ps ]; then
          echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
  		    cdo sellonlatbox,-90,30,-80,30 ${variavel}_6hrLev_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
  				echo "Convertendo de Pascal para milibar ano $year"
  				cdo divc,100 luciana/temp1.nc luciana/temp2.nc
  				rm luciana/temp1.nc
  				echo "Mudando nome da variavel $variavel e ano $year"
  				cdo chname,ps,Pair luciana/temp2.nc luciana/temp3.nc
  				rm luciana/temp2.nc
  				echo "Mudando metadado variavel $variavel e ano $year"
  				ncatted -a units,Pair,m,c,"milibar" luciana/temp3.nc luciana/$modelo-$variavel-$year.nc
  				rm luciana/temp3.nc
				fi

				# Radiacao de onda longa
				if [ "$variavel" == rlds ]; then
          echo "Selecionando horas variavel $variavel e ano $year"
          cdo seltime,01:30:00,07:30:00,13:30:00,19:30:00 ${variavel}_3hr_HadGEM2-ES_historical_r2i1p1_${year}.nc luciana/temp1.nc
          echo "Recortando para o Atlantico Sul variavel $variavel e ano $year"
  		    cdo sellonlatbox,-90,30,-80,30 luciana/temp1.nc luciana/temp2.nc
  		    rm luciana/temp1.nc
  				echo "Mudando nome da variavel $variavel e ano $year"
  				cdo chname,rlds,lwrad_down luciana/temp2.nc luciana/$modelo-$variavel-$year.nc
  				rm luciana/temp2.nc
				fi

			    fi

		done

		#4) Juntando todos os aquivos

      		echo "Juntando os arquivos variavel $variavel"
      		cdo copy luciana/$modelo-$variavel-* luciana/$modelo-$variavel.nc
      		# rm luciana/$modelo-$variavel-*


		#5) Mudar o time - DEIXAR PARA O FIM POR CAUSA DO PROBLEMA DAS DATAS!
      if [ "$variavel" == uas ] || [ "$variavel" == vas ] || [ "$variavel" == tas ] || [ "$variavel" == huss ] || [ "$variavel" == ps ]; then

          echo "Mudando a data de referência variavel $variavel"
          #funcionou na versão CDO 1.7.0 e 1.7.1. Este comando nao esta funcionando na versao CDO 1.9.1.
          cdo setreftime,1900-01-01,00:00:00,days -settaxis,1985-01-01,06:00:00,6hour -setcalendar,standard luciana/$modelo-$variavel.nc luciana/$variavel.nc
          rm luciana/$modelo-$variavel.nc
      else
          echo "Mudando a data de referência variavel $variavel"
          cdo setreftime,1900-01-01,00:00:00,days -settaxis,1985-01-01,07:30:00,6hour -setcalendar,standard luciana/$modelo-$variavel.nc luciana/$variavel.nc
          # rm luciana/$modelo-$variavel.nc
      fi

      		echo "Enviando arquivo para a pasta ready"
      		mv luciana/$variavel.nc $ROOTDIR/$modelo/$experimento/atm/ready

		# # Depois tem que rodar a rotina do Matlab para deixar o arquivo de acordo com o que o modelo entende!
		cd ../
done
