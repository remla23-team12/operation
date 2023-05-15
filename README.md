## Prerequisites

- Minikube
- Docker
- Helm
- Kubectl

## Kubernetes Migration
---
We have migrated our Docker deployment to Kubernetes.

Please follow these steps:
1. Run the  following command to start minikube (do not forget to also have docker running)
   ```bat
    minikube start
    ```
2. Run the following command once to enable ingress (if not already enabled)
   ```bat
    minikube addons enable ingress
    ```
3. Run the following command once and keep the terminal open for the Kubernetes dashboard
   ```bat
    minikube dashboard
    ```
4. Run the following command
   ```bat
    kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username=<GITHUB_USERNAME> \
    --docker-password=<GITHUB_PAT>
    ```
5. To see the Prometheus dashboard and monitoring total_predictions, correct_predictions, prediction_accuracy, prediction_accuracy_changes and prediction_duration_summary, first need to ensure a release name myprom was installed
    Add the myprom repo to use the ServiceMonitor
    ```bat
    helm install myprom prom-repo/kube-prometheus-stack   
    ```
6. Make prometheus available in the browser via localhost/prometheus
    ```bat
    helm upgrade myprom prom-repo/kube-prometheus-stack -f prometheusValues.yaml
    ```
    (If after the next few steps localhost/prometheus doesn't work use "minikube service myprom-kube-prometheus-sta-prometheus --url" instead)
7. Install the helm chart
    Run the following command:
    ```bat
    helm install myapp  ./helm_chart/
    ```
7. In the dashboard, you should see that there are 8 pods created and a few other sets of services.
8. Run the following command once and keep the terminal open for the tunnel to stay active.
    ```bat
    minikube tunnel
    ```
9. Open a new tab, and search for `localhost` on your browser of choice.
10. Test it by entering reviews. For example, submitting 'I hate this restaurant' would result in :( and 'The staff is very friendly' results in :D.
11. To get to Grafana dashboard run the following command
    ```bat
    minikube service myprom-grafana --url
    ```
13. Then go to the dashboard page via the menu on the left and click the "new" button on the right. select import and upload the Dashboard.json that is present in the repo. This will open up the Grafana visualizations.
12. When done, remove the application and close all terminals: 
    Run the following command:
    ```bat
    helm uninstall myapp
    ```
---

### Optionally to just use the model and not Prometheus and Grafana run the following commans instead of steps 5, 6, and 7
   Navigate to the root folder and enter the following command:
```bat
kubectl apply -f deployment.yml
```

To remove the pods again run:
 ```bat
 kubectl delete -f deployment.yml
 ```

### Some interesting starting pointers to files that help outsiders understand the code base:
In the docker-compose.yml file we have two services namely `flask-container-1` and `flask-container-2`. 

The `flask-container-1` container is the frontend of the application which is spawned from the `ghcr.io/remla23-team12/app:latest` image which is automatically released by Github Actions Workflow in the [app repostory of our organization](https://github.com/remla23-team12/app).

Similary, The `flask-container-1` container is the backend of the application and it's spawned from the `ghcr.io/remla23-team12/model-service:latest` image which is automatically released by Github Actions Workflow in the [model-service repostory of our organization](https://github.com/remla23-team12/model-service) whenever a version tag is pushed.

The code that is used for training and obtaining a model can be found in [the model-training repository](https://github.com/remla23-team12/model-training). After manually running [train.py](https://github.com/remla23-team12/model-training/blob/main/train.py), a joblib and pkl file is outputted in the models and bow respectively. These files need to be used in the backend (model-service), for now we have manually place a copy of said files in the model-service repository which are then used to build the model-service image. We approach is a bit iffy, which is why we would like to ask our reviewers to provide ideas on how to do this in a smarter way. One idea we had was to make use of multi-stage build in docker, where we build, but that would inivolve copying the code from the model-training repository to the model-service repository, which is also very iffy.

The lib repository can be found [here](https://github.com/remla23-team12/lib).

