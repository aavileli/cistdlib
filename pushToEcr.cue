package cistdlib

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/docker"
    "strings"
)

#PushToEcr: {
   // dockerpath or file to use
   dockerpath:  string
   // ecr token to be used
   token: dagger.#Secret 
   // target application to build a docker image
   input: dagger.#FS
   // aws 12 digit account id required for constructiong ecr registry
   accountId: string & strings.MinRunes(12) & strings.MaxRunes(12)
   // ecr repository name. Accepting only values like ash/web or ash-web/ash or ash/compliance-ms
   ecrName: string & =~"^[a-z]+[a-z/-]+[a-z]$"
   // ecr image tag reference
   tag: string
   // aws region required to construct ecr repository
   region: string | *"ap-southeast-2"
   _ecrFqdn: "\(accountId).dkr.ecr.\(region).amazonaws.com"
   _registry: core.#TrimSecret & {
      input: token
   }
   _buildImage: docker.#Dockerfile & {
      source: input
      dockerfile: path: dockerpath
        auth: { 
              "\(_ecrFqdn)":  {
                    username: "AWS"
                    secret: _registry.output
                 }
       }
   } 
   _ecrpush: docker.#Push & {
        dest:  "\(_ecrFqdn)/\(ecrName):\(tag)"
        image: _buildImage.output
        auth: {
                username: "AWS"
                secret: _registry.output
           }
   }
   // Output image fully qualified digest that was pushed to ecr
   digest: _ecrpush.result
} 