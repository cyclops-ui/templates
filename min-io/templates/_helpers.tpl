{{/*
Generate a checksum for the given configmap
*/}}
{{- define "configmap-checksum" -}}
{{- $sum := sha256sum (include (print $.Template.BasePath "/secret.yaml") .) -}}
{{- $sum -}}
{{- end -}}
