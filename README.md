> [!WARNING]
> 
> * Please install Docker on your computer. Also, make sure that Docker daemon is running before executing the scripts. And to be able to clone the project, you will also need to install Git.
>
> * If your anti-virus software or Windows Defender blocks the script execution, please allow it to run. Or contact me so that I can investigate further.

## Introduction

This repository is not meant to be a Java project. Rather, it contains scripts (one for Windows and one for Linux/MacOS), that do the following:

* Remove the existing folder/directory named `spring-base` and `spring-base-event` if existed.

* Clone the project `spring-base` [from GitHub](https://github.com/vulinh64/spring-base).

* Clone the project `spring-base-event` [from GitHub](https://github.com/vulinh64/spring-base-event).

* Do the docker compose build for both projects.

## Usage

* For Windows, run [this script](/run-full-squad.cmd).

* For Linux or MacOS, run [this script](/run-full-squad.sh).
