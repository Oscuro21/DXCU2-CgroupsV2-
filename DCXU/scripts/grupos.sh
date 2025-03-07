OKsalir=0
while [ $OKsalir -eq 0 ]; do

echo ""
echo "1 Limitar Consumo a GRUPO"
echo "2 Limitar Consumo a todos los usuarios del grupo"
echo "3 Mas Informacion"
echo "4 ABM de Usuarios y Grupos"
echo "0 Salir"
read var

case $var in


1)

bash ./scripts/limitar_grupo.sh
OKsalir=1
;;

2)

bash ./scripts/limitar_usuarios_grupo.sh
OKsalir=1
;;


3)

echo ""
echo ""
echo "Opcion 1"
echo "El consumo total del grupo no va a superar los limites establecidos"
echo "No se puede establecer limites individuales, a miembros que pertenezcan a este grupo"
echo "el limite es para todo el grupo"

echo ""
echo ""
echo "Opcion 2"
echo "Esta opcion genera limites para todos los usuarios de un grupo"
echo "Pero lo hace de manera individual, es decir es como agregar todos los usuarios manualmente"
echo "Y a todos ponerles los mismos limites, los cuales podemos ir editando uno a uno de quererlo"
echo "No estas limitando un grupo por ejemplo al 75% , estas limitando a cada persona"
echo "Diferente seria que el consumo total del grupo no supere el 75%"

;;

4)

sh ./scripts/admgrupos.sh
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
