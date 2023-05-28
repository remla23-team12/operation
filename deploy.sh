#!/usr/bin/env bash

echo '--- Starting Minikube ---'
minikube start

echo '--- Docker login ---'
docker login ghcr.io

echo '--- Install app ---'
helm install myapp ./helm_chart/

echo '--- Update label ---'
kubectl label ns default istio-injection=enabled

echo '--- Start tunnel ---'
minikube tunnel