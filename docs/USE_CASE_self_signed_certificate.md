# Use Case - With self signed certificate

1. Create `MANIFEST-demo-self-ca` file for you demo-cluster
   ```text
   #
   # Override values of MANIFEST for demo cluster
   #
   traefik.placement_constraint.0=mydomain

   traefik.entryPoints.websecure.port=443
   traefik.entryPoints.websecure.protocol=tcp

   traefik.certificateAuthority.name.common=traefik.maintenance.mydomain
   traefik.certificateAuthority.country=UA
   traefik.certificateAuthority.state=Kyiv
   traefik.certificateAuthority.organization=DemoCA
   traefik.certificateAuthority.organizationUnit=IT
   traefik.certificateAuthority.emailAddress=DemoCA@mydomain
   traefik.certificateAuthority.rootDomain=maintenance.mydomain
   ```
1. Generate `stack.yaml`
   ```shell
   cat stack.yml.liquid \
    | docker run --interactive --rm \
        --mount "type=bind,source=${PWD}/MANIFEST,target=/tmp/MANIFEST" \
        --mount "type=bind,source=${PWD}/MANIFEST-demo-self-ca,target=/tmp/MANIFEST-demo-self-ca" \
        --env DEPLOYMENT_CLUSTER="demo" \
        --env DEPLOYMENT_COMMIT="0000000000000000000000000000000000000000" \
        --env DEPLOYMENT_JOB_ID="$(hostname -s)-$(date '+%Y%m%d%H%M%S')" \
        --env DEPLOYMENT_PIPELINE_URL="http://ci.example.org/job/42" \
        --env DEPLOYMENT_VERSION="00000000" \
        --env DEPLOYMENT_EXTERNAL_CONFIGS_AND_SECRETS="" \
        theanurin/configuration-templates:20251014 \
            --engine liquid \
            --config-file="/tmp/MANIFEST" \
            --config-file="/tmp/MANIFEST-demo-self-ca" \
            --config-env \
    | tee stack.yml
   ```
1. Deploy stack to you demo cluster (use name: `maintenance` for stack)
   ```shell
   docker stack deploy --detach=false --compose-file "stack.yml" "maintenance"
   ```
1. Ensure you cluster has necessary labels
   ```shell
   docker node update --label-add "io.edgebus.ops=true" --label-add "mydomain=true" your_node_name
   ```
1. Ensure Traefik container started
   ```shell
   docker service ps       maintenance_traefik
   docker service inspect  maintenance_traefik
   docker service logs     maintenance_traefik
   ```
1. Download CA certificate and install into trusted storage
   ```shell
   docker ps
   docker cp maintenance_traefik.xxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxx:/traefik-data/ca.crt -
   ```
1. Add records in your `/etc/hosts`
   ```text
   127.0.0.1 traefik.maintenance.mydomain
   ```
1. Open browser at https://traefik.maintenance.mydomain:443 (SSL connection must be GREEN/trusted)
