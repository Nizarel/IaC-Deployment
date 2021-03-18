## Terraform Cheat Sheet

# Show version
terraform –version	Shows terraform version installed
 
# Initialize infrastructure
terraform init	Initialize a working directory
terraform init -input=true	Ask for input if necessary
terraform init -lock=false	Disable locking of state files during state-related operations
 
# Get
terraform get	downloads and update modules mentioned in the root module
terraform get -update=true	modules already downloaded will be checked for updates and updated
 
# Provision infrastructure
terraform plan	Creates an execution plan (dry run)
terraform plan -out=path	save generated plan output as a file
terraform plan -destroy	Outputs a destroy plan
terraform apply	Executes changes to the actual environment
terraform apply –auto-approve	Apply changes without being prompted to enter ”yes”
terraform apply -refresh=true	Update the state for each resource prior to planning and applying
terraform apply -input=false	Ask for input for variables if not directly set
terraform apply -var ‘foo=bar’	Set a variable in the Terraform configuration, can be used multiple times
terraform apply -var-file=foo	Specify a file that contains key/value pairs for variable values
terraform apply -target	Only apply/deploy changes to the targeted resource
terraform destroy –auto-approve	Destroy/cleanup without being prompted to enter ”yes”
terraform destroy -target	Only destroy the targeted resource and its dependencies
 
# Terraform Workspaces
terraform workspace new	Create a new workspace and select it
terraform workspace select	Select an existing workspace
terraform workspace list	List the existing workspaces
terraform workspace show	Show the name of the current workspace
terraform workspace delete	Delete an empty workspace
 
# Format and validate Terraform Code
terraform fmt	Format code as per HCL canonical standard
terraform validate	validate configuration files for syntax
 
# Inspect Infrastructure
terraform graph	creates a resource graph listing all resources in your configuration and their dependencies.
terraform output	List all the outputs for the root module
terraform output instance_public_ip	List only the specified output
terraform output -json	List all the outputs in JSON format
terraform show	provide human-readable output from a state or plan file
 
# Terraform Import
terraform import aws_instance.foo i-abcd1234	import an AWS instance with ID i-abcd1234 into aws_instance resource named “foo”
 
# Terraform State Manipulation
terraform state list	list all resources in the state file
terraform state list aws_instance.my_ec2	Only list resource with the given name
terraform state mv	move an item in the state file
terraform state rm	Remove items from the state file
terraform state pull	Pull current state and output to stdout
terraform state push	Update remote state from a local state file
terraform state show aws_instance.my_ec2	Show the attributes of a single resource
terraform state refresh	
 
# Terraform miscellaneous commands
echo “1 + 5” | terraform console	Display expected result of an expression as output
terraform taint aws_instance.my_ec2	marks a Terraform-managed resource as tainted, forcing it to be destroyed and recreated on the next apply
terraform untaint aws_instance.my_ec2	unmarks a Terraform-managed resource as tainted
terraform force-unlock LOCK_ID	removes the lock on the state for the current configuration
terraform login	obtain and save an API token for Terraform Cloud
terraform logout	remove credentials stored by terraform login