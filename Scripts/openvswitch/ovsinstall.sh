#!/bin/bash
#
# Установка Open vSwitch из исходников на ALT Linux
# Без sudo, запуск ТОЛЬКО от root
# При отсутствии зависимостей — автоматическая установка из репозиториев
#

set -e  # Завершать выполнение при ошибке

############################
# Проверка прав root
############################
if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: скрипт должен быть запущен от root."
    exit 1
fi

############################
# Параметры Open vSwitch
############################
OVS_VERSION="3.6.1"
OVS_TAR="openvswitch-${OVS_VERSION}.tar.gz"
OVS_URL="https://www.openvswitch.org/releases/${OVS_TAR}"
INSTALL_DIR="/tmp/ovs-install"

############################
# Проверка и установка зависимостей
############################
echo "Проверка зависимостей..."

REQUIRED_CMDS=(
    gcc
    make
    python3
    wget
    curl
    tar
)

REQUIRED_PKGS=(
    gcc
    make
    python3
    libssl-devel
    libcap-ng-devel
    libunbound-devel
)

MISSING_PKGS=()

# Проверка команд
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING_PKGS+=("$cmd")
    fi
done

# Проверка библиотек (через pkg-config где возможно)
if ! pkg-config --exists openssl 2>/dev/null; then
    MISSING_PKGS+=("libssl-devel")
fi

if ! pkg-config --exists libcap-ng 2>/dev/null; then
    MISSING_PKGS+=("libcap-ng-devel")
fi

if ! pkg-config --exists libunbound 2>/dev/null; then
    echo "Примечание: libunbound не найден (необязательно, но рекомендуется)"
fi

# Установка недостающих пакетов
if [ "${#MISSING_PKGS[@]}" -ne 0 ]; then
    echo "Будут установлены недостающие пакеты:"
    printf '  %s\n' "${MISSING_PKGS[@]}"

    apt-get update
    apt-get install -y "${MISSING_PKGS[@]}"
else
    echo "Все основные зависимости уже установлены."
fi

############################
# Сборка Open vSwitch
############################
echo "Начало установки Open vSwitch ${OVS_VERSION}"

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

# Загрузка исходников
if command -v wget >/dev/null 2>&1; then
    wget "${OVS_URL}"
else
    curl -LO "${OVS_URL}"
fi

# Распаковка
tar -xzf "${OVS_TAR}"
cd "openvswitch-${OVS_VERSION}"

# Конфигурация
./configure \
    --prefix=/usr \
    --localstatedir=/var \
    --sysconfdir=/etc

# Компиляция
make -j"$(nproc)"

# Установка
make install

############################
# Очистка
############################
cd /
rm -rf "${INSTALL_DIR}"

echo "========================================"
echo "Open vSwitch ${OVS_VERSION} успешно установлен."
echo
echo "Управление OVS:"
echo "  /usr/share/openvswitch/scripts/ovs-ctl start"
echo "  /usr/share/openvswitch/scripts/ovs-ctl stop"
echo "========================================"
