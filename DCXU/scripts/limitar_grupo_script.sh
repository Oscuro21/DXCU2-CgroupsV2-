#!/bin/bash

# Preguntar el nombre del grupo
read -p "Ingrese el nombre del grupo: " grupo

# Obtener usuarios del grupo
usuarios=$(getent group "$grupo" | awk -F: '{print $4}')

# Validar si el grupo tiene usuarios
if [[ -z "$usuarios" ]]; then
    echo "El grupo '$grupo' no tiene usuarios o no existe."
    exit 1
fi

# Crear la carpeta ./config si no existe
config_dir="./config/$grupo"
mkdir -p "$config_dir"

# Preguntar porcentaje de CPU y calcular el valor
read -p "Ingrese el porcentaje de CPU a utilizar: " cpu
cpu_max=$((cpu * 1000))

# Preguntar si se quiere limitar la RAM
read -p "¿Desea limitar la RAM? (s/n): " limitar_ram

if [[ "$limitar_ram" == "s" ]]; then
    read -p "Ingrese la cantidad de RAM en GB: " mem_gb
    memory_max=$((mem_gb * 1024 * 1024 * 1024))
else
    memory_max="MAX"
fi

# Crear archivo de configuración del grupo
echo -e "CPU_MAX=$cpu_max\nMEMORY_MAX=$memory_max" > "$config_dir/config.txt"

# Crear el servicio systemd para el grupo
servicio="/etc/systemd/system/limit-$grupo.service"

sudo bash -c "cat > $servicio" <<EOF
[Unit]
Description=Limitar recursos del grupo $grupo
After=multi-user.target

[Service]
ExecStart=/bin/sh -c 'while true; do for pid in \$(pgrep -u \$(getent group $grupo | cut -d: -f4 | tr ',' ',')); do echo \$pid | tee /sys/fs/cgroup/$grupo/cgroup.procs; done; sleep 2; done'
Restart=always

[Install]
WantedBy=default.target
EOF

# Recargar systemd y activar el servicio
sudo systemctl daemon-reload
sudo systemctl enable --now limit-$grupo

echo "Archivo config.txt creado en ./config/$grupo/ y servicio systemd configurado para el grupo $grupo."

