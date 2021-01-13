# terraform-aws-backend

![Terraform](assets/terraform-icon.png)

This repo is the a pattern to create the necessary components an AWS backend. The makefile holds the automation logic to create the infrastructure.

## Terraform Environment

Execute the command below create an environment to interact with the Terraform cli.

```makefile
make cli
```

## Make Targets to Create or Destroy Backend

Below are the main make targets for creating and destroying infrastructure. There are other make targets and to see them, open the makefile. Before executing make targets within the Terraform container, these environment variables must be set.

| Environment Variable  | Required | Description                                                                          |
| --------------------- | ---------| ------------------------------------------------------------------------------------ |
| AWS_ACCESS_KEY_ID     | Y        | This is the AWS access key.                                                          |
| AWS_DEFAULT_OUTPUT    | Y        | Specifies the output format to use.                                                  |
| AWS_DEFAULT_REGION    | Y        | This is the AWS region.                                                              |
| AWS_SECRET_ACCESS_KEY | Y        | This is the AWS secret key.                                                          |
| S3_BUCKET_NAME        | N        | Name of the bucket to create (defualts to <GIT_ACCOUNT_NAME>-<GIT_REPOSITORY_NAME>). |

To crate backend using a container to execute the following:

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

## References

* [How to manage Terraform state](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa)
* [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
* [Terraform: Beyond the Basics with AWS](https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/)
* [Terraform tips & tricks: loops, if statements, and gotchas](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)
* [AWS Service Endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html)

## License

[Apache 2](LICENSE)
