Узнаем UUID диска

```bash
lsblk -f
```

Создаем точку монтирования

```bash
sudo mkdir -p /media/Data
```

Узнаем ID пользователя

```bash
id
```

Добавляем запись в /etc/fstab

Где знаки вопроса - ваши UUID, uid, gid.

```bash
UUID=??? /media/Data  ntfs-3g  defaults,uid=???,gid=???,umask=000,nofail  0  0
```

Перемонтируем все ФС из fstab

```bash
sudo mount -a
```

