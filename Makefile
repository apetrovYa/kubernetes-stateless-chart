include ../../../lib/Makefiles/Helm.mk
include ../../../lib/Makefiles/HelmDocs.mk

# Define the name of the Kubernetes namespace.
kubeNamespace="kube-public"
# Define the name of the release.
helmChartName="stateless-chart"
# Define the location of the generated Kubernetes manifests.
helmOutputDir=".helm_output/kubernetes"
# Define the name of the generated template file.
helmOutputFile="${helmOutputDir}/template.all.yaml"


dependencies:
# It updates the dependencies: download them locally.
> @helm dependency update

template: dependencies
# It generates the Kubernetes manifests.
> @mkdir -p "${helmOutputDir}"
> @helm template --debug \
> --namespace "${kubeNamespace}" \
> "${helmChartName}" . > "${helmOutputFile}"

helm-schema:
# It generates the schema for the default values.yaml file.
> @helm schema-gen values.yaml > values.schema.json

readme: schema
# It generates the main README.md file for the chart.
> @docker run -v "${PWD}:/app/chart" \
> --entrypoint bash \
> quay.io/jetbrains/helm-packager:latest -c "readme-generator -v values.yaml -r README.md -s values.schema.json"