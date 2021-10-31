FROM golang:latest

RUN apt-get update && apt-get install -y cron

# timezone
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# workspase
RUN mkdir -p /go/src/app
WORKDIR /go/src/app

# this will ideally be built by the ONBUILD below ;)
CMD ["go-wrapper", "run"]

ONBUILD COPY . /go/src/app
ONBUILD RUN go-wrapper download
ONBUILD RUN go-wrapper install

# get env from local env file
RUN env > /env

#cron setting
#min(0-59) hour(0-23) day-of-month(1-31) month(1-12) day-of-week(0-6)(Sunday=0 or 7) command to be executed
CMD echo '*/1 * * * * cd /go/src/app; env - `cat /env` go run /go/src/app/batch.go >> /var/log/cron.log 2>&1' | crontab - && cron -f