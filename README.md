# terraform-aws-backend

![Terraform](assets/terraform-icon.png)

This repo is the a pattern to create the necessary components an AWS backend. The makefile holds the automation logic to create the infrastructure.

## Terraform Environment

Execute the command below to build the docker image that will be used for the Terraform environment.

```makefile
make docker-build
```

Execute the command below to spawn a container and ssh into it to be in the Terraform environment.

```makefile
make cli \ 
    AWS_ACCESS_KEY_ID=<This is the AWS access key.> \
    AWS_SECRET_ACCESS_KEY=<This is the AWS secret key.> \
    AWS_DEFAULT_REGION=<This is the AWS region.>
```

## Make Targets to Create or Destroy Backend

Below are the main make targets for creating and destroying infrastructure. There are other make targets and to see them, open the makefile. Before executing make targets within the Terraform container, these environment variables must be set.

| Environment Variable | Description |
| -------------------- | ----------- |
| AWS_ACCESS_KEY_ID | This is the AWS access key. |
| AWS_SECRET_ACCESS_KEY | This is the AWS secret key. |
| AWS_DEFAULT_REGION | This is the AWS region. |

To crate backend execute the following:

```makefile
make backend
```

To destroy backend execute the following:

```makefile
make destroy
```

## License

[Apache 2](LICENSE)
