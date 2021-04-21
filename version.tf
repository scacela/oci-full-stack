terraform {
  required_version = ">= 0.14"
  required_providers {
        oci = {
            source  = "hashicorp/oci"
            version = ">= 4.2.2"
        }
    }
}