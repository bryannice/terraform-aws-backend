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

| Environment Variable  | Description                         |
| --------------------- | ----------------------------------- |
| AWS_ACCESS_KEY_ID     | This is the AWS access key.         |
| AWS_DEFAULT_OUTPUT    | Specifies the output format to use. |
| AWS_DEFAULT_REGION    | This is the AWS region.             |
| AWS_SECRET_ACCESS_KEY | This is the AWS secret key.         |

To crate backend execute the following:

```makefile
make \
    AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID> \
    AWS_DEFAULT_OUTPUT=<AWS_DEFAULT_OUTPUT> \
    AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION> \
    AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY> \
    build
```

## License

[Apache 2](LICENSE)
