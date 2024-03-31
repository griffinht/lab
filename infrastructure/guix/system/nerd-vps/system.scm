(use-modules (gnu packages ssh)
             (gnu packages certs)
             (gnu packages admin)
             (gnu packages containers)
             (gnu services ssh)
             (gnu services docker)
             (gnu services monitoring)
             (guix gexp)
             (griffinht system))

(define ssh-pubkey
  (local-file "../cool-laptop.pub"))

(operating-system
  (host-name "nerd-vps")
  (bootloader %vm-bootloader)
  (file-systems %vm-file-systems)
  (packages
    (append
      (list
        nss-certs)
        ;podman)
      %base-packages))
  (services
    (append
      (list (service docker-service-type)
            (service prometheus-node-exporter-service-type
                     (prometheus-node-exporter-configuration
                       (web-listen-address "127.0.0.1:9100")))
            ; /etc/docker must be writable by docker daemon
            (extra-special-file "/etc/docker/daemon.json"
                                (local-file "daemon.json")))
      ; ssh
      (make-vm-services `(("root" ,ssh-pubkey))))))
