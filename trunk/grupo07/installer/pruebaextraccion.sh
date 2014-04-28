#prueba estraccion de path

a=$(grep "CONFDIR" "vars.def" | sed "s/^[^:]*://")

echo "$a"
