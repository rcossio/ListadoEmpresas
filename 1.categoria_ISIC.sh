
# Hola!
# En la pagina https://trade.nosis.com/es/
# buscar una empresa que encaje con el objetivo, 
# y buscar la categoria principal de la empresa
# Colocar el link de busqueda de empresas como fuente
# Colocar numero de paginas
# Elegir un nombre para recordar

output="prueba.csv"
fuente="https://trade.nosis.com/es/q?categories=45821+46572+46734+46745+46748+46749&T_tipoPerfil=Empresas"
num_pags=14


#demasiadas empresas!
[ "$num_pags" -gt "100" ] && echo "La busqueda se limita a 2000 empresas (100 paginas), considerar reformular la busqueda o colocar num_pags=100" && exit

mkdir search_results #(temporal)
mkdir nosis_lists  #esta carpeta queda
download_error="No pude descargar la ultima pagina!"

for i in $(seq 1 1 $num_pags)
do
	#borra paginas previamente descargadas y descarga
	[ -f search_results/$i.html ] && rm search_results/$i.html
	wget -O search_results/$i.html "${fuente}&page=$i"

	#si no se pudo descargar, detiene el script
	[ ! -f search_results/$i.html ] && echo "$download_error" && exit

	# metodo viejo, buscar la pagina
	#grep -A 10 resultadosDeBusquedaContent search_results/$i.html | grep href | awk -F '"' '{print "https://trade.nosis.com"$2}' | sed -e "s/&#39;/'/g" > nosis_lists/nosis_list_${i}.txt

	# metodo nuevo, acceder a una pagina imprimible, mas pequeña
	grep -A 10 resultadosDeBusquedaContent search_results/$i.html | grep href | awk -F '"' '{print $2}' | sed -e "s/&#39;/'/g" | awk -F '/' '{print "https://trade.nosis.com/"$2"/y/"$5"/"$4"/"$3}'  > nosis_lists/nosis_list_${i}.txt

done

#borra las paginas de busqueda
rm -r search_results

#Otros lugares interesantes
# https://w20argentina.com/ (será redundante?)
#https://www.argentino.com.ar/argentina/nombre+de+la+empresa
# Busqueda por cuit en trade.nosis https://trade.nosis.com/es/q?query=30514392001&T_tipoPerfil=Empresas

# Max time de error 403: 190 seg
