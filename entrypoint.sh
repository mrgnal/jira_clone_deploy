#!/bin/sh

otelcol --config=/etc/otel/config.yaml &

exec nodes /app/server.js >> /tmp/app.log 2>&1