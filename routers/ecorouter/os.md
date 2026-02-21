<p align="center">
<img src="logo.png" width="200"/>
</p>
<details>
<summary> подключение к BGP</summary>

```bash
router bgp 64500
bgp router-id 178.207.179.4 # уникальный идентификатор 
neighbor <ip провайдера> remote-as 31133
write
```

</details>

<details>
<summary>Подключение к RADIUS</summary>

```bash
rtr-cod(config)#security none 
rtr-cod(config)#aaa radius-server 192.168.10.1 port 1812 secret P@ssw0rd auth
rtr-cod(config)#aaa precedence local radius
```

</details>
  
<details>
<summary>Подключение к Zabbix</summary>

```bash
rtr-cod(config)#security none
rtr-cod(config)#snmp-server enable snmp
rtr-cod(config)#snmp-server community public ro 
```

</details>

<details>
<summary>NTP</summary>

```bash
rtr-cod(config)#ntp timezone utc+3
rtr-cod(config)#ntp server <адрес>
```
проверка
```bash
sh ntp timezone
sh ntp status
```
</details>

<details>
<summary>int+route</summary>

настройка интерфейса

```bash
config
  interface <назв инт>
  ip address <ip/маска>
  port <назв порта>
  service-instance <навз порта>/<назв инт>
  encapsulation untagged
  connect ip interface <назв инт>
```

маршрут по умолчанию + dns

```bash
config
  ip route 0.0.0.0/0 <ip>
  ip name-server <ip dns сервера>
```

</details>

<details>
<summary>vlan</summary>

```bash
config
  interface <внут инт>
  ip address <ip роутера>
  port <назв порта>
  service-instance <навз порта>/<назв инт>
  encapsulation dot1q <номер vlan> exact
  rewrite pop 1
  connect ip interface <назв инт>
```

</details>

<details>
<summary>nat</summary>

```bash
config
  interface <внеш инт>
  ip nat outside
  interface <внут инт>
  ip nat inside
  ex

  ip nat pool LAN <диапозон ip внут сети>
  ip nat source dynamic inside-to-outside pool LAN overload interface <внеш инт>
```

</details>

<details>
<summary>dhcp-server</summary>

создать пулы, потом настраивать

```bash
ip pool POOL_A 192.168.1.10,192.168.1.20-192.168.1.50,192.168.1.100-192.168.1.200
ip pool POOL_B 172.16.0.10-172.16.255.254
```

```bash

! Создание DHCP-сервера с номером 1
dhcp-server 1

! Настройка глобальных параметров (опционально)
lease 3600
gateway 192.168.1.1
dns 8.8.8.8
ntp 8.8.8.8

! Создание IP-пулов
pool POOL_A 10
mask 255.255.255.0
lease 7200
gateway 192.168.1.1
exit

! Создание статической привязки
static ip 192.168.1.100
  chaddr 0123.4567.89ab
  mask 255.255.255.0
  lease 86400
  gateway 192.168.1.1
exit

! Привязка DHCP-сервера к интерфейсу
interface eth0
  dhcp-server 1
  exit
```

</details>

<details>
<summary>gre+ospf</summary>

```bash
config
  interface tunnel.0
  ip address 10.10.10.1/30
  ip tunnel <ip внешнего интерфейса роутера> <ip внешнего интерфейса соседнего роутера> mode gre
```

```bash
config
  router ospf 1
  ospf router-id 10.10.10.1
  passive-interface default
  no passive-interface tunnel.0
  network 10.10.10.0/30 area 0
exit
```


```bash
config
  interface tunnel.0
  ip ospf authentication message-digest 
  ip ospf message-digest-key 1 md5 P@ssw0rd
exit
```

</details>


