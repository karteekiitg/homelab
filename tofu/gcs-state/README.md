## Instructions

1. Setup [gcloud cli](/DEVCONTAINER.md).
1. Setup TF_VAR_tofu_encryption_passphrase as per instruction below and save them to infisical.
1. Setup TF_VAR_gcp_sa_dev_emails = ["email1@example.com","email2@example.com"] (emails you want to grant access to) below and save them to infisical.
1. Setup .env file in root folder and commit it to git.
1. Follow devcontainers docs [here](/DEVCONTAINER.md). If done properly, all secrets from infisical will be available in the container environment.

```shell
# TF_VAR_tofu_encryption_passphrase generation command
openssl rand -base64 32
```

```shell
# Initialize tofu
tofu init
```

```shell
# Run tofu apply to create GCS bucket and permissions
tofu apply
```

```shell
# Copy GCS backend file
cp samples/backend_gcs.tofu.sample ./backend.tofu
```

```shell
# Re-initialize tofu to migrate state to GCS backend
tofu init -migrate-state -backend-config="prefix=gcs-state/$(git rev-parse --abbrev-ref HEAD)"
```
