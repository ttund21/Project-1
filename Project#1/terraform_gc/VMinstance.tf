resource "google_compute_instance" "ProjetoTerraform" {
 name         = "projterra-vm-1"
 machine_type = "f1-micro"
 zone         = "southamerica-east1-b"

 boot_disk {
  initialize_params {
   image = "debian-cloud/debian-9"
  }
 }

 network_interface {
  network   = "default"
  access_config {
  }
 }
}