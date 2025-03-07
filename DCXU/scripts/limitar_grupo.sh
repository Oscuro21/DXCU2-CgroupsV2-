OKsalir=0
while [ $OKsalir -eq 0 ]; do


grupos=$(getent group | awk -F: '$3 >= 1000 && $4 != "" {print $1 ": " $4}')
echo ""
echo "GRUPOS:"
echo "$grupos"
echo ""

echo "1 Crear Limite de consumo de CPU y RAM para un grupo"
echo "2 Ir a Consumo(luego presionar X para poder aplicar la configuracion generada)"
echo "3 Mas Informacion"
echo "0 Salir"
echo ""
echo "Seleccione una opcion:"

read var

case $var in

1)

bash ./scripts/limitar_grupo_script.sh
OKsalir=1
;;


2)

bash limitar.sh
OKsalir=1

;;


3)

echo ""
echo ""
echo "DETALLES:"
echo "El consumo total del grupo no va a superar los limites establecidos"
echo "No se puede establecer limites individuales, a miembros que pertenezcan a este grupo"
echo "el limite es para todo el grupo"

;;


0)

OKsalir=1

;;

*)

echo "Catacter Invalido"

;;

esac
done
