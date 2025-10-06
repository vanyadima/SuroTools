# SuroTools
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
iptables-save > /etc/sysconfig/iptables
systemctl enable iptables
```

Настройка правил:

[!Настройка на примере коммутатора](image/ALTLinux/iptables%20sw)

```bash

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

Инструкции и примеры для Arch Linux:

```bash
sudo pacman -Syu
sudo pacman -S nginx
```

</details>

---

<details>
<summary>🌿 EcoRouter</summary>

Описание, настройки или конфиги для EcoRouter:

```bash
systemctl restart ecorouter
```

</details>

---

## 🧑‍💻 Автор

> Автор: **vanyadima**  
> Контакт: **isurodin@yandex.ru** **https://vk.com/surodyn** **https://t.me/vanyadlma**

---

## 💬 Благодарности

Особая благодарность **[Gerasti](https://github.com/Gerasti)** —  
за вдохновение и подход к организации проекта, послужившие основой для создания **SuroTools**.
