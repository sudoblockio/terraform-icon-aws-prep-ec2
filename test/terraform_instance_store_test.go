package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"strings"
	"testing"
	"time"
)

func TestInstanceStore(t *testing.T) {
	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/instance-store")

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		terraform.Destroy(t, terraformOptions)

		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, keyPair := configureTerraformOptions(t, exampleFolder)
		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)
		test_structure.SaveEc2KeyPair(t, exampleFolder, keyPair)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)

		testExportersGoodHealth(t, terraformOptions, keyPair)
	})
}


func testExportersGoodHealth(t *testing.T, terraformOptions *terraform.Options, keyPair *aws.Ec2Keypair) {
	publicInstanceIP := terraform.Output(t, terraformOptions, "public_ip")

	publicHost := ssh.Host{
		Hostname:    publicInstanceIP,
		SshKeyPair:  keyPair.KeyPair,
		SshUserName: "ubuntu",
	}

	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", publicInstanceIP)

	// Run a simple echo command on the server
	expectedText := "200"

	ports := []string{"9100", "9113", "9115", "8080"}

	for _, port := range ports {
		command := fmt.Sprintf("curl -sL -w \"%%{http_code}\" localhost:%s/metrics -o /dev/null", port,)

		description = fmt.Sprintf("SSH to public host %s with error command", publicInstanceIP)

		// Verify that we can SSH to the Instance and run commands
		retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
			actualText, err := ssh.CheckSshCommandE(t, publicHost, command)

			if err != nil {
				return "", err
			}

			if strings.TrimSpace(actualText) != expectedText {
				return "", fmt.Errorf("Expected SSH command to return '%s' but got '%s'", expectedText, actualText)
			}

			return "", nil
		})
	}
}

