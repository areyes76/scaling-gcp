# Micro servicio <NOMBRE SERVICIO>

Micro servicio encagado de las operaciones de crear y eliminar PODS de otro ms ya funcionado en el cluster.
la idea es tener un minimo de pods creados y de acuerdo a la necesidad se crean nuevos pods para satisfacer las 
demanda de servicios, luego de ser usuados, estos son eliminados, pero haciendo una consulta a un servicio que nos 
proporciona la info para tomar la desicion de eliminacion, para este proyecto la variable es analizada desde un json como
respuesta y que dentro de este la variable sesion es la importa. si la variable es 0, este pod se elimina, de lo contrario
si la sesion es mayor a 0 se deja vivir, hasta que sea 0. es condicion no la puede medir el HPA de K8s, o al menos no tan al 
detalle, pero con este trabajo, se logro discriminar que POD es que candidato a morir.

## Métodos

### Get: recurso health

#### Ruta relativa: /servipag/v1/health/

