
#Copiar el header del script 1
output="prueba.csv"
fuente="https://trade.nosis.com/es/q?categories=45821+46572+46734+46745+46748+46749&T_tipoPerfil=Empresas"
num_pags=14



t0=$(date +%s)

mkdir paginas
[ ! -f $output ] && echo "NOMBRE; CUIT; ACTIVIDAD AFIP; ACTIVIDAD ISIC; PERFIL DE COMERCIALIZACIÓN; FECHA DE CONTRATO; FACTURADO; NRO DE EMPLEADxS; DOMICILIO; SITIO WEB; TELEFONO; REDES SOCIALES;USUARIO RESPONSABLE NOSIS; RESPONSABLE DE VENTAS" > $output


for nosis in $(seq 1 1 $num_pags)
do

input="nosis_lists/nosis_list_$nosis.txt"
echo "Empiezo a descargar paginas en $input"
echo "---------------------------------------------------------------------------------------------------------------------"

n=1
while IFS= read -r line
do
	id=$nosis-$n
	file=paginas/$id.html
	if [ ! -f paginas/$id.html ]||[ "$(cat paginas/$id.html)" == "" ]
	then
	        for i in {1..5}; do echo '';done

		#obtiene pagina
		echo $id
  		wget -O paginas/$id.html "$line"  #2> /dev/null


		# stops if error 
		if [ "$(cat paginas/$id.html)" == "" ] 
		then
			t=$(date +%s)
			dt=$((t-t0))
			echo " "
			echo "Se dieron cuenta de que soy un bot a los $dt segundos"
			echo " "
			/usr/bin/firefox --new-window https://trade.nosis.com/es/q?categories=46189+45619+46160+46161+46162+46183&T_tipoPerfil=Empresas
			exit
		fi



		# Obtencion de datos
		
		# Viejo, de cuando se obtenia la pagina de busqueda directamente
		#nombre=$(grep -A 1 profile-title     $file | tail -1 | awk -F ">" '{print $2}'| awk -F "<" '{print $1}')
	        #cuit=$(grep -A 3 profile-info-name $file | grep -m 1 -A 3 "CUIT"  | tail -1 | sed "s/-//g"| awk -F ">" '{print $2}'| awk -F "<" '{print $1}')
      		#afip=$(grep -A 4 profile-info-name $file | grep -A 4 "Actividad Principal AFIP" | tail -1 | awk '{print $1}')
        	#facturado=$(grep -A 3 profile-info-name $file | grep -A 3 "Facturación Estimada"  | tail -1 | awk -F ">" '{print $2}'| awk -F "<" '{print $1}' | sed "s/&gt;/>/g")
        	#empleados=$(grep -A 3 profile-info-name $file | grep -A 3 "Cantidad de Empleados" | tail -1 | awk -F ">" '{print $2}'| awk -F "<" '{print $1}')
		#domicilio=$(grep -A 5 profile-info-name $file | grep -A 5 "Domicilio" | tail -1 | sed 's/^ *//g' | awk '{print $0}'| sed 's/\r$//')
        	#sitioweb=$(grep site_name $file| awk -F '"' '{print $4}')
        	#telefono=$(grep -A 20 profile-info-name $file | grep -A 20 "Teléfonos" | grep "li class"| awk -F ">" '{print $2}'| awk -F "<" '{printf $1","}')
        	#sitioweb2=$(grep -A 20 profile-info-name $file | grep -A 20 "Sitios" | grep "itemprop"| awk -F ">" '{print $2}'| awk -F "<" '{printf $1","}')
		#redessociales=$(grep -A 20 profile-info-name $file | grep -A 20 "Redes Sociales"| grep "href" | awk -F "\"" '{print $2}' | awk '!seen[$0]++' | awk '{printf $0", "}')
		#actividad ISIC:             <div class="profile-info-name"> Actividad ISIC Principal </div>^M

		#Visualizaciones <a href="#" id="visualizacionesTrigger" onclick="ShowVisualizaciones('/es/Empresa/VerDetalleVisualizaciones?idEmpresa=1667154','BAGGINI HNOS SRL')">^M
		#Fecha de Contrato social: <div class="profile-info-name"> Fecha de Contrato Social </div>


		#Nuevo, de la lista para imprimir
                nombre=$(grep -A 1 '<h3 class="reclamar">' $file | tail -1 | sed 's/\r//'| awk -F "(" '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
                cuit=$(grep "CUIT" $file | grep -oP '(?<=</b>).*?(?=<br)' | sed "s/-//g")
		isic=$(grep -A 1 "Actividad ISIC Principal" $file | tail -1 | sed 's/\r//' | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
		afip=$(grep -A 1 "Actividad Principal AFIP" $file | tail -1 | sed 's/\r//' | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
		perfil_comer=$(grep -A 2 "Perfil de Comercialización" $file | tail -1 | sed 's/\r//g' | awk -F '<' '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
		facturado=$(grep -A 1 "Facturación Estimada" $file | tail -1 | sed 's/\r//'| awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
		empleados=$(grep "Cantidad de Empleados" $file | grep -oP '(?<=</b>).*?(?=</span>)')
		fecha_contrato=$(grep -A 2 "Fecha de Contrato Social" $file | tail -1 | sed 's/\r//g' | awk -F '<' '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
		usuario_resp=$(grep -A 1 "Usuario Responsable" $file | tail -1 | sed 's/\r//' | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
                domicilio=$(grep -A 3 "Domicilio" $file | tail -1 | sed 's/\r//' | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
                sitioweb=$(grep -A 1 "Sitios" $file | tail -1 | sed 's/\r//g' | awk -F '<' '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
                telefono=$(grep -A 2 "Teléfonos" $file | tail -1 | sed 's/\r//g' | awk -F '<' '{gsub(/^[ \t]+|[ \t]+$/, ""); print $1}')
                redessociales=$(grep -A 20 "Redes Sociales" $file| grep -oP '(?<=<li>).*?(?=</li>)' | awk '!seen[$0]++' | awk '{printf $0", "}')
		responsable_ventas=$(grep -A 20 "Responsable de Venta" $file| grep -A 3 "Nombre" | tail -1 | sed 's/\r//'| awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
                #Visualizaciones <a href="#" id="visualizacionesTrigger" onclick="ShowVisualizaciones('/es/Empresa/VerDetalleVisualizaciones?idEmpresa=1667154','BAGGINI HNOS SRL')">^M



		#Imprimir datos
		string=$(echo "$nombre;$cuit;$afip;$isic;$perfil_comer;$fecha_contrato;$facturado;$empleados;$domicilio;$sitioweb;$telefono;$redessociales;$usuario_resp;$responsable_ventas" | sed "s/&#209;/Ñ/g" | sed "s/&amp;/\&/g" | sed "s/&#220;/Ü/g" | sed "s/&#211;/Ó/g" | sed "s/&#218;/Ú/g" | sed "s/&#39;/\'/g"| sed "s/&#243;/ó/g"| sed "s/&#237;/í/g" | sed "s/&#225;/á/g" | sed "s/&#233;/é/g")
	       	echo $string | tee -a $output

	else
		echo "File $id exists already"
	fi
	((n++))

done < "$input"

done
