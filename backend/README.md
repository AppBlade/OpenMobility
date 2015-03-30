# README

Install the gems and setup the database.

    $ bundle
    $ rake db:setup

Generate a CA keypair, use the pass-phrase "development" for now.

    $ openssl req -new -x509 -keyout ssl/cakey.pem -out ssl/cacert.pem -days 3650

Optional, get your hands on dep-sim if you are developing against that.

Spin up your dev environment:

    $ foreman start

I highly suggest using Forward HQ https://forwardhq.com/ for testing enrollment and jazz. We have a Team account, bug Mike or James for access.
