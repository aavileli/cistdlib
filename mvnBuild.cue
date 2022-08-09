package cistdlib

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/docker"
)

#MvnBuild: {
    // Source code of the maven application
    app: dagger.#FS

    // docker image address to be used for building the project.   
    mvnImage: dagger.#Ref | *"maven:3.6.3-amazoncorretto-11"

    // Maven goal and options to run for the mvn client 
    mvnCmd: string
   
    // Maven settings file to use to connect to private repositories 
    mvn_settings: dagger.#Secret

    _image: docker.#Pull & {
        source: mvnImage
    }

    _copy: docker.#Copy & {
            input:    _image.output
            contents: app
            dest:     "/mnt"
    }

    // Build steps
    _build: docker.#Run & {
        input: _copy.output
        workdir: "/mnt"
        _m2CachePath:   "/root/.m2"
        env: {
            MAVEN_OPTS: "-Dmaven.repo.local=\(_m2CachePath)"
        }
        // mounting cache directory and mvn settings file which will be created in buildkit to be used on subsequent builds
        mounts: {
            "m2 cache": {
				contents: core.#CacheDir & {
					id: "m2"  // this cache can be shared with other runs as its not set as locked or private
				}
				dest: _m2CachePath
			}
            "m2 settings": {
                dest: "/run/secrets/settings.xml"
                "contents": mvn_settings
            }
        }
        // mvn goals and flags sent to execute
        command: {
			name: "sh"
            flags: "-c": """
                mvn \(mvnCmd) -gs '/run/secrets/settings.xml'
            """
        }
		
        // exporting target artifact directory
        export: directories: "/mnt": _
    }
    // exporting target artifact directory to be consumed by other actions
    output: _build.export.directories."/mnt"
}