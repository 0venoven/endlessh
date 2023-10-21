# endlessh

## Overview

[Endlessh](https://github.com/skeeto/endlessh) by skeeto is an ssh tarpit which will stall anyone indefinitely by slowly serving up an endless banner when trying to log into the endlessh service. It can swapped with the real ssh service on port 22 to deceive malicious actors (think script runners, script kiddies, botnets) into attacking the endlessh server, possibly wasting their resources (albeit likely not significantly so).

Check out [autoswap_endlessh.sh](https://github.com/0venoven/endlessh/blob/main/autoswap_endlessh.sh) for the automated script to swap and set-up endlessh.

## Set up SSH on Ubuntu (and use nmap to see how it behaves normally)

Install and start ssh server

- `sudo apt install openssh-server`

![image](https://github.com/0venoven/endlessh/assets/51714567/3e278426-6cde-43aa-88be-678af1b0362f)

Check ssh status

- `sudo systemctl status ssh`

![image](https://github.com/0venoven/endlessh/assets/51714567/306859a8-45a4-4312-9be1-9bfa4185c871)

Use nmap to run a scan

- `nmap -T4 -A 192.168.158.129`

![image](https://github.com/0venoven/endlessh/assets/51714567/d83474ce-d48b-4c1b-9687-2feaa974bbb8)

Some system/service output from the scan/brute force (THC-hydra)

- `sudo systemctl status ssh` after the nmap scan

![image](https://github.com/0venoven/endlessh/assets/51714567/615d160d-2f2f-45e7-b3ab-edf56c3f88f1)

- `sudo systemctl status ssh` when running a hydra with wordlist

![image](https://github.com/0venoven/endlessh/assets/51714567/7170373b-05af-4854-87f3-d1f307ee4dd0)

Trying to connect to the ssh instance gave me a warning message as the host key has likely changed somehow. We can simply remove the host key tagged to the machine and retry.

- `ssh ivan@192.168.158.129`
- `ssh-keygen -R 192.168.158.129`

![image](https://github.com/0venoven/endlessh/assets/51714567/1144fa42-f9b4-412d-9c89-aabb3b5df4f9)

- `ssh ivan@192.168.158.129`

![image](https://github.com/0venoven/endlessh/assets/51714567/3da53e18-c8b4-41dd-a6e8-52bd56c083f7)

Checking users logged in after logging in from another machine

- `users`

![image](https://github.com/0venoven/endlessh/assets/51714567/e4c3252b-91e2-4017-ab2d-7c9ecba00d1f)

## Set up endlessh

Clone endlessh repo

- `git clone https://github.com/skeeto/endlessh`
- `cd endlessh`

Installing dependencies

- `sudo apt install build-essential libc6-dev`

Compile binary

- `make`

![image](https://github.com/0venoven/endlessh/assets/51714567/aeaefef3-c9de-4621-825e-1fb3735b3b58)

Move the executable to the local binary folder

- `sudo mv endlessh /usr/local/bin/`

By copying the `.service` file to `/etc/systemd/system/` and reloading the units, the endlessh service becomes known to systemd, enabling us to manage it using `systemd` commands like `systemctl`.

- `sudo cp util/endlessh.service /etc/systemd/system/`
    - What are unit files
        - https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files

Use `systemctl` to enable the endlessh service (that is now known to `systemd`)

- `sudo systemctl enable endlessh`
    - Enable `systemd` service
 
![image](https://github.com/0venoven/endlessh/assets/51714567/31051109-c95d-44c3-9c87-8da9de8ba61a)

- `sudo systemctl daemon-reload`

![image](https://github.com/0venoven/endlessh/assets/51714567/42b7ad2b-cd63-4d82-9f1f-1918de946964)
- Otherwise we’ll be asked to run systemctl daemon-reload to reload units when we try to start the endlessh service.


Change real ssh port to another port
- `sudo vim /etc/ssh/sshd_config`

![image](https://github.com/0venoven/endlessh/assets/51714567/e004222a-cf96-4a6e-a4a3-efc87bfc6e34)

- Comment out the port and use some other port (that is more than 1024 or some uncommon port).

Allow firewall on port 2244

- `sudo ufw allow 2244/tcp`

Restart ssh

- `sudo systemctl restart ssh`

Check ssh is running on 2244

- `sudo netstat -tulpn | grep ssh`

![image](https://github.com/0venoven/endlessh/assets/51714567/7c5a88c5-7500-4dec-8b1f-74e1c8a4f9c7)

Change endlessh port to 22
- `sudo vim /etc/systemd/system/endlessh.service`

![image](https://github.com/0venoven/endlessh/assets/51714567/7f5b497d-4fc7-44e8-8607-cf0c7f48f316)

- sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/endlessh

Create config files
    - `sudo mkdir -p /etc/endlessh`
    - `sudo vim /etc/endlessh/config`
        - Add in a single line “Port 22”.
     
Start endlessh
    - `sudo systemctl start endlessh`
 
Verifying endlessh is running
    - If netstat isn’t installed
        - `sudo apt install net-tools`
    - `sudo netstat -tulpn | grep endlessh`
 
![image](https://github.com/0venoven/endlessh/assets/51714567/f1692e31-f9d5-4ddb-a11d-c3655267cc79)

## Testing endlessh

- `ssh ivan@192.168.158.129`

![image](https://github.com/0venoven/endlessh/assets/51714567/d7486ed7-cbc1-4e8a-a2fa-26ae11392e63)

- The ssh connection will be stuck in this state indefinitely.

- ssh -vvv ivan@192.168.158.129

![image](https://github.com/0venoven/endlessh/assets/51714567/84a3d588-4223-4d55-9784-2de754aa0ce4)

- As we can see the banner just keeps printing out random stuff very slowly.

- nmap will also be similarly stuck in this state.

![image](https://github.com/0venoven/endlessh/assets/51714567/d79ea667-8b87-4f0c-a077-c930ac36471c)

## Disable services (if needed)

To disable ssh
- `sudo systemctl disable --now ssh`

![image](https://github.com/0venoven/endlessh/assets/51714567/297646f8-a836-4d1c-8152-31566b47c42d)

To disable endlessh
- `sudo systemctl stop endlessh`

## Resources and Acknowledgments
### endlessh by skeeto
- https://github.com/skeeto/endlessh

### Youtube video walkthrough by Ilya Kozorezov
- https://www.youtube.com/watch?v=4JECQLXFtYA

### Others
- https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-20-04/
- https://www.cyberciti.biz/faq/howto-start-stop-ssh-server/
- https://ubuntu.com/server/docs/service-openssh
- https://stackoverflow.com/questions/20840012/ssh-remote-host-identification-has-changed
- https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files
