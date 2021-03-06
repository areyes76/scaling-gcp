#!/bin/bash

#CONEXION A GCP
kubectl versionon --client
gcloud auth activate-service-account --key-file=./credencial.json
gcloud config set project servipag-preprod
gcloud container clusters get-credentials preproduccion --zone=us-west2-a

#VARIABLES DINAMICAS PARA SU SETEO
NAMEPOD=$1
NAMESPACE=$2
MINSESION=$3
MAXSESION=$4
MINREPLICA=$5
TOTALSESION=$6

echo $NAMEPOD $NAMESPACE $MINSESION $MAXSESION $MINREPLICA $TOTALSESION

#SE OBTIENE LA LISTA DE POD Y EL TAMAÑO DE ESTE
list_pod=$(kubectl -n ${NAMESPACE} get pod | grep ${NAMEPOD} | awk '{print $1}' )
list_size=$(kubectl -n ${NAMESPACE} get deploy | grep ${NAMEPOD} | awk '{print $3}')

#SE RECORRE LA LISTA Y SE ACTUA DE ACUERDO A LA LOGICA DE NEGOCIO
for pod in $list_pod; do
    echo "TAMAÑO LISTA ${list_size}"
    json=$(kubectl -n ${NAMESPACE} get po ${pod} -o json)
    podIP=`echo  ${json} | jq -c '.status.podIP' | sed s/" "/_/g | sed s/'"'/''/g  `
    json=$(curl ${podIP}:3000/apis/custom.metrics.k8s.io/v1beta1/)
    sesion=$((`echo  ${json} | jq -c '.items.value' | sed s/" "/_/g | sed s/'"'/''/g  `))
    #sesion=$(($sesion + 1))
    echo $sesion

    if [ $sesion -le ${MINSESION} ]
    then
        podDel=$(kubectl -n ${NAMESPACE} po delete ${pod} )
        list_size=$(($list_size - 1))
        echo ${list_size}
	if [ $list_size -ge ${MINREPLICA} ]
	then
		echo "--replicas=${list_size}"
         	podRep=$(kubectl -n ${NAMESPACE} scale deployment ${NAMEPOD}-deployment --replicas=${list_size})
	fi
        echo "sesion es ${sesion}, se elimina pod"
#    else
#     if [ $sesion -ge ${MAXSESION} ]
#     then
        TOTALSESION=$(($TOTALSESION + $sesion))
#     fi
    fi
done

list_size=$(kubectl -n ${NAMESPACE} get deploy | grep ${NAMEPOD} | awk '{print $3}')
let PROMEDIO=$TOTALSESION/$list_size
if [ $PROMEDIO -le $MAXSESION ]
then
  list_size=$(($list_size + 1))
  echo "FINAL --replicas=${list_size}"
  podRep=$(kubectl -n ${NAMESPACE} scale deployment ${NAMEPOD}-deployment --replicas=${list_size})
fi

sleep 2m