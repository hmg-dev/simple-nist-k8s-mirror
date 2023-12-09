# Simple Mirror/Cache for NISTs NVD

On 15.12.2023, the official NVD-Feed of NIST "retired" and only the API remains.

In order to provide a mirror nevertheless, this project utilizes the vulnz-application of the [Open-Vulnerability-Project](https://github.com/jeremylong/Open-Vulnerability-Project/tree/main/vulnz), to fetch all the data from the API,
and provide a feed similar to the old one.

## Client changes
In order to use this feed, you need version 9 (or newer) of [DependencyCheck](https://github.com/jeremylong/DependencyCheck) - its not backwards-compatible to older versions.

Also be aware of the changed settings. The new setting to utilize the feed is: `nvdDatafeedUrl`

See http://jeremylong.github.io/DependencyCheck/dependency-check-maven/configuration.html for details.

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
* Optional: enter your NVD-API Key in the secret.yaml - if you have one.
