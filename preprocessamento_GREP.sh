for i in *.nc
	do
	echo u$i
	cdo -b f32 -copy -setmissval,nan $i u$i
done

