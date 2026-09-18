# Terraform Learning Notes

Kurze Notizen zu den Terraform-Konzepten, die ich im Rahmen dieses Projekts praktisch ausprobiert habe.

## Infrastructure as Code

* Infrastruktur wird deklarativ in Dateien beschrieben.
* Terraform versucht, den beschriebenen Sollzustand herzustellen.
* Ähnlich zu Kubernetes-Manifests, aber Terraform wird häufig für Infrastruktur außerhalb bzw. unterhalb der Anwendungsebene verwendet.
* Kubernetes reconciled den Zustand kontinuierlich; Terraform vergleicht und verändert Infrastruktur, wenn Terraform ausgeführt wird.

## Provider

* Ein Provider verbindet Terraform mit einem externen System bzw. dessen API.
* In diesem Projekt verwende ich den Docker Provider.
* Terraform selbst kennt Docker-Ressourcen nicht; der Provider stellt Ressourcentypen wie `docker_image` und `docker_container` bereit.

Projektbeispiel:

`Terraform -> Docker Provider -> Docker API -> Docker-Ressourcen`

## terraform init

* Initialisiert ein Terraform-Arbeitsverzeichnis.
* Lädt benötigte Provider herunter.
* Erstellt bzw. aktualisiert `.terraform.lock.hcl`.

In diesem Projekt wurde dabei der Docker Provider `kreuzwerker/docker` installiert.

## .terraform.lock.hcl

* Speichert die konkret ausgewählten Provider-Versionen.
* Hilft dabei, Terraform-Ausführungen reproduzierbar zu halten.
* Wird im Gegensatz zum `.terraform/`-Verzeichnis in Git versioniert.

## Resource

Eine Resource beschreibt ein konkretes Objekt, das Terraform verwalten soll.

Bisherige Ressourcen:

* `docker_image.nginx`
* `docker_container.web`

Beispiel:

`docker_image.nginx` sorgt dafür, dass das konfigurierte Docker-Image vorhanden ist.

## Terraform Workflow

Bisher praktisch verwendet:

* `terraform fmt` – formatiert Terraform-Dateien
* `terraform validate` – prüft die Konfiguration
* `terraform plan` – zeigt geplante Änderungen
* `terraform apply` – führt Änderungen aus

Ein `plan` verändert die Infrastruktur noch nicht.

## Terraform State

* Terraform speichert Informationen über die von ihm verwalteten Ressourcen in `terraform.tfstate`.
* State verbindet die Terraform-Konfiguration mit real existierenden Ressourcen.
* Terraform kann dadurch erkennen, welche Ressourcen bereits existieren und welche Änderungen notwendig sind.
* State sollte nicht einfach in ein öffentliches Git-Repository committed werden.

Mentales Modell:

`Configuration -> gewünschter Zustand`

`State -> von Terraform bekannte Ressourcen`

`Real Infrastructure -> tatsächlich existierende Ressourcen`

## Drift

Drift entsteht, wenn eine von Terraform verwaltete Ressource außerhalb von Terraform verändert wird.

Praktisches Experiment:

1. Terraform erstellte `nginx:latest`.
2. Das Image wurde manuell mit `docker rmi nginx:latest` gelöscht.
3. `terraform plan` erkannte, dass die Ressource fehlte.
4. Terraform plante `1 to add`.
5. `terraform apply` stellte den gewünschten Zustand wieder her.

## Variables

Variablen vermeiden unnötig fest eingebaute Werte.

Projektbeispiel:

`image_name` besitzt aktuell den Default-Wert `nginx:latest`.

Die Resource verwendet:

`var.image_name`

Dadurch kann derselbe Terraform-Code später mit einem anderen Image verwendet werden.

## Outputs

Outputs machen Werte einer Terraform-Konfiguration nach außen verfügbar.

Projektbeispiel:

`docker_image_name`

gibt den Namen des von Terraform verwalteten Docker-Images aus.

Outputs werden ebenfalls im Terraform State gespeichert.

## Dependencies

Terraform kann Abhängigkeiten automatisch aus Referenzen erkennen.

Projektbeispiel:

`docker_container.web` verwendet:

`docker_image.nginx.image_id`

Dadurch erkennt Terraform automatisch:

`docker_image.nginx -> docker_container.web`

Das ist eine implizite Dependency.

`depends_on` ist dafür nicht notwendig.

## Resource Replacement

Der externe Port des Containers wurde von `8080` auf `8081` geändert.

Der Terraform Plan zeigte:

`-/+ destroy and then create replacement`

und:

`external = 8080 -> 8081 # forces replacement`

Der Docker Provider kann diese Eigenschaft nicht am bestehenden Container ändern. Terraform musste deshalb den bestehenden Container löschen und mit der neuen Konfiguration neu erstellen.

Wichtige Plan-Symbole:

* `+` Create
* `-` Destroy
* `~` Änderung an bestehender Resource
* `-/+` Resource ersetzen

## Aktueller Stand

Terraform verwaltet aktuell:

* ein Nginx Docker Image
* einen Nginx Container
* Port-Mapping `8081 -> 80`

Der Container ist lokal unter `http://localhost:8081` erreichbar.
