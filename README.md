# KIAM

This kustomize setup will Deploy KIAM (agent, server, rbac, certificate & sample-app).

## To Deploy

1. Change directory into any environment directory, e.g. `tst`, or specify the directory
   when using `kustomize` e.g. `kustomize build directory_here`
2. Run `kustomize build` to build the `yaml` and either output into a file to apply
   later or pipe into `kubectl`:
    * Output to a file: `kustomize build > kiam.yaml`
    * Pipe directly to `kubectl`: `kustomize build | kubectl apply -f -`
    * Using `kubectl`'s built in `kustomize`: `kubectl apply -k`
      * Please note that the version of `kustomize` that ships with `kubectl` is
        likely to be behind the main release of `kustomize` and may not work
3. Check the operator is running with `kubectl -n kiam get pods,certificate,secret,issuer`

## Install KIAM **Terraform**
### Creating IAM Roles

1. Create the IAM role called `kiam-server`

2. Enable `Trust Relationship` between the newly created role and role attached to Kubernetes cluster workers nodes.
	- Go to the newly created role in AWS console and Select `Trust relationships` tab
	- Click on `Edit trust relationship`
	- Add the following content to the policy:
	```
	   {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<ARN_SERVER_MASTER_IAM_ROLE>"
      },
      "Action": "sts:AssumeRole"
    }
	```

3. Add inline policy to the `kiam-server` role
   ```
   {
  	 "Version": "2012-10-17",
     "Statement": [
      {
        "Effect": "Allow",
        "Action": [
        	"sts:AssumeRole"
      	 ],
      	"Resource": "*"
      }
  	]
   }
   ```

4. Create the IAM role (let's call it `app-role-*`) with appropriate access to AWS resources.

5. Enable `Trust Relationship` between the newly created role and role attached to Kiam server role.
	- Go to the newly created role in AWS console and Select `Trust relationships` tab
	- Click on `Edit trust relationship`
	- Add the following content to the policy:
	```
	   {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<ARN_KIAM-SERVER_IAM_ROLE>"
      },
      "Action": "sts:AssumeRole"
    }
	```

6.  Enable Assume Role for Master Pool IAM roles. Add the following content as inline policy to Master IAM roles:
   ```
   {
  	 "Version": "2012-10-17",
     "Statement": [
      {
        "Effect": "Allow",
        "Action": [
        	"sts:AssumeRole"
      	 ],
      	"Resource": "<ARN_KIAM-SERVER_IAM_ROLE>"
      }
  	]
   }
   ```

## [Deploying Cert-Manager](https://github.com/ZeroDeth/cert-manager)


## Testing

```sh
kubectl -n tst exec -it ssm-tst-* -- curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
app-role-*
```

```sh
kubectl -n tst exec -it ssm-tst-* -- curl http://169.254.169.254/latest/meta-data/iam/security-credentials/app-role-*
```

### Example for `SSM` parameter store

1. Exec into the pod and run
```sh
kubectl exec -it -n tst ssm-tst-* /bin/bash
```
You should get `app-role-*` as the response.

1. Returns details about the IAM identity whose credentials are used to call the API.
```sh
aws sts get-caller-identity
```

3. Get lists the value for a parameter.
```sh
export AWS_DEFAULT_REGION="eu-central-1"
aws ssm get-parameter --name "kiam-ssm-tst"
```
