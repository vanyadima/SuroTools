VyOS — это бесплатный Open Source Linux-дистрибутив для превращения сервера или ПК в мощный сетевой маршрутизатор. Прямой аналог Cisco с похожим интерфейсом командной строки (CLI), но работающий на стандартном железе.

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

