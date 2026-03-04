# SuroTools 

<p align="center">
<img src="Image/logo.png" width="400"/>
</p>


> [!NOTE]
> ⚙️ Данный репозиторий предназначен для системных администраторов и инженеров, работающих с Linux‑системами. Он объединяет инструменты, типовые конфигурации и сопроводительную документацию.
> 
> ⚙️ Основная цель — создать единое пространство для хранения и автоматизации ключевых операционных решений, упрощая повседневную работу с Linux.
> 
> ⚙️ Часть конфигураций была разработана мной, другие - собраны из открытых источников, проверены и адаптированы для практического использования.

<p>
  <a href="https://www.altlinux.org/"><img src="https://img.shields.io/badge/ALT%20Linux-005FAD?logo=altlinux&logoColor=fff" alt="ALT"></a>
  <a href="https://archlinux.org/"><img src="https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=fff" alt="Arch"></a>
  <a href="https://www.debian.org/"><img src="https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff" alt="Debian"></a>
  <a href="https://fedoraproject.org/"><img src="https://img.shields.io/badge/Fedora-51A2DA?logo=fedora&logoColor=fff" alt="Fedora"></a>
  <a href="https://almalinux.org/"><img src="https://img.shields.io/badge/AlmaLinux-000?logo=almalinux&logoColor=fff" alt="Alma"></a>
  <a href="https://www.centos.org/"><img src="https://img.shields.io/badge/CentOS-A14F8C?logo=centos&logoColor=white" alt="CentOS"></a>
  <a href="https://rockylinux.org/"><img src="https://img.shields.io/badge/Rocky%20Linux-10B981?logo=rockylinux&logoColor=fff" alt="Rocky"></a>
  <a href="https://vyos.io/"><img src="https://img.shields.io/badge/VyOS-00C4FF?logo=vyos&logoColor=fff" alt="VyOS"></a>
  <a href="https://nixos.org/"><img src="https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=fff" alt="NixOS"></a>
</p>

---

В данный момент идёт работа над ссылками

---
## 💾 Образы ОС

JEOS ALT Linux - [Скачать](https://nightly.altlinux.org/sisyphus/tested/regular-jeos-systemd-latest-x86_64.iso)

VyOS - [Скачать](https://vyos.net/get/)

---
## 📂 Полезные штучки

<details>
<summary>Таблица CIDR </summary>

| CIDR | Пример диапазона IP | Обратная маска | Маска | Адресов | Хостов |
|------|------------------|----------|------|-----------|-------|
| /32 | 192.168.1.1 | 0.0.0.0 | 255.255.255.255 | 1 | 1 |
| /31 | 192.168.1.0-1 | 0.0.0.1 | 255.255.255.254 | 2 | 2 |
| /30 | 192.168.1.0-3 | 0.0.0.3 | 255.255.255.252 | 4 | 2 |
| /29 | 192.168.1.0-7 | 0.0.0.7 | 255.255.255.248 | 8 | 6 |
| /28 | 192.168.1.0-15 | 0.0.0.15 | 255.255.255.240 | 16 | 14 |
| /27 | 192.168.1.0-31 | 0.0.0.31 | 255.255.255.224 | 32 | 30 |
| /26 | 192.168.1.0-63 | 0.0.0.63 | 255.255.255.192 | 64 | 62 |
| /25 | 192.168.1.0-127 | 0.0.0.127 | 255.255.255.128 | 128 | 126 |
| /24 | 192.168.1.0-255 | 0.0.0.255 | 255.255.255.0 | 256 | 254 |
| /23 | 192.168.0.0-1.255 | 0.0.1.255 | 255.255.254.0 | 512 | 510 |
| /22 | 192.168.0.0-3.255 | 0.0.3.255 | 255.255.252.0 | 1024 | 1022 |
| /21 | 192.168.0.0-7.255 | 0.0.7.255 | 255.255.248.0 | 2048 | 2046 |
| /20 | 192.168.0.0-15.255 | 0.0.15.255 | 255.255.240.0 | 4096 | 4094 |
| /19 | 192.168.0.0-31.255 | 0.0.31.255 | 255.255.224.0 | 8192 | 8190 |
| /18 | 192.168.0.0-63.255 | 0.0.63.255 | 255.255.192.0 | 16384 | 16382 |
| /17 | 192.168.0.0-127.255 | 0.0.127.255 | 255.255.128.0 | 32768 | 32766 |
| /16 | 192.168.0.0-255.255 | 0.0.255.255 | 255.255.0.0 | 65536 | 65534 |
| /15 | 192.168.0.0-1.255.255 | 0.1.255.255 | 255.254.0.0 | 131072 | 131070 |
| /14 | 192.168.0.0-3.255.255 | 0.3.255.255 | 255.252.0.0 | 262144 | 262142 |
| /13 | 192.168.0.0-7.255.255 | 0.7.255.255 | 255.248.0.0 | 524288 | 524286 |
| /12 | 192.168.0.0-15.255.255 | 0.15.255.255 | 255.240.0.0 | 1048576 | 1048574 |
| /11 | 192.168.0.0-31.255.255 | 0.31.255.255 | 255.224.0.0 | 2097152 | 2097150 |
| /10 | 192.168.0.0-63.255.255 | 0.63.255.255 | 255.192.0.0 | 4194304 | 4194302 |
| /9 | 192.168.0.0-127.255.255 | 0.127.255.255 | 255.128.0.0 | 8388608 | 8388606 |
| /8 | 10.0.0.0-255.255.255 | 0.255.255.255 | 255.0.0.0 | 16777216 | 16777214 |
| /7 | 10.0.0.0-11.255.255.255 | 1.255.255.255 | 254.0.0.0 | 33554432 | 33554430 |
| /6 | 10.0.0.0-13.255.255.255 | 3.255.255.255 | 252.0.0.0 | 67108864 | 67108862 |
| /5 | 10.0.0.0-17.255.255.255 | 7.255.255.255 | 248.0.0.0 | 134217728 | 134217726 |
| /4 | 10.0.0.0-25.255.255.255 | 15.255.255.255 | 240.0.0.0 | 268435456 | 268435454 |
| /3 | 10.0.0.0-41.255.255.255 | 31.255.255.255 | 224.0.0.0 | 536870912 | 536870910 |
| /2 | 10.0.0.0-73.255.255.255 | 63.255.255.255 | 192.0.0.0 | 1073741824 | 1073741822 |
| /1 | 0.0.0.0-127.255.255.255 | 127.255.255.255 | 128.0.0.0 | 2147483648 | 2147483646 |
| /0 | 0.0.0.0-255.255.255.255 | 255.255.255.255 | 0.0.0.0 | 4294967296 | 4294967294 |

</details>

<details>
<summary>🔧 Репозитории Linux</summary>

| ОС / Дистрибутив                  | Репозиторий                                                                                                                                                                                                 | Путь к конфигурационному файлу                                           |
| :-------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------- |
| **Debian**                        | `deb http://deb.debian.org/debian/ bookworm main`<br>`deb-src http://deb.debian.org/debian/ bookworm main`                                                                                                  | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |
| **Ubuntu**                        | `deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse`<br>`deb-src http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse`                                  | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |
| **Fedora**                        | `baseurl=https://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/`<br>`metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch` | `/etc/yum.repos.d/fedora.repo`<br>`/etc/yum.repos.d/fedora-updates.repo` |
| **CentOS**                        | `baseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/`<br>`baseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/`                                                 | `/etc/yum.repos.d/CentOS-Base.repo`                                      |
| **Arch Linux**                    | `Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch`                                                                                                                                            | `/etc/pacman.d/mirrorlist`                                               |
| **openSUSE**                      | `baseurl=https://download.opensuse.org/distribution/leap/$releasever/repo/oss/`                                                                                                                             | `/etc/zypp/repos.d/`                                                     |
| **AlmaLinux**                     | `baseurl=https://repo.almalinux.org/almalinux/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://repo.almalinux.org/almalinux/$releasever/AppStream/$basearch/os/`                                       | `/etc/yum.repos.d/almalinux.repo`                                        |
| **Rocky Linux**                   | `baseurl=https://download.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://download.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/`                             | `/etc/yum.repos.d/rocky.repo`                                            |
| **Astra Linux (Орел / Смоленск)** | `deb [trusted=yes] http://repo.astralinux.ru/astra/stable/orel main contrib non-free`<br>`deb-src [trusted=yes] http://repo.astralinux.ru/astra/stable/orel main contrib non-free`                          | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |
| **ALT Linux**                     | `rpm [alt] http://mirror.yandex.ru/altlinux p10 branch`<br>`rpm [alt] http://mirror.yandex.ru/altlinux p10 updates`                                                                                         | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |


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

<details>
<summary>🔧✝️ Репозитории Яндекса: теперь с православным apt update</summary>

| ОС / Дистрибутив  | Репозиторий                                                                                                                                                                                                                                                          | Путь к конфигурационному файлу                                           |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------- |
| **Debian**        | `deb http://mirror.yandex.ru/debian/ bookworm main`<br>`deb-src http://mirror.yandex.ru/debian/ bookworm main`<br>`deb http://mirror.yandex.ru/debian-security/ bookworm-security main`<br>`deb-src http://mirror.yandex.ru/debian-security/ bookworm-security main` | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |
| **Ubuntu**        | `deb http://mirror.yandex.ru/ubuntu/ noble main restricted universe multiverse`<br>`deb-src http://mirror.yandex.ru/ubuntu/ noble main restricted universe multiverse`                                                                                               | `/etc/apt/sources.list`<br>`/etc/apt/sources.list.d/`                    |
| **Fedora**        | `baseurl=https://mirror.yandex.ru/fedora/linux/releases/$releasever/Everything/$basearch/os/`<br>`metalink=https://mirror.yandex.ru/fedora/linux/updates/$releasever/Everything/$basearch/`                                                                          | `/etc/yum.repos.d/fedora.repo`<br>`/etc/yum.repos.d/fedora-updates.repo` |
| **CentOS Stream** | `baseurl=http://mirror.yandex.ru/centos-stream/$releasever-stream/BaseOS/$basearch/os/`<br>`baseurl=http://mirror.yandex.ru/centos-stream/$releasever-stream/AppStream/$basearch/os/`                                                                                | `/etc/yum.repos.d/CentOS-Base.repo`                                      |
| **Arch Linux**    | `Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch`                                                                                                                                                                                                         | `/etc/pacman.d/mirrorlist`                                               |
| **openSUSE Leap** | `baseurl=https://mirror.yandex.ru/opensuse/distribution/leap/$releasever/repo/oss/`<br>`baseurl=https://mirror.yandex.ru/opensuse/update/leap/$releasever/oss/`                                                                                                      | `/etc/zypp/repos.d/`                                                     |
| **AlmaLinux**     | `baseurl=https://mirror.yandex.ru/almalinux/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://mirror.yandex.ru/almalinux/$releasever/AppStream/$basearch/os/`                                                                                                    | `/etc/yum.repos.d/almalinux.repo`                                        |
| **Rocky Linux**   | `baseurl=https://mirror.yandex.ru/rockylinux/$releasever/BaseOS/$basearch/os/`<br>`baseurl=https://mirror.yandex.ru/rockylinux/$releasever/AppStream/$basearch/os/`                                                                                                  | `/etc/yum.repos.d/rocky.repo`                                            |

</details>

<details>
<summary>📚💻 Каталог дистрибутивов по назначению и сложности</summary>

| Дистрибутив                          | Идея / философия                              | Уровень сложности | Целевое использование                     |
| ------------------------------------ | --------------------------------------------- | ----------------- | ----------------------------------------- |
| **Alpine Linux**                     | Минимальный и безопасный                      | Средний/высокий   | Серверы, контейнеры, минимальные образы   |
| **antiX**                            | Лёгкий и быстрый Linux                        | Низкий            | Домашние ПК, старые ПК                    |
| **Arch Linux**                       | Минимализм и контроль                         | Высокий           | Домашние ПК, рабочие станции              |
| **Bodhi Linux**                      | Минимализм с Moksha DE                        | Средний           | Домашние ПК, старые ПК                    |
| **CentOS / Rocky Linux / AlmaLinux** | Корпоративная стабильность                    | Средний           | Серверы, корпоративные системы            |
| **Clear Linux**                      | Производительность Intel                      | Средний/высокий   | Рабочие станции, серверы                  |
| **ClearOS**                          | Простая серверная платформа для бизнеса       | Средний           | Серверы, SMB-инфраструктура               |
| **Debian**                           | Стабильность и универсальность                | Средний           | Серверы, рабочие станции                  |
| **Deepin**                           | Красивый и интуитивный интерфейс              | Средний           | Домашние ПК, рабочие станции              |
| **EndeavourOS**                      | Arch-основа с простым установщиком            | Средний           | Домашние ПК                               |
| **Elementary OS**                    | Красота и простота                            | Низкий/средний    | Домашние ПК                               |
| **Fedora**                           | Передовые технологии                          | Средний           | Рабочие станции, разработка               |
| **Garuda Linux**                     | Arch с графическим улучшением                 | Средний           | Домашние ПК, геймеры                      |
| **Gentoo**                           | Полный контроль и оптимизация                 | Высокий           | Рабочие станции, серверы                  |
| **KaOS**                             | KDE и Qt-ориентированный дистрибутив          | Средний           | Домашние ПК, рабочие станции              |
| **Kali Linux**                       | Безопасность и пентестинг                     | Средний           | Рабочие станции, пентестинг               |
| **Knoppix**                          | Live-CD для восстановления                    | Низкий            | Домашние ПК, тестирование, восстановление |
| **Linux Mint**                       | Пользовательский комфорт                      | Низкий            | Домашние ПК                               |
| **Manjaro**                          | Arch без боли                                 | Средний           | Домашние ПК, рабочие станции              |
| **MX Linux**                         | Лёгкость и стабильность                       | Низкий/средний    | Домашние ПК, старые ПК                    |
| **NixOS**                            | Всё в одном конфиге, декларативное управление | Средний/высокий   | Рабочие станции, серверы                  |
| **Nitrux**                           | Rolling release с красивым интерфейсом        | Средний           | Домашние ПК                               |
| **Oracle Linux**                     | Корпоративная стабильность (RHEL-клон)        | Средний           | Серверы                                   |
| **Parrot OS**                        | Безопасность, разработка и анонимность        | Средний           | Рабочие станции, пентестинг               |
| **Pop!_OS**                          | Linux для разработчиков и геймеров            | Средний           | Домашние ПК, рабочие станции              |
| **Puppy Linux**                      | Очень лёгкий Linux для старых ПК              | Низкий            | Домашние ПК, старые ПК                    |
| **Q4OS**                             | Windows-подобный интерфейс для старых ПК      | Низкий            | Домашние ПК                               |
| **RebornOS**                         | Arch с графическим установщиком               | Средний           | Домашние ПК                               |
| **Slackware**                        | Классика UNIX, минимализм                     | Высокий           | Рабочие станции, серверы                  |
| **Solus**                            | Десктопная оптимизация                        | Средний           | Домашние ПК, рабочие станции              |
| **SteamOS / SteamOS 3**              | Игры на Linux                                 | Средний           | Домашние ПК, игровые станции              |
| **Tails**                            | Анонимность и безопасность                    | Средний           | Рабочие станции, безопасность             |
| **Tiny Core Linux**                  | Минимум для минимума                          | Высокий           | Встраиваемые системы, минимальные ПК      |
| **Ubuntu**                           | Простота для пользователя                     | Низкий/средний    | Домашние ПК, рабочие станции, серверы     |
| **Void Linux**                       | Минимализм и гибкость                         | Высокий           | Рабочие станции, серверы                  |
| **Zorin OS**                         | Linux для переходящих с Windows               | Низкий            | Домашние ПК                               |


</details>

[Калькулятор IP](https://ipfix.ru/tools/ip-calculator)

---

## 🧑‍💻 Автор

> Автор: **vanyadima**  
> Контакт: **isurodin@tutanota.com** **[Telegram](https://t.me/vanyadlma)**

