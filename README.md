# About

Example Infrastructure as Code repository.

Companion repositories are:
- [example-api](https://github.com/kohanyirobert/example-api)
- [example-web](https://github.com/kohanyirobert/example-web)

This repository is set up to deploy a multi-tier application (web => api => db) into AWS.

## Requirements

- Locally installed Terraform, AWS, GitHub and [Graphviz](https://graphviz.org/) CLI tools
- Access to an AWS account
- Hosted zone/domain registered in AWS Route 53
- Configuration in place
- Forking *this* GitHub repository to get admin access for GitHub Actions

Note: Graphviz is optional, but generating it's a nice addition to `terraform graph`, e.g.

```
terraform graph | dot -Tsvg -o infra.svg
start infra.svg
```

## Usage

### Phase 1

For running Terraform locally.

- Fork the repository
- Copy [`terraform.tfvars.sample`](terraform.tfvars.sample) to `terraform.tfvars` (ignored by `.gitignore`)
- Change the values in the file accordingly (see `variables.tf` for reference)
- **Before running `terraform init` comment out the `backend` block in `main.tf`**
- Run `terraform init` (using `local` backend)
- Run `terraform apply`
- Approve and wait for things to finish and settle
- See whether `http://web.<yoursubdomain>.<yourdomain>.<yourtld>` loads and works (no errors)
- Copy [`config.s3.tfbackend.sample`](config.s3.tfbackend.sample) to `config.s3.tfbackend` (ignored by `.gitignore`)
- Change the values in the file accordingly (refer to what is set in [`backend.tf`](backend.tf))
- Run `terraform init -backend-config=config.s3.tfbackend`
- This will push the local Terraform state to S3

### Phase 2

For running Terraform in GitHub Actions.

- Set the following secret variables in GitHub Actions
  - `AWS_REGION`
  - `AWS_DEFAULT_REGION` - this might not actually be needed (previous one should be enough)
  - `AWS_ROLE_TO_ASSUME` - set to `GitHubActionsTerraformAutomationRole` (actually since this is defined in [`oicd.tf`](oicd.tf) this doesn't need to be a secret)
  - `PASSPHRASE` - used by the [`tf-via-pr`](https://github.com/DevSecTop/TF-via-PR) GitHub Action to encrypt Terraform plans
  - `TF_BACKEND_BUCKET`
  - `TF_BACKEND_DYNAMO_TABLE`
  - `TF_BACKEND_KEY`
  - `TF_BACKEND_REGION`
- Copy [`github-actions-secrets.env.sample`](github-actions-secrets.env.sample) to `github-actions-secrets.env` (ignored by `.gitignore`)
- Change the values in the file accordingly (same settings as in `terraform.tfvars`)
- Run `gh auth login`
- Run `gh secret set -f github-actions-secrets.env` (this can be done manually as well, but it's easier like this)

### Phase 3

- Change infra via editing `.tf` files or tweaking parameters, etc.
- **Create feature branch and commit changes to Git**
- Push feature branch/changes to GitHub
- Open a PR
- Terraform plan automatically runs on GitHub Actions, if there are no error the branch can be merged to main
- Once merged GitHub Actions runs on the main branch and runs `terraform apply` making the infra to change

Note: when the `api` or `web` images deployed to the infra change related Terraform variables need to be updated manually.

## TODO

- It seems that the `db` insteance gets recreated a lot when it doesn't need to because there are some weird dependencies somewhere...
- Move variables all into `github-actions-secrets.env` for ease of use
- Make `AWS_ROLE_TO_ASSUME` not a secret or parameterize role name in `.tf` config
- Set `TF_BACKEND_*` variables with GitHub CLI as well

## Other

- [Other way to pass `-backend-config` parameters](https://developer.hashicorp.com/terraform/language/backend#command-line-key-value-pairs) (see [`terraform.yml`](.github/workflows/terraform.yml) how it's done with the `tf-via-pr` action)
- [Info on OIDC thumbprint](https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#configuring-iam-to-trust-github) when authenticating against AWS from GitHub Actions via roles
- Guides on how to connect GitHub Actions and AWS, [here](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services), [here](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) and [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub)
