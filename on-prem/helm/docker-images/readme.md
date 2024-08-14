# Migrating Docker Images to a Private Registry

When deploying applications in environments without access to Docker Hub, you might need to transfer Docker images to a private registry. This section details the process of automating this migration using a Makefile.

## Setting Up for Migration

The Makefile uses two key variables to manage the migration process:

1. **TARGET_REPO**: Defines the destination repository. Update this in the `Makefile` to specify where the images will be moved.
2. **IMAGES**: Lists the Docker images to be transferred. This list is sourced from `images.list`, containing IOMETE Docker images present in the public Docker Hub.

The Makefile automates the transfer of each image through the following steps:

- **Pulling:** Retrieves the image from IOMETE's public Docker Hub registry.
- **Tagging:** Assigns a new tag to the image, incorporating the target repository's address.
- **Pushing:** Uploads the image to your specified target repository.

## Executing the Migration

Before initiating the migration, ensure you're authenticated with your private Docker registry. This authentication is crucial for pushing images to the target repository.

To start the migration, execute the Makefile with the following command in your terminal:

```shell
make
```

This command triggers the Makefile to loop through each image in the `IMAGES` list, applying the pull, tag, and push operations to migrate them to your specified private registry.

By completing these steps, you'll successfully relocate the necessary Docker images from the public IOMETE registry to your own private registry, ensuring your environment has the required resources for deployment.