#!/bin/bash
#
# Инициализация и запуск Open vSwitch
# - Без установки
# - Без сборки
# - Без sudo (только root)
# - Идемпотентный (можно запускать многократно)
#

set -e

############################
# Проверка root
############################
if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: скрипт должен быть запущен от root."
    exit 1
fi

############################
# Пути
############################
OVS_ETC="/etc/openvswitch"
OVS_DB="${OVS_ETC}/conf.db"
OVS_SCHEMA="/usr/share/openvswitch/vswitch.ovsschema"
OVS_CTL="/usr/share/openvswitch/scripts/ovs-ctl"

############################
# Проверки
############################
if [ ! -x "$(command -v ovsdb-tool)" ]; then
    echo "Ошибка: ovsdb-tool не найден. Open vSwitch не установлен?"
    exit 1
fi

if [ ! -f "${OVS_SCHEMA}" ]; then
    echo "Ошибка: схема OVS не найдена: ${OVS_SCHEMA}"
    exit 1
fi

if [ ! -x "${OVS_CTL}" ]; then
    echo "Ошибка: ovs-ctl не найден: ${OVS_CTL}"
    exit 1
fi

############################
# Создание базы OVSDB
############################
echo "Проверка базы Open vSwitch..."

mkdir -p "${OVS_ETC}"

if [ ! -f "${OVS_DB}" ]; then
    echo "Создание ${OVS_DB}"
    ovsdb-tool create "${OVS_DB}" "${OVS_SCHEMA}"
else
    echo "База ${OVS_DB} уже существует"
fi

############################
# Запуск OVS
############################
echo "Запуск Open vSwitch..."

"${OVS_CTL}" start

############################
# Проверка
############################
echo "Проверка состояния..."

ovs-vsctl show

echo "========================================"
echo "Open vSwitch успешно инициализирован и запущен."
echo "========================================"
