# Simple Mirror/Cache for NISTs NVD

There is another existing solution for a nist mirror in k8s: [https://github.com/stevespringett/nist-data-mirror](https://github.com/stevespringett/nist-data-mirror)<br/>
But it has its drawbacks! 
* Using the same Dockerimage for fetching the data and serving it. 
* Running Cronjobs in the POD instead of using a k8s cronjob (and thus risking a race-condition).
* Using Java for fetching and verifying the files seems a bit bloated.

<br/>
So, here is a little more simple approach.

* Using nginx without a custom image and inject the config via k8s ConfigMap
* Use a small bash-script to fetch and verify the files and put it in a tiny Dockerimage
* Use k8s Cronjob to fetch the files on a regular basis

## notes and tech details
### nginx config
The nginx config is hard to read within the ConfigMap yaml.<br/>
So it exists as regular config in a dedicated directory and can be converted into k8s ConfigMap via:
```
kubectl create configmap nist-mirror-cm --dry-run="client" --from-file nginx-config -o yaml > k8s/configmap.yaml
```
don't forget to add labels afterwards!

### specific details / required changes
* You might want/need to change the `storageClassName` of the PVC
* Don't forget to replace Host in `mirror.conf`, `configmap.yaml` and `ingress.yaml`
* Don't forget to replace Dockerregistry in `azure-pipelines.yml` and `cronjob.yaml`
