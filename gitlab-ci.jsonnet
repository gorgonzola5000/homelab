local branch = 'feature/flux-d2-architecture';

local clusters = [
  'starfruit6000/homelab:meddle',
  'starfruit6000/homelab:meddle-local',
  'starfruit6000/homelab:animals',
  'starfruit6000/homelab:animals-local'
];

local makeComp(repo, name, ns=null) = {
  name: name,
  repo: repo,
  path: if repo == 'fleet' then 'kubernetes/fleet' else 'kubernetes/' + repo + '/components/' + name,
  reg_path: if repo == 'fleet' then 'fleet' else repo + '/' + name,
  ns: if ns != null then ns else name,
};

local components = {
  fleet: [
    makeComp('fleet', 'fleet', ns='flux-system')
  ],
  infra: [
    makeComp('infra', 'cert-manager'),
    makeComp('infra', 'openebs'),
    makeComp('infra', 'envoy-gateway-system'),
    makeComp('infra', 'cnpg-system'),
    makeComp('infra', 'external-dns'),
    makeComp('infra', 'external-secrets'),
    makeComp('infra', 'keycloak'),
    makeComp('infra', 'alloy'),
    makeComp('infra', 'node-feature-discovery'),
    makeComp('infra', 'inteldeviceplugins-system'),
    makeComp('infra', 'rbac'),
    makeComp('infra', 'gitlab-agent')
  ],
  apps: [
    makeComp('apps', 'arr'),
    makeComp('apps', 'seerr'),
    makeComp('apps', 'redmanager')
  ]
};

local generateBuildJob(comp) = {
  stage: 'build-artifact',
  rules: [
    {
      changes: [
        comp.path + '/**/*',
        comp.path + '/*'
      ]
    }
  ],
  trigger: {
    strategy: 'depend',
    forward: { pipeline_variables: true },
    include: [
      {
        component: '$CI_SERVER_FQDN/starfruit6000/fluxcd/oci-artifact@0.5.0',
        inputs: {
          as: 'build-' + comp.name,
          stage: 'build',
          version: '0.5.0',
          registry_image_url: 'oci://$CI_REGISTRY_IMAGE/' + comp.reg_path,
          manifest_path: comp.path,
          image_tag: 'latest',
          skip_reconcile: true,
          job_image_name: '$CI_REGISTRY/starfruit6000/fluxcd/fluxcd', // needed for forks
        }
      }
    ]
  }
};

local generateReconcileJob(comp) = {
  stage: 'reconcile-clusters',
  needs: ['build-trigger-' + comp.name], 
  allow_failure: true,
  rules: [
    {
      changes: [
        comp.path + '/**/*',
        comp.path + '/*'
      ]
    }
  ],
  parallel: {
    matrix: [ { TARGET_AGENT: clusters } ]
  },
  trigger: {
    strategy: 'depend',
    forward: { pipeline_variables: true },
    include: [
      {
        component: '$CI_SERVER_FQDN/starfruit6000/fluxcd/reconcile@0.5.0',
        inputs: {
          as: 'reconcile-' + comp.name,
          stage: 'build',
          version: '0.5.0',
          flux_source_type: 'oci',
          flux_source_name: comp.repo,
          flux_source_namespace: comp.ns,
          kubernetes_agent_reference: '$TARGET_AGENT',
          job_image_name: '$CI_REGISTRY/starfruit6000/fluxcd/fluxcd', // needed for forks
        }
      }
    ]
  }
};

local all_components = components.fleet + components.infra + components.apps;

{
  stages: ['setup', 'build-artifact', 'reconcile-clusters'],
  
  'pipeline-init': {
    stage: 'setup',
    image: 'alpine:latest',
    script: [
      'echo "Dynamic pipeline generated successfully!"',
      'echo "If no other jobs are running, it means no application files were modified in this commit."'
    ]
  }
}
+ {
  ['build-trigger-' + comp.name]: generateBuildJob(comp) for comp in all_components
}
+ {
  ['reconcile-trigger-' + comp.name]: generateReconcileJob(comp) for comp in all_components
}
