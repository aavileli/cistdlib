## This is a dagger cue package libary to be used with [dagger](https://docs.dagger.io/) client

## download package into build project `cue.mod/pkg`
```bash
dagger project update
dagger project update github.com/aavileli/cistdlib@v0.0.1
```
## import package in your build project `main.cue`
```go
import "github.com/aavileli/cistdlib"
```
## Usage

### MvnBuild schema defination [MvnBuild](mvnBuild.cue)
```go
        // Build maven goal with private maven repository
        build: cistdlib.#MvnBuild & {
            app: client.filesystem["."].read.contents
            mvn_settings: client.filesystem["/.settings.xml"].read.contents
            mvnImage: client.env.MVN_IMAGE
            mvnCmd: client.env.MVN_CMD
        }
```
### EcrToken schema defination [EcrToken](ecrToken.cue)
```go
        // Get ecr secret token required to push image from aws client 
        ecrToken: cistdlib.#EcrToken & {
            credsFile: client.filesystem["~/.aws/credentials"].read.contents
        }
```
### PushToEcr schema defination [PushToEcr](pushToEcr.cue)
```go
        // Build docker image from supplied dockerpath and push to ecr
        pushToEcr: cistdlib.#PushToEcr & {
            input: build.output
            accountId: client.env.ACCOUNT_ID
            dockerpath: config.DOCKERPATH
            token: ecrToken.token 
            ecrName: client.env.ECR_NAME
            tag: "\(client.env.BRANCH_NAME)-\(client.env.BUILD_NUMBER)"
        }

```
````
 __________________
< work in progress >
 ------------------
   \         ,        ,
    \       /(        )`
     \      \ \___   / |
            /- _  `-/  '
           (/\/ \ \   /\
           / /   | `    \
           O O   ) /    |
           `-^--'`<     '
          (_.)  _  )   /
           `.___/`    /
             `-----' /
<----.     __ / __   \
<----|====O)))==) \) /====
<----'    `--' `.__,' \
             |        |
              \       /
        ______( (_  / \______
      ,'  ,-----'   |        \
      `--{__________)        \/

````
