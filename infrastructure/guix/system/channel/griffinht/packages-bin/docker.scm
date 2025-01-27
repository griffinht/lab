(define-module (griffinht packages-bin docker)
               #:use-module (guix packages)
               #:use-module (guix download)
               #:use-module (guix git-download)
               #:use-module (guix build-system copy)
               #:use-module (guix build-system gnu)
               #:use-module (guix licenses)
               #:use-module (guix gexp)
               #:use-module (gnu packages docker)
               #:use-module (gnu packages containers)
               #:use-module (gnu packages base)
               #:use-module (gnu packages linux))
; https://docs.docker.com/engine/security/rootless/
; todo go through all the limitations and try to support them
; https://github.com/docker/docker-install/blob/master/rootless-install.sh


; todo modern docker compose?
; todo netavark


; requires /etc/uid and /etc/gid to be configured
; requires shadow (newuidmap) to be installed with setuid
(define-public
  rootlesskit
  (package
    (name "rootlesskit")
    (version "2.0.0")
    (source ; todo build from source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/rootless-containers/rootlesskit/releases/download/v" version "/rootlesskit-x86_64.tar.gz"))
        (sha256 "0gvjh6sh8v3gh6hm1zm737q7n1nibbxma90q1dm5gsx9dkwy61c2")))
    (build-system copy-build-system)
    #|
    (propagated-inputs
      (list shadow))
    |#
    (arguments
      '(#:install-plan '(("." "bin"))))
    (synopsis "")
    (description "")
    (home-page "https://github.com/rootless-containers/rootlesskit")
    (license asl2.0)))

; todo set DOCKERD_ROOTLESS_env vars to use pasta https://docs.docker.com/engine/security/rootless/#network-is-slow
#| todo i can't get this to build
(define-public
  passt
  (package
    (name "passt")
    (version "2023_12_30.f091893")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "git://passt.top/passt")
               (commit version)))
        (sha256 "0s895zrk4kxx5q02wld0naw9xmbyf2vaicac7hmnb3rl5vsmqgjn")))
    (build-system gnu-build-system)
    (inputs
      (list glibc))
    (arguments
      '(#:phases
        (modify-phases
          %standard-phases
          (delete 'configure))
        #:make-flags
        (list
          "CC=gcc"))) ; /bin/sh no such file or dir
    (synopsis "")
    (description "")
    (home-page "https://passt.top/passt/")
    (license bsd-3 gpl2+)))
|#


; requires system to have configured /etc/subuid and /etc/subgid, for example:
; echo "${USERNAME}:100000:65536" >> /etc/subuid
; echo "${USERNAME}:100000:65536" >> /etc/subgid
; also might require iptables module to be loaded: modprobe iptables, but using guix service also seems to work
; 
; launch: (expects userland proxy binary to be called docker-proxy, but docker-libnetwork-cmd-proxy has it as just proxy)
; dockerd-rootless.sh --userland-proxy-path $(which proxy)
;
;
; todo this should probably inherit from the guix docker package somehow
;
;
; modprobe aufs
; devmapper not configured
; --host tcp:// doesn't work - it just breaks in a weird way
(define-public
  dockerd-rootless.sh
  (package
    (name "dockerd-rootless.sh")
    ;(version "25.0.1")
    (version "20.10.27") ; maybe should match the guix docker version idk
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/moby/moby")
               (commit (string-append "v" version))))
        (sha256 "017frilx35w3m4dz3n6m2f293q4fq4jrk6hl8f7wg5xs3r8hswvq")))
        ;(sha256 "01h0yrs9frrk9ni25f8vvgicn359cyfayrq2zmcl1nbwal59a1a8")))
    (build-system copy-build-system)
    (arguments
      '(#:install-plan '(("contrib/dockerd-rootless.sh" "bin/"))))
    (propagated-inputs
      (list
        rootlesskit
        slirp4netns
        ;grep
        ;coreutils
        ;util-linux ; ns-enter
        ;iproute ; ip
        docker ; dockerd
        containerd
        docker-libnetwork-cmd-proxy ; proxy (usually installed as docker-proxy)
        ; note that proxy is optional, so maybe make it optional here? https://github.com/docker/docs/issues/17312
        ;iptables ; for containerd
        ))
    (synopsis "")
    (description "")
    (home-page "https://mobyproject.org")
    (license asl2.0)))
