locals {
  bin_dir  = module.setup_clis.bin_dir
  yaml_dir = "${path.cwd}/.tmp/namespace-${var.name}"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}'"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-namespace ${var.name} --contentDir ${local.yaml_dir} --serverName ${var.server_name}"

    environment = {
      GIT_CREDENTIALS = nonsensitive(yamlencode(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

module "ci_config" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ci-namespace.git?ref=v1.4.3"
  depends_on = [null_resource.setup_gitops]

  gitops_config   = var.gitops_config
  git_credentials = var.git_credentials
  namespace       = var.name
  provision       = var.ci
  server_name     = var.server_name
}
