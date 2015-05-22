# Virus Scanner

## Scanning Flow

1) User uploads file

2) App saving it on S3 and on store_file callback we are creating Scan association for defined AR instance (ex: FormAnswerAttachment) with generated UUID and status = 'scanning'

3) Once Scan association created -> we are sending uploaded file url (from S3) and generated unique UUID to virus scanner server

4) Virus Scanner handles this request right here https://github.com/bitzesty/virus-scanner/blob/master/app/api/scan.rb#L30 (edited)

5) Virus Scanner app creating Scan entry and schedule Shoryuken background job
Shoryuken is same Sidekiq but for AWS SQS Message Queue (https://github.com/phstc/shoryuken)

6) Shoryuken job scanning uploaded file on viruses using open source antivirus clamav

7) Once file is scanned Virus Scanner sends callback request to QAE APP (edited) It's implemented right here https://github.com/bitzesty/virus-scanner/blob/master/app/jobs/scan_job.rb#L24

8) QAE app handling it right here (using vs-rails app) https://github.com/bitzesty/vs-rails/blob/master/app/controllers/vs_rails/scans_controller.rb#L5


## Setup on local

#### STEP 1: Setup clamav antivirus on local

[Installing Clam AV](https://github.com/bitzesty/virus-scanner#installing-clam-av)

#### STEP 2: Set proper env vars to .env file in virus scanner repo

```
AVENGINE=clamdscan
AWS_REGION=eu-west-1
AWS_ACCESS_KEY_ID=<...>
AWS_SECRET_ACCESS_KEY=<...>
SQS_QUEUE=<...>
```

#### STEP 3: Populate API account

Here is the rake script https://github.com/bitzesty/virus-scanner/blob/master/lib/tasks/account.rake

Basicly you need to run:
```
account = Account.create!(name: 'test_api_account', callback_url: "http://localhost:3000/vs_rails/scans/callback")

account.api_key
 => kdsjfsf728832....
```

* on Account creation api_key would be generated automatically.

#### STEP 4: Setup env vars on Target Rails app side

In .env you need to specify following env variables
```
DISABLE_VIRUS_SCANNER=false # it true by default on localhost
VIRUS_SCANNER_API_URL=http://localhost:5000 # can be different on your side
VIRUS_SCANNER_API_KEY=<API KEY>
```

#### STEP 5: Run both apps

```
foreman start
```

Targer app in this example on 3000 port and virus scanner app on 5000

NOTE: Make sure that in target rails app's Gemfile you have:
```
gem "vs_rails", "~> 0.0.7"
```

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
