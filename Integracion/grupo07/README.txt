#################################################################################################

README.txt para version 1.0 de RETAILC.

Este archivo explica la instalacion del sistema RETAILC y su modo de uso.

#################################################################################################

QUE ES RETAILC

	El sistema RETAILC permite a sus usuarios crear una lista maestra de precios a partir de las
	listas de precios de supermercados y grandes tiendas que luego se emplea para presupuestar
	listas de compras.


#################################################################################################

INSTALACION

	Una vez descomprimido el paqute se debera contar con 4 directorio:

	. installer
	. exe
	. datos
	. conf


	Para instalar el Paquete:

	1) Ejecutar el comando "installer.sh" que se encuentra en el directorio "installer".

	2) Aceptar los terminos y condiciones de la instalacion.

	ACLARACION: Se debera contar con perl v5 o superior para que la instalacion se concluya.

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

	Una vez completada la instalacion, se habran creado los directorios (con todos los 
	subdirectorios que correspondiesen) que ha definido el usuario durante la misma en
	el directorio grupo07/. Adicionalmente se habran movido los archivos ubicados en
	grupo07/datos/maestros al Directorio de Archivos Maestros y Tablas definido por el
	usuario.


#################################################################################################

EJECUCION DEL PROGRAMA

	El programa puede ser ejecutado de diferentes modos:
		
		1) Ejecutar Completo
		2) Masterlist solamente
	
	Existe una funcionalidad llamada reporting que no se ejecuta en ninguno de los
	modos exhibidos. 
	
	--------------------------------------------------------------------------------------

	1) Ejecutar Completo
		
		El programa se ejecuta en esta modalidad ingresando el comando:
		
		source initializer.sh	o	. ./initializer.sh

		En este modo, el programa inicializara todos los recursos necesarios para su
		correcta ejecucion y luego ejecutara un demonio que correra como un proceso de
		fondo por lo que sera invisible al usuario. Mientras este demonio este activo
		todas las listas de precios y listas de compras que lleguen al Directorio de
		Novedades seran procesados por los procesos Masterlist y Rating respectivamente.

		Para detener detener el demonio se debe ingresar el siguiente comando en la terminal:
		
		./stop.sh listener.sh

		(Se detiene el proceso listener.sh ya que es este el demonio corriendo de fondo).

	--------------------------------------------------------------------------------------

	2) Masterlist Solamente

		En esta modalidad el sistema procesa los archivos de listas de precios ubicados
		en el Directorio de Novedades, enviandolos al directorio de procesados dentro
		del Directorio de Maestros y Tablas si estos fueron correctamente procesados.
		A su vez, con cada archivo de lista de precios se actualiza (crea la primera
		vez) el archivo Lista de Precios Maestra.

		Para correr el programa en esta modalidad se debe ejecutar el siguiente comando	
		en la terminal (sin que este corriendo el demonio listener en el momento):

		./Masterlist.sh    o     ./start Masterlist.sh [MODO]

		El argumento MODO puede tomar 2 valores:
			
			1) T  : Ejecuta el comando normalmente.
			2) B  : Ejecuta el comando en background.

	--------------------------------------------------------------------------------------

	Reporting

	Esta funcionalidad debe ser ejecutada desde la terminal ingresando
	el siguiente comando:
		
		./reporting.pl [OPCION]

	El argumento opcion puede ser alguno de los siguientes
	a (ayuda)
	-w (grabar)
	-r (precio de referencia) (combinable con m y d)
	-m (menor precio)
	-d (donde comprar)
	-f (faltante)
	-x (filtrar por provincia-supermercado)
	-u (filtrar por usuario)



#################################################################################################

AUTORES

	Gallippi, Leandro
	Graffe, Fabrizio
	Martinez, Gaston
	Merlo Schurmann, Bruno
	Raineri, Luciano
	Rojas, Agustin
	

#################################################################################################
