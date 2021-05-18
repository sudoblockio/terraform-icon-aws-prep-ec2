package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"io/ioutil"
	"log"
	"os"
	"path"
	"testing"
)

func configureTerraformOptions(t *testing.T, exampleFolder string) (*terraform.Options, *aws.Ec2Keypair) {
	uniqueID := random.UniqueId()
	awsRegion := "us-east-2"

	keyPairName := fmt.Sprintf("terratest-ssh-example-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

	privateKeyPath := path.Join(exampleFolder, "id_rsa_test")
	publicKeyPath := path.Join(exampleFolder, "id_rsa_test.pub")

	err := ioutil.WriteFile(privateKeyPath, []byte(keyPair.PrivateKey), 0644)
	if err != nil {
		panic(err)
	}

	err = os.Chmod(privateKeyPath, 0600)
	if err != nil {
		log.Println(err)
	}

	err = ioutil.WriteFile(publicKeyPath, []byte(keyPair.PublicKey), 0644)
	if err != nil {
		panic(err)
	}

	terraformOptions := &terraform.Options{
		TerraformDir: exampleFolder,
		OutputMaxLineSize: 1024 * 1024,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":    awsRegion,
			"public_key_path":    publicKeyPath,
			"private_key_path":   privateKeyPath,
		},
	}

	return terraformOptions, keyPair
}

