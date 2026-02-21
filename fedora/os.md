<p align="center">
<img src="logo.svg" width="200"/>
</p>

<details>
<summary>🛠️ Постустановка ОС</summary>

При попытке обновлении системы, вы можете столкнуться с ошибкой 403 fedora-cisco-openh264. Это набор кодеков от Cisco. 

Лицензия Cisco не позволяет Fedora его распространять. Удаляем «заблокированного друга» и подключаем свободный RPM Fusion

Удаление репозитория openh264

```bash
sudo dnf5 config-manager setopt fedora-cisco-openh264.enabled=0
sudo dnf5 remove openh264 mozilla-openh264 gstreamer1-plugin-openh264
```

Установка RPM Fusion

```bash
sudo dnf install --nogpgcheck \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Установка кодеков для браузеров

```bash
sudo dnf install ffmpeg-libs --allowerasing
```

</details>
