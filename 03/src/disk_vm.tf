resource "yandex_compute_disk" "disks" {
  name  = "disk-${count.index}"
  count = 3
  size  = 1
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = "network-hdd"
      size     = 5
    }
  }

  dynamic "secondary_disk" {
    for_each = disks.yandex_compute_disk.*
    content {
      disk_id = data.yandex_compute_disk.disks.id
    }

  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  allow_stopping_for_update = true
}
