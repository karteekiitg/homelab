#!/bin/bash

if [[ -v TF_VAR_infisical_domain ]] && [[ -n "$TF_VAR_infisical_domain" ]] &&
   [[ -v TF_VAR_infisical_client_id ]] && [[ -n "$TF_VAR_infisical_client_id" ]] &&
   [[ -v TF_VAR_infisical_project_id ]] && [[ -n "$TF_VAR_infisical_project_id" ]] &&
   [[ -v TF_VAR_infisical_ro_secrets_path ]] && [[ -n "$TF_VAR_infisical_ro_secrets_path" ]] &&
   [[ -v TF_VAR_infisical_client_secret ]] && [[ -n "$TF_VAR_infisical_client_secret" ]]; then

  export INFISICAL_TOKEN=$(infisical login --method=universal-auth --domain="$TF_VAR_infisical_domain" --client-id="$TF_VAR_infisical_client_id" --client-secret="$TF_VAR_infisical_client_secret" --silent --plain)
  if [ $? -ne 0 ]; then
    echo "Error: Infisical login failed."
    exit 1
  fi

  infisical export --domain="$TF_VAR_infisical_domain" --projectId="$TF_VAR_infisical_project_id" --path="$TF_VAR_infisical_ro_secrets_path" --format=dotenv-export > "$HOME/.infisical_exports.env"
  if [ $? -ne 0 ]; then
    echo "Error: Infisical export failed."
    exit 1
  fi

else
  echo "Error: One or more required Infisical environment variables are not set:"
  if [[ ! -v TF_VAR_infisical_domain ]]; then echo "  - TF_VAR_infisical_domain"; fi
  if [[ ! -v TF_VAR_infisical_client_id ]]; then echo "  - TF_VAR_infisical_client_id"; fi
  if [[ ! -v TF_VAR_infisical_project_id ]]; then echo "  - TF_VAR_infisical_project_id"; fi
  if [[ ! -v TF_VAR_infisical_ro_secrets_path ]]; then echo "  - TF_VAR_infisical_ro_secrets_path"; fi
  if [[ ! -v TF_VAR_infisical_client_secret ]]; then echo "  - TF_VAR_infisical_client_secret"; fi
fi

exit 0
