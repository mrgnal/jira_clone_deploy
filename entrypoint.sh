#!/bin/sh
npx prisma migrate deploy

npx prisma db seed