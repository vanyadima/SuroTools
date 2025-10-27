# SuroTools
> ⚙️ Проект находится на стадии активного развития.
> В начале представлены базовые настройки и примеры, которые со временем будут дополнены и расширены.

> Набор инструментов, конфигураций и документации для системных администраторов и инженеров Linux.  
> Цель проекта — создать единое место для хранения и автоматизации всех необходимых решений для Linux.

---

<details>
<summary>🐧 ALT Linux</summary>

<details>
<summary>🛠️🐧JEOS</summary>
    
После установки сего шедевра отечественного айти-прома первым делом нужно поставить нужные пакеты для комфортной работы - потому что даже автодополнение команд в этом дистрибутиве является опциональной, недостижимой мечтой, фичей уровня «Enterprise Deluxe Edition» :)))))

```bash
apt-get update
apt-get install bash-completion etcnet-full iptables nano 
```
    
</details>
    
<details>
<summary>🔀Настройка маршрутизации</summary>

<details>
<summary>ip_forward</summary>

net.ipv4.ip_forward позволяет системе работать как маршрутизатор - пересылать пакеты между сетевыми интерфейсами.

```bash
vim /etc/net/sysctl.conf
net.ipv4.ip_forward=1 #Меняем 0 на 1
vim /etc/sysctl.conf
net.ipv4.ip_forward=1
```

Перезагрузка sysctl

```bash
sysctl -p
```

</details>
    
<details>
<summary>iptables</summary>

iptables — это фаервол, который фильтрует и управляет сетевым трафиком на основе правил, решая, что пропустить, а что заблокировать.

Базовые команды iptables:

```bash
# Очистка старых правил
iptables -F
iptables -t nat -F
```

Сохранение настроек:

```bash
iptables-save >> /etc/sysconfig/iptables
systemctl enable iptables
```

 правил на примере коммутатора:

![ на примере коммутатора](Image/ALTLinux/iptables%20sw.png)

```bash
iptables -t nat -A POSTROUTING -o <интерфейс с выходом на интернет> -j MASQUERADE
iptables -A	FORWARD	-i <интернет> -o <внут. инт> -j ACCEPT
iptables -A	FORWARD	-i <внут. инт> -o <интернет> -n state --state ESTABLISHED,RELATED -j ACCEPT
```

>iptables -t nat -A POSTROUTING -o <интерфейс с выходом на интернет> -j MASQUERADE - Прячет все внутренние компьютеры за своим внешним IP (Маскарадинг).
>
>iptables -A	FORWARD	-i <интернет> -o <внут. инт> -j ACCEPT - Позволяет внутренним компьютерам ходить в интернет.
>
>iptables -A	FORWARD	-i <внут. инт> -o <интернет> -n state --state ESTABLISHED,RELATED -j ACCEPT - Пропускает обратно только "ответы" на их запросы, повышая безопасность.

 iptables после настройки DHCP

```bash
iptables -A INPUT -i <инт> -p udp -j ACCEPT
iptables -A INPUT -i <инт> -p tcp -j ACCEPT
```

</details>

<details>
<summary>DHCP</summary>

Установка DHCP-сервера

```bash
apt-get install dhcp-server
```
 /etc/dhcp/dhcpd.conf

```bash
default-lease-time 3600;
max-lease-time 86400;
authoritative;

subnet 10.21.211.0 netmask 255.255.255.0 {
    range 10.21.211.10 10.21.211.230;
    option routers 10.21.211.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.21.211.255;
}
```

> default-lease-time 3600; - время аренды по умолчанию (1 час)
>
> max-lease-time 86400; - максимальное время аренды (24 часа)
>
> authoritative; - сервер является авторитетным для данной сети
>
> subnet 10.21.211.0 netmask 255.255.255.0 - определение подсети
>
> range 10.21.211.10 10.21.211.230; - диапазон выдаваемых IP-адресов
>
> option routers 10.21.211.1; - шлюз по умолчанию
>
> option subnet-mask 255.255.255.0; - маска подсети
>
> option broadcast-address 10.21.211.255; - широковещательный адрес

Создание и  /etc/default/isc-dhcp-server

```bash
DHCP_CONF=/etc/dhcp/dhcpd.conf
DHCP_PID=/var/run/dhcpd.pid
DHCP_OPTS="-4"
INTERFACEv4="<ens34>"
INTERFACEv6=""
```

> DHCP_CONF=/etc/dhcp/dhcpd.conf - путь к основному конфигурационному файлу
>
> DHCP_PID=/var/run/dhcpd.pid - путь к файлу PID-процесса
>
> DHCP_OPTS="-4" - опции запуска (работа только с IPv4)
>
> INTERFACEv4="ens34" - интерфейс для IPv4
>
> INTERFACEv6="" - интерфейс для IPv6 (пусто - отключено)

Запускаем и добавляем в автозапуск dhcpd

```bash
systemctl start dhcpd && systemctl enable dhcpd
```

</details>
  
<details>
<summary> портов и маршрута</summary>

###  интерфейса

❗ Интерфейсы в виртуальную машину добавляем по одному.

>Потому что если накидать сразу пять - потом начнётся великий квест под названием:
>
>“А кто из вас, ребята, ens36?”
>
>Один окажется внутренней сетью, другой мостом, третий вообще зачем-то к Wi-Fi подключён…
>
>И вот ты стоишь посреди ip a, как градоначальник на развалинах, и думаешь - зачем я это сделал?..
>
>Так что добавляем по одному интерфейсу, настраиваем, проверяем, подписываем - и живём спокойно.
>
>Всё как в нормальной инфраструктуре: порядок, последовательность, и никакой магии:)

```bash
mkdir /etc/net/ifaces/ens34/
cp /etc/net/ifaces/ens33/options /etc/net/ifaces/ens34/
```
Если папка ifaces пустая, то берем конфиг options отсюда

```bash
BOOTPROTO=static
TYPE=eth
NM_CONTROLLED=no
DISABLED=no
CONFIG_WIRELESS=no
SYSTEMD_BOOTPROTO=dhcp4
CONFIG_IPV4=yes
SYSTEMD_CONTROLLED=no
ONBOOT=yes
CONFIG_IPV6=no
```
В конфигурации ipv4address пишите ip ❗❗❗ *с маской!!!* ❗❗❗

Поднимаем интерфейс

```bash
ifup ens34
```
Или перезапускаем network

```bash
systemctl restart network
```

###  шлюза

```bash
vim /etc/net/ifaces/ens34/ipv4route
```

```bash
default via <ip роутера>
```

Если по какой-то причине шлюз не хочет вставать - решаем эту проблему до первой перезагрузки:)

```bash
#Добавляем шлюз
ip route add default via 192.168.1.1
#Удаляем шлюз
ip route del default via 192.168.1.1
```

</details>

<details>
<summary>VLAN</summary>

Создаём каталог в интерфейсах

```bash
mkdir /etc/net/ifaces/ens33.XX # где XX - номер vlan
```

Создаем файлы ipv4address и options

```bash
touch /etc/net/ifaces/ens33.XX/ipv4address
touch /etc/net/ifaces/ens33.XX/options
```

Конфигурация options

```bash
TYPE=vlan
HOST=ens33
VID=XX
DISABLED=no
BOOTPROTO=static
```

В конфигурации ipv4address пишите ip ❗❗❗ *с маской!!!* ❗❗❗

</details>

<details>
<summary>GRE туннель</summary>

GRE — это протокол для создания виртуальных точка-точка туннелей, который инкапсулирует один IP-пакет внутри другого, позволяя соединять удалённые сети через интернет.

Создаем каталог gre1 и конфигурируем options

```bash
mkdir /etc/net/ifaces/gre1
vim /etc/net/ifaces/gre1/options
```

```bash
TYPE=iptun
TUNTYPE=gre
TUNLOCAL=<внешний ip роутера, с которого настраиваете>
TUNREMOTE=<внешний ip удаленного роутера>
```

Настраиваем IP турренля

```
nano /etc/net/ifaces/gre1/ipv4address

10.10.10.1/30 #к примеру
```

</details>

</details>

<details>
<summary>📦 Установка и настройка ПО</summary>
    
<details>
<summary>Драйвера VMware</summary>

‼️ Без драйверов VMware вы не сможете копировать команды между вашим компьютером и виртуальной машиной!
    
```bash
apt-get install open-vm-tools open-vm-tools-desktop xrandr
systemctl enable vmtoolsd
systemctl start vmtoolsd
```
> open-vm-tools — базовые функции (общая папка, время, пр.)
>
> open-vm-tools-desktop — автоматическое разрешение экрана, мышь, графика
>
> xrandr — утилита для управления разрешением (на случай ручной настройки)
    
</details>

<details>
<summary>rsyslog</summary>

rsyslog — это система, которая собирает, фильтрует и перенаправляет логи (журналы событий) в нужные места.

Устанавливаем на клиент и на сервер

```bash
apt-get install rsyslog logrotate
```

### Настройка сервера

Настройка конфига в /etc/rsyslog.conf

![Настройка на сервере](Image/ALTLinux/rsyslogsrv.png)

```bash
#include(file="/etc/rsyslog.d/*.conf" mode="options1") 

module(load="imuxsock")
module(load="imklog")
module(load="imudp")
input(type="imudp" port="514")
module(load="imtcp")
input(type="imtcp" port="514")

$template 404, "/opt/%HOSTNAME%/%PROGRAMNAME%.log"

if ($fromhost-ip != "127.0.0.1" and $syslogseverity <= 4) then ?404
& stop 
```

>#include(file="/etc/rsyslog.d/*.conf" mode="optional")  - ЗАКОММЕНТИРОВАНО - подключение дополнительных конфигов
>
>module(load="imuxsock") - Загрузка модуля для Unix-сокетов (локальные приложения)
>
>module(load="imklog") - Загрузка модуля для логов ядра
>
>module(load="imudp") - Загрузка UDP-модуля
>
>input(type="imudp" port="514") - Прослушивание syslog-сообщений по UDP на порту 514
>
>module(load="imtcp") - Загрузка TCP-модуля
>
>input(type="imtcp" port="514") - Прослушивание syslog-сообщений по TCP на порту 514
>
>$template 404, "/opt/%HOSTNAME%/%PROGRAMNAME%.log" - Шаблон для именования файлов логов
>
>if ($fromhost-ip != "127.0.0.1" and $syslogseverity <= 4) then ?404 - Правило фильтрации: если IP отправителя не 127.0.0.1 и уровень серьезности <= 4 (warning)
>
>& stop - Остановка дальнейшей обработки для этих сообщений

P.S. 404 — это произвольное имя шаблона, как переменная.

Создание каталогов для сбора логов клиентских машин

```bash
mkdir -p /opt/cli1
mkdir -p /opt/cli2
mkdir -p /opt/cli3
```
logrotate — это утилита для автоматического управления лог-файлами: их ротации, сжатия, архивирования и удаления по заданным правилам.

Настройка logrotate в /etc/logrotate.d/rsyslog-opt

![Настройка logrotate](Image/ALTLinux/logrotate.png)

```bash
/opt/*/*.log {
    weekly
    size 10M
    rotate 4
    compress
    missingok
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
```
>/opt/*/*.log {                    - Применять правила ко всем .log файлам в поддиректориях /opt/
>
>weekly                        - Ротация раз в неделю
>
>size 10M                      - Или при достижении размера файла 10 МБ
>
>rotate 4                      - Хранить 4 архивных копии логов
>
>compress                      - Сжимать архивные копии gzip
>
>missingok                     - Не считать ошибкой отсутствие файлов логов
>
>notifempty                    - Не ротировать пустые файлы
>
>create 0640 root root         - Создавать новый файл лога с правами 640, владелец root:root
>
>sharedscripts                 - Выполнять скрипты только один раз для всей группы файлов
>
>postrotate                    - Начало блока команд после ротации
>
>systemctl reload rsyslog > /dev/null 2>&1 || true  - Перезагрузка rsyslog, подавление вывода
>
>endscript                     - Конец блока команд
}

Включение автозапуска и немедленный запуск

```bash
systemctl enable --now rsyslog logrotate
```

---

### Настройка клиента

Настройка конфига в /etc/rsyslog.conf

![Настройка на клиенте](Image/ALTLinux/rsyslogcli.png)

```bash
*.warning action(type="omfwd"
    target="10.21.12.50"
    port="514"
    protocol="tcp"
    action.resumeRetryCount="-1"
    queue.type="linkedList"
    queue.size="10000")
```

>*.warning action(type="omfwd"    - Правило для всех сообщений с уровнем warning и выше
>
>target="10.21.12.50"         - Адрес удаленного syslog-сервера
>
>port="514"                   - Порт для отправки
>
>protocol="tcp"               - Использование TCP протокола
>
>action.resumeRetryCount="-1" - Бесконечные попытки переподключения при обрыве
>
>queue.type="linkedList"      - Тип очереди - связный список
>
>queue.size="10000")          - Максимальный размер очереди - 10000 сообщений

Включение автозапуска и немедленный запуск

```bash
systemctl enable --now rsyslog
```

</details>

<details>
<summary>DNS сервер (bind)</summary>

Установка и включение bind

```bash
apt-get install bind bind-utils
systemctl start bind
```

<details>
<summary>Базовая настройка (Кэширование сети)</summary>

Самая простая настройка - сделать сервер кэширующим для Вашей сети. Он будет принимать запросы от клиентов и перенаправлять их вышестоящим серверам 

```bash
options {
    # Слушаем на всех интерфейсах, порт 53
    listen-on { any; };
    listen-on-v6 { any; };

    # Разрешаем запросы от клиентов в вашей сети (например, 192.168.1.0/24)
    allow-query { localhost; 192.168.1.0/24; };

    # Рекурсивные запросы разрешены для доверенных клиентов
    recursion yes;
    allow-recursion { localhost; 192.168.1.0/24; };

    # Укажите форвардеры (DNS-сервера, которым BIND будет пересылать запросы)
    forwarders {
        8.8.8.8;
        8.8.4.4;
        1.1.1.1;
    };

    # Каталог по умолчанию для файлов зон
    directory "/var/bind";

    # Опции безопасности: не раскрываем версию BIND
    version "not currently available";

    # Опции DNSSEC
    dnssec-validation auto;
    auth-nxdomain no;    # conform to RFC1035
};

```
</details>

<details>
<summary>Создание прямой зоны </summary>
    
</details>

</details>

</details>

<details>
<summary>🎨 Установка графической оболочки (на примере xfce)</summary>

### Установка

```bash
apt-get install task-edu-xfce lightdm
systemctl enable --now lightdm
```

### Удаление

```bash
apt-get remove 'xfce4*' 'xfwm4*' 'thunar*' --purge
apt-get remove lightdm
systemctl disable lightdm
```

</details>

</details>

---

<details>
<summary>🧊 Arch Linux</summary>

<details>
<summary>🛠️ Установка ОС</summary>

<details>
<summary>Перед установкой</summary>
    
Вот и настал тот самый день. День, когда вы решили, что жить спокойно — это не про вас, и поставили цель установить Arch Linux в качестве основной системы. 

Поздравляю! :)

Вы уже скачали образ, записали его на флешку, загрузились, и перед вами гордо мигает курсор в терминале. Момент истины настал.

Но… что дальше? 
Правильно! Сначала нужно убедиться, что интернет работает.

```bash
ping archlinux.org
```

Если вы на Wi-Fi, то пора приручить беспроводную сеть. Делается это просто (ну, относительно просто):

Проверка на блок Wi-Fi

```bash
rfkill
```

Если заблокирован - выполянем команду:

```bash
rfkill unblock wifi
```

### Подключение к Wi-Fi

```bash
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <SSID>
```

Или можно сделать проще:

```bash
wifi-menu
```

</details>
    
<details>
<summary>1. Монтирование и разметка дисков</summary>
Для того, чтобы определять диски, используется команда <code>lsblk</code>
    
```bash
lsblk
```
Теперь нам нужно выбрать: GPT или MBR. Если у тебя ПК с UEFI - ставль GPT. 

А если стоит BIOS, - MBR

Внизу таблицы разметки

<details>
<summary>MBR</summary>

Разметка раздела

| Раздел | Название | Формат | Размер   | Назначение          |
|---------|-----------|---------|----------|----------------------|
| sdX1    | bios      | BIOS    | 1 MB    | Загрузочный BIOS     |
| sdX2    | boot      | EXT4    | 1 GB    | Ядра Linux           |
| sdX3    | swap      | SWAP    | 8 GB    | Раздел подкачки      |
| sdX4    | root      | EXT4   | Всё остальное | Система, данные      |


</details>

<details>
<summary>GPT</summary>

Разметка раздела

| Раздел | Название | Формат | Размер   | Назначение          |
|---------|-----------|---------|----------|----------------------|
| sdX1    | efi      | FAT32    | 300 MB    | Загрузочный BIOS     |
| sdX2    | boot      | EXT4    | 1 GB    | Ядра Linux           |
| sdX3    | swap      | SWAP    | 8 GB    | Раздел подкачки      |
| sdX4    | root      | EXT4   | Всё остальное | Система, данные      |

</details>

С помощью утилиты fdisk / cfdisk форматируем каталоги

```bash
mkfs.fat -F32 /dev/sda1
mkfs.ext4 -L boot /dev/sda2
mkswap -L swap /dev/sda3
mkfs.ext4 -L arch /dev/sda4 
```

Монтируем диски

```bash
mount /dev/sda4 /mnt                        
mkdir -p /mnt/{boot,home,var}          
mount /dev/sda2 /mnt/boot 
mkdir -p /mnt/boot/efi                        
mount /dev/sda1 /mnt/boot/efi                 
```

</details>

<details>
<summary>2. Установка ядра и базовая настройка</summary>

На этом этапе мы, наконец, превращаем пустой раздел /mnt во что-то, похожее на операционную систему

```bash
pacstrap /mnt base base-devel linux linux-headers linux-firmware intel-ucode amd-ucode nano               
```
или (LTS версия)

```bash
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware intel-ucode amd-ucode nano             
```

>base - минимальный набор, чтобы система вообще существовала
>
>base-devel - инструменты для сборки пакетов, потому что половину софта в Arch вы всё равно соберёте сами
>
>linux и linux-headers - ядро и его заголовки. Без них компьютер не поймёт, что делать
>
>linux-firmware - чтобы Wi-Fi, видеокарта и прочее не притворялись кирпичами
>
>intel-ucode и amd-ucode - микрокоды, которые чинят ошибки в процессорах. Неплохо, когда CPU не падает в обморок от собственного кода=)

Мы уже установили Arch в /mnt, всё красиво, но пока что система не знает, где у неё что лежит.
Она загрузится - и спросит:

«А где мой корень? А где /home? А swap куда делся?»

Чтобы этого не произошло, мы создаём файл /etc/fstab.
В нём записано, какие разделы куда монтировать при загрузке.

```bash
genfstab -pU /mnt >> /mnt/etc/fstabi                 
```

>genfstab — просто смотрит на то, что сейчас примонтировано
>
>-U - записывает всё с использованием UUID (уникальных идентификаторов разделов, чтобы не перепутать при перезагрузке)
>
>-p - добавляет информацию о существующих точках монтирования

Меняем корневой каталог на /mnt

```bash
arch-chroot /mnt                
```

Задаем пароль root

```bash
passwd               
```

Даем имя

```bash
nano /etc/hostname               
```

Настройка временной зоны

```bash
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime               
```

Открываем файл с локалями и раскомментируем строки:

```bash
nano /etc/locale.gen

#Ищем
ru_RU.UTF8 UTF8
en_US.UTF8 UTF8

```

Создаем локали

```bash
locale-gen              
```

Настраиваем язык консоли, добавляем кириллицу

```bash
nano /etc/vconsole.conf

KEYMAP=ru
FONT=cyr-sun16  
```

Устанавливаем язык системы по умолчанию

```bash
nano /etc/locale.conf

LANG="ru_RU.UTF-8"
```
</details>

<details>
<summary>3. PACMAN</summary>

Когда вы ставите Arch, у вас есть свежая система, которая пока не доверяет никому.
И это, в принципе, правильно - кто знает, что там за пакеты в интернете?)))

Инициализируем пакетный менеджер pacman и загружаем ключи

```bash
pacman-key --init
pacman-key --populate archlinux    
```

Конфигурируем pacman

```bash
nano /etc/pacman.conf             
```

Включаем репозитории multilib

```bash
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Это добавит поддержку 32-битных библиотек.
Они нужны, если вы хотите запускать старые программы или, например, игры из Steam, которые до сих пор живут в прошлом=)

Без этого Steam просто посмотрит на вас, скажет «нет библиотек» и уйдёт

Можно сделать так, чтобы pacman не только работал, но и выглядел симпатично:

>Color — включает цветную подсветку
>Чтобы видеть, где успех, а где ошибка, не только по интонации
>
>ParallelDownloads = 5 — позволяет качать несколько пакетов одновременно
>Архивы прилетают быстрее, и вы чувствуете, что живёте в XXI веке
>
>ILoveCandy — не влияет ни на что, кроме настроения
>Делает индикатор загрузки похожим на игру Pac-Man: маленький жёлтый кружок ест пакеты
>Серьёзная система, но с чувством юмора😄

Теперь добавляем то, что делает систему по-настоящему удобной

```bash
pacman -Sy
pacman -S bash-completion openssh arch-install-scripts networkmanager git wget htop neofetch xdg-user-dirs pacman-contrib ntfs-3g
```

>bash-completion - автодополнение в терминале.
>Чтобы не набирать по памяти всё целиком, как герой.
>
>openssh - возможность подключаться по SSH, и к вам тоже.
>Без него сервер - это просто компьютер, скучающий в углу.
>
>arch-install-scripts - набор утилит, включая genfstab и arch-chroot.
>Уже пользовались ими - теперь они станут постоянными жителями вашей системы.
>
>networkmanager - ваш новый лучший друг для Wi-Fi и сетей.
>Без него - вручную через ip link и dhcpcd, что весело, но недолго.
>
>git - чтобы клонировать репозитории, коммитить, и вообще чувствовать себя разработчиком.
>
>wget - чтобы скачивать всё подряд без браузера.
>Минимализм, но с пользой.
>
>htop - чтобы смотреть, кто ест всю оперативку, в красивом интерфейсе.
>
>neofetch - чтобы показывать красивую ASCII-заставку системы и рассказывать всем, что у вас Arch.
>
>xdg-user-dirs - создаёт стандартные папки вроде Documents, Downloads и т.д.
>Чтобы домашний каталог не выглядел как свалка.
>
>pacman-contrib - набор дополнительных инструментов для pacman, включая checkupdates и paccache.
>
>ntfs-3g - чтобы Linux мог читать и писать на диски с файловой системой Windows.
>Полезно, если вы ещё не готовы окончательно попрощаться с прошлым.

</details>

<details>
<summary>4. Постустановка</summary>

Создаем начальный загрузочный лиск (в зависимости какое ядро вы выбрали)

```bash
mkinitcpio -p linux
mkinitcpio -p linux-lts
```

Разрешаем пользователю применять права root

```bash
nano /etc/sudoers

%wheel ALL=(ALL:ALL) ALL
```

Создаем пользователя и придумываем пароль для него

```bash
useradd -mg users -G wheel <имя пользователя> 
passwd <имя пользователя> 
```

Добавляем в автозагрузку сетевой менеджер

```bash
systemctl enable NetworkManager.service
```

</details>

<details>
<summary>5. GRUB</summary>

Для UEFI
    
```bash
pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
```

Для BIOS

```bash
pacman -S grub os-prober
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

</details>

<details>
<summary>6. Установка графики</summary>

Intel

```bash
pacman -S xf86-video-intel
```

NVIDIA

```bash
pacman -S nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-dkms
```

AMD

```bash
pacman -S lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

Установка менеджер входа

| DM          | Особенности                                                                |
| ----------- | -------------------------------------------------------------------------- |
| **GDM**     | GNOME Display Manager, лучший для GNOME/GTK, поддержка Wayland             |
| **SDDM**    | Simple Desktop Display Manager, лучший для KDE/Qt, поддержка тем и Wayland |
| **LightDM** | Легкий универсальный DM, поддерживает GTK и Qt, множество грейдеров        |
| **LXDM**    | Очень легкий, для LXDE/LXQt, минималистичный                               |
| **XDM**     | Классический XDM, минимальный, без настроек                                |

Рекомендации по DM

| DE            | Рекомендуемый DM |
| ------------- | ---------------- |
| GNOME         | GDM              |
| KDE Plasma    | SDDM             |
| LXQt          | SDDM / LightDM   |
| XFCE          | LightDM          |
| Cinnamon      | LightDM          |
| MATE          | LightDM          |
| LXDE          | LXDM / LightDM   |
| Deepin        | GDM              |
| Budgie        | LightDM          |
| Enlightenment | LightDM / LXDM   |


<details>
<summary>GDM</summary>

```bash
sudo pacman -S gdm
sudo systemctl enable gdm.service   
sudo systemctl start gdm.service 
```

</details>

<details>
<summary>SDDM</summary>

```bash
sudo pacman -S sddm
sudo systemctl enable sddm.service
sudo systemctl start sddm.service
```

</details>

<details>
<summary>LightDM</summary>

```bash
sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
sudo systemctl enable lightdm.service
sudo systemctl start lightdm.service
```

</details>

Графические оболочки и их установка

<details>
<summary>GNOME</summary>

```bash
sudo pacman -S gnome gnome-extra gdm
sudo systemctl enable gdm
sudo pacman -S gnome-tweaks gnome-shell-extensions gnome-themes-extra
```

</details>

<details>
<summary>KDE Plasma</summary>

```bash
sudo pacman -S plasma kde-applications sddm
sudo systemctl enable sddm
sudo pacman -S kde-graphics-meta kde-utilities-meta plasma-wayland-session
```

</details>

<details>
<summary>XFCE</summary>

```bash
sudo pacman -S xfce4 xfce4-goodies
sudo pacman -S thunar-volman gvfs gvfs-mtp tumbler ristretto parole
```

</details>

<details>
<summary>Cinnamon</summary>

```bash
sudo pacman -S cinnamon nemo-fileroller cinnamon-translations
sudo pacman -S lightdm-slick-greeter xed xviewer pix
```

</details>

<details>
<summary>MATE</summary>

```bash
sudo pacman -S mate mate-extra
sudo pacman -S caja-extensions mate-system-monitor mate-power-manager
```

</details>

<details>
<summary>LXQt</summary>

```bash
sudo pacman -S lxqt lxqt-qtplugin lximage-qt obconf-qt
sudo pacman -S xdg-utils gvfs sddm
sudo systemctl enable sddm
```

</details>

<details>
<summary>LXDE</summary>

```bash
sudo pacman -S lxde
sudo pacman -S lxappearance lxtask galculator gpicview
```

</details>

<details>
<summary>Budgie</summary>

```bash
sudo pacman -S budgie-desktop budgie-extras
sudo pacman -S gnome-control-center gnome-terminal nautilus
```

</details>

<details>
<summary>Deepin</summary>

```bash
sudo pacman -S deepin deepin-extra
sudo pacman -S deepin-terminal deepin-file-manager deepin-screenshot
```

</details>

<details>
<summary>Enlightenment</summary>

```bash
sudo pacman -S enlightenment terminology ephoto rage
```

</details>

</details>

<details>
<summary>7. Конец установки</summary>

```bash
exit
umount -R /mnt
reboot
```

</details>

<details>
<summary>Рекомендую после установки ОС</summary>
Пакетный менеджер yay для пользовательского репозитория AUR и ARCH

```bash
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```
Имеет смысл отключить сборку отладочных пакетов, выключив !debug и !strip

```bash
sudo sed -i.bak '/^OPTIONS=/s/strip/!strip/; /^OPTIONS=/s/debug/!debug/' /etc/makepkg.conf
```

Timeshift — система резервного копирования

```bash
sudo pacman -S timeshift
```

Скрипт автоматического резервного копирования при обновлениях

```bash
yay -S timeshift-autosnap
```

Автоматическая очистка кэша пакетов

```bash
sudo pacman -S pacman-contrib
sudo systemctl enable paccache.timer
```

</details>

<details>
<summary>Путь самурая (для ленивых)</summary>

Герой <code>archinstall</code>! Перед тем как ты нажал на этот чудесный спойлер, взгляни на методичку сверху. Она там лежит, как тайный свиток мудрости: не страшно, не укусит, а поможет почувствовать, что Arch - это не просто «клик-клик-установил».

Подумай о методичке как о карте сокровищ: каждая страница - подсказка, как собрать свой Arch не просто рабочим, а с удовольствием и чуть-чуть гордости. И кто знает, может, именно там ты найдёшь тот секрет, который превращает «Next-Next-Finish» в «Ого, я сам это сделал!».

Так что берёшь чашку кофе, садишься поудобнее и слегка посмеиваешься над собой - методичка сверху ждёт:)

</details>

</details>

<details>
<summary>📦 Установка и настройка ПО</summary>

</details>

</details>

---

<details>
<summary>🔄 CentOS</summary>

Пока пусто :(

</details>

---

<details>
<summary>🌿 EcoRouter</summary>

Пока пусто :(

</details>

---

<details>
<summary>🌐 VyOS</summary>

VyOS — это бесплатный Linux-дистрибутив для превращения сервера или ПК в мощный сетевой маршрутизатор. Прямой аналог Cisco с похожим интерфейсом командной строки (CLI), но работающий на стандартном железе.

<details>
<summary>🛠️ Установка ОС</summary>

Вводим пользователя и пароль

```bash
vyos login: vyos
Password: vyos
```

Установка ОС

```bash
install image

This command will install VyOS to your permanent storage. 
Would you like to continue? [y/N] y
What would you like to nаме this image? <enter>
Please enter a password for the ”vyos" user: vyos
What console should be used by default? (K: KVM, S: Serial)?
# если на виртуралку - нажимаем K
# если на железо - нажимаем S
Probing disks
1 disk(s) found
The following disks were found:
Drive: /dev/sda (20.0 GB)
Which one should be used for installation? (Default: /dev/sda) <enter>
Installation will delete all data on the drive. Continue? [y/N] y
Would you like to use all the free space on the drive? [Y/n] y
```
```bash
The following config files are available for boot:
1: /opt/vyatta/etc/config/config.boot
2: /opt/vyatta/etc/config.boot.default

Which file would you like as boot config? (Default: 1)
```

>/opt/vyatta/etc/config/config.boot → Это текущая живая конфигурация, которая сейчас в памяти.
>
>/opt/vyatta/etc/config.boot.default → Это чистый дефолтный конфиг, минимальный, без изменений.

```bash
reboot
```

</details>

<details>
<summary>🧭 Команды</summary>

| Категория | Команда | Назначение |
|------------|----------|-------------|
| **Режимы CLI** | `configure` | Войти в режим конфигурации |
| | `exit` | Выйти в операционный режим |
| | `run <команда>` | Выполнить операционную команду из конфигурационного режима |
| | `commit` | Применить изменения |
| | `save` | Сохранить конфигурацию в `/config/config.boot` |
| | `discard` | Отменить неподтверждённые изменения |
| | `compare` | Показать разницу между текущей и сохранённой конфигурацией |
| | `show configuration` | Показать текущую конфигурацию |
| **Система** | `set system host-name vyos-router` | Установить имя хоста |
| | `set system domain-name example.local` | Установить доменное имя |
| | `set system time-zone Europe/Moscow` | Установить часовой пояс |
| | `set system name-server 1.1.1.1` | DNS-сервер |
| | `set system name-server 8.8.8.8` | Дополнительный DNS |
| | `set system login user admin authentication plaintext-password mypass` | Создать пользователя |
| | `set system login user vyos level admin` | Установить уровень доступа |
| | `delete system login user <user>` | Удалить пользователя |
| | `set system console device ttyS0` | Активировать serial-консоль |
| | `show system image` | Показать установленные образы VyOS |
| | `add system image /path/to/image.iso` | Установить новую версию VyOS |
| | `delete system image <version>` | Удалить старый образ |
| | `reboot` / `sudo reboot` | Перезагрузить систему |
| | `poweroff` / `sudo poweroff` | Выключить систему |
| | `show version` | Показать текущую версию VyOS |
| **Интерфейсы** | `set interfaces ethernet eth0 address dhcp` | Автоматическое получение IP |
| | `set interfaces ethernet eth0 address 192.168.1.1/24` | Задать статический IP |
| | `set interfaces ethernet eth0 description "WAN"` | Добавить описание |
| | `set interfaces ethernet eth1 address 10.0.0.1/24` | Задать LAN-интерфейс |
| | `set interfaces ethernet eth1 disable` | Отключить интерфейс |
| | `delete interfaces ethernet eth1` | Удалить интерфейс |
| | `show interfaces` | Показать состояние всех интерфейсов |
| | `show interfaces ethernet eth0` | Показать детали интерфейса |
| | `show interfaces brief` | Краткий обзор интерфейсов |
| **Маршрутизация** | `set protocols static route 0.0.0.0/0 next-hop 192.0.2.1` | Маршрут по умолчанию |
| | `set protocols static route 10.10.0.0/24 next-hop 192.168.1.2` | Статический маршрут |
| | `delete protocols static route <сеть>` | Удалить маршрут |
| | `show ip route` | Таблица маршрутизации |
| | `show ipv6 route` | Таблица IPv6 маршрутов |
| **NAT** | `set nat source rule 100 outbound-interface eth0` | Указать исходящий интерфейс |
| | `set nat source rule 100 source address 192.168.1.0/24` | Исходный диапазон адресов |
| | `set nat source rule 100 translation address masquerade` | Включить маскарадинг |
| | `set nat destination rule 200 inbound-interface eth0` | Входящий интерфейс для DNAT |
| | `set nat destination rule 200 destination port 80` | Порт назначения |
| | `set nat destination rule 200 translation address 192.168.1.10` | IP назначения после DNAT |
| | `set nat destination rule 200 translation port 80` | Порт назначения после DNAT |
| | `show nat source translations` | Активные исходящие NAT-сессии |
| | `show nat destination translations` | Активные входящие DNAT-сессии |
| **Firewall** | `set firewall name WAN_IN default-action drop` | Действие по умолчанию — блокировать |
| | `set firewall name WAN_IN rule 10 action accept` | Разрешить соединения |
| | `set firewall name WAN_IN rule 10 state established enable` | Разрешить установленные соединения |
| | `set firewall name WAN_IN rule 10 state related enable` | Разрешить связанные соединения |
| | `set firewall name WAN_IN rule 20 action drop` | Явно блокировать трафик |
| | `set interfaces ethernet eth0 firewall in name WAN_IN` | Применить firewall к интерфейсу |
| | `show firewall name WAN_IN` | Проверить состояние правил |
| **VPN (WireGuard, IPsec, OpenVPN)** | `set interfaces wireguard wg0 address 10.10.10.1/24` | Создать интерфейс WireGuard |
| | `set interfaces wireguard wg0 listen-port 51820` | Установить порт |
| | `set interfaces wireguard wg0 peer PEER1 public-key <ключ>` | Добавить peer |
| | `set interfaces wireguard wg0 peer PEER1 allowed-ips 10.10.10.2/32` | Разрешённые IP |
| | `set vpn ipsec site-to-site peer <ip>` | Создать IPsec peer |
| | `set vpn ipsec site-to-site peer <ip> authentication mode pre-shared-secret` | Метод аутентификации |
| | `set vpn ipsec site-to-site peer <ip> local-address <addr>` | Локальный адрес IPsec |
| | `show vpn ipsec sa` | Проверить статус IPsec |
| **Сервисы** | `set service ssh` | Включить SSH-сервер |
| | `set service https api enable` | Включить HTTPS API |
| | `set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 range 0 start 192.168.1.100 end 192.168.1.200` | DHCP диапазон |
| | `set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 default-router 192.168.1.1` | Gateway для DHCP |
| | `set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 dns-server 1.1.1.1` | DNS для DHCP |
| | `show service dhcp-server leases` | Просмотр активных DHCP-лизов |
| | `restart service ssh` | Перезапустить SSH |
| | `restart service dhcp-server` | Перезапустить DHCP |
| **Диагностика** | `ping 8.8.8.8` | Проверка соединения |
| | `traceroute 8.8.8.8` | Трассировка маршрута |
| | `show log` | Просмотр системного лога |
| | `show log tail` | Последние строки лога |
| | `show system processes` | Просмотр запущенных процессов |
| | `show arp` | Таблица ARP |
| | `show dhcp client leases` | Текущие DHCP-лизы |
| | `monitor traffic interface eth0` | Просмотр трафика в реальном времени |
| | `show configuration commands` | Конфигурация в виде команд |
| **Работа с файлами** | `ls /config` | Просмотр содержимого каталога конфигураций |
| | `cat /config/config.boot` | Просмотр текущей конфигурации |
| | `cp /config/config.boot /config/config.backup` | Создание резервной копии |
| | `load /config/config.backup` | Загрузка сохранённой конфигурации |
| | `save /config/config.boot` | Сохранение конфигурации |
| **Прочее / системное** | `show system storage` | Проверить дисковое пространство |
| | `show system uptime` | Время работы системы |
| | `show hardware cpu` | Информация о CPU |
| | `show hardware temperature` | Температура оборудования |
| | `show interfaces statistics` | Статистика трафика |
| | `clear interface statistics eth0` | Сброс статистики интерфейса |
| | `run show system boot-messages` | Показать логи загрузки |
| | `show users` | Список пользователей |
| | `show configuration diff` | Разница между конфигурациями |

</details>

<details>
<summary>Настройка маршрутизации</summary>

<details>
<summary>Настройка портов</summary>

```bash
config
set interfaces ethernet <интерфейс на интернет> address dhcp
set interfaces ethernet <интерфейс на локалку> address <ip адрес/маска>
commit
save
```

Если провайдер выдал статические ip

```bash
config
set interfaces ethernet eth0 address <ip адрес/маска>
set protocols static route 0.0.0.0/0 next-hop <ip адрес шлюза>
commit
save
```

</details>

<details>
<summary>NAT</summary>

```bash
config
set nat source rule 1 outbound-interface name <интерфейс на интернет>
set nat source rule 1 source address <ip маршрут/маска интерфейса на локалку>
set nat source rule 1 translation address masquerade
commit
save
```
</details>

<details>
<summary>VLAN</summary>
    
```bash
config
set interfaces ethernet eth1 vif 2 address 192.168.2.1/24
set interfaces ethernet eth2 vif 3 address 192.168.3.1/24
commit
save
```

<code>vif</code> - виртуальный интерфейс VLAN

Если нужно взять несколько интерфейсов в один VLAN - создаем мост

```bash
configure
# создаём мост
set interfaces bridge br0

# добавляем интерфейсы в мост
set interfaces bridge br0 member interface eth1
set interfaces bridge br0 member interface eth2
set interfaces bridge br0 member interface eth3
set interfaces bridge br0 member interface eth4
set interfaces bridge br0 member interface eth5

# включаем поддержку VLAN на мосту
set interfaces bridge br0 enable-vlan

# создаём VLAN на мосту
set interfaces bridge br0 vif 2 address 192.168.2.1/24
set interfaces bridge br0 vif 3 address 192.168.3.1/24

commit
save
```

❗ Не забываем настраивать клиент на работу с VLAN! 

>Почему мы используем мост br0 в VyOS?
>Потому что один порт — это скучно, два порта — еще терпимо,
>а мост — это как админский спа-комплекс для пакетов: 
>все интерфейсы встречаются, общаются, и никто не теряется. 😎

</details>

<details>
<summary>DHCP</summary>

```bash
set service dhcp-server shared-network-name <имя> authoritative
set service dhcp-server shared-network-name <имя> subnet 192.168.100.0/24 subnet-id 1
set service dhcp-server shared-network-name <имя> subnet 192.168.100.0/24 default-router '192.168.100.1'
set service dhcp-server shared-network-name <имя> subnet 192.168.100.0/24 range 0 start '192.168.100.10'
set service dhcp-server shared-network-name <имя> subnet 192.168.100.0/24 range 0 stop '192.168.100.100'
commit
save
```

</details>

<details>
<summary>DNS</summary>

```bash
set system name-server 77.88.8.8
commit
save
```

</details>

</details>

</details>

---
## 💾 Образы ОС

JEOS ALT Linux - [Скачать](https://nightly.altlinux.org/sisyphus/tested/regular-jeos-systemd-latest-x86_64.iso)

VyOS - [Скачать](https://vyos.net/get/)

---
## 📂 Полезные штучки
<details>
<summary>Автоматизация настройки статики</summary>

<details>
<summary>ALT Linux</summary>

</details>

</details>

<details>
<summary>🔧 Репозитории Linux</summary>

| ОС / Дистрибутив | Репозиторий | Путь к конфигурационному файлу |
| :--- | :--- | :--- |
| **Debian** | `deb http://deb.debian.org/debian/ bookworm main`<br>`deb-src http://deb.debian.org/debian/ bookworm main` | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/` |
| **Ubuntu** | `deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse`<br>`deb-src http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse` | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/` |
| **Fedora** | `baseurl=https://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/`<br>`metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch` | `/etc/yum.repos.d/fedora.repo`<br>`/etc/yum.repos.d/fedora-updates.repo` |
| **CentOS** | `baseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/`<br>`baseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/` | `/etc/yum.repos.d/CentOS-Base.repo` |
| **Arch Linux** | `Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch` | `/etc/pacman.d/mirrorlist` |
| **openSUSE** | `baseurl=https://download.opensuse.org/distribution/leap/$releasever/repo/oss/` | `/etc/zypp/repos.d/` |
| **AlmaLinux** | `baseurl=https://repo.almalinux.org/almalinux/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://repo.almalinux.org/almalinux/$releasever/AppStream/$basearch/os/` | `/etc/yum.repos.d/almalinux.repo` |
| **Rocky Linux** | `baseurl=https://download.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://download.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/` | `/etc/yum.repos.d/rocky.repo` |

Переменные
- `$releasever` — версия дистрибутива (40 для Fedora, 9.0 для CentOS Stream)
- `$basearch` — архитектура процессора (x86_64, aarch64)
- `$repo` — имя репозитория (core, extra, community в Arch)
- `$arch` — архитектура процессора

Ключевые слова репозиториев (Debian/Ubuntu)
- **main** — официальные пакеты
- **restricted** — проприетарное ПО, необходимое для системы
- **universe** — ПО, поддерживаемое сообществом
- **multiverse** — проприетарное ПО, не поддерживаемое официально

Обновление конфигурации
- **Debian/Ubuntu**: `sudo apt update`
- **Fedora/CentOS/RHEL**: `sudo dnf check-update`
- **Arch Linux**: `sudo pacman -Syy`

</details>

---

## 🧑‍💻 Автор

> Автор: **vanyadima**  
> Контакт: **isurodin@yandex.ru** **[VK](https://vk.com/surodyn)** **[Telegram](https://t.me/vanyadlma)**

## 💬 Благодарности

Особая благодарность **[Gerasti](https://github.com/Gerasti)** —  
за вдохновение и подход к организации проекта, которые послужили основой для создания SuroTools.
