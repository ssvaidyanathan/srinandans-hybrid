helm install vault-sidecar-injector $CHART_LOCATION --set injector.enabled=true --set injector.externalVaultAddr=http://vault.srinandans.internal:8200 --set server.standalone.enabled=false --set server.service.enabled=false --set server.dataStorage.enabled=false --namespace vault --set vault.addr=http://vault.srinandans.internal:8200
