# Traefik Deployment

- Upstream of this branch is https://github.com/edgebus/deployment-docker-swarm/tree/traefik%23main
- How to use [EdgeBus Ops](https://docs.edgebus.io/ops/swarm) for Docker Swarm

![Diagram](docs/diagram.drawio.svg)

## Automated Deploy

To launch automated deploy (via your CI/CD platform) use:

- push a commit (to create a deploy pipeline against `devel` cluster ONLY)
- create a tag (to create deploy pipelines against multiple clusters)

### Tags Format

|                   | Format                                | What to deploy                                               |
| ----------------- | ------------------------------------- | ------------------------------------------------------------ |
| Release Candidate | `traefik[a-z]*-YYYYMMDDhhmmss-rcXxxx` | create deploy pipelines against ALL (except `prod`) clusters |
| Release           | `traefik[a-z]*-YYYYMMDDhhmmss`        | create deploy pipelines against ALL clusters                 |

Examples:

- `traefiksomething-20250503-rc000`
- `traefiksomething-20250503-rc00`
- `traefiksomething-20250503-rc0`
- `traefiksomething-2025050323-rc0`
- `traefiksomething-202505032359-rc0`
- `traefiksomething-20250503235959-rc0`
- `traefiksomething-20250503`
- `traefiksomething-2025050323`
- `traefiksomething-202505032359`
- `traefiksomething-20250503235959`

### Commits

Commits trigger deploy to **devel** cluster ONLY.

## Manual Deploy

1. Prepare secrets
   ```shell
   mkdir .secrets
   ```
1. ```shell
   #
   ```
1. Export deployment variables
   ```shell
   export DEPLOYMENT_CLUSTER="devel"
   export DEPLOYMENT_STACK_NAME="cluster"
   export DEPLOYMENT_COMMIT="$(git rev-parse HEAD)"
   export DEPLOYMENT_JOB_ID="$(hostname -s)-$(date '+%Y%m%d%H%M%S')"
   export DEPLOYMENT_PIPELINE_URL="http://ci.example.org/job/42"
   export DEPLOYMENT_VERSION="$(git rev-parse --short HEAD)"
   ```
1. Generate Docker Stack file
   ```shell
   cat stack.yml.mustache \
   | docker run --interactive --rm \
      --mount "type=bind,source=${PWD}/MANIFEST,target=/tmp/MANIFEST" \
      --mount "type=bind,source=${PWD}/MANIFEST-${DEPLOYMENT_CLUSTER},target=/tmp/MANIFEST-${DEPLOYMENT_CLUSTER}" \
      --env DEPLOYMENT_CLUSTER \
      --env DEPLOYMENT_COMMIT \
      --env DEPLOYMENT_JOB_ID \
      --env DEPLOYMENT_PIPELINE_URL \
      --env DEPLOYMENT_VERSION \
      --env DEPLOYMENT_EXTERNAL_CONFIGS_AND_SECRETS="" \
      theanurin/configuration-templates:20250710 \
         --engine mustache \
         --config-file="/tmp/MANIFEST" \
         --config-file="/tmp/MANIFEST-${DEPLOYMENT_CLUSTER}" \
         --config-env \
   | tee stack.local.yml
   ```
1. Deploy stack
   ```shell
   docker stack deploy --detach=false --compose-file stack.local.yml  "${DEPLOYMENT_STACK_NAME}"
   ```
1. Monitoring
   ```shell
   docker stack ps               "${DEPLOYMENT_STACK_NAME}"                #Lists the tasks that are running as part of the specified stack.
   docker service logs --follow  "${DEPLOYMENT_STACK_NAME}_traefik"      #Used to view the logs of a Docker service in real-time.
   ```

## Setup

1. Commit changes and see for CD pipeline for deployment into `devel` cluster
1. Test Release Candidates to deploy pipelines against ALL (except `prod`) clusters

   2.1 Make tag in format `traefik[a-z]*-rcXX`

   2.2 Start pipeline against the tag in your CI/CD platform
1. Test Release to deploy pipelines against ALL clusters

   3.1 Make tag in format `traefik[a-z]*-YYYYMMDDxx`

   3.2 Start pipeline against the tag in your CI/CD platform
1. Add label to cluster  
   ```shell
   docker node update --label-add "example.org=true" [name of the target Swarm node you are adding the label]
   ```
1. If you want to creare self-sighned sertificate you need to add this to MANIFEST file
   ```shell
   traefik.certificateAuthority.name.common=traefik.example.org
   traefik.certificateAuthority.country=UA
   traefik.certificateAuthority.state=Kyiv
   traefik.certificateAuthority.organization=DemoCA
   traefik.certificateAuthority.organizationUnit=IT
   traefik.certificateAuthority.emailAddress=DemoCA@example.org
   traefik.certificateAuthority.rootDomain=example.org
   ```
