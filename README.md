# terraform-aws-backend

![Terraform](assets/terraform-icon.png)

This repo is a pattern to create the necessary components for instantiating an AWS backend.

The makefile holds the automation logic to create the infrastructure.

For your convenience, we provide a Docker-based Terraform instance, and associated Terraform modules, for provisioning your AWS Backend instance. All components of this repo utilize semantic versioning to provide transparency, auditability, as well as improve reproducibility.

Your AWS Backend will enable you to maintain state files associated with your application deployment; leveraging a combination of both Amazon S3 storage and Amazon DynamoDB.

## Terraform Environment

Execute the command below create an environment to interact with the Terraform Command Line Interface (Terraform CLI).

```makefile
make cli
```

## Make Targets to Provision (aka "create") or Deprovision (aka "destroy") Your AWS Backend

Below are the main make targets for provisioning and deprovisioning infrastructure.

There are other make targets and to see them, open the makefile.

Before executing make targets within the Terraform container, these environment variables must be set.

You will customize these variables based upon attributes specific to your own AWS developer account configuration. Be sure you've security hardened your AWS account, and you are using non-root IAM AWS credentials for implementing your AWS Backend.

| Environment Variable  | Required | Description                                                                          |
| --------------------- | ---------| ------------------------------------------------------------------------------------ |
| AWS_ACCESS_KEY_ID     | Y        | This is the AWS access key.                                                          |
| AWS_DEFAULT_OUTPUT    | Y        | Specifies the output format to use.                                                  |
| AWS_DEFAULT_REGION    | Y        | This is the AWS region.                                                              |
| AWS_SECRET_ACCESS_KEY | Y        | This is the AWS secret key.                                                          |
| S3_BUCKET_NAME        | N        | Name of the bucket to create (defaults to <GIT_ACCOUNT_NAME>-<GIT_REPOSITORY_NAME>). |

To create backend using a container to execute the following:

```makefile
make \
    AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
    AWS_DEFAULT_OUTPUT=<AWS_DEFAULT_OUTPUT> \
    AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION> \
    AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
    S3_BUCKET_NAME=<S3_BUCKET_NAME> \
    provision
```

To destroy backend using a container to execute the following:

```makefile
make \
    AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
    AWS_DEFAULT_OUTPUT=<AWS_DEFAULT_OUTPUT> \
    AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION> \
    AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
    S3_BUCKET_NAME=<S3_BUCKET_NAME> \
    deprovision
```

## main.tf Provides Links to Pinned Semantic Versions

This pattern is designed to be re-usable and extensible. For your convenience as well as reliability and stability, we have pinned this repository to a specific version of Terraform as well as two other repositories we have published.

```makefile
terraform {
  required_version = ">= 0.14"
}
```

Feel free to use our provided repositories or modify as you desire. All of these linkages are specified in main.tf. Please note the Semantic Version pinning for this repository version via "?ref=1.1.0".

```makefile
module "backend_s3_bucket" {
  bucket        = var.bucket
  enabled       = true
  force_destroy = true
  source        = "github.com/bryannice/terraform-aws-module-s3-bucket//?ref=1.1.0"
  sse_algorithm = "AES256"
}
```

## References

### Terraform and Amazon Web Services

* [How to Manage Terraform State](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa)
* [State Management with Terraform](https://medium.com/@mitesh_shamra/state-management-with-terraform-9f13497e54cf)
* [How to: Terraform Locking State in S3](https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6)
* [How to Create Reusable Infrastructure with Terraform Modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
* [Terraform: Beyond the Basics with AWS](https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/)
* [Terraform Tips & Tricks: Loops, If Statements, and Gotchas](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)
* [AWS Service Endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html)
* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)

### Semantic Versioning

* [Semantic Versioning 2.0.0](https://semver.org/)
* [Introduction to Semantic Versioning](https://www.geeksforgeeks.org/introduction-semantic-versioning/)

## License

[GPLv3](LICENSE)
