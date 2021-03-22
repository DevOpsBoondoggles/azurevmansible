# azurevmansible

A terraform file that creates a vm then uses the custom script extension to run powershell from a remote repo. 
This enables the winrm requirements for ansible dev testing.
Along with some sample playbooks and an Azure DevOps pipeline file to deploy them.
The Terraform file will need a Backend added if it's all in Azure for state.

There's also a packer file and terraform for custom image which doesn't appear to work very well but might be a useful start for people.  
