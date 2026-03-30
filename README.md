> [!WARNING]
> 
> * Please install Docker on your computer. Also, make sure that Docker daemon is running before executing the scripts. And to be able to clone the project, you will also need to install Git.
>
> * If your anti-virus software or Windows Defender blocks the script execution, please allow it to run. Or contact me so that I can investigate further.

## Introduction

This repository is not meant to be a Java project. Rather, it contains scripts (one for Windows and one for Linux/MacOS), that do the following:

* Remove the existing folder/directory named `spring-base`, `spring-base-event`, and `spring-base-frontend` if existed.

* Clone the project `spring-base` [from GitHub](https://github.com/vulinh64/spring-base).

* Clone the project `spring-base-event` [from GitHub](https://github.com/vulinh64/spring-base-event).

* Clone the project `spring-base-frontend` [from GitHub](https://github.com/vulinh64/spring-base-frontend).

* Do the docker compose build for all projects.

## Usage

* For Windows, run [this script](./run-full-squad.cmd) or [this script](./run-full-squad-jar.cmd) that use host OS to build jar files, or [this script](./run-full-squad-full-stack.cmd) that also includes the frontend.

* For Linux or MacOS, run [this script](./run-full-squad.sh) or [this script](./run-full-squad-jar.sh) that use host OS to build jar files, or [this script](./run-full-squad-full-stack.sh) that also includes the frontend.
