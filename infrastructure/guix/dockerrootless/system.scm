(use-modules (gnu bootloader)
             (gnu bootloader grub)
             (gnu system file-systems)
             (gnu packages ssh)
             (gnu packages certs)
             (gnu services base)
             (gnu services networking)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services docker)
             (guix gexp))

(operating-system
  (host-name "dockerrootless")
  (bootloader (bootloader-configuration (bootloader grub-bootloader)))
  (file-systems %base-file-systems)
  (users
    (append
      (list
        (user-account
          (name "docker")
          (group "users")))))
  (services
    (append
      (list (service dhcp-client-service-type)
            ; make acpi shutdown work
            (service elogind-service-type)
            (service openssh-service-type
                     (openssh-configuration
                      (openssh openssh-sans-x)
                      (permit-root-login `prohibit-password)
                      (password-authentication? #f)
                      (authorized-keys
                       `(("root" ,(local-file "../id_ed25519.pub")))))))
      %base-services)))