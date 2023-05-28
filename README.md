## Prerequisites

- Minikube
- Docker
- Helm
- Kubectl
- Istio
## Kubernetes Migration
---
We have migrated our Docker deployment to Kubernetes.

Please follow these steps:
1. Run the  following command to start minikube with sufficient resources (do not forget to also have docker running)
    ```bat
    minikube start --memory=<the more the better, 11900 was used> --cpus=<the more the better, 4 was used>
    ```
3. Run the following command once and keep the terminal open for the Kubernetes dashboard
    ```bat
    minikube dashboard
    ```
4. Run the following command
    ```bat
    docker login ghcr.io
    ```
    If that does not work login via this command.
    ```bat
    kubectl create secret docker-registry ghcr-credentials \
    --docker-server=ghcr.io \
    --docker-username=<GITHUB_USERNAME> \
    --docker-password=<GITHUB_PAT>
    ```
5. Install the helm chart
    Run the following command:
    ```bat
    helm install myapp  ./helm_chart/
    ```
6. Set the following label to the default namespace:
    ```bat
    kubectl label ns default istio-injection=enabled
    ```
7. In the dashboard, you should see that there are 10 pods created and a few other sets of services.
8. Run the following command once and keep the terminal open for the tunnel to stay active to access the services.
    ```bat
    minikube tunnel
    ```
9. Check the dashboard and wait until everything has started and is green to continue to the next step.
10. To access the ML model for restaurant reviews simply navigate to `localhost`.
11. Test it by entering reviews. For example, submitting 'I hate this restaurant' would result in :( and 'The staff is very friendly' results in :D.
12. To access promotheus simply navigate to `localhost/prometheus`.
13. To access grafana simply navigate to `localhost/grafana`. You will be prompted to login, the username is `admin` and the password is `prom-operator`. To navigate to the dashboard that is automatically imported via a ConfigMap, click on the hamburger icon which is also known as the toggle menu, in that menu click on Dashboard. Then type `REMLATeam12` (the title name of our dashboards) in the text box which has `Search for dashboard` in it. There should be a row in the search results below the text box with the value `REMLATeam12` under the Name column, click that to be directed to the dashboards.
14. When done, remove the application and close all terminals: 
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

