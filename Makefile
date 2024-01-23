SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >


# Define the name of the Kubernetes namespace.
kubeNamespace="kube-public"
# Define the name of the release.
helmChartName="stateless-chart"
# Define the location of the generated Kubernetes manifests.
helmOutputDir=".helm_output/kubernetes"
# Define the name of the generated template file.
helmOutputFile="${helmOutputDir}/template.all.yaml"

.PHONY: dependencies
dependencies:
# It downloads dependencies on the Client workstation (locally).
> @helm dependency update

.PHONY: template
template: dependencies
# It generates the Kubernetes YAML manifests.
> @mkdir -p "${helmOutputDir}"
> @helm template --debug \
> --namespace "${kubeNamespace}" \
> "${helmChartName}" . > "${helmOutputFile}"

.PHONY: schema
schema:
# It generates the schema for the default values.yaml file
> @helm schema values.yaml > values.schema.json
.PHONY: readme
readme: schema
# It generates the main README.md file for the chart.
> @docker run -v "${PWD}:/app/chart" \
> --entrypoint bash \
> quay.io/jetbrains/helm-packager:latest -c "readme-generator -v values.yaml -r README.md -s values.schema.json"

.PHONY: tests
tests:
# It runs the helm unit tests. Requires the Helm Unit Test Plugin installed.
# Ref: https://github.com/helm-unittest/helm-unittest.git
> @helm unittest -f './tests/*/*.yaml' .