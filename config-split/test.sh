rm -f apisix.yaml

docker run \
-v $(pwd)/base/config.yaml:/input/config/01-base.yaml \
-v $(pwd)/base/tls.crt:/input/certificates/vitaservicesdev/tls.crt \
-v $(pwd)/base/tls.key:/input/certificates/vitaservicesdev/tls.key \
-v $(pwd)/tenants/aokrps/config.yaml:/input/config/02-aokrps.yaml \
-v $(pwd)/tenants/aokrps/tls.crt:/input/certificates/aokrps/tls.crt \
-v $(pwd)/tenants/aokrps/tls.key:/input/certificates/aokrps/tls.key \
-v $(pwd)/tenants/kvb/config.yaml:/input/config/03-kvb.yaml \
-v $(pwd)/tenants/kvb/tls.crt:/input/certificates/kvb/tls.crt \
-v $(pwd)/tenants/kvb/tls.key:/input/certificates/kvb/tls.key \
-v $(pwd)/tenants/kvbw/config.yaml:/input/config/04-kvbw.yaml \
-v $(pwd)/tenants/kvbw/tls.crt:/input/certificates/kvbw/tls.crt \
-v $(pwd)/tenants/kvbw/tls.key:/input/certificates/kvbw/tls.key \
-v $(pwd)/tenants/kvno/config.yaml:/input/config/05-kvno.yaml \
-v $(pwd)/tenants/kvno/tls.crt:/input/certificates/kvno/tls.crt \
-v $(pwd)/tenants/kvno/tls.key:/input/certificates/kvno/tls.key \
-v $(pwd):/apisix-config \
chrb0/apisix-reload-sidecar:test