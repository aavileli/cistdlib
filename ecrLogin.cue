package cistdlib

import (
	"universe.dagger.io/aws"
	"dagger.io/dagger"
	"dagger.io/dagger/core"
)

#EcrToken: {
	// Pass the aws region for the aws client. Default provided to ap-southeast-2
	region: string | *"ap-southeast-2"
	// Pass optional aws credentials file otherwise use instance profile of node
	credsFile?: dagger.#Secret
	// aws profile to use if using in non ci environments 
	profile?:   string
	_profile: string & { "--profile \(profile)" } | *""
	_ecrlogin: aws.#Container & {
		always: true
		if credsFile != _|_ {
			// mounting credential file for aws client
			mounts: {
				aws: core.#Mount & {
					dest:     "/root/.aws/credentials"
					contents: credsFile
				}
			}
		}

		// Aws command to retreive ecr token
		command: {
			name: "sh"
			args: [ "-c", "aws ecr get-login-password --region \(region) \(_profile) > /token.txt"]
		}
		// token file to be exported 
		export: secrets: "/token.txt": _
	}
	// exported token secret to be passed to other actions 
	token: _ecrlogin.export.secrets."/token.txt"
}