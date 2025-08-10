#!/bin/sh

otelcol --config=/etc/otel/config.yaml &

exec node /app/server.js >> /tmp/app.log 2>&1