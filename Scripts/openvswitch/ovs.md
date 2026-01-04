# Установка Open vSwitch с помощью скриптов

Open vSwitch (OVS) — это виртуальный коммутатор с открытым исходным кодом, широко используемый в виртуализации, SDN и облачной инфраструктуре.

> [!WARNING]  
>Скрипт написан впервые, поэтому, пожалуйста, используйте с осторожностью. Любые баги и предложения приветствуются.

### Установка

> [!IMPORTANT]  
> Выполняйте только от имени root

```bash
git clone https://github.com/vanyadima/SuroTools.git
cd SuroTools/Scripts/openvswitch
chmod +x ovsinstall.sh
chmod +x ovsinit.sh
./ovsinstall.sh
./ovsinit.sh
./ovsinit.sh
```
