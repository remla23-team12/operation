# Operation
---
Please follow these steps:
1. Make sure Docker is up and running (e.g. via the Docker desktop app or by running the following command in a Linux operating system:) 
    ```bat
    sudo service docker start
    ```
2. In your command line interface make sure your are in the root of the folder where the docker-compose.yml file is located. Once in the right directory run the following command:
    ```bat
    docker-compose up -d
    ```
3. Open localhost:8081 on your browser of choice
4. Test it by entering reviews. For example submitting 'I hate this restaurant' would result in :( and 'The staff is very friendly' results in :D.
5. To stop the application execute the following command: 
    ```bat
    docker-compose down
    ```
---

## Kubernetes Migration
---
We have migrated our Docker deployment to Kubernetes.

Please follow these steps:
1. Run the  following command to start minikube (do not forget to also have docker running)
   ```bat
    minikube start
    ```
2. Run the following command once to enable ingress
   ```bat
    minikube addons enable ingress
    ```
3. Run the following command once and keep the terminal open for the kubernetes dashboard
   ```bat
    minikube dashboard
    ```
4. Navigate to the root folder and enter the following command:
   ```bat
    kubectl apply -f deployment.yml
    ```
5. In the dashboard you should see that there are two pods created
6. Open a new tab, and search for `localhost` on your browser of choice
7. Test it by entering reviews. For example submitting 'I hate this restaurant' would result in :( and 'The staff is very friendly' results in :D.
8. To remove the pods: 
    ```bat
    kubectl delete -f deployment.yml
    ```
---

### Some interesting starting pointers to files that help outsiders understand the code base:
In the docker-compose.yml file we have two services namely `flask-container-1` and `flask-container-2`. 

The `flask-container-1` container is the frontend of the application which is spawned from the `ghcr.io/remla23-team12/app:latest` image which is automatically released by Github Actions Workflow in the [app repostory of our organization](https://github.com/remla23-team12/app).

Similary, The `flask-container-1` container is the backend of the application and it's spawned from the `ghcr.io/remla23-team12/model-service:latest` image which is automatically released by Github Actions Workflow in the [model-service repostory of our organization](https://github.com/remla23-team12/model-service) whenever a version tag is pushed.

The code that is used for training and obtaining a model can be found in [the model-training repository](https://github.com/remla23-team12/model-training). After manually running [train.py](https://github.com/remla23-team12/model-training/blob/main/train.py), a joblib and pkl file is outputted in the models and bow respectively. These files need to be used in the backend (model-service), for now we have manually place a copy of said files in the model-service repository which are then used to build the model-service image. We approach is a bit iffy, which is why we would like to ask our reviewers to provide ideas on how to do this in a smarter way. One idea we had was to make use of multi-stage build in docker, where we build, but that would inivolve copying the code from the model-training repository to the model-service repository, which is also very iffy.

The lib repository can be found [here](https://github.com/remla23-team12/lib).

