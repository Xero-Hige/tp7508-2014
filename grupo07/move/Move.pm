#!/usr/bin/env perl

package Move;
use Exporter;
@ISA = ('Exporter');
@EXPORT = ('move');
@EXPORT_OK = ('move');

use File::Spec::Functions qw(catfile);
use File::Copy qw(copy);

# Receives a path to a directory. Checks if a dup directory exists in 
# it
sub checkDup {
    my ($dup) = catfile(@_[0], "dup");
    return (-e -d $dup);
}

# Receives a list of files to check, returns the next secuence number 
# for duplicated files
sub getNextSecuenceNumber {
    my ($dir_path, @files) = @_;
    my ($ret_n) = 0;
    foreach (@files) {
        #Aca no sé bien que carajo poner, si no esta completo el path no anda
        my ($file) = catfile($dir_path, $_);
        next unless (-f $file);
        ($file =~ /(\d{0,3}$)/);
        $ret_n = $1 if ($ret_n < $1);
    }
    return ++$ret_n;
}

# Receives a path to a directory and a file name that is duplicated. 
# Returns the path where the file is going to be moved, including dup
# directory and secuence number
sub assembleExistingDestFilePath {
    my ($destination, $file_name) = @_;
    my ($dup_destination) = catfile($destination, "dup");
    opendir(DEST_DIR_H, $dup_destination) || return "";
    my ($secuence_n) = getNextSecuenceNumber($dup_destination, readdir(DEST_DIR_H));
    closedir(DEST_DIR_H);
    return (catfile($dup_destination, ($file_name.".".$secuence_n)));
}

# Receives an origin an a destination (full paths). Copies the origin 
# file to the destination file, and deletes the first. Returns 1 if 
# both operation succeeded, 0 if one of them failed
sub moveFile {
    my ($origin, $destination) = @_;
    return (copy("$origin", "$destination") && unlink("$origin"));
}

# Falta documentar, falta logguear errores
sub move {
    my ($origin, $original_file) = (@_[0] =~ /(^.*\/)(\w*(?:\.*\w*)*$)/);
    my ($destination, $copy_file) = (@_[1] =~ /(^.*\/)(\w*(?:\.*\w*)*$)/);
    $copy_file = $original_file if (! $copy_file);
    my ($origin_full) = @_[0];
    my ($destination_full) = catfile($destination, $copy_file);
    return 0 if ($origin eq $destination);
    return -1 if (! -e $origin_full); #Logguear error
    return -2 if (! -e $destination); #Logguear error
    # Checks if file exists in destination folder
    if (-f -e $destination_full) {
        # Checks if the dup folder exists, and creates it if it doesn't
        mkdir(catfile($destination, "dup")) if (! checkDup(destination));
        # Adds the secuence number to the destination file path
        $destination_full = assembleExistingDestFilePath($destination, $copy_file);
        return -3 if (! $destination_full); #Logguear error
    }
    return 0 if (moveFile($origin_full, $destination_full));
    return -4; #Logguear error
}
