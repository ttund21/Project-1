resource "google_compute_firewall" "firewall" {
  name    = "allowhttp"
  network = "default"
  
  allow {
   protocol = "tcp"
   ports    = ["80"]
  }
}