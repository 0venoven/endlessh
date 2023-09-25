# endlessh

## Overview

Endlessh is an ssh tarpit which will stall anyone indefinitely by slowly serving up an endless banner when trying to log into the endlessh service. It can swapped with the real ssh service on port 22 to deceive malicious actors (think script runners, script kiddies, botnets) into attacking the endlessh server, possibly wasting their resources (albeit likely not significantly so).

## Set up SSH on Ubuntu (and use nmap to see how it behaves normally)

Install and start ssh server

- `sudo apt install openssh-server`

![image](https://github.com/0venoven/endlessh/assets/51714567/3e278426-6cde-43aa-88be-678af1b0362f)

Check ssh status

`sudo systemctl status ssh`

![image](https://github.com/0venoven/endlessh/assets/51714567/306859a8-45a4-4312-9be1-9bfa4185c871)

Use nmap to run a scan

`nmap -T4 -A 192.168.158.129`

![image](https://github.com/0venoven/endlessh/assets/51714567/d83474ce-d48b-4c1b-9687-2feaa974bbb8)

Some system/service output from the scan/brute force (THC-hydra)

`sudo systemctl status ssh` after the nmap scan

![image](https://github.com/0venoven/endlessh/assets/51714567/615d160d-2f2f-45e7-b3ab-edf56c3f88f1)

`sudo systemctl status ssh` when running a hydra with wordlist

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

## Resources and Acknowledgments
### endlessh by skeeto
* https://github.com/skeeto/endlessh
