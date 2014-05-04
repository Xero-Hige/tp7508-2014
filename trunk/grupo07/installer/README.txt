PARA AGREGAR AL README:

*Se va a tener un archivo que tenga el significado de cada sigla de los directorios(vars.def). ej: BINDIR = Directorio ejecutables.
*Para saber si existe perl, se llama al comando perl -v. Si perl existe , devolvera un texto del cual se extraera su version. si no, el valor de retorno sera distinto de 0 ya que no existe el comando.
*Ademas de checkear el archivo installer.conf, se checkea que los directorios que se encuentran en el existan.
*Si al archivo de configuracion le falta una definicion, no se considera erroneo sino que se considera como que ese directorio no existe y se crea en la instalacion

