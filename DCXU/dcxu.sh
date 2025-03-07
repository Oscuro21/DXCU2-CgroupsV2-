OKsalir=0
while [ $OKsalir -eq 0 ]; do

#grupos=$(getent group | awk -F: '$3 >= 1000 && $4 != "" {print $1 ": " $4}')
echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control >/dev/null 2>&1
#estatus=$(cat /sys/fs/cgroup/cgroup.subtree_control)
#echo "Estatus: $estatus"


echo ""
#echo "$grupos"
echo ""
echo "----------------------------------------"
echo "1 Estresar CPU"
echo "2 Estresar con varios nucleos"
echo "T Todos los usuarios a la vez"
echo "----------------------------------------"
echo "3 Detener Estres(Todos)"
echo "4 Detener solo de un usuario"
echo "----------------------------------------"
echo "5 Ver limitaciones de usuarios"
echo "6 Ver limitaciones de grupos"
echo "A Limitar Consumo"
echo "----------------------------------------"
echo "H HTOP"
echo "U Monitorear Consumo usuario Especifico"
echo "----------------------------------------"
echo "R Respaldar Configuracion"
echo "G Limitar Grupos"
echo "0 Salir"
echo "Seleccione una Opcion"
read var

case $var in


"a"|"A")

bash limitar.sh
;;

"h"|"H")

htop

;;


"r"|"R")

echo ""
echo "Ingrese Ruta a copiar el Respaldo"
read destino
actual=$(pwd)
echo "Copiando configuracion... $actual/config a la ruta de destino $destino"
cp -rp $actual/config/ $destino
OKsalir=1


;;



"u"|"U")

echo ""
echo "Ingrese nombre de usuario"
read u
#cat /sys/fs/cgroup/$u/cgroup.procs

watch -n 2 "ps -u $u -o pid,%cpu,%mem,cmd"

#ps -u $u -o pid,%cpu,%mem,cmd
#OKsalir=1
;;



"g"|"G")

bash ./scripts/grupos.sh
;;

"t"|"T")
# Obtener los usuarios con UID entre 1000 y 59999
usuariosss=$(awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd)
for user in $usuariosss; do
sudo -u "$user" bash -c "yes > /dev/null &"
done
;;

1)
echo "Ingrese nombre del usuario que se encargara del estres"
read u
#su - $u -c "yes > /dev/null &"
sudo -u $u bash -c "yes > /dev/null &"

;;

2)

echo "Ingrese Cantidad de Nucleos"
read u
echo "Ingrese nombre del Usuario"
read usu
#su - $usu -c "for i in {1..4}; do yes > /dev/null & done"
sudo -u $usu bash -c "for i in {1..$u}; do yes > /dev/null & done"

;;

3)

#killall yes
sudo pkill yes

;;

4)

echo "Ingrese usuario"
read us

sudo -u $us pkill yes

;;


6)
# Obtener lista de grupos válidos con GID ≥ 1000 que no sean usuarios
grupos=$(comm -23 <(awk -F: '$3 >= 1000 {print $1}' /etc/group | sort) <(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | sort))

for grupo in $grupos; do
    cgroup_path="/sys/fs/cgroup/$grupo"
    if [ -d "$cgroup_path" ]; then
        echo "---------------------------------"
        echo "Grupo: $grupo"
        echo -n "CPU: " && cat "$cgroup_path/cpu.max"
        echo -n "RAM: " && cat "$cgroup_path/memory.max"
    fi
done
;;






5)

# Obtener lista de usuarios válidos con UID ≥ 1000
usuarios=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)

for usuario in $usuarios; do
    cgroup_path="/sys/fs/cgroup/$usuario"
    if [ -d "$cgroup_path" ]; then
        echo "---------------------------------"
        echo "Usuario: $usuario"
        echo -n "CPU: " && cat "$cgroup_path/cpu.max"
        echo -n "RAM: " && cat "$cgroup_path/memory.max"
    fi
done

;;



0)

OKsalir=1

;;

*)

echo "Catacter Invalido"

;;

esac
done
