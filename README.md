# oci-full-stack
Deploy and manage a stack with web, app and database tiers, autoscaling, and load balancing in OCI.

### Workshop Prerequisites
- Access to an OCI Tenancy (account)
- (CLI Terraform deployment only) Terraform set up on your local machine. You can access the steps [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm).
- OCI Policies:
<pre>
Allow group GROUPNAME to manage instance-family in compartment COMPARTMENTNAME
Allow group GROUPNAME to manage virtual-network-family in compartment COMPARTMENTNAME
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
<b>List Scope</b>, Select the Compartment where you wish to create the stack.
7. Click <b>Create Stack</b>.
8. On the <b>Stack Information</b> page, under <b>Stack Configuration</b>, browse for and select the this project folder from your local machine.
9. Click <b>Next</b>.
10. On the <b>Configure Variables</b> page, edit the variables that will influence the stack topology according to your preferences.
12. Click <b>Next</b>.
12. On the <b>Review</b> page, review your choices for the stack deployment.
13. Click <b>Create</b>.
14. Click <b>Terraform Actions</b> > <b>Apply,/ > <b>Apply</b>.
15. You can track the logs associated with the job by clicking <b>Jobs</b> > <b>Logs</b>. After the deployment has finished, review the output information at the bottom of the logs for instructions on how to access the nodes in the topology. You can also find outputs at Jobs > Outputs.

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