{{/*
This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.mongodb.secret" -}}
{{- $pghost := printf "%v-%v" .Release.Name "mongodb" }}

{{- if .Values.mongodb.enabled }}
enabled: true
expandObjectName: false
{{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
{{- $fetchname := printf "%s-mongodbcreds" $basename -}}
{{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname }}
{{- $dbpreviousold := lookup "v1" "Secret" .Release.Namespace "mongodbcreds" }}
{{- $dbPass := "" }}
{{- $rootPass := "" }}
data:
{{- if $dbprevious }}
  {{- $dbPass = ( index $dbprevious.data "mongodb-password" ) | b64dec  }}
  {{- $rootPass = ( index $dbprevious.data "mongodb-root-password" ) | b64dec  }}
  mongodb-password: {{ ( index $dbprevious.data "mongodb-password" ) }}
  mongodb-root-password: {{ ( index $dbprevious.data "mongodb-root-password" ) }}
{{- else if $dbpreviousold }}
  {{- $dbPass = ( index $dbpreviousold.data "mongodb-password" ) | b64dec  }}
  {{- $rootPass = ( index $dbpreviousold.data "mongodb-root-password" ) | b64dec  }}
  mongodb-password: {{ ( index $dbpreviousold.data "mongodb-password" ) }}
  mongodb-root-password: {{ ( index $dbpreviousold.data "mongodb-root-password" ) }}
{{- else }}
  {{- $dbPass = randAlphaNum 50 }}
  {{- $rootPass = randAlphaNum 50 }}
  mongodb-password: {{ $dbPass }}
  mongodb-root-password: {{ $rootPass }}
{{- end }}
  url: {{ ( printf "mongodb://%v:%v@%v-mongodb:27017/%v" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) }}
  urlssl: {{ ( printf "mongodb://%v:%v@%v-mongodb:27017/%v?ssl=true" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) }}
  urltls: {{ ( printf "mongodb://%v:%v@%v-mongodb:27017/%v?tls=true" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) }}
  jdbc: {{ ( printf "jdbc:mongodb://%v-mongodb:27017/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) }}
  plainhost: {{ ( printf "%v-%v" .Release.Name "mongodb" ) }}
  plainporthost: {{ ( printf "%v-%v:27017" .Release.Name "mongodb" ) }}
type: Opaque
{{- $_ := set .Values.mongodb.url "mongodbPassword" ( $dbPass | quote ) }}
{{- $_ := set .Values.mongodb.url "mongodbRootPassword" ( $rootPass | quote ) }}
{{- $_ := set .Values.mongodb.url "plain" ( ( printf "%v-%v" .Release.Name "mongodb" ) | quote ) }}
{{- $_ := set .Values.mongodb.url "plainhost" ( ( printf "%v-%v" .Release.Name "mongodb" ) | quote ) }}
{{- $_ := set .Values.mongodb.url "plainport" ( ( printf "%v-%v:27017" .Release.Name "mongodb" ) | quote ) }}
{{- $_ := set .Values.mongodb.url "plainporthost" ( ( printf "%v-%v:27017" .Release.Name "mongodb" ) | quote ) }}
{{- $_ := set .Values.mongodb.url "complete" ( ( printf "mongodb://%v:%v@%v-mongodb:27017/%v" .Values.mongodb.mongodbUsername $dbPass .Release.Name .Values.mongodb.mongodbDatabase  ) | quote ) }}
{{- $_ := set .Values.mongodb.url "jdbc" ( ( printf "jdbc:mongodb://%v-mongodb:27017/%v" .Release.Name .Values.mongodb.mongodbDatabase  ) | quote ) }}

{{- end }}
{{- end -}}

{{- define "tc.v1.common.dependencies.mongodb.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.mongodb.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret ( printf "%s-%s" .Release.Name "mongodbcreds" ) $secret -}}
  {{- end -}}
{{- end -}}
