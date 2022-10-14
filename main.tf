locals {
  bin_dir  = module.setup_clis.bin_dir
  yaml_dir = "${path.cwd}/.tmp/namespace-${var.name}"
  create_operator_group = var.name != "openshift-operators" && var.create_operator_group
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.create_operator_group}' '${var.argocd_namespace}' '${var.ci}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = var.name
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
    chart_version = "0.2.0"
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-namespace ${self.triggers.name} --serverName ${self.triggers.server_name} --helmRepoUrl https://charts.cloudnativetoolkit.dev --helmChart namespace --helmChartVersion ${self.triggers.chart_version} --valueFiles ${self.triggers.yaml_dir}/values.yaml"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-namespace ${self.triggers.name} --delete --contentDir ${self.triggers.yaml_dir} --serverName ${self.triggers.server_name}"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

