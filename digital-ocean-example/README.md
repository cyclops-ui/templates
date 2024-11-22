# Cyclops on digital ocean

The following example will show you how to start a Kubernetes cluster on Digital Ocean, install Cyclops, and manage your applications/databases through the Cyclops UI.

## Create a Kubernetes cluster on Digital ocean

To create a cluster on DO, visit https://cloud.digitalocean.com/kubernetes/clusters/new

Here, you can configure the region, version of your cluster, and how many resources your cluster will need.

If you want to manage your databases from your Cyclops instance, make sure to check the box for `Add database operator`:

<img width="858" alt="Screenshot 2024-11-07 at 14 19 32" src="https://github.com/user-attachments/assets/54f4f59c-d208-4161-b554-109c7b888471">

Make sure to add a name for your cluster:

<img width="665" alt="Screenshot 2024-11-07 at 14 20 44" src="https://github.com/user-attachments/assets/13830743-64a0-475b-80a4-f80b0834bb3d">

At the bottom, you can see the cost prediction for your Kubernetes cluster. You can play around with node count and node types to reduce it if needed.

Hit `Create Cluster` and wait a couple of minutes.

## Installing Cyclops into a Digital Ocean cluster

Once your cluster is up and running, you can download the kubeconfig file by clicking the `Download Config file`

<img width="618" alt="Screenshot 2024-11-07 at 14 34 18" src="https://github.com/user-attachments/assets/933e929c-a3f3-4ebf-9836-705c0d7cf7c7">

After you download the kubeconfig file, you can configure your `kubectl` to access your DO cluster by setting the environment variable `KUBECONFIG` to point to your kubeconfig file:

```bash
export KUBECONFIG=~/Downloads/<name of your cluster>-kubeconfig.yaml
```

Verify your `kubectl` is properly configured:

```bash
kubectl get nodes

NAME                   STATUS   ROLES    AGE     VERSION
pool-e404vn0zb-gqcfh   Ready    <none>   9m6s    v1.31.1
pool-e404vn0zb-gqcfk   Ready    <none>   8m58s   v1.31.1
```

You can now install Cyclops with the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/cyclops-ui/cyclops/v0.15.2/install/cyclops-install.yaml && kubectl apply -f https://raw.githubusercontent.com/cyclops-ui/templates/refs/heads/digital-ocean-managed-dbs/digital-ocean-example/digital-ocean-templates.yaml
```

You check if cyclops pods are ready:

```bash
kubectl get pods -n cyclops

NAME                            READY   STATUS    RESTARTS   AGE
cyclops-ctrl-6d9dcb855f-wdlzl   1/1     Running   0          21s
cyclops-ui-8467b5d54c-lnnxk     1/1     Running   0          23s
```

And once they are, you can port forward Cyclops to access it:

```bash
kubectl port-forward svc/cyclops-ui 3000:3000 -n cyclops
```

Cyclops is now available on http://localhost:3000/

## Deploy a Digital Ocean mysql

In your Cyclops, go to add Module and select the `digital-ocean-mysql` template:

<img width="1512" alt="Screenshot 2024-11-22 at 16 40 37" src="https://github.com/user-attachments/assets/6534f55f-10ac-47f9-9590-a40a7184d406">

Select the environment, size and region you want to deploy to and hit `Deploy`.

> ⚠️ Make sure that the environment you are deploying your application in is the same as the environment of the database you are connecting to

You can select any region regardless of where your cluster is running.

You can now check your digital ocean databases, and in a couple of minutes, you will have a running Mysql.

<img width="1512" alt="Screenshot 2024-11-07 at 14 41 10" src="https://github.com/user-attachments/assets/0f38b1bb-a61f-4136-bfde-e29885b00dd7">

The Cyclops UI in the Cyclops above is pretty simple and only has three fields (environment, size and region), but you can expand the template as much as you want by editing the Helm chart [here](https://github.com/cyclops-ui/templates/tree/digital-ocean-resources/digital-ocean-database), or by reaching out to us and we can help you with that.

## Connecting an application to the database

Once your MySQL is up and running, you can deploy the application and easily connect it to your database. Since the database is deployed via Cyclops and Kubernetes, all of your credentials are already in your Kubernetes cluster and can easily be injected into your app using Cyclops.

In Cyclops, go to `Add module` and select the `app-template-digital-ocean` template.

<img width="1512" alt="Screenshot 2024-11-22 at 16 43 40" src="https://github.com/user-attachments/assets/c9836b59-afc9-4318-93ac-d2c1d149269b">

Here, you can change the docker image you will deploy and configure environment variables, but you can also configure your MySQL connection.

<img width="1512" alt="Screenshot 2024-11-22 at 16 42 46" src="https://github.com/user-attachments/assets/cdf3e259-841a-4306-ae9a-403fd06edc4f">

Under `Instance name`, input the name of the database module you just deployed, and under `Database name`, the name of the database you will use (defaultdb comes with each new instance). All of the other credentials (like instance host, user, and password) are injected, and you don’t have to worry about them.

<img width="1512" alt="Screenshot 2024-11-07 at 14 51 37" src="https://github.com/user-attachments/assets/f357c0cc-5dcf-4992-a168-35f764af3e44">

You should now have a running app that has all of the information to connect to a MySQL instance injected as environment variables you can read in your application and use to connect to your app.

- `MYSQL_HOST` - host of your instance
- `MYSQL_PORT` - port of your instance
- `MYSQL_DATABASE` - database in MySQL
- `MYSQL_USER` - database user
- `MYSQL_PASSWORD` - database password

All of these are coming from [this template](https://github.com/cyclops-ui/templates/tree/digital-ocean-resources/app-template-digital-ocean) and can be changed. The main idea is that you don’t have to handle your credentials by hand, and deploying (and connecting) your application and database is as easy as possible.
