<p align="center">
<img src="logo.png" width="200"/>
</p>

<details>
<summary>🛠️🐧JEOS</summary>
    
После установки сего шедевра отечественного айти-прома первым делом нужно поставить нужные пакеты для комфортной работы - потому что даже автодополнение команд в этом дистрибутиве является опциональной, недостижимой мечтой, фичей уровня «Enterprise Deluxe Edition» :)))))

```bash
apt-get update
apt-get install bash-completion etcnet-full iptables nano sudo wget
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

Безопасная настройка iptables:

```bash
iptables -t nat -A POSTROUTING -s <внут. ip сеть/маска> -o <интерфейс с выходом на интернет> -j MASQUERADE
iptables -A	FORWARD	-i <интернет> -o <внут. инт>  -s <внут. ip сеть/маска> -j ACCEPT

# Пример
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o ens33 -j MASQUERADE
iptables -A	FORWARD	-i ens33 -o ens37 -s 192.168.1.0/24 -j ACCEPT
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

### Настройка сервера

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
    option domain-name "example.local";
    option domain-name-servers 192.168.1.1, 8.8.8.8;
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
>
> option domain-name "example.local"; - домен
>
> option domain-name-servers 192.168.1.1, 8.8.8.8; - адрес домена

Проверка конфигурации

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Создание и настройка /etc/default/isc-dhcp-server

```bash
#DHCP_CONF=/etc/dhcp/dhcpd.conf
#DHCP_PID=/var/run/dhcpd.pid
#DHCP_OPTS="-4"
INTERFACEv4="<инт, который будет раздавать ip>"
INTERFACEv6=""
```

Если DHCP не заработает - то расскомментируете эти строчки

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

### Настройка клиента 

```bash
dhcpcd
```

</details>
  
<details>
<summary>Настройка портов и маршрута</summary>

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
CONFIG_IPV4=yes
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
TUNOPTIONS='ttl 64'
TUNTTL=64
TUNMTU=1476
```

Настраиваем IP турренля

```
nano /etc/net/ifaces/gre1/ipv4address

10.10.10.1/30 #к примеру
```

</details>

<details>
<summary>FRR</summary>

FRR (Free Range Routing) - это набор демонов, который превращает обычный сервер в маршрутизатор, будто он всегда этим и мечтал быть. Поддерживает BGP, OSPF и другую сетевую магию, работает быстро и запускается почти везде. Отличный способ не покупать дорогую железку и при этом выглядеть профи.

Установка

```bash
apt-get install frr
systemctl enable --now frr
```

### Настройка OSPF

Чтобы начать настраивать OSPF, сначала подружите ваши роутеры через GRE-туннели (см. сверху). Без него OSPF просто не знает, куда идти и обижается :(

Входим в оболочку
```bash
vtysh
```

Базовая настройка OSPF

```vtysh
conf
router ospf
    router-id <ID роутера>
    network <IP вашего туннеля> area 0.0.0.0
    network <IP-ики вашей внутренней сети> area 0.0.0.0
    ...
    network <IP-ики вашей внутренней сети> area 0.0.0.0
do wr
```

MD5-аутентификация в OSPF

```vtysh
interface <инт>
    ip ospf authentication message-digest
    ip ospf message-digest-key 1 md5 <пароль>
do wr
```

Проверка работы OSPF

```vtysh
show ip ospf neighbor // проверка соседей
show ip ospf database // проверка lsa
```

</details>


<details>
<summary>Статическая трансляция портов (на основе iptables)</summary>

```bash
iptables -t nat -A PREROUTING -p tcp -i <внешний_интерфейс> --dport <порт_внешний> -j DNAT --to-destination <ip_сервера>:<порт_внутренний>
iptables -A FORWARD -p tcp -d <ip_сервера> --dport <порт_внутренний> -j ACCEPT
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
```

Структура каталога bind

```bind
/etc/bind/
├── named.conf              # главный конфигурационный файл (include остальных)
├── options.conf            # глобальные параметры BIND
├── local.conf              # описание локальных зон (master/slave)
├── bind.keys               # корневые DNSSEC ключи (trust anchors)
├── rfc1912.conf            # стандартные служебные зоны (localhost и др.)
├── rfc1918.conf            # зоны для частных IP-адресов (RFC1918)
├── zone/                   # каталог файлов DNS-зон
│   ├── localhost           # прямая зона localhost
│   ├── localdomain         # прямая зона localdomain
│   ├── empty               # пустая зона-заглушка
│   ├── managed-keys.bind   # управляемые DNSSEC ключи
│   ├── managed-keys.bind.jnl # журнал изменений DNSSEC ключей
│   ├── slave/              # каталог slave-зон (получаемых с master)
│   └── 127.in-addr.arpa    # обратная зона loopback (127.0.0.1)
└── rndc.key                # ключ для управления BIND через rndc

```

<details>
<summary>Базовая настройка options.conf</summary>

```bash
listen-on { any; };
allow-query { any; };
allow-recursion { any; };
forwarders { 77.88.8.8; };
recursion yes;
```

</details>

<details>
<summary>Базовая настройка local.conf</summary>

Создание локальных зон

ВАЖНО! Имя зоны в конфигурации BIND (в блоке zone "...") должно совпадать с именем домена, указанным в SOA-записи этого файла зоны.

```bash
zone "ZONE_NAME" {                  # имя зоны (например: "domentest" или "100.168.192.in-addr.arpa")
    type TYPE;                       # тип зоны: master или slave
    file "ZONE_FILE_PATH";           # путь к файлу зоны (относительно /etc/bind/)
};
```

Пример прмяой зоны

```bash
zone "domentest" {
    type master;
    file "zone/domentest.db";
};

```

Пример обратной зоны

```bash
zone "11.168.192.in-addr.arpa" {
    type master;
    file "zone/100.168.192.in-addr.arpa";
};

```

</details>

<details>
<summary>Создание файлов зон</summary>

Берем шаблоны с localhost и 127.in-addr.arpa и назначаем владельца

```bash
cp /etc/bind/zone/{localhost,domaintest.db}
cp /etc/bind/zone/{127.in-addr.arpa,100.168.192.in-addr.arpa}

chown named:named /etc/bind/zone/domaintest.db
chown named:named /etc/bind/zone/100.168.192.in-addr.arpa
```

Шаблон файла прямой зоны

```bash
; Зона example.com
; Последнее изменение: 2026-01-18
$TTL 1d          ; Значение по умолчанию для всех записей без явного TTL (1 день — хороший современный выбор)

@               IN SOA  ns1.example.com. admin.example.com. (
                2026011801  ; Серийный номер — формат ГГГГММДДnn (сегодня + 01)
                1h          ; Refresh — как часто slave проверяет изменения
                15m         ; Retry    — через сколько пытаться снова при ошибке
                1w          ; Expire   — когда slave перестанет отвечать, если мастер недоступен
                1d          ; Minimum / Negative cache TTL — для NXDOMAIN и других отрицательных ответов
)

; Серверы имён (NS-записи) — минимум один, лучше 2+
                IN NS   ns1.example.com.
                IN NS   ns2.example.com.   ; желательно второй сервер (в идеале — в другой сети)

; Основные адреса
ns1             IN A    203.0.113.10
ns2             IN A    198.51.100.53

@               IN A    203.0.113.5        ; адрес сайта по умолчанию (www тоже часто добавляют)
www             IN A    203.0.113.5
mail            IN A    203.0.113.10

; Пример MX (почта)
                IN MX 10 mail.example.com.

; Примеры других полезных записей (раскомментируйте по необходимости)
; ftp           IN A    203.0.113.5
; autodiscover  IN CNAME mail.example.com.
; _dmarc        IN TXT   "v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com;"
; example.com.  IN TXT   "v=spf1 mx a -all"

```

Шаблон файла обратной зоны

```bash
; Обратная зона для подсети 203.0.113.0/24
$TTL 1d

@               IN SOA  ns1.example.com. admin.example.com. (
                2026011801  ; YYYYMMDDnn
                1h
                15m
                1w
                1d )

                IN NS   ns1.example.com.
                IN NS   ns2.example.com.

; PTR-записи — пишем только последнюю часть IP (хвост октета)
10              IN PTR  ns1.example.com.
5               IN PTR  example.com.
5               IN PTR  www.example.com.     ; один IP может иметь несколько PTR (хотя не всегда полезно)
53              IN PTR  ns2.example.com.
```

Пример прямой зоны

```bash
$TTL 1D
@       IN SOA    dns.domaintest. root.domaintest. (
                2025011801  ; serial — формат YYYYMMDDnn, увеличь при изменениях
                1H          ; refresh
                15M         ; retry
                1W          ; expire
                1D )        ; minimum / negative cache TTL

@       IN NS     dns.domaintest.
dns     IN A      192.168.100.50

```

Пример обратной зоны

```bash
$TTL 1D
@       IN SOA    dns.domaintest. root.domaintest. (
                2025011801  ; serial — синхронизирован с forward-зоной
                1H          ; refresh
                15M         ; retry
                1W          ; expire
                1D )        ; minimum

@       IN NS     dns.domaintest.
50      IN PTR    dns.domaintest.

```

</details>

После настройки всех конфигов нужно проверить на ошибки и указать DNS-настройки системы в /etc/resolv.conf

```bash
nameserver 127.0.0.1
search domaintest
```

```bash
named-checkconf -z
named-checkzone domaintest /etc/bind/db.domaintest
named-checkzone 100.168.192.in-addr.arpa /etc/bind/db.192.168.100
```

Если всё правильно, запускаем и добавляем в автозагрузку

```bash
systemctl enable --now bind
```

</details>

<details>
<summary>dnsmasq</summary>

dnsmasq - это лёгкий сервис, который одновременно работает как простой DNS-сервер и DHCP-сервер. Он раздаёт IP-адреса устройствам в сети и может кешировать DNS-запросы, а также давать локальные доменные имена (например, home.lan). Его используют на домашних роутерах и небольших серверах, потому что он простой, быстрый и не требует сложной настройки.

> [!WARNING]
> У вас должен быть отключен BIND!!!

Заходим в /etc/dnsmasq.conf

```bash
# ————— DNS —————

# DNS будет работать на локальных интерфейсах
listen-address=127.0.0.1,192.168.0.1

# Домен
domain=home.lan

# Запрещаем пересылку запросов для наших локальных доменов
local=/home.lan/

# Включаем DNS-кеш
cache-size=1000

# Форвардинг DNS (провайдер, DoH, локальный резолвер)

server=77.88.8.8 

# Разрешаем использование /etc/hosts
expand-hosts

# Логи
log-queries
log-facility=/var/log/dnsmasq.log

# ————— A-записи ————— # (если отказываетесь от expand-hosts)
# address=/имя/IPv4

address=/router.home.lan/192.168.0.1
address=/server.home.lan/192.168.0.10
address=/nas.home.lan/192.168.0.20
address=/pc1.home.lan/192.168.0.50

# ————— DHCP —————

# Включаем DHCP-сервер
dhcp-range=192.168.0.50,192.168.0.150,12h

# Маска и шлюз
dhcp-option=3,192.168.0.1          # Default gateway
dhcp-option=6,192.168.0.1          # DNS — сам dnsmasq

# Домен для DHCP-клиентов
dhcp-option=15,home.lan

# ————— Безопасность —————

# Запрещаем интерфейсы, на которых dnsmasq не должен работать
#except-interface=lo
#except-interface=eth1

# Запуск от непривилегированного пользователя
user=nobody
group=nogroup

```

<details>
<summary>Таблица DHCP опций</summary>

|     Код | Название                         | Описание                        |
| ------: | -------------------------------- | ------------------------------- |
|0        | Pad                              | Пустой байт                     |
|       1 | Subnet Mask                      | Маска подсети                   |
|       2 | Time Offset                      | Смещение времени                |
|       3 | Router                           | Основной шлюз (Default Gateway) |
|       4 | Time Server                      | Сервер времени                  |
|       5 | Name Server                      | Сервер имён (несовр.)           |
|       6 | DNS Server                       | DNS-сервера                     |
|       7 | Log Server                       | Сервер журнала                  |
|       8 | Cookie Server                    | Сервер cookies (редкость)       |
|       9 | LPR Server                       | Принт-сервер                    |
|      10 | Impress Server                   | Старый print сервер             |
|      11 | RLP Server                       | Сервер RLP                      |
|      12 | Hostname                         | Имя клиента                     |
|      13 | Boot File Size                   | Размер загрузочного файла       |
|      14 | Merit Dump File                  | Dump-файл                       |
|      15 | Domain Name                      | Домен клиента                   |
|      16 | Swap Server                      | Swap-сервер                     |
|      17 | Root Path                        | Корневой путь                   |
|      18 | Extensions Path                  | Путь расширений                 |
|      19 | IP Forwarding                    | Разрешить форвардинг?           |
|      20 | Non-local Source Routing         | Маршрутизация?                  |
|      21 | Policy Filter                    | Фильтр политик                  |
|      22 | Max Datagram Reassembly          | Максимальная фрагментация       |
|      23 | Default TTL                      | TTL по умолчанию                |
|      24 | Path MTU Aging                   | Время устаревания MTU           |
|      25 | Path MTU Plateau Table           | Таблица MTU                     |
|      26 | MTU Interface                    | MTU интерфейса                  |
|      27 | MTU Subnet                       | MTU подсети                     |
|      28 | Broadcast Address                | Broadcast адрес                 |
|      29 | Trailer Encapsulation            | Trailer используется?           |
|      30 | ARP Timeout                      | Таймаут ARP                     |
|      31 | Ethernet Encapsulation           | Ethernet флаг                   |
|      32 | TCP Default TTL                  | TCP TTL                         |
|      33 | TCP Keepalive Interval           | Интервал keepalive              |
|      34 | TCP Keepalive Garbage            | Отправлять garbage?             |
|      35 | NIS Domain                       | NIS домен                       |
|      36 | NIS Server                       | NIS сервер                      |
|      37 | NTP Server                       | Сервер времени NTP              |
|      38 | Vendor Specific                  | Vendor-specific параметры       |
|      39 | NetBIOS Name Server              | WINS сервер                     |
|      40 | NetBIOS Dist Server              | WINS распределённый             |
|      41 | NetBIOS Node Type                | Тип узла NetBIOS                |
|      42 | NetBIOS Scope                    | Scope NetBIOS                   |
|      43 | Vendor Specific Info             | Данные производителя            |
|      44 | NetBIOS Name Server              | WINS                            |
|      45 | NetBIOS Dist Server              | WINS распредел.                 |
|      46 | NetBIOS Node Type                | B, P, M, H                      |
|      47 | NetBIOS Scope                    | Scope                           |
|      48 | X Window Font Server             | Шрифтовый X-сервер              |
|      49 | X Window Display Manager         | XDM сервер                      |
|      50 | Requested IP Address             | Клиент хочет IP                 |
|      51 | Lease Time                       | Время аренды                    |
|      52 | Option Overload                  | Доп. поля                       |
|      53 | DHCP Message Type                | Тип DHCP сообщения              |
|      54 | DHCP Server ID                   | IP DHCP сервера                 |
|      55 | Parameter Request List           | Запрос опций                    |
|      56 | Message                          | Сообщение                       |
|      57 | Max DHCP Message Size            | Макс. размер пакета             |
|      58 | Renewal Time                     | T1                              |
|      59 | Rebinding Time                   | T2                              |
|      60 | Vendor Class ID                  | ID класса                       |
|      61 | Client Identifier                | Идентификатор клиента           |
|      62 | Netware/IP Domain Name           | NetWare                         |
|      63 | Netware/IP Sub Options           | Подопции                        |
|      64 | NIS+ Domain                      | NIS+ домен                      |
|      65 | NIS+ Server                      | NIS+ сервер                     |
|      66 | TFTP Server Name                 | Адрес TFTP (PXE)                |
|      67 | Bootfile Name                    | Имя PXE-файла                   |
|      68 | Mobile IP Home Agent             | Mobile IP                       |
|      69 | SMTP Server                      | Почтовый сервер                 |
|      70 | POP3 Server                      | POP3                            |
|      71 | NNTP Server                      | Новости                         |
|      72 | WWW Server                       | Web-сервер                      |
|      73 | Finger Server                    | Finger                          |
|      74 | IRC Server                       | IRC                             |
|      75 | StreetTalk Server                | StreetTalk                      |
|      76 | STDA Server                      | StreetTalk Directory            |
|      77 | User Class                       | Класс пользователя              |
|      78 | SLP Directory Agent              | SLP                             |
|      79 | SLP Scope                        | SLP                             |
|  80–127 | Зарезервировано (IANA)           | —                               |
| 128–135 | Vendor Specific (PXE)            | PXE параметры BIOS/UEFI         |
| 136–254 | Разные расширения производителей | —                               |
|     255 | End                              | Конец списка опций              |


</details>

После этого запускаем dnsmasq

```bash
systemctl enable --now dnsmasq
```

P.S.

Параметр <code>expand-hosts</code> в dnsmasq позволяет не прописывать <code>address=</code> в конфигурации. Когда <code>expand-hosts</code> включён, dnsmasq автоматически создаёт DNS-записи на основе файла <code>/etc/hosts</code>, добавляя к ним локальный домен, указанный в параметре <code>domain</code>. Например, если в <code>/etc/hosts</code> записано <code>192.168.0.10 server</code>, а в dnsmasq задано <code>domain=home.lan</code>, то dnsmasq автоматически создаст записи <code>server</code> и <code>server.home.lan</code>, обе указывающие на IP 192.168.0.10. Поэтому A-записи через <code>address=</code> в таком случае не нужны - dnsmasq сам формирует полноценные локальные DNS-имена. Дополнительно, при включённом <code>localise-queries</code> генерируются и соответствующие PTR-записи для обратного разрешения. Использовать <code>address=</code> имеет смысл только тогда, когда нужно задать IP-адрес, отсутствующий в <code>/etc/hosts</code>, создать wildcard-запись или настроить перенаправление домена. Во всех остальных случаях <code>/etc/hosts + expand-hosts</code> полностью покрывают задачу локального DNS без необходимости прописывать каждую запись вручную.

</details>

<details>
<summary>Chrony</summary>

### Настройка сервера

```bash
apt-get install chrony
```

Идем в /etc/chrony.conf и в конфиге пишем:

https://www.ntp-servers.net/servers.html - сервера времени

```bash
server <адресс сервера времени> iburst     # iburst нужен для ускорения первоначальной синхронизации
allow 192.168.0.0/24   # замените на подсеть вашей сети
```

Добавляем в автозагрузку и запускаем

### Настройка клиента

В /etc/chrony.conf

```bash
server <ip сервера> iburst
```

Запускаем и проверяем:

```bash
chronyc sources -v
chronyc tracking
```

</details>

<details>
<summary>SAMBA</summary>

<details>
<summary>Настройка домена Samba Active Directory</summary>

### Настройка сервера

Устанавливаем необходимые пакеты

```bash
apt-get install -y task-samba-dc
```

Очищаем от первоначальных конфигов

```bash
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba
rm -rf /var/cache/samba
mkdir -p /var/lib/samba/sysvol
```

Настраиваем DNS сервер в /etc/resolf.conf

```bash
echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

Создаем домен

```bash
samba-tool domain provision
```

Активируем и запускаем службу Samba

```bash
systemctl enable --now samba
```

Копируем сгенерированный файл настроек Kerberos

```bash
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
```

Проверяем на работоспособность

```bash
samba-tool domain info 127.0.0.1
host -t SRV _kerberos._udp.ad.team
host -t SRV _ldap._tcp.ad.team
host -t A srv-hq.ad.team
```

Получаем билет Kerberos и проверяем его наличие

```bash
kinit administrator@AD.TEAM
klist
```

### Настройка клинета

Устанавливаем пакеты для интеграции с Active Directory

```bash
apt-get install -y task-auth-ad-sssd
```

Активируем службы для работы с доменом

```bash
systemctl enable --now smb winbind sssd
```

В /etc/krb5.conf вписываем:

```bash
[libdefaults]
default_realm = AD.TEAM
dns_lookup_kdc = true
dns_lookup_realm = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true

[realms]
AD.TEAM = {
    kdc = 192.168.11.67
    default_domain = ad.team
    admin_server = 192.168.11.67
}

[domain_realm]
.ad.team = AD.TEAM
ad.team = AD.TEAM
```

Настройка DNS

```bash
domain ad.team
nameserver 192.168.11.67
search ad.team
```

Присоединяемся к домену

```bash
net ads join -U administrator@AD.TEAM -S 192.168.11.67
su -
acc
```

Проверка

```bash
host srv-hq
host $(hostname)
```

После этого перезагружаемся

```bash
reboot
```

</details>

<details>
<summary>Создание системной группы и пользователя</summary>

Создать группу

```bash
sudo samba-tool group add <имя>
```

Создание пользователя

```bash
sudo samba-tool user create <имя>
```

Добавить пользователя в группу

```bash
sudo samba-tool group addmembers <имя группы> <имя пользователя>
```

Проверка, что пользователь создан и добавлен в группу

```bash
sudo samba-tool user list
```

```bash
sudo samba-tool group listmembers students
```

--

</details>

<details>
<summary>Полезные штучки</summary>

Ниже приведён полный набор команд для расширенной настройки домена Samba AD DC.

```bash
#############################
# 1. ПАРОЛЬНАЯ ПОЛИТИКА
#############################

# Отключить сложность паролей
sudo samba-tool domain passwordsettings set --complexity=off

# Минимальная длина пароля (1 для тестов)
sudo samba-tool domain passwordsettings set --min-pwd-length=1

# Максимальное время действия пароля (0 = не истекает)
sudo samba-tool domain passwordsettings set --max-pwd-age=0

# Минимальное время перед сменой (0 = отключено)
sudo samba-tool domain passwordsettings set --min-pwd-age=0

# Длина истории паролей (0 = можно повторять)
sudo samba-tool domain passwordsettings set --pwd-history-length=0
```

```bash
#############################
# 2. ПОЛИТИКА БЛОКИРОВКИ
#############################

# Порог блокировки (0 = блокировка отключена)
sudo samba-tool domain passwordsettings set --lockout-threshold=0

# Длительность блокировки, мин
sudo samba-tool domain passwordsettings set --lockout-duration=30

# Время сброса счётчика неудачных попыток
sudo samba-tool domain passwordsettings set --reset-count=30
```

```bash
#############################
# 3. ПОЛИТИКА KERBEROS
#############################

# Время жизни тикета (часы)
sudo samba-tool domain passwordsettings set --krb-ticket-lifetime=24

# Время обновления тикета (часы)
sudo samba-tool domain passwordsettings set --krb-renewal-lifetime=168   # 7 дней
```

```bash
#############################
# 4. ПОЛИТИКА УЧЁТНЫХ ЗАПИСЕЙ
#############################

# Сделать так, чтобы никто не должен менять пароль при первом входе
# (для всех новых пользователей уже не требуется смена)
# (для конкретного: samba-tool user setpassword user --must-change-at-next-login=no)

# Разрешить устаревшие (expired) пароли использовать для входа
sudo samba-tool domain passwordsettings set --store-plaintext-password=yes

# Разрешить пустые пароли (если сильно нужно)
# ВНИМАНИЕ! Использовать только в изолированных стендах
sudo samba-tool domain passwordsettings set --allow-plaintext-password=yes
```

```bash
#############################
# 5. ПОЛИТИКА АВТОРИЗАЦИИ ПО ВРЕМЕНИ
#############################

# Ограничение часов входа — отключено по умолчанию.
# Но для справки:
# sudo samba-tool user setexpiry <username> --expiry=<YYYYMMDDHHMMSS.0Z>

# Включить "пароль не истекает" по умолчанию для новых пользователей
# (нужно править smb.conf, но через samba-tool можно для каждого)
# Пример: sudo samba-tool user setexpiry user --noexpiry
```

```bash
#############################
# 6. ПАРАМЕТРЫ БЕЗОПАСНОСТИ ДОМЕНА
#############################

# Разрешить использование старых алгоритмов шифрования (NTLMv1/LM)
# (не рекомендовано, но иногда нужно для старых устройств)
sudo samba-tool domain passwordsettings set --allow-microsecond-timestamps=yes

# Включить поддержку слабых клиентов:
sudo samba-tool domain passwordsettings set --allow-weak-crypto=yes
```

```bash
#############################
# 7. ПОЛИТИКА TGT/TGS (KRB5)
#############################

# Maximally permissive Kerberos policy
sudo samba-tool domain passwordsettings set --krb-policy-flags=0x00000000
```

```bash
#############################
# 8. ПАРАМЕТРЫ АУДИТА И ЛОГОВ
#############################

# Повышение детализации логов AD
sudo samba-tool domain level show

# Логи Samba:
# sudo smbcontrol all debug 3
# sudo smbcontrol all debug 10   # максимум
```

```bash
#############################
# 9. ПАРАМЕТРЫ ДОМЕННОГО ФУНКЦИОНАЛЬНОГО УРОВНЯ
#############################

# Узнать уровень:
sudo samba-tool domain level show

# Установить максимально доступный уровень:
sudo samba-tool domain level raise --domain-level=2008_R2
sudo samba-tool domain level raise --forest-level=2008_R2
```

```bash
#############################
# 10. ПОЛНАЯ ПРОВЕРКА ТЕКУЩЕЙ ПОЛИТИКИ
#############################

sudo samba-tool domain passwordsettings show

```

</details>

</details>

<details>
<summary>OpenSSH</summary>

OpenSSH - это стандартный инструмент для безопасного удалённого подключения к серверу. Он шифрует весь трафик, защищая ваши данные от посторонних глаз, и позволяет управлять сервером с любого устройства.

Устанавливаем на устройства, куда нужно

```bash
sudo apt install openssh-common
sudo systemctl enable --now sshd
```

Редактируем файл /etc/openssh/sshd_config на машине, к которой будем подключаться

```bash
PasswordAuthentication yes
// По желанию можете поменять port, AllowUsers (белый список) и так далее.
```

<details>
<summary>Подключение по ключу</summary>

Генерируем с клиентской машины(откуда будем подключаться) ключ

```bash
ssh-keygen
```

Копируем публичный ключ на машину, к которой будем подключаться

```bash
ssh-copy-id -i ~/.ssh/id.pub пользователь@сервер
```

Настройка sshd_config 

```bash
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes  # можно отключить после проверки ключей
```

--

</details>

Создаем и добавляем пользователя

```bash
useradd -mg users -G wheel <имя пользователя> 
passwd <имя пользователя> 
```

Расскомментируем строчку в /etc/sudoers

```bash
%wheel ALL=(ALL:ALL) ALL
```
После настройки перезагружаем sshd
```bash
sudo systemctl restart sshd
```

</details>

<details>
<summary>mdadm</summary>
    
mdadm — это утилита для создания, управления и мониторинга программных RAID-массивов на Linux. Она поддерживает все популярные уровни RAID: 0, 1, 4, 5, 6, 10 и т. д.

Основные функции mdadm:

>Создание RAID-массивов (--create)
>
>Добавление/удаление дисков (--add, --remove)
>
>Проверка состояния массива (--detail, /proc/mdstat)
>
>Сборка существующих массивов (--assemble)
>
>Мониторинг с уведомлением (--monitor)

<details>
<summary>Команды для разных уровней RAID</summary>

| RAID    | Команда шаблона                                                                           |
| ------- | ----------------------------------------------------------------------------------------- |
| RAID 0  | `mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb /dev/sdc`                    |
| RAID 1  | `mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc`                    |
| RAID 5  | `mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd`           |
| RAID 6  | `mdadm --create /dev/md0 --level=6 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde`  |
| RAID 10 | `mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde` |

</details>

Допустим, у нас есть 3 диска и мы хотим сделать RAID-5

```bash
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
```

>/dev/md0 — имя создаваемого массива
>
>--level=5 — уровень RAID (0, 1, 5, 6, 10…)
>
>--raid-devices=N — количество дисков
>
>Список дисков — /dev/sdX

Проверка состояния RAID

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

Создание файловой системы

```bash
sudo mkfs.ext4 /dev/md0
```

Монтирование

```bash
sudo mkdir /mnt/raid5
sudo mount /dev/md0 /mnt/raid5
```

Чтобы RAID монтировался автоматически при загрузке, добавьте запись в /etc/fstab

```bash
/dev/md0   /mnt/raid5   ext4   defaults   0 0
```

Сохранение конфигурации mdadm

```bash
sudo mdadm --detail --scan >> /etc/mdadm.conf
```

</details>

<details>
<summary>OpenSSL CA</summary>

OpenSSL CA используется для создания и управления собственным центром сертификации, что позволяет самостоятельно выпускать, подписывать и проверять цифровые сертификаты для защиты внутренних сетевых служб и шифрования соединений.

### Настройка сервера

Создадим директорию которую будем использовать в качестве корневой для Центра Сертификации

```bash
mkdir /ca
```
Припомощи утилиты "openssl" найдём путь где расположен конфигурационный файл

```bash
openssl ca
```

Сделаем резервную копию данного конфигурационного файла перед его редактированием

```bash
cp /var/lib/ssl/openssl.{cnf,cnf.backup}
```

Переходим к редактированию конфигурационного файла "openssl.cnf":

* первым делов в секции [ CA_default ] правим параметр определяющий корневую директорию CA:


```bash
dir     =ca
```

После смены корневой директории CA - необходимо создать определённую структуру директорий, описанную в секции [ CA_default ]

```bash
cd /ca
mkdir certs newcerts crl private
touch index.txt
echo -n '00' > serial   # опция "-n" для того, чтобы небыло никакого пробела и перевода строки
```

Возвращаемся к редактированию конфигурационного файла, далее в секции [ CA_default ] - определяем в качестве политики по умолчанию «policy = policy_anything», так мы принимаем все, что угодно, и требуем только CN (Common Name)

```bash
policy = policy_anything
commonName = supplied
```

Далее добавляем некоторые необходимые значения по умолчанию для CA в секции [ req_distinguished_name ]:

* Например наш CA должен удовлетворять следующим требованиям: C=RU, O=champ.first, CN=champ.first RootCA

Здесь говорится, что описание названия страны - "Название страны (2-буквенный код — RU)" и запись для названия организации

```bash
countryName_default    = RU
0.organizationName_defauIt    = champ.first
```

Далее добавляем расширения для самого CA в секции [ v3_ca ]:

```bash
basicConstraints = CA:true
```

Указываем, что данный сертификат выпущенный при использовании расширения (-extensions v3_ca ) может быть корневым CA

Генерируем открытый и закрытый ключ для CA

Значения C=RU и O=champ.first — автоматически подставляются из конфигурационного файла, также не забываем указать CN (т. к. он у всех разный), в случае когда поля необходимо оставить пустыми — ставим «.»

```bash
openssl req -nodes -new -out cacert.csr -keyout private/cakey.pem -extensions v3_ca
```

Прочитать содержимое сертификата:

```bash
openssl x509 -text -noout -in cacert.pem | less
```

### Настройка клиента

Для добавления корневого сертификата выпущенного нашим Центром Сертификации - нееобходимо поместить данный сертификат в директории в зависимости от дистрибутива:

   * на базе deb /usr/local/share/ca-certificates, после чего выполнить команду update-ca-certificates

   * на базе rpm /etc/pki/ca-trust/source/anchrors, после чего выполнить команду update-ca-trust extract

P.S. сертификаты должны иметь расширение ".crt"

</details>

<details>
<summary>FreeIPA</summary>


## ⚠️ Важно!

 В файле hostname не должно быть заглавных букв!

<details>
<summary>С интегрированным DNS</summary>

### Настройка сервера

Установим пакет FreeIPA с интегрированным DNS-сервером:

```bash
apt-get install -y freeipa-server-dns
```

Запускаем интерактивную установку FreeIPA

```bash
ipa-server-install
```


1 - отвечаем yes на вопрос, нужно ли сконфигурировать DNS-сервер BIND;
2, 3, 4 - нужно указать имя узлаЮ на котором будет установлен сервер FreeIPA, доменное имя и пространство Kerberos;

* Эти имена нельзя изменить после завершения установки!

Далее необходимо проверить информацию о конфигурации и подтвердить ответив yes

Проверяем запущенные службы

```bash
ipactl status
```

Получаем билет kerberos

```bash
kinit admin
klist
```

Создаем пользователя и группу

```bash
ipa user-add login --first=Name --last=Name --password
ipa group-add group_name
```
Добавление пользователя в группу

```bash
ipa group-add-member group_name --users=username
```

### Настройка клиента

Устанавливаем пакеты

```bash
apt-get install -y freeipa-client zip
```

Запускаем скрипт настройки клиента

```bash
ipa-client-install --mkhomedir --enable-dns-updates
```

Также после ввода в домен - клиент автоматически доверяет интегрированному корневому центру 

</details>

<details>
<summary>Без интегрированного DNS</summary>

### Настройка сервера

Установим пакет FreeIPA без DNS-сервера:

```bash
apt-get install -y freeipa-server
```

Запускаем интерактивную установку FreeIPA

```bash
ipa-server-install
```

Проверяем запущенные службы

```bash
ipactl status
```

Получаем билет kerberos

```bash
kinit admin
klist
```

Создаем пользователя и группу

```bash
ipa user-add login --first=Name --last=Name --password
ipa group-add group_name
```
Добавление пользователя в группу

```bash
ipa group-add-member group_name --users=username
```

1 - отвечаем no на вопрос, нужно ли сконфигурировать DNS-сервер BIND;

2, 3, 4 - нужно указать имя узла на котором будет установлен сервер FreeIPA, доменное имя и пространство Kerberos;

### Настройка клиента

Устанавливаем пакеты

```bash
apt-get install -y freeipa-client zip
```

Запускаем скрипт настройки клиента

```bash
ipa-client-install --mkhomedir --enable-dns-updates
```

</details>

</details>

<details>
<summary>База данных</summary>

<details>
<summary>MySQL</summary>

Устанавливаем пакет и включаем в автозагрузку

```bash
apt-get install -y MySQL-server
systemctl enable --now mysqld
```

Задаем пароль

```bash
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'P@ssw0rd';
```

Разрешаем доступ к MySQL из сети

```bash
sed -i "s/skip-networking/#skip-networking/g" /etc/my.cnf.d/server.cnf
systemctl restart mysqld
```

Разрешаем доступ для пользователя "root" по сети с любого узла

```bash
mysql -u root -p

GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
UPDATE mysql.user SET host='%' WHERE user='root';
EXIT;

systemctl restart mysqld
```

Проверяем на сервере

```bash
SELECT user, HOST FROM mysql.user;
```

Удаленное подключение на клиенте

```bash
mysql -h <ip сервера> -u root -p
```

Создание БД

```bash
mysql -u root -p
CREATE DATABASE db01; # где db01 - имя создаваемой БД
```

Создание пользователя (знак процента означает, что пользователь может подключаться к серверу с любого хоста)

```bash
CREATE USER 'user01'@'%' IDENTIFIED BY 'P@ssw0rd';
```
Проверка существования БД и пользователя

```bash
SHOW DATABASES;
SELECT user, HOST FROM mysql.user;
```

</details>

<details>
<summary>MariaDB</summary>

Установка пакетов

```bash
apt-get install -y mariadb-server
systemctl enable --now mariadb
```

Задаем пароль root

```bash
mariadb -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'P@ssw0rd';
```

Разрешаем доступ к MySQL из сети

```bash
sed -i "s/skip-networking/#skip-networking/g" /etc/my.cnf.d/server.cnf
systemctl restart mariadb
```
Разрешаем доступ для пользователя "root" по сети с любого узла

```bash
mariadb -u root -p

GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
UPDATE mysql.user SET host='%' WHERE user='root';
EXIT;

systemctl restart mysqld
```

Проверяем на сервере

```bash
SELECT user, HOST FROM mysql.user;
```

Удаленное подключение на клиенте

```bash
mariadb -h <ip сервера> -u root -p
```

Создание БД

```bash
mariadb -u root -p
CREATE DATABASE db01; # где db01 - имя создаваемой БД
```

Создание пользователя (знак процента означает, что пользователь может подключаться к серверу с любого хоста)

```bash
CREATE USER 'user01'@'%' IDENTIFIED BY 'P@ssw0rd';
```
Проверка существования БД и пользователя

```bash
SHOW DATABASES;
SELECT user, HOST FROM mysql.user;
```

</details>

<details>
<summary>PostgreSQL</summary>

Установка пакетов

```bash
apt-get install -y postgresql16-server
```

Создаем системные БД

```bash
/etc/init.d/postgresql initdb
```

Включаем и добавляем в автзагрузку 

```bash
systemctl enable --now postgresql
```

Разрешаем доступ к PostgreSQL из сети

```bash
vim /var/lib/pgsql/data/postgresql.conf
```

В конфигарционном файле находим строку "listen_addresses = 'localhost'" и приводи м  ее к следующему виду:

```bash
listen_addresses = '*'

systemctl restart postgresql
```

Для заведения пользователей и создания баз данных, необходимо переключиться в учётную запись "postgres"

```bash
psql -U postgres
```

Зададим пароль

```bash
ALTER USER postgres WITH ENCRYPTED PASSWORD 'P@ssw0rd';
```

Настраиваем парольную аутентификацию для удалённого доступа и приводим к следующему виду:

```bash
vim /var/lib/pgsql/data/pg_hba.conf
```

```bash
host    all    all    0.0.0.0/0    md5

systemctl restart postgresql
```

Создаем пользователей с правами на БД

```bash
psql -U postgres
```

```bash
CREATE DATABASE db01;
CREATE USER user01 WITH PASSWORD 'P@ssw0rd';
GRANT ALL PRIVILEGES ON DATABASE db01 to user01;
```

Проверка

```bash
SELECT datname FROM pg_database;
SELECT username, usersuper, usecreatedb FROM pg_catalog.pg_user;
```
И на клиенте

```bash
psql -U user01 db01
psql -U user01 -h <ip сервера> -d db01
```

</details>

</details>

<details>
<summary>NFS</summary>

Устанавливаем пакеты для NFS сервера

### Настройка сервера 

```bash
apt-get install -y nfs-server nfs-utils
```

Создаём директорию для общего доступа /raid/nfs

```bash
mkdir /raid/nfs
```

Назначаем права на созданную директорию

```bash
chmod 777 /raid/nfs
```

Редактируем файл /etc/exports

```bash
vim /etc/exports

/raid/nfs    <клиентская сеть>(rw,no_root_squash)
```

Экспортируем файловую систему, указанную выше в /etc/exports

```bash
exportfs -arv

systemctl enable --now nfs-server
```

### Настройка клиента

Выполняем установку пакетов для NFS 

```bash
apt-get install -y nfs-utils nfs-clients
```

Создадим директорию для монтирования общего ресурса

```bash
mkdir /mnt/nfs 
```

Задаём права на созданную директорию:

```bash
chmod 777 /mnt/nfs 
```

Настраиваем автомонтирование общего ресурса через fstab

```bash
vim /etc/fstab

<ip сервера>:/raid/nfs /mnt/nfs    nfs    default    0    0
```

Выполняем монтирование общего ресурса

```bash
mount -av
df -h # проверка
```

</details>

<details>
<summary>ansible</summary>

### Настройка сервера

Установка пакетов ansible и sshpass

```bash
apt-get install –y ansible sshpass 
```

Приведём файл инвентаря ansible к следующему виду, отредактировав конфигурационный файл по пути /etc/ansible/hosts

```bash
[Servers]
HQ-SRV ansible_host=192.168.100.2
[Routers]
HQ-RTR ansible_host=10.10.10.1
BR-RTR ansible_host=192.168.0.1
[Clients]
HQ-CLI ansible_host=192.168.200.2
[Servers:vars]
ansible_user=sshuser
ansible_password=P@ssw0rd
ansible_port=2026
[Routers: vars]
ansible_user=net_admin
ansible_password=P@ssw0rd
ansible_connection=network_cli
ansible_network_os=ios
[Clients:vars]
ansible_user=user
ansible_password=resu
[all:vars]
ansible_python_interpreter=/usr/bin/python3
```
> ansible_host           — IP-адрес или DNS-имя хоста для подключения\
> 
> ansible_user           — пользователь для SSH-подключения
> 
> ansible_password       — пароль для подключения
> 
> ansible_port           — порт SSH (по умолчанию 22)
> 
> ansible_become         — включение повышения привилегий (yes/no)
> 
> ansible_become_user    — пользователь, под которым выполняются команды через sudo
> 
> ansible_become_method  — метод повышения привилегий (sudo, su, pbrun, etc.)
> 
> ansible_connection     — тип подключения (ssh, network_cli, local и др.)
> 
> ansible_network_os     — тип ОС сетевого устройства (ios, junos, nxos и др.)
> 
> ansible_python_interpreter — путь к Python на удаленном хосте
> 
> ansible_ssh_private_key_file — путь к приватному ключу SSH для подключения
> 
> ansible_ssh_common_args — дополнительные параметры SSH (например, ProxyCommand)

Редактируем файл /etc/ansible/ansible.cfg

```bash
[defaults]

inventory = /etc/ansible/hosts
host_key_checking = False
```
<details>
<summary>Если нужно будет подключить к EcoRouter</summary>

```bash
ansible-galaxy collection install ansible.netcommon
ansible-galaxy collection install cisco.ios
```

</details>

Устанавливаем пакет python3-module-pip для возможности установки библиотеки ansible-pylibssh

```bash
apt-get install –y python3-module-pip
pip3 install ansible-pylibssh
```

### Проверка клиента

```bash
ansible -m ping all
```

</details>

<details>
<summary>nginx</summary>

<details>
<summary>Установка и настройка</summary>

### Настройка сервера

Устанавливаем пакет nginx

```bash
apt-get install -y nginx
```

Настраиваем nginx как реверсивный прокси сервер, приведя файл /etc/nginx/sites-available.d/default.conf к следующему виду

```bash
# Конфигурация для web.au-team.irpo
server {
    listen 80;  # Слушаем HTTP на порту 80
    server_name web.au-team.irpo;  # Домен, на который реагирует этот серверный блок

    location / {
        proxy_pass http://172.16.1.2:8080;  
        # Перенаправляем все запросы на внутренний сервер 172.16.1.2:8080

        proxy_set_header Host $host;  
        # Передаем оригинальный хост (имя домена), чтобы внутренний сервер видел, к какому домену пришел запрос

        proxy_set_header X-Real-IP $remote_addr;  
        # Передаем IP адрес клиента, чтобы внутренний сервер видел реальный IP, а не IP Nginx

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        # Добавляем в заголовок цепочку всех прокси-переадресаций для отслеживания источника запроса

        proxy_set_header X-Forwarded-Proto $scheme;  
        # Передаем схему запроса (http или https), чтобы внутренний сервер понимал, как был сделан запрос
    }
}

# Конфигурация для docker.au-team.irpo
server {
    listen 80;  # Слушаем HTTP на порту 80
    server_name docker.au-team.irpo;  # Домен, на который реагирует этот серверный блок

    location / {
        proxy_pass http://172.16.2.2:8080;  
        # Перенаправляем все запросы на внутренний сервер 172.16.2.2:8080

        proxy_set_header Host $host;  
        # Передаем оригинальный хост

        proxy_set_header X-Real-IP $remote_addr;  
        # Передаем IP клиента

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        # Добавляем цепочку прокси

        proxy_set_header X-Forwarded-Proto $scheme;  
        # Передаем схему запроса (http или https)
    }
}

```

Проверяем на наличие ошибок

```bash
nginx -t 
```

Добавляем символическую ссылку на данный файл

```bash
ln -s /etc/nginx/sites-available.d/default.conf /etc/nginx/sites-enabled.d/
```

Запускаем

```bash
systemctl enable --now nginx
```

### Настройка клиента

Добавляем записи в файл /etc/hosts

```bash
<ip серверов>    <домены>
```

Проверяем с помощью браузера

```bash
apt-get install task-edu-xfce lightdm
systemctl enable --now lightdm
```

</details>

<details>
<summary>Web-based аутентификация</summary>

Устанавливаем пакет

```bash
apt-get install -y apache2-htpasswd
```

Средствами утилиты htpasswd создать пользователя WEB и добавить информацию о нём в файл /etc/nginx/.htpasswd

```bash
htpasswd –c /etc/nginx/.htpasswd WEB
```

Добавляем web-based аутентификацию для доступа к сайту web.au-team.irpo в конфигурационный файл /etc/nginx/sites-available.d/default.conf

```bash
auth_basic "Restricted area";
auth_basic_user_file /etc/nginx/.htpasswd;
```

Перезагружаем

```bash
systemctl restart nginx
```

</details>

</details>

<details>
<summary>Яндекс.404</summary>

Без комментариев:)

```bash
apt-get install –y yandex-browser-stable
```

</details>

<details>
<summary>Zabbix</summary>

<details>
<summary>MariaDB</summary>

Устанавливаем СУБД

```bash
apt-get install mariadb-server zabbix-server-mysql fping
systemctl enable --now mysqld
```

Создаем БД Zabbix и пользователя

```bash
mysql -uroot -p
Enter password: # можно пропустить
MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by '<пароль>';
MariaDB [(none)]> quit;
```

Добавляем в БД данные для веб интерфейса (важно соблюдать порядок ввода команд)

```bash
mysql -uzabbix -p<пароль> zabbix < /usr/share/doc/zabbix-common-database-mysql-*/schema.sql
mysql -uzabbix -p<пароль> zabbix < /usr/share/doc/zabbix-common-database-mysql-*/images.sql 
mysql -uzabbix -p<пароль> zabbix < /usr/share/doc/zabbix-common-database-mysql-*/data.sql
```

Устанавливаем apache2

```bash
apt-get install apache2 apache2-mod_php8.2
systemctl enable --now httpd2
apt-get install php8.2 php8.2-mbstring php8.2-sockets php8.2-gd php8.2-xmlreader php8.2-mysqlnd-mysqli php8.2-ldap php8.2-openssl
```

Меняем опции в <code>etc/php/8.2/apache2-mod_php/php.ini</code>

```bash
memory_limit = 256M
post_max_size = 32M
max_execution_time = 600
max_input_time = 600
date.timezone = Europe/Moscow (регион вписать свой)
always_populate_raw_post_data = -1
```

Перезагружаем

```bash
systemctl restart httpd2
```
Редактируем <code>/etc/zabbix/zabbix_server.conf</code>

```bash
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Пароль
```

```bash
systemctl enable --now zabbix_mysql
```

Установка web интерфейса

```bash
apt-get install zabbix-phpfrontend-apache2 zabbix-phpfrontend-php8.2
ln -s /etc/httpd2/conf/addon.d/A.zabbix.conf /etc/httpd2/conf/extra-enabled/
systemctl restart httpd2
chown apache2:apache2 /var/www/webapps/zabbix/ui/conf
```

Заходим на сайт <ip сервера>/zabbix и подключаемся к БД, вводим пароль от БД

Логин и пароль для входа по умолчанию

```
Логин: Admin
Пароль: zabbix
```

</details>

<details>
<summary>PostgreSQL</summary>


Устанавливаем СУБД

```bash
apt-get install postgresql16-server zabbix-server-pgsql fping
```

Создаем системные базы данных и включаем в автозапуск

```bash
/etc/init.d/postgresql initdb
systemctl enable --now postgresql
```

Создаем БД Zabbix и пользователя

```bash
su - postgres -s /bin/sh -c 'createuser --no-superuser --no-createdb --no-createrole --encrypted --pwprompt zabbix'
Введите пароль для новой роли: 
Повторите его:
su - postgres -s /bin/sh -c 'createdb -O zabbix zabbix'
```

Добавляем в БД данные для веб интерфейса (важно соблюдать порядок ввода команд)

```bash
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/schema.sql zabbix'
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/images.sql zabbix'
su - postgres -s /bin/sh -c 'psql -U zabbix -f /usr/share/doc/zabbix-common-database-pgsql-*/data.sql zabbix'
```

Устанавливаем apache2

```bash
apt-get install apache2 apache2-mod_php8.2
systemctl enable --now httpd2
apt-get install php8.2 php8.2-mbstring php8.2-sockets php8.2-gd php8.2-xmlreader php8.2-pgsql php8.2-ldap php8.2-openssl
```

Меняем опции в <code>etc/php/8.2/apache2-mod_php/php.ini</code>

```bash
memory_limit = 256M
post_max_size = 32M
max_execution_time = 600
max_input_time = 600
date.timezone = Europe/Moscow (регион вписать свой)
always_populate_raw_post_data = -1
```

Перезагружаем

```bash
systemctl restart httpd2
```
Редактируем <code>/etc/zabbix/zabbix_server.conf</code>

```bash
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Пароль
```

```bash
systemctl enable --now zabbix_mysql
```

Установка web интерфейса

```bash
apt-get install zabbix-phpfrontend-apache2 zabbix-phpfrontend-php8.2
ln -s /etc/httpd2/conf/addon.d/A.zabbix.conf /etc/httpd2/conf/extra-enabled/
systemctl restart httpd2
chown apache2:apache2 /var/www/webapps/zabbix/ui/conf
```

Заходим на сайт <ip сервера>/zabbix и подключаемся к БД, вводим пароль от БД

Логин и пароль для входа по умолчанию

```
Логин: Admin
Пароль: zabbix
```

</details>

<details>
<summary>Подключение клиента</summary>

Устанавливаем

```bash
apt-get install zabbix-agent
```

Редактируем конфиг

```bash
nano /etc/zabbix/zabbix_agentd.conf
```

```bash
Server=<ip сервера>
ServerActive=<ip сервера>
Hostname=<назв комп>
```

Заходим на сайт, добавляем узел сети

* Мониторинг -> Узел сети

* Создаем узел сети

* В шаблонах ищем Templates, нажимаем поиск и выбираем Linux by Zabbix agent

* Добавляем группу Discovered hosts

* Вписываем IP компьютера


</details>

</details>

<details>
<summary>Fail2ban</summary>

Fail2ban — это утилита для защиты серверов от атак методом перебора 

Установка

```bash
apt-get install fail2ban python3-module-systemd
```

ALT Linux использует systemd, она не пишет текстовые логи в /var/log, поэтому для переключения на systemd нужно установить пакет python3-module-systemd  

В <code>/etc/fail2ban/jail.conf</code> в секции INCLUDES заменяем

```bash
before = paths-altlinux.conf
```

на

```bash
before = paths-altlinux-systemd.conf
```

Структура fail2ban

```bash
/etc/fail2ban/
├── fail2ban.conf          # Настройки демона
├── jail.conf             # Базовые настройки
├── jail.d
│    └── sshd.conf        # ВАШ КОНФИГ ХРАНИТСЯ ТУТ!
├── filter.d/
│   └── sshd.conf         # Фильтр для анализа логов SSH
└── action.d/
    └── iptables.conf     # Действие: блокировка через iptables
```

### Минимальная настройка 

Представим, нам нужно указать порт ssh, поставить таймер бана (на 10 секунд) и указать количество попыток (3 попытки)

Создаем файл sshd.conf в директории jail.d

```bash
nano /etc/fail2ban/jail.d/sshd.conf
```

В нём пишем следующее

```bash
[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 10
findtime = 60 # время попыток ввода
```

Перезагружаем fail2ban и добавляем в автозапуск

```bash
systemctl restart fail2ban
systemctl enable fail2ban
```

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

