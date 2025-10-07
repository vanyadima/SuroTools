# SuroTools
> ⚙️ Проект находится на стадии активного развития.
> В начале представлены базовые настройки и примеры, которые со временем будут дополнены и расширены.

> Набор инструментов, конфигураций и документации для системных администраторов и инженеров Linux.  
> Цель проекта — создать единое место для хранения и автоматизации всех необходимых решений для Linux.

---

<details>
<summary>🐧 ALT Linux</summary>

<details>
<summary>🧱 iptables</summary>

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

Настройка iptables после настройки DHCP

```bash
iptables -A INPUT -i <инт> -p udp -j ACCEPT
iptables -A INPUT -i <инт> -p tcp -j ACCEPT
iptables -A OUTPUT -i <инт> -p udp -j ACCEPT
iptables -A OUTPUT -i <инт> -p tcp -j ACCEPT
```

</details>

<details>
<summary>🛰️ Статическая маршрутизация</summary>

Пример настройки статических маршрутов:

```bash
# Добавление маршрута к сети 192.168.10.0/24 через шлюз 192.168.1.1
ip route add 192.168.10.0/24 via 192.168.1.1 dev eth0
```

Проверка таблицы маршрутизации:

```bash
ip route show
```

Сохранение маршрута в конфигурации:

```bash
echo "192.168.10.0/24 via 192.168.1.1 dev eth0" >> /etc/net/ifaces/eth0/ipv4route
```

</details>

</details>

---

<details>
<summary>🎯 Arch Linux</summary>

Пока пусто :(

</details>

---

<details>
<summary>🌿 EcoRouter</summary>

Пока пусто :(

</details>

---

## 🧑‍💻 Автор

> Автор: **vanyadima**  
> Контакт: **isurodin@yandex.ru** **https://vk.com/surodyn** **https://t.me/vanyadlma**

## 💬 Благодарности

Особая благодарность **[Gerasti](https://github.com/Gerasti)** —  
за вдохновение и подход к организации проекта, которые послужили основой для создания SuroTools.
