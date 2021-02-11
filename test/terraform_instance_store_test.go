package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"strconv"
	"strings"
	"testing"
	"time"
	"os"
)

func TestInstanceStore(t *testing.T) {
	t.Parallel()

    os.Remove("../examples/default-vpc/keystore-instance-store-operator")
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
		testApiEndpoint(t, terraformOptions)
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

	ports := []string{"9100", "9115", "8080"}

	for _, port := range ports {
		command := fmt.Sprintf("curl -sL -w \"%%{http_code}\" localhost:%s/metrics -o /dev/null", port, )

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

func testApiEndpoint(t *testing.T, terraformOptions *terraform.Options) {

	nodeIp := terraform.Output(t, terraformOptions, "public_ip")

	expectedStatus := "200"
	body := strings.NewReader(`{
    "jsonrpc": "2.0",
    "id": 1234,
    "method": "icx_call",
    "params": {
        "to": "cx0000000000000000000000000000000000000000",
        "dataType": "call",
        "data": {
            "method": "getPReps",
            "params": {
                "startRanking" : "0x1",
                "endRanking": "0x1"
            }
        }
    }
}`)
	url := fmt.Sprintf("http://%s:9000/api/v3", nodeIp)
	headers := make(map[string]string)
	headers["Content-Type"] = "text/plain"

	description := fmt.Sprintf("curl to LB %s with error command", nodeIp)
	maxRetries := 30
	timeBetweenRetries := 1 * time.Second

	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		outputStatus, _, err := http_helper.HTTPDoE(t, "POST", url, body, headers, nil)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(strconv.Itoa(outputStatus)) != expectedStatus {
			return "", fmt.Errorf("expected SSH command to return '%s' but got '%s'", expectedStatus, strconv.Itoa(outputStatus))
		}

		return "", nil
	})
}
