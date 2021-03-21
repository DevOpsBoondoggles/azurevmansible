#   resource "null_resource" "Azurediskinitialization_5" {
#    provisioner "local-exec" {
#          command = "az vm extension set --resource-group web-rg  --vm-name rakdbserver01 --name CustomScriptExtension --publisher Microsoft.Compute --settings jj.json --version 1.9"

#                  }
#   }