OKsalir=0
while [ $OKsalir -eq 0 ]; do


dir="$(pwd)/config/"

#usuarios=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)
grupos=$(getent group | awk -F: '$3 >= 1000 && $4 != "" {print $1 ": " $4}')


echo ""

#echo "USUARIOS"
#echo "$usuarios"
#echo ""


echo "GRUPOS:"
echo "$grupos"
echo ""

echo "1 Crear Limites de consumo de CPU y RAM independiente para todos los integrantes de un grupo"
echo "2 Ir a Consumo(luego presionar X para poder aplicar la configuracion generada)"
echo "3 Mas Informacion"
echo "0 Salir"
echo ""
echo "Seleccione una opcion:"

read var

case $var in

3)

echo ""
echo "DETALLES:"
echo "Esta opcion genera limites para todos los usuarios de un grupo"
echo "Pero lo hace de manera individual, es decir es como agregar todos los usuarios manualmente"
echo "Y a todos ponerles los mismos limites"
echo "No estas limitando un grupo por ejemplo al 75% , estas limitando a cada persona"
echo "Diferente seria que el consumo total del grupo no supere el 75%"

;;

2)

bash limitar.sh
OKsalir=1

;;

1)

bash ./scripts/limitar_usuarios_grupo_script.sh
OKsalir=1

;;

0)

OKsalir=1

;;

*)

echo "Catacter Invalido"

;;

esac
done
