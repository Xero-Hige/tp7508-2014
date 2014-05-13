################################################################################

README.txt para version 1.3 de RETAILC.

Este archivo explica la instalacion del sistema RETAILC y su modo de uso.

################################################################################

QUE ES RETAILC

	El sistema RETAILC permite a sus usuarios crear una lista maestra de 
	precios a partir de las listas de precios de supermercados y grandes 
	tiendas que luego se emplea para presupuestar listas de compras.

################################################################################

COMO INSTALAR
	
	Para poder instalar el sistema, primero debe descomprimir el archivador
	descargado:


	DESCOMPRESION:

	El fichero se puede descomprimir en cualquier carpeta. Se recomienda 
	realizarlo en el directorio donde se desea instalar para poder contar 
	con las opciones de reparacion de instalacion mas facilmente en el 
	futuro. Para mover el archivador puede hacer uso del comando:

	mv ./grupo07.tgz [DIRECTORIO DESTINO]
	
	Para descomprimir, se utiliza el siguiente comando, ubicado en la 
	carpeta donde se encuentra el mismo

	tar -zxf grupo07.tgz -C [DESTINO]

	Una vez descomprimido el paquete, se generara una carpeta grupo07, que 
	cuenta con los siguientes directorios:

	. installer
	. exe
	. datos
	. conf


	INSTALACION:

	1) Colocarse en el directorio installer y ejecutar installer.sh mediante
	el comando:

	bash ./installer.sh

	2) Aceptar los terminos y condiciones de la instalacion.

	ACLARACION: Se debera contar con perl v5 o superior para que la 
		    instalacion se concluya.

	3) Proveer los paths de directorios a crear y datos pedidos:

		         Directorio de Configuracion
		         Directorio de Ejecutables
		         Directorio de Archivos Maestros y Tablas
		         Directorio de Novedades
		         Tamanio maximo de Directorio de Novedades
		         Directorio de Novedades Aceptadas
		         Directorio de Informes de Salida
		         Directorio de Archivos Rechazados
		         Directorio de Log de Comandos
		         Extension de Archivos de Log de Comandos
		         Tamanio maximo de Archivos de Log de Comandos

	4) Verificar los paths y si estan correctos aceptar.

	5) Instalacion COMPLETA.

	Una vez completada la instalacion, se habran creado los directorios 
	(con todos los subdirectorios que correspondiesen) que ha definido el 
	usuario durante la misma en el directorio grupo07/. Adicionalmente se 
	habran movido los archivos ubicados en grupo07/datos/maestros al 
	Directorio de Archivos Maestros y Tablas definido por el usuario.


################################################################################

EJECUCION DEL PROGRAMA

	El programa puede ser ejecutado de diferentes modos:
		
		1) Ejecutar Completo
		2) Masterlist solamente
	
	Existe una funcionalidad llamada reporting que no se ejecuta en ninguno 
	de los modos exhibidos. 
	
	------------------------------------------------------------------------

	1) Ejecutar Completo
		
		El programa se ejecuta en esta modalidad ingresando el comando:
		
		source initializer.sh	o	. ./initializer.sh

		En este modo, el programa inicializara todos los recursos 
		necesarios para su correcta ejecucion y luego ejecutara un 
		demonio que correra como un proceso de fondo por lo que sera 
		invisible al usuario. Mientras este demonio este activo todas 
		las listas de precios y listas de compras que lleguen al 
		Directorio de Novedades seran procesados por los procesos 
		Masterlist y Rating respectivamente.

		Para que el Masterlist pueda procesar los archivos de precios 
		estos deben ser movidos manualmente al Directorio de Novedades 
		desde el directorio datos/precios.
	
		Para que el Rating pueda procesar los archivos de compras estos 
		deben ser movidos manualmente al Directorio de Novedades desde 
		el directorio datos/compras.
		

		Para detener detener el demonio se debe ingresar el siguiente 
		comando en la terminal:
		
		./stop.sh listener.sh

		(Se detiene el proceso listener.sh ya que es este el demonio 
		corriendo de fondo).

	------------------------------------------------------------------------

	2) Masterlist Solamente

		En esta modalidad el sistema procesa los archivos de listas de 
		precios ubicados en el Directorio de Novedades, enviandolos al 
		directorio de procesados dentro del Directorio de Maestros y 
		Tablas si estos fueron correctamente procesados.
		A su vez, con cada archivo de lista de precios se actualiza 
		(crea la primera vez) el archivo Lista de Precios Maestra.

		Para correr el programa en esta modalidad se debe ejecutar el 
		siguiente comando en la terminal (sin que este corriendo el 
		demonio listener en el momento):

		./Masterlist.sh    o     ./start Masterlist.sh [MODO]

		El argumento MODO puede tomar 2 valores:
			
			1) T  : Ejecuta el comando normalmente.
			2) B  : Ejecuta el comando en background.

################################################################################

REPORTING
	
	El programa reporting analiza las listas presupuestadas y realiza 
	informes sobre los resultados. Esta funcionalidad debe ser ejecutada 
	desde la terminal ingresando el siguiente comando:
		
		./reporting.pl [OPCION]

	El argumento opcion puede ser uno o más de los siguientes (por lo menos
	una opción de informe debe estar presente):

	Opciones de informe:
	-r: Informa sobre los Precios Cuidados, para cada producto de la lista. 
	    Puede combinarse con -m y -d (ya sea poniendo las dos opciones, o 
	    con -rm y -rd). En ese caso, muestra la información correspondiente 
	    a -r o -d, y la comparación con los Precios Cuidados.
	-m: Informa sobre el precio más bajo para cada producto. Se puede 
	    combinar con -r (ya sea usando las dos opciones o como -rm) para 
	    mostrar esta información, más la comparación con los Precios 
	    Cuidados.
	-d: Informa sobre donde comprar. Busca el precio más bajo de cada 
	    producto y lo agrupa por provincia-supermercado. Se puede combinar 
	    con -r (ya sea usando las dos opciones o como -rd) para mostrar esta
	    información, más la comparación con los Precios Cuidados.
	-f: Informa sobre los productos a los que les falta información. No es 
	    combinable con ninguna opción de informe.

	Opciones generales (pueden usarse junto con las de informe en cualquier
	combinación):
	-a: Imprime el mensaje de ayuda del programa.
	-w: Graba en un archivo los resultados de la consulta realizada. Este 
	    archivo se guarda en el directorio de info con el nombre info_xxx, 
	    siendo xxx un número consecutivo al último informe realizado.

	Opciones de filtro (pueden usarse junto con las de informe en cualquier
	combinación):
	-x: Filtra por provincia-supermercado. Despliega un menú con todas las 
	    opciones disponibles, y permite elegir todos, algunos o ninguno 
	    para que sea considerado en el reporte.
	-u: Filtra por usuario. Muestra una lista de usuarios disponibles y 
	    permite elegir las listas de quienes serán analizadas para realizar
	    el informe.

	------------------------------------------------------------------------

	Los informes se pueden mostrar de dos formas, dependiendo las opciones
	elegidas. La información se muestra en columnas en el siguiente orden:
	Informe simple (-r, -f, -m, -d):
		- N° item 
		- Producto pedido
		- Producto encontrado
		- Precio
		- Provincia-Supermercado
	Informe comparativo (-rm, -rd):
		- Provincia-Supermercado
		- N° item
		- Producto pedido
		- Producto encontrado
		- Precio
		- Precio de referencia
		- Observaciones
	En la columna de observaciones se indica si el precio es menor o igual, 
	o más alto que el de referencia; o si este último no se encuentra. 



################################################################################

AUTORES

	Gallippi, Leandro
	Graffe, Fabrizio
	Martinez, Gaston
	Merlo Schurmann, Bruno
	Raineri, Luciano
	Rojas, Agustin


################################################################################
