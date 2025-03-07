#!/bin/bash

set -e  # Detener el script si hay un error

CONFIG_DIR="$(pwd)/config"
mkdir -p "$CONFIG_DIR"

# Función para mostrar los usuarios del sistema
listar_usuarios() {
    echo ""
    echo "Usuarios del sistema:"
    echo ""
    awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd
}

# Función para asignar límites a un usuario
asignar_limites() {
    local usuario=$1
    local cpu_percent=$2
    local cpu_max=$((cpu_percent * 1000))
    local mem_max=$3
    
    echo "Asignando límites a $usuario: CPU=$cpu_max, RAM=${mem_max}B"
    
    # Guardar configuración
    mkdir -p "$CONFIG_DIR/$usuario"
    echo -e "CPU_MAX=$cpu_max\nMEMORY_MAX=$mem_max" > "$CONFIG_DIR/$usuario/config.txt"
    
    # Crear servicio systemd
    servicio="/etc/systemd/system/limit-$usuario.service"
    sudo bash -c "cat > $servicio" <<EOF
[Unit]
Description=Limitar recursos del usuario $usuario
After=multi-user.target

[Service]
ExecStart=/bin/sh -c 'while true; do for pid in \$(pgrep -u $usuario); do echo \$pid | tee /sys/fs/cgroup/$usuario/cgroup.procs; done; sleep 2; done'
Restart=always

[Install]
WantedBy=default.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now limit-$usuario
    sleep 1
    echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control >/dev/null 2>&1
    restaurar_todos
}

# Función para eliminar límites de un usuario
eliminar_limites() {
    local usuario=$1
    echo "Eliminando restricciones para $usuario..."
    sudo systemctl stop limit-$usuario || true
    sudo systemctl disable limit-$usuario || true
    sudo rm -f /etc/systemd/system/limit-$usuario.service
    sudo systemctl daemon-reload
    
    # Mover procesos fuera del cgroup
    if [ -d "/sys/fs/cgroup/$usuario" ]; then
        for pid in $(cat /sys/fs/cgroup/$usuario/cgroup.procs 2>/dev/null); do
            echo $pid | sudo tee /sys/fs/cgroup/cgroup.procs >/dev/null
        done
        sudo rmdir /sys/fs/cgroup/$usuario 2>/dev/null || echo "No se pudo eliminar completamente el cgroup, puede contener archivos protegidos."
    fi
    
    # Eliminar configuración almacenada
    rm -rf "$CONFIG_DIR/$usuario"
}

# Función para ver los límites actuales de un usuario
ver_limites() {
    local usuario=$1
    if [ -d "/sys/fs/cgroup/$usuario" ]; then
        echo "Límites actuales para $usuario:"
        echo "CPU: $(cat /sys/fs/cgroup/$usuario/cpu.max)"
        echo "RAM: $(cat /sys/fs/cgroup/$usuario/memory.max)"
    else
        echo "No hay límites configurados para $usuario."
    fi
}

# Función para restaurar configuraciones de un usuario
restaurar_configuracion() {
    local usuario=$1
    local config_file="$CONFIG_DIR/$usuario/config.txt"
    sudo mkdir -p /sys/fs/cgroup/$usuario
    if [ -f "$config_file" ]; then
        source "$config_file"
        echo "Restaurando límites para $usuario: CPU=$CPU_MAX, RAM=$MEMORY_MAX"

        # Restaurar configuración con el formato correcto
        if [[ "$CPU_MAX" =~ ^[0-9]+$ ]]; then
            echo "$CPU_MAX 100000" | sudo tee /sys/fs/cgroup/$usuario/cpu.max > /dev/null
        else
            echo "CPU_MAX no tiene un valor válido, se dejará como 'max'."
            echo "max 100000" | sudo tee /sys/fs/cgroup/$usuario/cpu.max > /dev/null
        fi

        if [[ "$MEMORY_MAX" =~ ^[0-9]+$ ]]; then
            echo "$MEMORY_MAX" | sudo tee /sys/fs/cgroup/$usuario/memory.max > /dev/null
        fi
    else
        echo "No hay configuración guardada para $usuario."
    fi
}

# Función para restaurar todas las configuraciones
restaurar_todos() {
    for usuario in $(ls "$CONFIG_DIR"); do
        restaurar_configuracion "$usuario"
    done
}

# Función para eliminar límites de todos los usuarios configurados
eliminar_todos() {
    for usuario in $(ls "$CONFIG_DIR"); do
        eliminar_limites "$usuario"
    done
}

# Menú interactivo
listar_usuarios
echo ""
read -p "Ingrese el usuario para configurar o ingrese 'x' para otras opciones: " usuario
if [[ "$usuario" == "x" || "$usuario" == "X" ]]; then
    echo "5) Aplicar configuración a todos los usuarios y grupos"
    echo "6) Eliminar límites de todos los usuarios y grupos"
    echo "7) Eliminar limites de un Usuario o Grupo especifico"
    echo "G) Limitar Consumo de GRUPOS"
    echo ""
    read -p "Seleccione una opción: " opcion
    if [ "$opcion" == "5" ]; then
        restaurar_todos
    elif [ "$opcion" == "6" ]; then
        eliminar_todos
    elif [[ "$opcion" == "g" || "$opcion" == "G" ]]; then
        bash ./scripts/grupos.sh
    elif [ "$opcion" == "7" ]; then
        echo "Ingrese Usuario o Grupo"
	read usuario
        eliminar_limites "$usuario"
    else
        echo "Opción no válida."
    fi
elif [[ ! "$usuario" =~ ^[0-9]+$ ]] && id "$usuario" &>/dev/null; then

    echo ""
    echo "1) Asignar límites"
    echo "2) Eliminar límites y restaurar estado estándar"
    echo "3) Ver límites actuales"
#    echo "4) Aplicar/Restaurar configuración guardada al usuario"
    echo ""
    read -p "Seleccione una opción: " opcion
    if [ "$opcion" == "1" ]; then
        read -p "Ingrese el límite de CPU en porcentaje (ejemplo: 5 para 5%): " cpu_percent
        read -p "Ingrese el límite de RAM en GB (ejemplo: 1 para 1GB): " mem_gb
        mem_max=$((mem_gb * 1024 * 1024 * 1024))
        asignar_limites "$usuario" "$cpu_percent" "$mem_max"
    elif [ "$opcion" == "2" ]; then
        eliminar_limites "$usuario"
    elif [ "$opcion" == "3" ]; then
        ver_limites "$usuario"
    #elif [ "$opcion" == "4" ]; then
    #    restaurar_configuracion "$usuario"
    else
        echo "Opción no válida."
    fi
else
    echo "El usuario no existe."
fi
