# Dockerization of SailPoint IdentityIQ

_Note: **SailPoint IdentityIQ** is a software provided by **SailPoint** and **requires a license from them to be used**. When a licence is acquired, you will be able to go on the [community website](https://community.sailpoint.com/) to download the binaries of IdentityIQ._

## Requirements

- A licence from SailPoint for IdentityIQ (this is **mandatory**!)
- IdentityIQ **8.1** Binaries (including the patches and efixes)
- [Docker](https://www.docker.com/) _(and docker-compose)_

## Why use this _(do not use as-is in production)_

I've created this docker configuration just to play with IdentityIQ for education purposes and to take look at the new versions before promoting the changes to our production instances. **This setup is not intended to be used in production**.

## How to use

### Scope
Since this project was created mostly for testing and education purposes, I've simplified the usage to make it easy to deploy new versions instantly without too much regard for data storage and persistence.

### Preparation
1. Drop the binaries to their respective folders inside the `binaries` folder \
    - `identityiq-8.1.zip` -> `binaries/base/` (only one file allowed)
    - `identityiq-8.1p2.jar` -> `binaries/patch/` (only one file allowed)
    - `identityiq-8.1p2-XXXXX.zip ` -> `binaries/efixes/` (multiple files allowed)
2. Adjust the `.env` file to match the binaries you want to use. 
    ```
    TOMCAT_VERSION=9.0.43
    ```

### Build & Launch
```
docker-compose up --build
```
> Yes... I'm boring with that... but it's better to be safe than sorry. SailPoint IdentityIQ is not an open-source software and should be treated with that in mind. You must never publish the created images to public repositories. **You've been warned again**!

### Start Fresh (between different version of IdentityIQ)
Delete the volumes created from previous executions by running this command:
```
docker-compose rm -v
```

### Access
IdentityIQ should be accessible from [http://localhost:8080/](http://localhost:8080/) and [http://localhost:8080/identityiq](http://localhost:8080/identityiq).

> I'm not gonna provide any details regarding the authentication. You will find those details inside the software documentation.

Tomcat manager from [http://localhost:8080/manager/](http://localhost:8080/manager/) with the username `admin` and password `admin`

Adminer from [http://localhost:8081/](http://localhost:8081/)

## Support

**I'm not working for SailPoint and I will not provide any support for IdentityIQ. Please contact SailPoint if you need assistance with their product.** 

Regarding this repository, If you find something that is not working correctly or you need some assistance, take the time to open a detailed issue and I will be more than happy to take a look when I'm available. 