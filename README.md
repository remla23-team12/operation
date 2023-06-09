## Prerequisites

- Minikube
- Docker
- Helm
- Kubectl
- Istio
## Istio Implementation
---

Please follow these steps:
1. Run the  following command to start minikube with sufficient resources (do not forget to also have docker running)
    ```bat
    minikube start --memory=<the more the better, 8900 was used> --cpus=<the more the better, 4 was used>
    ```
2. Run the following command once to get Istio Custom Resource Definitions (minikube must be started before this step)
    ```bat
    istioctl install
    ```
3. Run the following command once and keep the terminal open for the Kubernetes dashboard
    ```bat
    minikube dashboard
    ```
4. Set the following label to the default namespace:
    ```bat
    kubectl label ns default istio-injection=enabled
    ```
5. Install the helm chart, you can pick the name of the chart.
    Run the following command:
    ```bat
    helm install <NAME>  ./helm_chart/
    ```
6. In the dashboard, you should see that there are 12 pods created and a few other sets of services.
7. Run the following command once and keep the terminal open for the tunnel to stay active to access the services.
    ```bat
    minikube tunnel
    ```
8. Check the dashboard and wait until everything has started and is green to continue to the next step.
9. To access the ML model for restaurant reviews simply navigate to `localhost`. If you get a page with the message `no healthy upstream`, this is probably because not all pods are running yet, make sure to wait until all pods returned by the `kubectl get pods` command have the value `Running` for the `Status` column (This takes around 4.5 minutes if 9 GB and 4 cpus is assigned to minikube).
10. Test it by entering reviews. For example, submitting 'I hate this restaurant' would result in :( and 'The staff is very friendly' results in :D.
11. To access promotheus simply navigate to `localhost/prometheus`.
12. To access grafana simply navigate to `localhost/grafana`. You will be prompted to login, the username is `admin` and the password is `prom-operator`. To navigate to the dashboard that is automatically imported via a ConfigMap, click on the hamburger icon which is also known as the toggle menu, in that menu click on Dashboard. Then type `REMLATeam12` (the title name of our dashboards) in the text box which has `Search for dashboard` in it. There should be a row in the search results below the text box with the value `REMLATeam12` under the Name column, click that to be directed to the dashboards. After clicking on the dashboard, you should see the `Panel Predictions rate` (our app specific metric) for each version of the deployments (data on the graph only appears after leaving reviews and clicking correct and incorrect buttons)
13. When done, remove the application and close all terminals: 
    Run the following command:
    ```bat
    helm uninstall <NAME>
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

### A figure of Kiali dashboard
The screenshot only includes deployments and ingress gateway, entities outside the pictures are grafana and prometheus relevant sources.
![Screenshot](./istio.png)

### Some interesting starting pointers to files that help outsiders understand the code base:
In the docker-compose.yml file we have two services namely `flask-container-1` and `flask-container-2`. 

The `flask-container-1` container is the frontend of the application which is spawned from the `ghcr.io/remla23-team12/app:latest` image which is automatically released by Github Actions Workflow in the [app repostory of our organization](https://github.com/remla23-team12/app).

Similary, The `flask-container-1` container is the backend of the application and it's spawned from the `ghcr.io/remla23-team12/model-service:latest` image which is automatically released by Github Actions Workflow in the [model-service repostory of our organization](https://github.com/remla23-team12/model-service) whenever a version tag is pushed.

The code that is used for training and obtaining a model can be found in [the model-training repository](https://github.com/remla23-team12/model-training). After manually running [train.py](https://github.com/remla23-team12/model-training/blob/main/train.py), a joblib and pkl file is outputted in the models and bow respectively. These files need to be used in the backend (model-service), for now we have manually place a copy of said files in the model-service repository which are then used to build the model-service image. We approach is a bit iffy, which is why we would like to ask our reviewers to provide ideas on how to do this in a smarter way. One idea we had was to make use of multi-stage build in docker, where we build, but that would inivolve copying the code from the model-training repository to the model-service repository, which is also very iffy.

The lib repository can be found [here](https://github.com/remla23-team12/lib).

