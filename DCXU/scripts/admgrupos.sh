OKsalir=0
while [ $OKsalir -eq 0 ]; do


dir="$(pwd)/config/"

usuarios=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)
totalusuarios=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd | wc -l)
grupos=$(getent group | awk -F: '$3 >= 1000 && $4 != "" {print $1 ": " $4}')
totalengrupos=$(getent group | awk -F: '$3 >= 1000 && $4 != "" {split($4, users, ","); print $1 ": " length(users) " Total"}')

echo ""
echo "USUARIOS"
echo "$usuarios"
echo "Total: $totalusuarios"
echo ""

echo "GRUPOS:"
echo "$grupos"
echo "$totalengrupos"
echo ""

echo "3 Crear grupo"
echo "4 Unir usuario a grupo"
echo "5 Eliminar grupo"
echo "6 Eliminar usuario de grupo"
echo "7 Crear Usuario"
echo "0 Salir"
echo "Seleccione una opcion:"

read var

case $var in

3)

echo "Ingrese nombre del Grupo"
read nom
sudo groupadd $nom

;;

4)

echo "Ingrese nombre del Grupo"
read gru
echo "Ingrese Usuario"
read usu

sudo usermod -aG $gru $usu

;;

5)

echo "Ingrese Grupo a Eliminar"
read g
sudo groupdel $g

;;

6)

echo "Ingrese nombre del Grupo"
read grupo
echo "Ingrese Usuario"
read usuario

sudo gpasswd -d $usuario $grupo

;;

7)
echo "Ingrese Usuario"
read addu
sudo adduser $addu

;;

0)

OKsalir=1

;;

*)

echo "Catacter Invalido"

;;

esac
done
