# oci-full-stack
Deploy and manage a stack with web, app and database tiers in OCI. Optional autoscaling configuration, and load balancing for each tier, and optional shared file storage.

### What does the stack provision?
1. An optional Compute layer, which provisions Instance Pools that generate Compute Instances that comprise the compute tiers. Each compute tier is provisioned within its own corresponding subnet. The compute tiers are:
	a. The <b>Web</b> tier. This tier <b>uses</b> public IP addresses.
	b. The <b>App</b> tier. This tier <b>uses</b> public IP addresses.
	c. The <b>Database</b> tier. This compute tier <b>prohibits</b> Public IP addresses.
2. An optional Load Balancer layer, which provisions resources that comprise the load balancer tiers. Each load balancer tier is provisioned within its own corresponding subnet. The load balancer tiers are:
	a. The <b>Load Balancer for Web</b> tier. This tier <b>uses<b> public IP addresses.
	b. The <b>Load Balancer for App</b> tier. This tier <b>prohibits</b> public IP addresses.
Each load balancer tier load balances a corresponding compute tier by associating with its respective instance pool.
3. A Network layer, which provisions a subnet for each compute tier and for each load balancer tier within a single VCN. The subnets are provisioned with security lists and route tables, and the VCN is provisioned with an internet gateway and optional NAT Gateway and optional Service Gateway. Security list rules and gateway access via route rules are assigned to each subnet based on whether the subnet allows or prohibits public IP addresses.
4. An optional Autoscaling Configuration layer, which provisions an Autoscaling Configuration for each compute tier that associates with its respective instance pool. The threshold-based metric that triggers the autoscaling action is CPU Utilization.
5. An optional File Storage layer. This layer provisions File Storage Service resources within a designated subnet that is also provisioned as part of this layer. The subnet <b>prohibits</b> public IP addresses.
	b. Instances that are generated as part of the instance pool optionally connect to file storage service, with File Storage Service resources in its own private subnet.
6. An optional Bastion layer, for accessibility into the stack. This layer provisions a Compute Instance with a public IP address to serve as a bastion node, within a designated subnet that is also provisioned as part of this layer. The bastion node has a public IP address.
7. A new SSH key pair for accessing all Compute Instances in the stack.

### Prerequisites
- Access to an OCI Tenancy (account)
- (CLI Terraform deployment only) Terraform set up on your local machine. You can access the steps [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm).
- Sample OCI Policies:
<pre>

# includes instances, instance-images
<b>Allow group GROUPNAME to manage instance-family in compartment COMPARTMENTNAME</b>

# includes instance-configurations, instance-pools
<b>Allow group GROUPNAME to manage compute-management-family in compartment COMPARTMENTNAME</b>

# includes autoscaling configuration
<b>Allow group GROUPNAME to manage auto-scaling-configurations in compartment COMPARTMENTNAME</b>

# includes vcns, subnets, route-tables, security-lists, private-ips, public-ips, internet-gateways, nat-gateways, service-gateways
<b>Allow group GROUPNAME to manage virtual-network-family in compartment COMPARTMENTNAME</b>

# includes load-balancers
<b>Allow group GROUPNAME to manage load-balancers in compartment COMPARTMENTNAME</b>

# includes file-systems, mount-targets, export-sets
<b>Allow group GROUPNAME to manage file-family in compartment COMPARTMENTNAME</b>
</pre>
- Sufficient availability of resources. You can check resource availability:
<pre>
Hamburger Menu &gt Governance &gt Limits, Quotas and Usage
</pre>

### Deployment via Resource Manager
##### Recommended for first time users of this project. The 'Configure Variables' page in Resource Manager helps users provide valid input.
1. [Download this project](https://github.com/scacela/oci-full-stack/archive/refs/heads/main.zip) to your local machine.
2. Navigate to [cloud.oracle.com](https://cloud.oracle.com/) on a web browser.
3. Sign into OCI.
4. Click the hamburger icon.
5. Hover over <b>Resource Manager</b> from the dropdown menu, and click <b>Stacks</b>.
6. Under <b>List Scope</b>, Select the Compartment where you wish to create the stack.
7. Click <b>Create Stack</b>.
8. On the <b>Stack Information</b> page, under <b>Stack Configuration</b>, browse for and select the this project folder from your local machine.
9. Click <b>Next</b>.
10. On the <b>Configure Variables</b> page, edit the variables that will influence the stack topology according to your preferences.
12. Click <b>Next</b>.
12. On the <b>Review</b> page, review your choices for the stack deployment.
13. Click <b>Create</b>.
14. Click <b>Terraform Actions</b> > <b>Apply</b> > <b>Apply</b>.
15. You can track the logs associated with the job by clicking <b>Jobs</b> > <b>Logs</b>. After the deployment has finished, review the output information at the bottom of the logs for instructions on how to access the nodes in the topology. You can also find outputs at <b>Jobs</b> > <b>Outputs</b>.

### Deployment via CLI Terraform


1. [Download this project](https://github.com/scacela/oci-full-stack/archive/refs/heads/main.zip) to your local machine.
2. [Set up CLI Terraform on your local machine.](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm) 
3. Navigate to project folder on your local machine via CLI.
<pre>
cd YOUR_PATH_TO_THIS_PROJECT
</pre>
4. Open <b>env.sh</b> and edit the variables of prefix <b>TF_VAR_</b>, which will influence the stack topology according to your preferences.
<pre>
vi env.sh
</pre>
5. Export the <b>TF_VAR_</b> variables to the environment of the CLI instance.
<pre>
source env.sh
</pre>
6. Initialize your Terraform project, downloading necessary packages for the deployment.
<pre>
terraform init
</pre>
7. View the plan of the Terraform deployment, and confirm that the changes described in the plan reflect the changes you wish to make in your OCI environment.
<pre>
terraform plan
</pre>
8. Apply the changes described in the plan, and answer yes when prompted for confirmation.
<pre>
terraform apply
</pre>
9. You can track the logs associated with the job by monitoring the output on the CLI. After the deployment has finished, review the output information at the bottom of the logs for instructions on how to access the nodes in the topology.