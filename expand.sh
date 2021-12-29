#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# initalize variables
source vars.sh

# step 1. install cert manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.2 --set installCRDs=true --set nodeSelector."cloud\.google\.com/gke-nodepool"=apigee-runtime

# step 2: install asm
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.12 > asmcli

chmod +x asmcli

./asmcli install \
  --project_id ${PROJECT_ID} \
  --cluster_name ${CLUSTER_NAME} \
  --cluster_location ${CLUSTER_REGION} \
  --fleet_id ${PROJECT_ID} \
  --enable_all --option legacy-default-ingressgateway \
  --ca mesh_ca

# step 3: Create Apigee CA
kubectl create secret tls apigee-ca -n cert-manager --cert=tls.crt --key=tls.key

# step 4: install crds
kubectl create -f cluster/crds

# step 5: create cluster resources
kubectl apply -f cluster

# step 6: install apigee controller. Controller kustomize scripts were already created.
kubectl apply -k overlays/controller

# step 7: Generate kustomize for expnding Cassandra
./generateMultiRegionKustomize.sh

# step 8: install apigee runtime instance (datastore, telemetry, redis and org)
kubectl apply -k overlays/${INSTANCE_ID}

# step 9: install the apigee environment
kubectl apply -k overlays/${INSTANCE_ID}/environments/${ENV_NAME}
