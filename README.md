
# EVPN with Cumulus Linux
![network scheme](https://ghe.cloud.croc.ru/dc-support/EVPN-with-Cumulus-VX/blob/master/EVPN.PNG)

### Как пользоваться:

Устанавливаем vagrant и virtualbox
```sh
:~$ yum install -y vagrant virtualbox
```
Клонируем репозиторий
```sh
:~$ git@ghe.cloud.croc.ru:dc-support/EVPN.git
:~$ cd EVPN/
```
Сначала запускается сервер управления:
```sh
:~$ vagrant up manage
```

После можно запускать все остальное:
```sh
:~$ vagrant up dc1sw1 dc1sw2 dc2sw1 dc2sw2 dc3sw1 dc3sw2 dc1server dc2server dc3server
```

Проверяем:
```sh
:~$ vagrant ssh manage
vagrant@manage:~$ ssh dc1server
vagrant@dc1server:~$ ping 10.0.100.102
PING 10.0.100.102 (10.0.100.102) 56(84) bytes of data.
64 bytes from 10.0.100.102: icmp_seq=1 ttl=64 time=5.67 ms
64 bytes from 10.0.100.102: icmp_seq=2 ttl=64 time=2.89 ms
64 bytes from 10.0.100.102: icmp_seq=3 ttl=64 time=2.86 ms
64 bytes from 10.0.100.102: icmp_seq=4 ttl=64 time=2.69 ms
64 bytes from 10.0.100.102: icmp_seq=5 ttl=64 time=3.64 ms
^C
--- 10.0.100.102 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4007ms
rtt min/avg/max/mdev = 2.693/3.554/5.674/1.111 ms
```

Просмотр состояния ВМ:
```sh
:~$ vagrant status
Current machine states:

manage                    running (virtualbox)
dc1sw1                    running (virtualbox)
dc1sw2                    running (virtualbox)
dc2sw1                    running (virtualbox)
dc2sw2                    running (virtualbox)
dc3sw1                    running (virtualbox)
dc3sw2                    running (virtualbox)
dc1server                 running (virtualbox)
dc2server                 running (virtualbox)
dc3server                 running (virtualbox)

```


Удалить ВМ:
```sh
:~$ vagrant destroy -f <VM_name>
```

### Полезные команды:
  - show shows the mac-address table for local and remote VTEPs
```sh
:~$ sudo net show bridge macs
```
  - shows BGP IPv4 neighbor adjacencies
```sh
:~$ sudo net show bgp evpn summary
```
  - shows VNIs that this device is participating in (only works on a VTEP)
```sh
:~$ sudo net show bgp evpn vni
```
  - shows remote VTEPs that share VNIs that this switch is participating in (only works on a VTEP)
```sh
:~$ sudo net show evpn vni
```
  - show MAC address information learned per VNI
```sh
:~$ sudo net show evpn mac vni all
```
 - show all EVPN routes
```sh
:~$ sudo net show bgp evpn route
```
