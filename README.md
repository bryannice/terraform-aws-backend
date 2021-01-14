# terraform-aws-backend

![Terraform](assets/terraform-icon.png)

This repo is a pattern to create the necessary components an AWS backend. 

The makefile holds the automation logic to create the infrastructure.



## Terraform Environment

Execute the command below create an environment to interact with the Terraform Command Line Interface (Terraform CLI).

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

## References

* [How to manage Terraform state](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa)
* [State Management with Terraform](https://medium.com/@mitesh_shamra/state-management-with-terraform-9f13497e54cf)
* [How to: Terraform Locking State in S3](https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6)
* [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
* [Terraform: Beyond the Basics with AWS](https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/)
* [Terraform tips & tricks: loops, if statements, and gotchas](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)
* [AWS Service Endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html)
* [Terraform CLI](https://www.terraform.io/docs/cli-index.html)


## License

[Apache 2](LICENSE)
