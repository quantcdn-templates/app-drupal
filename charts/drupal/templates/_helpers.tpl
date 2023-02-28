{{/*
Expand the name of the chart.
*/}}
{{- define "quant.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quant.labels" -}}
helm.sh/chart: {{ include "quant.chart" . }}
{{ include "quant.selectorLabels" . }}
{{- if .Values.appVersion }}
app.kubernetes.io/version: {{ .Values.appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quant.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quant.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create an image pull secret
*/}}
{{- define "quant.imagePullSecretValue" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.secrets.registry.registry (printf "%s:%s" .Values.secrets.registry.user .Values.secrets.registry.token | b64enc) | b64enc }}
{{- end }}
