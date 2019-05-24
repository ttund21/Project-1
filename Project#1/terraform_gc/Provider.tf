provider "google" { 
 credentials = "${file("Credencial.json")}"
 project     = "nomedoprojeto"
 region      = "southamerica-east1"
}
