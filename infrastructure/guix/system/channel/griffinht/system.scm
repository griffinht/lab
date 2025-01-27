(define-module (griffinht system)
               #:use-module (gnu bootloader)
               #:use-module (gnu bootloader grub)
               #:use-module (gnu system file-systems)
               #:use-module (gnu packages ssh)
               ; vm-packages
               #:use-module (gnu system)
               #:use-module (gnu packages python)
               #:use-module (gnu packages curl)
               ;
               #:use-module (gnu services)
               #:use-module (gnu services base)
               #:use-module (gnu services networking)
               #:use-module (gnu services ssh)
               #:use-module (gnu services desktop)
               #:use-module (gnu services vpn)
               #:use-module (guix gexp))

;(define-public ssh-pubk
(define-public wireguard-address-guix "10.0.0.1")
(define-public wireguard-address-hypervisor "10.0.0.2")
(define-public wireguard-address-nerd-vps "10.0.0.3")

(define-public wireguard-peer-cool-laptop
               (wireguard-peer
                 (name "cool-laptop")
                 (public-key "5V21izdEyjthdeALvOrADIq1B2fvqX9I9RC4Ow37XnA=")
                 (allowed-ips '("10.0.0.9/32"))))

(define-public wireguard-peer-cloudtest
               (wireguard-peer
                 (name "cloudtest")
                 (public-key "gw5LGcb/Wfgambnv3UuPxO/zmQsPr+v6mHzZuGhWPnk=")
                 (allowed-ips '("10.0.0.10/32"))))

;(define-public wireguard-address-hot "10.0.0.11")
;(define-public wireguard-address-griffinht "10.0.0.11")

(define-public %vm-ssh-admin-pubkey
  (local-file (getenv "SSH_PUBKEY")))

(define-public %vm-packages
               (append
                 (list
                   python
                   curl)
                 %base-packages))

(define-public %vm-bootloader
  (bootloader-configuration (bootloader grub-bootloader)))

(define-public %vm-file-systems
  (append
    (list
      (file-system
      (mount-point "/")
      (type "ext4")
      (device (file-system-label "Guix_image"))))
    %base-file-systems))

;(define ssh-pubkey
;  (local-file (getenv "GUIX_PUBKEY")))

(define-public (make-vm-services authorized-keys)
  (append
    (list
      (service dhcp-client-service-type)
      ; make acpi shutdown work
      (service elogind-service-type)
      (service openssh-service-type
               (openssh-configuration
                 (openssh openssh-sans-x)
                 (permit-root-login `prohibit-password)
                 (password-authentication? #f)
                 (authorized-keys authorized-keys))))
    (modify-services
      %base-services
      ; https://stumbles.id.au/getting-started-with-guix-deploy.html
      ;; The server must trust the Guix packages you build. If you add the signing-key
      ;; manually it will be overridden on next `guix deploy` giving
      ;; "error: unauthorized public key". This automatically adds the signing-key.
      (guix-service-type
        config =>
        (guix-configuration
        (inherit config)
        (authorized-keys
          (append
            (list (local-file "/etc/guix/signing-key.pub"))
            %default-authorized-guix-keys)))))))

(define (etc-subid name filename user)
  (simple-service
    name
    etc-service-type
    (list
      `(,filename ,(plain-file filename
                              (string-append user ":100000:65536\n"))))))

(define-public (etc-subuid user)
               (etc-subid 'etc-subuid "subuid" user))

(define-public (etc-subgid user)
               (etc-subid 'etc-subgid "subgid" user))
