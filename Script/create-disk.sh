#!/bin/bash

echo "Создание динамического qcow2-диска для KVM"

# Определяем папку, где лежит сам скрипт (по умолчанию)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Запрашиваем путь для сохранения
read -p "Куда сохранить диск? (по умолчанию: $SCRIPT_DIR): " save_dir

# Если ничего не ввели — используем папку скрипта
if [ -z "$save_dir" ]; then
    save_dir="$SCRIPT_DIR"
fi

save_dir="${save_dir%/}"

# Создаём папку, если её нет
if [ ! -d "$save_dir" ]; then
    echo "📁 Папка $save_dir не существует. Создаём..."
    mkdir -p "$save_dir" || {
        echo "❌ Не удалось создать папку! Проверь права доступа."
        exit 1
    }
    echo "✅ Папка создана"
fi

# Запрашиваем имя файла
read -p "Введите имя файла (без .qcow2): " name

if [ -z "$name" ]; then
    echo "❌ Ошибка: имя файла не может быть пустым!"
    exit 1
fi

# Запрашиваем размер
read -p "Введите размер диска в ГБ (например 50): " size_gb

if ! [[ "$size_gb" =~ ^[0-9]+$ ]] || [ "$size_gb" -le 0 ]; then
    echo "❌ Ошибка: размер должен быть положительным целым числом!"
    exit 1
fi

# Формируем полный путь
filepath="${save_dir}/${name}.qcow2"

# Проверка на существование
if [ -f "$filepath" ]; then
    echo "⚠️  Файл уже существует: $filepath"
    read -p "Перезаписать? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Операция отменена."
        exit 0
    fi
fi

echo "✅ Создаём диск:"
echo "   Путь: $filepath"
echo "   Размер: ${size_gb}G"

qemu-img create -f qcow2 "$filepath" "${size_gb}G"

# Проверка результата
if [ $? -eq 0 ]; then
    echo "🎉 Диск успешно создан!"
    qemu-img info "$filepath" | grep -E "virtual size|disk size"
else
    echo "❌ Ошибка при создании диска!"
fi
