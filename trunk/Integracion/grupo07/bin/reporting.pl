#!/usr/bin/env perl

use Term::ReadKey;
use File::Spec::Functions qw(catfile);

use Env qw(ENVIRONMENT INFODIR MAEDIR INFON);
$MAEFILE = "super.mae"; 
$PRESDIR = "pres";
$REF_BOUNDARY = 100;
$OBS_LE = "(*)";
$OBS_GT = "(**)";
$OBS_NF = "(***)";
$INFO_LINE = "$OBS_LE Precio menor o igual al Precio Cuidado.\n$OBS_GT Precio mayor al Precio Cuidado.\n$OBS_NF Precio Cuidado no encontrado.\n";
$NO_RESULT_MSG = "No hay resultados para la consulta\n";

# Usando los datos de super.mae, guarda los datos de los supermercados en el hash recibido por parámetro
sub makeSupermarketsHash { 
    my($supermarkets_ref) = @_[0];
    open(SUPER_MAE_H, "<".catfile($MAEDIR, $MAEFILE)) || die "No se pudo abrir super.mae\n";
    while (<SUPER_MAE_H>) {
        my($id, $province, $super_name) = ($_ =~ /^(\d+);(.+);(.*)(?:;.*){3}$/);
        ${$supermarkets_ref}{$id} = $province."-".$super_name;
    }
    close(SUPER_MAE_H);
}

# Lee una tecla del stdin y la devuelve
sub readKey {
    ReadMode('cbreak');
    my($key) = ReadKey(0);
    ReadMode('normal');
    return $key;
}

# Imprime a stdout el mensaje de ayuda del comando
sub printHelp {
    print "\nAyuda\n\n";
    print "El programa reporting analiza las listas presupuestadas y realiza informes sobre los resultados\n".
                "Se ofrecen varias opciones para los informes:\n\n\t-r: Informa sobre los Precios Cuidados, ".
                "para cada producto de la lista. Puede combinarse con -m y -d (ya sea poniendo las dos opciones, o ".
                "con -rm y -rd). En ese caso, muestra la información correspondiente a -r o -d, y la comparación con los ".
                "Precios Cuidados.\n\n\t-m: Informa sobre el precio más bajo para cada producto. Se puede combinar ".
                "con -r (ya sea usando las dos opciones o como -rm) para mostrar esta información, más la ".
                "comparación con los Precios Cuidados.\n\n\t-d: Informa sobre donde comprar. Busca el precio más ".
                "bajo de cada producto y lo agrupa por provincia-supermercado. Se puede combinar con -r (ya sea ".
                "usando las dos opciones o como -rd) para mostrar esta información, más la comparación con los ".
                "Precios Cuidados.\n\n\t-f: Informa sobre los productos a los que les falta información. No es ".
                "combinable con ninguna opción.\n\n\t-w: Graba en un archivo los resultados de la consulta realizada. ".
                "Este archivo se guarda en el directorio de info con el nombre info_xxx, siendo xxx un número ".
                "consecutivo al último informe realizado.\n\n\t-x: Filtra por provincia-supermercado. Despliega un ".
                "menú con todas las opciones disponibles, y permite elegir todos, algunos o ninguno para que sea ".
                "considerado en el reporte.\n\n\t-u: Filtra por usuario. Muestra una lista de usuarios disponibles y ".
                "permite elegir las listas de quienes serán analizadas para realizar el informe.\n\n";    
    print "Presione una tecla para continuar...\n\n";
    readKey;
}

# Obtiene el número de secuencia para nombrar los archivos de informes
sub getNextDescriptorNumber {
    my ($ret_n) = 0;
    opendir(INFODIR_H, "$INFODIR");
    foreach (readdir(INFODIR_H)) {
        my ($file) = catfile($INFODIR, $_);
        next unless (-f $file);
        ($file =~ /info_(\d{3})$/);
        $ret_n = $1 if ($ret_n < $1);
    }
    closedir(INFODIR_H);
    return (sprintf("%03d", ++$ret_n));
}

# Recibe una lista con las opciones ingresadas como parámetro y una referencia al hash donde se
# guardarán las opciones procesadas y validadas
sub processOptions {
    my(@options_input) = @{@_[0]};
    my($href) = @_[1];
    foreach (@options_input) {
        if (($_ eq "r") && 
            (! exists ${$href}{"f"})) {
                ${$href}{"r"} = 1;
        }
        if (($_ eq "m") && 
            (! exists ${$href}{"f"}) && 
            (! exists ${$href}{"d"})) { 
                ${$href}{"m"} = 1;
        }
        if (($_ eq "d") && 
            (! exists ${$href}{"f"}) && 
            (! exists ${$href}{"m"})) {
                ${$href}{"d"} = 1;
        }
        if (($_ eq "f") && 
            (! exists ${$href}{"r"}) && 
            (! exists ${$href}{"m"}) && 
            (! exists ${$href}{"d"})) {
                ${$href}{"f"} = 1;
        } elsif (($_ eq "x") && (! exists ${$href}{"f"})) {
            ${$href}{"x"} = 1;
        } elsif ($_ eq "w") {
            ${$href}{"w"} = 1;
        } elsif ($_ eq "u") {
            ${$href}{"u"} = 1;
        } elsif ($_ eq "a") {
            ${$href}{"a"} = 1;
            last;
        }
    }
    # Removes, if present, the -x option in case it isn used (like for options -f, or -x
    # without -d or -m)
    if ((exists ${$href}{"r"}) && ! (exists ${$href}{"m"} || exists ${$href}{"d"})) {
        delete(${$href}{"x"});
    } elsif (exists ${$href}{"f"}) {
        delete(${$href}{"x"});
    }
}

# Recibe una referencia al hash de opciones procesadas, y devuelve 1 si alguna opción de consulta 
# (r, m, d y/o f) fue elegida o 0 si ninguna se encuentra en el hash
sub checkProcessingOptions {
    foreach (keys(%{@_[0]})) {
        return 1 if ($_ =~ /[r|m|d|f]/);
    }
    return 0;
}

# Imprime una lista de provincia-supermercado y su respectivo id, a partir del hash recibido
sub printAvailableSupermarkets {
    my($supermarkets_ref) = @_[0];
    print "\nLos supermercados disponibles son: \n";
    foreach $super_id (sort {$a <=> $b} keys %{$supermarkets_ref}) {
        print $super_id." - ".${$supermarkets_ref}{$super_id}."\n" if ($super_id >= 100);
    }
    print "\n";
}

# Lee por stdin una lista de id de supermercados elegidos y devuelve una lista con los mismos
sub selectFilters {
    print "Seleccione los supermercados que desea incluir ingresando los números correspondientes ".
                 "a cada supermercado separados por comas (,). Ingrese 'todos' si desea elegirlos todos. Ingrese ".
                 "'ninguno' si no desea incluir ningún supermercado.\n";
    print "Selección: ";
    return (<STDIN> =~ /,?\s*(\w*)\s*,?/g);
}

# Recibe una referencia al hash de supermercados, una al hash donde se guardaran los supermercados
# elegidos, y una lista de elecciones. Procesa la lista y agrega los supermercados que correspondan
# al hash
sub processSelectedFilters {
    my($supermarkets_ref) = @_[0];
    my($selected_ref) = @_[1];
    my(@selection) = @_[2..@_];
    print "Supermecados elegidos:";
    foreach (@selection) {
        if ($_ eq "todos") {
            %{$selected_ref} = %{$supermarkets_ref};
            print " todos\n";
            return;
        } elsif ($_ eq "ninguno") {
            %{$selected_ref} = ();
            print " ninguno\n";
            return;
        } elsif ((exists ${$supermarkets_ref}{$_}) && ($_ >= $REF_BOUNDARY)) {
            ${$selected_ref}{$_} = ${$supermarkets_ref}{$_};
            print " $_";
        }
    }
    print "\n";
}

# Devuelve 1 o 0, dependiendo si se confirmo o rechazo la selección de filtros
sub confirmFilterSelection {
    print "Es correcto? Presione s para continuar, n para elegir de vuelta.\n\n";
    return 1 if (readKey =~ /[s|S]/);
    return 0;
}

# Recibe una referencia al hash de opciones, una al hash de supermercados, y una al hash
# donde se guardaran los supermercados elegidos. Al finalizar su ejecución, dicho hash 
# tiene cargado los filtros de supermercados elegidos
sub makeFilterHash {
    my(%options) = %{@_[0]};
    my($supermarkets_ref) = @_[1];
    my($filter_ref) = @_[2];
    if (exists $options{"f"}) {
        ${$filter_ref}{""} = "";
    } elsif ((exists ${$href}{"r"}) && ! (exists ${$href}{"m"} || exists ${$href}{"d"})) {
        ${$filter_ref}{""} = "";
    } elsif (exists $options{"x"}) {
        my($filter_choosen) = 0;
        my(%selected_filters);
        while (! $filter_choosen) {
            %selected_filters = ();
            printAvailableSupermarkets($supermarkets_ref);
            processSelectedFilters($supermarkets_ref, \%selected_filters, selectFilters);
            $filter_choosen = confirmFilterSelection;
        }       
        %{$filter_ref}= %selected_filters;
    } else {
        %{$filter_ref}= %{$supermarkets_ref};
    }
}

# Obtiene y devuelve una lista de los usuarios, a partir de las listas de compras presupuestadas
sub getUserList {
    my(%users) = ();
    opendir(PRES_H, catfile($INFODIR, $PRESDIR));
    foreach $file (readdir(PRES_H)) {
        (my($user_name)) = ($file =~ /^(.*)\.\w{3}$/);
        next if ($user_name !~ /\w+/); # Skips if the user name doesn't have any letters, usually for . and ..
        $users{$user_name} = 1 unless (exists $users{$user_name});
    }
    closedir(PRES_H);
    return (keys %users);
}

# Recibe la lista de usuarios. Imprime la misma, y toma por stdin una lista de usuarios elegidos
# para procesar sus consultas
sub selectUsers {
    my(@users_list) = @_;
    print "Usuarios con listas presupuestadas: \n";
    for ($i = 0; $i <= $#users_list; $i++) {
        print $i." - ".$users_list[$i]."\n";
    }
    print "Seleccione los usuarios que desea incluir ingresando los números correspondientes ".
                 "a cada uno separados por comas (,): ";
    return (<STDIN> =~ /,?\s*(\d*)\s*,?/g);
}

# Recibe una referencia al hash que se usará como filtro de usuarios, una referencia a la lista
# de usuarios, y una lista de usuarios elegidos. Procesa la lista de elegidos, y agrega al hash
# los que correspondan
sub processSelectedUsers {
    my($users_filter_ref) = @_[0];
    my(@users_list) = @{@_[1]};
    my(@selection) = @_[2..@_];
    foreach $selected_user (@selection) {
        next if (($selected_user !~ /^\d+$/) || ($selected_user > $#users_list));
        my($user_name) = $users_list[$selected_user];
        next if (exists ${$users_filter_ref}{$user_name});
        ${$users_filter_ref}{$user_name} = $selected_user;
    }
}

# Recibe una referencia al hash que se usará como filtro de usuarios. Ofrece una lista de usuarios
# disponibles y permite elegir los que integraran el filtro, procesa la selección, y agrega los que
# correspondan al hash
sub makeUserFilter {
    my($users_filter_ref) = @_[0];
    my(@users_list) = getUserList;
    processSelectedUsers($users_filter_ref, \@users_list, selectUsers(@users_list));
}

# Recibe la ruta al archivo de presupuesto a procesar, una referencia al hash de opciones, una 
# referencia al filtro de supermercados, una al hash donde guardar los resultados de referencia 
# (Precios Cuidados), y una al hash donde guardar los resultados de productos. Procesa el archivo y
# llena los hash con los resultados que correspondan a las opciones elegidas.
sub processList {
    my($usr_file) = @_[0];
    my(%options) = %{@_[1]};
    my(%supermarkets_filter) = %{@_[2]};
    my($references_result_ref) = @_[3];
    my($items_result_ref) = @_[4];
    my(%references_result, %items_result);
    open(LIST, "<$usr_file") || die "No se pudo abrir el archivo de lista presupuestada\n";
    while (<LIST>) {
        my($item_id, $item_name, $super_id, $item_info, $price) = split(/;/, $_ );
        chomp($price);
        # Checks if data is missing, and stores it if required (-f) or next if it doens't
        if ($super_id eq "") {
            next unless (exists $options{"f"});
            $items_result{$item_id} = [$item_name, $item_info, $price, $super_id];
            next; # If -f is present, no more data is neded
        }
        # Checks supermarkets filter, next if the super_id is filtered
        next unless ((exists $supermarkets_filter{$super_id}) || ($super_id < $REF_BOUNDARY));
        # Checks if it's a reference price, and stores the data if required
        if ($super_id < $REF_BOUNDARY) {
            next unless (exists $options{"r"});
            $references_result{$item_id} = [$item_name, $item_info, $price, $super_id];
            next;
        }
        # Checks if low prices are required, and stores the data if it is
        if ((exists $options{"m"}) || (exists $options{"d"})) {
            next if ((exists $items_result{$item_id}) && (${$items_result{$item_id}}[2] < $price));
            $items_result{$item_id} = [$item_name, $item_info, $price, $super_id];
        }
    }
    close(LIST);
    %{$references_result_ref} = %references_result;
    %{$items_result_ref} = %items_result;
}

# Función de comparación para sort que ordena según el item id
sub sortByItemId {
    return (@_[0] <=> @_[1]);
}

# Función de comparación para sort que ordena según el id de supermercado, y por id de item como 
# segunda condición
sub sortBySuperId {
    my($a, $b, $result_ref) = @_;
    my(@data_a) = @{${$result_ref}{$a}};
    my(@data_b) = @{${$result_ref}{$b}} ;
    return (($data_a[3] <=> $data_b[3]) || ($a <=> $b));
}

# Recibe una referencia al hash con el resultado, una referencia a la lista de supermercados, y una 
# a la función de comparación a utilizar para ordenar. Devuelve una lista ordenada con la 
# información del resultado como debe mostrarse en el caso de opción de consulta simple (-r, -m, -d 
# o -f)
sub makeOrderedSimpleResultList{
    my(%result) = %{@_[0]};
    my($supermarkets_ref) = @_[1];
    my($sort_sub_ref) = @_[2];
    my(@ordered_list) = ();
    foreach $item_id (sort {$sort_sub_ref->($a, $b, \%result)} keys %result) {
        my(@data) = @{$result{$item_id}};
        my($super_name) = ${$supermarkets_ref}{$data[3]};
        push(@ordered_list, $item_id."\t".$data[0]."\t".$data[1]."\t".$data[2]."\t".$super_name."\n");
    }
    return @ordered_list;
}

# Recibe una referencia al hash con el resultado de precios de referencia, una al hash de resultado
# de productos, una a la lista de supermercados, y una a la función de comparación a utilizar para 
# ordenar. Devuelve una lista ordenada con la información del resultado como debe mostrarse en el 
# caso de opción de consulta doble (-rm o -rd)
sub makeOrderedDoubleResultList {
    my(%references) = %{@_[0]};
    my(%items) = %{@_[1]};
    my($supermarkets_ref) = @_[2];
    my($sort_sub_ref) = @_[3];
    my(@ordered_list) = ();
    foreach $item_id (sort {$sort_sub_ref->($a, $b, \%items)} keys %items) {
        my(@data) = @{$items{$item_id}};
        my($super_name) = ${$supermarkets_ref}{$data[3]};
        my($ref_price);
        my($obs);
        if (exists $references{$item_id}) {
            $ref_price = $references{$item_id}[2];
            $obs = $OBS_LE if ($data[2] <= $ref_price);
            $obs = $OBS_GT if ($data[2] > $ref_price);
        } else {
            $ref_price = "no encontrado";
            $obs = $OBS_NF;
        }
        push(@ordered_list, $super_name."\t".$item_id."\t".$data[0]."\t".$data[1]."\t".$data[2]."\t".$ref_price."\t".$obs."\n");
    }
    return @ordered_list;
}

# Recibe una referencia al hash de opciones, una referencia a la lista de filtro de supermercados, 
# una al hash de resultados de precios de referencia y una al hash de resultado de productos. Genera
# la lista con el resultado para mostrar y lo devuelve
sub makeReport {
    my(%options) = %{@_[0]};
    my($filter_ref) = @_[1];
    my($references_ref) = @_[2];
    my($items_ref) = @_[3];
    my($sort_sub_ref, $sort_hash_ref);
    if (exists $options{"d"}) {
        $sort_sub_ref = \&sortBySuperId;
    } else {
        $sort_sub_ref = \&sortByItemId;
    }
    if (((exists $options{"r"}) && (exists $options{"m"})) || ((exists $options{"r"}) && (exists $options{"d"}))) {
        return makeOrderedDoubleResultList($references_ref, $items_ref, $filter_ref, $sort_sub_ref);
    } else {
        if (exists $options{"r"}) {
            $sort_hash_ref = $references_ref;
        } else {
            $sort_hash_ref = $items_ref;
        }
        return makeOrderedSimpleResultList($sort_hash_ref, $filter_ref, $sort_sub_ref);
    }
}

# Recibe una referencia al hash de opciones, una al filtro de supermercados, una al de usuarios y, 
# si se necesita (por la opción -w) un handler de un archivo donde grabar. Imprime a stdout, y al 
# archivo si corresponde, el header del resultado (Consulta, contenido de filtros, y otra 
# información necesaria)
sub printHeader {
    my(%options) = %{@_[0]};
    my($supermarkets_ref) = @_[1];
    my($users_ref) = @_[2];
    my(@print_to) = (STDOUT);
    push(@print_to, @_[3]) if (exists $options{"w"});
    foreach $fh (@print_to) {
        print $fh "Opciones y filtros:"; print $fh " -".$_ foreach(keys (%options)); print $fh "\n";
        if (exists $options{"x"}) {
            print $fh "Supermercados elegidos (-x):";
            print $fh " ".${$supermarkets_ref}{$_} foreach(sort {$a <=> $b} keys %{$supermarkets_ref});
            print $fh "\n";
        }
        if (exists $options{"u"}) {
            print $fh "Usuarios elegidos (-u):";
            print $fh " ".$_ foreach(sort keys %{$users_ref});
            print $fh "\n";
        }
        print $fh $INFO_LINE if ((exists $options{"r"}) && ((exists $options{"m"}) || (exists $options{"d"})));
    }
}
    
# Recibe una referencia al hash de opciones, una al filtro de supermercados, una al de usuarios y, 
# si se necesita (por la opción -w) un handler de un archivo donde grabar. Imprime a stdout, y al 
# archivo si corresponde, el resultado de la consulta realizada
sub printResults {
    my(%options) = %{@_[0]};
    my($usr_file) = @_[1];
    my($result_list_ref) = @_[2];
    my(@print_to) = (STDOUT);
    push(@print_to, @_[3]) if (exists $options{"w"});
    foreach $fh (@print_to) {
        print $fh "\n";
        print $fh ($usr_file =~ /.*\/(.*)$/); print $fh "\n";
        print $fh $_ foreach (@{$result_list_ref});
    }
}

############################################### Main ###############################################

# Checks for system initialization
die "No se realizó la inicialización de ambiente\n" if ($ENVIRONMENT != 1);
# Checks if the process is already running
($process_name) = ($0 =~ /\/(.+)$/);
die "Reporting ya está ejecutándose\n" if (`ps -C  $process_name -o pid=`);
# Supermarkets hash initialization
%supermarkets = ();
makeSupermarketsHash(\%supermarkets);
# Parse and process the options arguments
$parameters = "";
$parameters = $parameters.$_ foreach(@ARGV);
@options_input = ($parameters =~ /-(\w)(\w*)/g);
%options = (); # Cleans the options hash
processOptions(\@options_input, \%options);
# Help message
if (exists $options{"a"}) {
    printHelp;
    die;
}
# Checks for query options
if (! checkProcessingOptions(\%options)) {
    print "\nAlguna de las siguientes opciones debe estar presentes: -r -m -rm -d -rd -f\n";
    print "Use la opción -a para ver la ayuda del programa.\n\n";
    die;
}
# Users filter
%users_filter = ();
if (exists $options{"u"}) {
    makeUserFilter(\%users_filter);
}
# Supermarket filter
%supermarkets_filter = ();
makeFilterHash(\%options, \%supermarkets, \%supermarkets_filter);
if (exists $options{"w"}) {
    $ext = getNextDescriptorNumber;
    open(INFO_H, ">".catfile($INFODIR,"info_$ext"));
}
# Result processing and displaying (and writing, if required)
printHeader(\%options, \%supermarkets_filter, \%users_filter, INFO_H);
opendir(PRES_H, catfile($INFODIR, $PRESDIR));
foreach $file (readdir(PRES_H)) {
    # Skips . .. and any other file that doesn't have the required format
    next unless ($file =~ /^.*\..{3}$/);
    # Filter by user
    ($user_name) = ($file =~ /^(.*)\.\w{3}$/);
    next unless ((scalar keys %users_filter < 1) || (exists $users_filter{$user_name}));
    %references_result = ();
    %items_result = ();
    $usr_file = catfile($INFODIR, $PRESDIR, $file);
    processList($usr_file, \%options, \%supermarkets_filter, \%references_result, \%items_result);
    @result_list = makeReport(\%options, \%supermarkets_filter, \%references_result, \%items_result);
    push(@result_list, $NO_RESULT_MSG) if ($#result_list < 0);
    printResults(\%options, $usr_file, \@result_list, INFO_H);
}
print "\nPresione una tecla para continuar...\n\n";
readKey;
closedir(PRES_H);
close(INFO_H) if (exists $options{"w"});
