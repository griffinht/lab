# dev guide
docker compose up

## caddy
http://localhost:8080 (note that auto redirect doesn't work because caddy thinks it is listening at :443)
https://localhost:4434

# alerting
email
    create migadu account
xmpp
    create snikket account
irc
    meh
could self host, with backup external for if self hosted goes down
do whatever is easy



https://github.com/ivbeg/awesome-status-pages
# stack
prometheus
blackbox exporter
certbot
nginx
grafana

complexity! remember that hot is capable of monitoring itself!
this should really just monitor the monitors





alerts
# actionable
status.griffinht.com
    certbot expiry

# semi actionable
griffinht.com
    is it responding with ssl
    response time
    speedtest?

is wireguard pingable? maybe even test routing to local? but that would require exposing wireguard keys on vps :(
