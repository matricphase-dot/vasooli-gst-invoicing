# Deploying Vasooli to Serverpod Cloud

The repo is deployable as-is — Serverpod Cloud builds Dart 3.13 projects from
the server package (`vasooli/vasooli_server`). Postgres is managed by the
platform; **no Docker required locally or remotely**.

## One-time

```console
$ dart pub global activate serverpod_cli        # version matching pubspec: ^4.0.0
$ serverpod cloud auth login                    # opens app.serverpod.dev in the browser
```

> If you registered on the waitlist during the hackathon, make sure cloud
> access is enabled for your account (the event partners Serverpod — credits
> cover the ~$5/mo starter plan).

## Deploy

```console
$ cd vasooli/vasooli_server
$ serverpod cloud launch                        # first time: guided project setup
```

`launch` (verified against CLI help, 2026-09-27):

* detects an existing Serverpod Cloud project near the current directory and
  redeploys, *or* walks you through creating one (region, plan);
* uploads, builds and rolls out the server; `--wet-run` does everything
  except the final rollout — good for a dry validation;
* writes `scloud.yaml` into the server package (project id, deployment
  settings) — **commit this file** once it's created.

## Database & migrations

The managed Postgres is provisioned automatically. Apply the migrations on
first boot either by running the deployed server role with
`--apply-migrations` (Serverpod Cloud's default launch template does this),
or explicitly:

```console
$ serverpod cloud deploy --help | grep -i migration   # see current flag name
```

Then verify:

```console
$ serverpod cloud status           # project + rollout status
$ serverpod cloud log              # tail server logs
```

The demo driver can be pointed at the cloud API instead of localhost to
prove parity:

```console
$ dart run bin/demo.dart --url https://<project>.serverpod.app/
```

## Secrets

No secrets are needed beyond the DB (managed). If/when AI keys arrive
(Gemini/OpenAI), they go in **cloud variables**, not in git:

```console
$ serverpod cloud variable create GEMINI_API_KEY=<key> --secret
```

## Local-vs-cloud config map

| Local (`config/development.yaml`) | Cloud |
| --- | --- |
| embedded Postgres at `database.dataPath` | managed Postgres (host/port/name/user injected) |
| `apiServer.publicHost: localhost` | assigned `<project>.serverpod.app` |
| `--apply-migrations` at boot | migration step in rollout |

The stock `config/production.yaml` in this repo is the Terraform template —
Serverpod Cloud injects its own values; keep the file committed for future
self-hosted/AWS deployment either way.

## Cost note

Starter instance ~ $5/mo (should be covered by hackathon credits). Stop the
project after judging if you don't want it to keep billing:

```console
$ serverpod cloud project pause    # verify exact subcommand with --help
```
