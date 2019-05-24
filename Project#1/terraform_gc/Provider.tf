provider "google" { 
 credentials = "${file("Credencial.json")}"
 project     = "projetoterraform"
 region      = "southamerica-east1"
}