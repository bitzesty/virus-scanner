# Virus Scanner

## Installing Clam AV

    brew install clamav

    modify /usr/local/etc/clamav/freshclam.conf.sample
    save /usr/local/etc/clamav/freshclam.conf (comment out the example line)

    modify /usr/local/etc/clamav/clamd.conf

    freshclam

    (OSX Run Clamd for faster scanning & MD5 caching)
    /usr/local/Cellar/clamav/0.98.6/sbin/clamd

## Running

    Load ENV variables see .env.example

    foreman start

## Testing

`rspec`

Or use postman


## API

This application will receive post requests with a url of a file to download.

This will trigger a Job that:

- [x] Downloads the file into a temp location
- [x] Takes a md5 & sh1 checksum
- [x] Scans the file
- [x] Send the results back to the requesting web application via a webhook
- [x] Removes temp file

To do any request below you need to pass auth token in HTTP headers

    X-Auth-Token: [your_token]

Scan a file

    POST /scan, {url: "URL TO SCAN"}

  e.g.

    curl -X POST -H "X-Auth-Token: your_token" -F url="URL TO SCAN" http://virus_scanner_host/scan

Check the status of a file

    GET /status/UUID

  e.g.

    curl -H "X-Auth-Token: your_token" http://virus_scanner_host/status/UUID

## Architecture

                ┌─────────────────┐
                │  API Requests   │
                └─────────────────┘
                         │
                         ▼
    ┌──────────────────────────────────────┐
    │           ┌────────────────┐         │      Download AV
    │           │    AWS ELB     │         │        Updates
    │           └────────────────┘  ┌──────┼───────────┐
    │                               │      │           │
    │                               │      │           ▼
    │ ┌─────────┐ ┌─────────┐  ┌─────────┐ │ ┌──────────────────┐
    │ │         │ │         │  │         │ │ │                  │
    │ │  Virus  │ │  Virus  │  │  Virus  │ │ │  ┌─────────────┐ │
    │ │scanning │ │scanning │  │scanning │ │ │  │ Squid Proxy │ │
    │ │   API   │ │   API   │  │   API   │ │ │  └─────────────┘ │
    │ │         │ │         │  │         │ │ │                  │
    │ └─────────┘ └─────────┘  └─────────┘ │ │ AWS Auto Scaling │
    │     AWS Auto Scaling Group 1..n      │ │    Group 1..1    │
    └──────────────────────────────────────┘ └──────────────────┘
                       ▲
               ┌───────┴─────┐
               ▼             ▼
          ┌─────────┐   ┌─────────┐
          │         │   │         │
          │         │   │         │
          │ AWS RDS │   │ AWS SQS │
          │         │   │         │
          │         │   │         │
          └─────────┘   └─────────┘
