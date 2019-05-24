resource "google_compute_project_metadata_item" "user" {
 key   = "ssh-keys"
 value = "User:${file("~/.ssh/id_rsa.pub")}" 
}
