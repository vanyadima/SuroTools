<p align="center">
<img src="logo.svg" width="400"/>
</p>


Вот и настал тот самый день. День, когда вы решили, что жить спокойно — это не про вас, и поставили цель установить Arch Linux в качестве основной системы. 

Поздравляю! :)

Вы уже скачали образ, записали его на флешку, загрузились, и перед вами гордо мигает курсор в терминале. Момент истины настал.

Но… что дальше?

<details>
<summary>Перед установкой</summary>

 
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
<summary>Рекомендую после установки </summary>
Пакетный менеджер yay для AUR

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
