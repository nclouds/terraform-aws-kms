# Contributing

When contributing to this repository, please first create a new issue.

There are a few tools that if you have them [installed](INSTALL.md) on your machine will help with the complete [workflow](WORKFLOW.md) we follow.

## Pull Request Process

1. Add [semantic prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
2. Update the README.md with any changes to new variables, ports or other needed information to use the new feature. `terraform_docs` hook will help with updating the module variables automatically.
3. Do not update the CHANGELOG file. The maintainers of the project will take care of this when they [release](RELEASE.md) a new version of the module.
4. Add a reviewer to your PR and wait for feedback and one approval before being able to merge your change.
5. Make sure the Github Actions are completed successfully.
6. Once your changes are approved and all checks are successful you should be able to merge in your changes (squashing is recommended). Merged PRs will be included in the next release.

## Semantic Pull Requests

To generate the changelog, Pull Requests or Commits must have semantic and must follow conventional specs below:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation and examples
- `style:` changes that do not affect the meaning of the code (white-space, formatting, etc.)

## Terraform specifics

* Modules must include the `identifier` variable:
```
variable "identifier" {
  description = "For resource names"
  type        = string
}
```
* Modules must include the `append_workspace` variable:
```
variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}
```
This setting goes together with the `identifier` variable, to use it a local must be declared like this:
```
locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
}
```
All resource names must use `local.identifier` to name resources
* Modules must include the following `tags` variable:
```
variable "tags" {
    description = "Tags to be applied to the resource"
    default     = {}
    type        = map(any)
}
```
We enforce two tags across all resources `Environment` and `Name`. These tags have to be configured like this:
```
locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier

  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}
```
And all resources that support it must be tagged with it like so:
```
resource "aws_security_group" "default" {
    description = var.description
    vpc_id      = var.vpc_id
    name        = local.identifier

    tags        = local.tags <------- always at the bottom
}
```

* If a resource includes a `count` or a `for_each` directive it must be at the top of that resource’s attributes followed by a blank line:
```
resource "aws_security_group_rule" "default_ingress_rules" {
  count             = length(var.ingress_rule_list) <---- always at the top

  security_group_id = aws_security_group.default.id
  ...
```
* Variable names must be in lowercase [snake_case](https://en.wikipedia.org/wiki/Snake_case)
* Resource names must be in lowercase [kebab-case](https://en.wiktionary.org/wiki/kebab_case)
* All modules should generate a single output called `output` as an object that includes every relevant resource that was created as part of the module. For example:
```
output "output" {
    value = {
      log_group = aws_cloudwatch_log_group.function_logs
      function  = aws_lambda_function.function
    }
}
```
* Resource and module attributes should always be ordered from longest to shortest like this:

Resources:
```
resource "aws_vpc" "vpc" {
  enable_dns_hostnames = var.vpc_settings["dns_hostnames"]
  enable_dns_support   = var.vpc_settings["dns_support"]
  instance_tenancy     = var.vpc_settings["tenancy"]
  cidr_block           = var.vpc_settings["cidr"]
  tags                 = local.tags
}
```
Modules:
```
module "vpc" {
  source  = "app.terraform.io/ncodelibrary/vpc/aws"
  version = "0.1.2"

  kubernetes_tagging = true
  multi_nat_gw       = local.config.multi_nat_gw
  vpc_settings       = local.config.vpc_settings
  identifier         = local.config.identifier
  region             = local.config.region
  tags               = local.config.tags
}
```
