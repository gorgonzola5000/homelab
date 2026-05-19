### initial configuration
1. tofu apply -var 'use_bootstrap=true'
2. delete the temporary 'terraform-bootstrap' client from keycloak. Use the 'keycloak' account to log in to the master realm
3. in the subsequent runs use 'tofu apply' without the use_bootstrap variable
