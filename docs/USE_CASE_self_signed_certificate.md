# Use Case - With self signed certificate

1. Create `MANIFEST-demo` file for you demo-cluster
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
   cat stack.yml.mustache \
    | docker run --interactive --rm \
        --mount "type=bind,source=${PWD}/MANIFEST,target=/tmp/MANIFEST" \
        --mount "type=bind,source=${PWD}/MANIFEST-demo,target=/tmp/MANIFEST-demo" \
        --env DEPLOYMENT_CLUSTER="demo" \
        --env DEPLOYMENT_COMMIT="0000000000000000000000000000000000000000" \
        --env DEPLOYMENT_JOB_ID="$(hostname -s)-$(date '+%Y%m%d%H%M%S')" \
        --env DEPLOYMENT_PIPELINE_URL="http://ci.example.org/job/42" \
        --env DEPLOYMENT_VERSION="00000000" \
        --env DEPLOYMENT_EXTERNAL_CONFIGS_AND_SECRETS="" \
        theanurin/configuration-templates:20250710 \
            --engine mustache \
            --config-file="/tmp/MANIFEST" \
            --config-file="/tmp/MANIFEST-demo" \
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
