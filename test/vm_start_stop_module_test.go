package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func Test_Patterns(t *testing.T) {
	t.Parallel()

	patterns := []string{
		"pattern_basic",
	}

	for _, patternPath := range patterns {
		t.Run(patternPath, func(t *testing.T) {
			tfOptions := &terraform.Options{
				TerraformDir: patternPath,
			}

			defer terraform.Destroy(t, tfOptions)

			terraform.Init(t, tfOptions)
			terraform.Plan(t, tfOptions)
			terraform.Apply(t, tfOptions)
		})
	}
}
