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

Настройка правил на примере коммутатора:

![Настройка на примере коммутатора](Image/ALTLinux/iptables%20sw.png)

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

Настройка iptables после настройки DHCP

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
Настройка /etc/dhcp/dhcpd.conf

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

Создание и настройка /etc/default/isc-dhcp-server

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
<summary>Статическая маршрутизация</summary>

### Настройка интерфейса

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

### Настройка шлюза

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

</details>

<details>
<summary>2. Установка ядра и базовая настройка</summary>
Пока пусто :(

</details>

<details>
<summary>3. GRUB</summary>



</details>

<details>
<summary>4. Установка графики</summary>
Пока пусто :(

</details>

<details>
<summary>Рекомендую к установке</summary>
Пока пусто :(

</details>

<details>
<summary>Путь самурая (для ленивых)</summary>
Пока пусто :(

</details>

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

</details>

---
## 💾 Образы ОС

JEOS ALT Linux - [Скачать](https://nightly.altlinux.org/sisyphus/tested/regular-jeos-systemd-latest-x86_64.iso)

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
